#!/bin/bash
# ==============================================================================
# Entrypoint Script pour Try Waterfall
# ==============================================================================

set -e

echo "🚀 Starting Waterfall Application..."

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ==============================================================================
# Génération des secrets
# ==============================================================================
generate_secret() {
    local var_name=$1
    local current_value=${!var_name}
    
    if [ -z "$current_value" ]; then
        local secret=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        export $var_name="$secret"
        echo "$secret" > "/app/secrets/$var_name"
        log_info "Generated $var_name: ${secret:0:8}..."
    else
        echo "$current_value" > "/app/secrets/$var_name"
        log_info "Using provided $var_name"
    fi
}

log_info "Generating/checking secrets..."
generate_secret JWT_SECRET
generate_secret INTERNAL_AUTH_TOKEN

# Lecture des secrets
export JWT_SECRET=$(cat /app/secrets/JWT_SECRET)
export INTERNAL_AUTH_TOKEN=$(cat /app/secrets/INTERNAL_AUTH_TOKEN)

log_success "Secrets configured"

# ==============================================================================
# Configuration des variables d'environnement
# ==============================================================================
export FLASK_ENV=${FLASK_ENV:-production}
export LOG_LEVEL=${LOG_LEVEL:-info}
export APP_MODE=production
export IN_DOCKER_CONTAINER=true

log_success "Environment configured"

# ==============================================================================
# Configuration SSL
# ==============================================================================
if [ ! -f "/app/secrets/server.crt" ]; then
    log_info "Generating SSL certificates..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /app/secrets/server.key \
        -out /app/secrets/server.crt \
        -subj "/C=US/ST=State/L=City/O=Waterfall/CN=localhost"
    chmod 600 /app/secrets/server.key
    log_success "SSL certificates generated"
fi

# ==============================================================================
# Attendre PostgreSQL
# ==============================================================================
log_info "Waiting for PostgreSQL..."

DB_HOST=$(echo $DATABASE_URL_AUTH | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DATABASE_URL_AUTH | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')

for i in {1..30}; do
    if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U waterfall > /dev/null 2>&1; then
        log_success "PostgreSQL is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        log_error "PostgreSQL not available after 30 attempts"
        exit 1
    fi
    sleep 2
done

# ==============================================================================
# Migrations des bases de données
# ==============================================================================
run_migrations() {
    local service=$1
    local service_dir="${service}_service"
    local db_url_var="DATABASE_URL_$(echo $service | tr '[:lower:]' '[:upper:]')"
    local db_url=${!db_url_var}
    
    log_info "Running migrations for $service..."
    cd "/app/$service_dir"
    
    export DATABASE_URL="$db_url"
    export FLASK_APP=app
    
    # Attendre que la base soit accessible
    for i in {1..10}; do
        if python3 -c "import psycopg2; psycopg2.connect('$db_url')" > /dev/null 2>&1; then
            break
        fi
        sleep 2
    done
    
    # Exécuter les migrations
    python3 -c "
from app import create_app
from flask_migrate import upgrade

app = create_app('app.config.ProductionConfig')
with app.app_context():
    try:
        upgrade()
        print('Migrations completed successfully')
    except Exception as e:
        print(f'Migration error: {e}')
"
}

run_migrations "auth"
run_migrations "identity"
run_migrations "guardian"

log_success "All migrations completed"

# ==============================================================================
# Génération des configurations de services
# ==============================================================================
log_info "Generating service configurations..."

# Configuration Gunicorn pour chaque service
for service in auth identity guardian; do
    service_dir="${service}_service"
    port=""
    if [[ $service == "auth" ]]; then
        port="5001"
    elif [[ $service == "identity" ]]; then
        port="5002"
    else
        port="5003"
    fi
    
    cat > "/app/$service_dir/gunicorn.conf.py" << 'GUNICORN_EOF'
bind = "127.0.0.1:PORT_PLACEHOLDER"
workers = 2
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2
max_requests = 1000
max_requests_jitter = 100
preload_app = True
pythonpath = "/app/SERVICE_DIR_PLACEHOLDER"
chdir = "/app/SERVICE_DIR_PLACEHOLDER"
GUNICORN_EOF
    
    sed -i "s/PORT_PLACEHOLDER/$port/g" "/app/$service_dir/gunicorn.conf.py"
    sed -i "s/SERVICE_DIR_PLACEHOLDER/$service_dir/g" "/app/$service_dir/gunicorn.conf.py"
done

# Configuration Next.js
cat > "/app/web/server.js" << 'NEXTJS_EOF'
const { createServer } = require('http')
const { parse } = require('url')
const next = require('next')

const dev = false
const hostname = '127.0.0.1'
const port = 3000

const app = next({ dev, hostname, port, dir: '/app/web' })
const handle = app.getRequestHandler()

app.prepare().then(() => {
  createServer(async (req, res) => {
    try {
      const parsedUrl = parse(req.url, true)
      await handle(req, res, parsedUrl)
    } catch (err) {
      console.error('Error occurred handling', req.url, err)
      res.statusCode = 500
      res.end('internal server error')
    }
  }).listen(port, hostname, (err) => {
    if (err) throw err
    console.log(`> Ready on http://${hostname}:${port}`)
  })
})
NEXTJS_EOF

log_success "Service configurations generated"

# ==============================================================================
# Démarrage avec Supervisor
# ==============================================================================
log_info "Starting Supervisor to manage all services..."
exec "$@"
