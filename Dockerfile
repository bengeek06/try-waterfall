# ==============================================================================
# Dockerfile Try Waterfall - Standalone Image
# ==============================================================================
# Image standalone contenant tous les services Waterfall (sans PostgreSQL)
# PostgreSQL est fourni via docker-compose pour plus de flexibilité

# Stage 1: Build web frontend (Next.js)
FROM node:24.9.0-slim AS web-builder

WORKDIR /app/web
COPY web/package*.json ./
RUN npm ci --only=production
COPY web/ ./
RUN npm run build

# =============================================================================
# Stage 2: Final runtime image with all services
# =============================================================================
FROM debian:trixie-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NODE_ENV=production \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /app

# Install all runtime dependencies (NO PostgreSQL server)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # PostgreSQL client only
    postgresql-client-17 \
    # Python 3.13
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    libpq5 \
    libpq-dev \
    # Build dependencies for Python packages
    build-essential \
    gcc \
    # Node.js
    curl \
    ca-certificates \
    gnupg \
    # Nginx
    nginx \
    # Supervisor pour gérer les processus
    supervisor \
    # SSL
    openssl \
    # Utils
    pwgen \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create Python symlink (Python 3.13 is already python3 in Debian Trixie)
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Copy requirements files and install in runtime environment
COPY services/auth_service/requirements.txt /tmp/auth-requirements.txt
COPY services/guardian_service/requirements.txt /tmp/guardian-requirements.txt
COPY services/identity_service/requirements.txt /tmp/identity-requirements.txt

# Install Python dependencies (using --break-system-packages for Docker container)
RUN pip install --no-cache-dir --break-system-packages \
    -r /tmp/auth-requirements.txt \
    -r /tmp/guardian-requirements.txt \
    -r /tmp/identity-requirements.txt \
    && rm -f /tmp/*-requirements.txt

# Copy application code
COPY services/auth_service /app/auth_service
COPY services/guardian_service /app/guardian_service
COPY services/identity_service /app/identity_service
COPY --from=web-builder /app/web/.next /app/web/.next
COPY --from=web-builder /app/web/public /app/web/public
COPY --from=web-builder /app/web/package*.json /app/web/
COPY --from=web-builder /app/web/node_modules /app/web/node_modules
COPY web/next.config.ts /app/web/
COPY web/tsconfig.json /app/web/
COPY web/app /app/web/app
COPY web/components /app/web/components
COPY web/lib /app/web/lib
COPY web/dictionaries /app/web/dictionaries

# Copy configuration files
COPY config/supervisord.conf /etc/supervisor/conf.d/waterfall.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/waterfall.conf /etc/nginx/sites-available/waterfall
RUN ln -sf /etc/nginx/sites-available/waterfall /etc/nginx/sites-enabled/waterfall \
    && rm -f /etc/nginx/sites-enabled/default

# Create necessary directories with proper permissions
RUN mkdir -p \
    /app/logs \
    /app/secrets \
    /var/run/supervisor \
    /var/log/supervisor \
    && chmod 777 /app/logs \
    && chmod 755 /app/secrets

# Copy entrypoint script
COPY config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 80 443 3000 5001 5002 5003

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Volumes for persistence
VOLUME ["/app/logs", "/app/secrets"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
