# Try Waterfall - Structure Overview

## 📂 Directory Structure

```
try-waterfall/
├── .dockerignore           # Docker build exclusions
├── .env.example            # Configuration template
├── .gitignore             # Git exclusions
├── CONTRIBUTING.md        # Contribution guidelines
├── Dockerfile             # Multi-stage build (no PostgreSQL)
├── LICENSE                # License file
├── README.md              # Main documentation
├── docker-compose.yml     # Orchestration with profiles
├── validate.sh            # Setup validation script
│
├── .github/workflows/     # CI/CD automation
│   ├── build-and-test.yml    # Build & test on push/PR
│   └── publish-image.yml     # Publish on release
│
├── config/                # Runtime configuration
│   ├── entrypoint.sh         # Container startup script
│   ├── init-db.sh            # PostgreSQL database initialization
│   ├── nginx.conf            # Nginx main config
│   ├── supervisord.conf      # Process manager config
│   └── waterfall.conf        # Nginx site config
│
└── profiles/              # Profile documentation
    └── README.md             # Profile usage guide
```

## 🎯 Key Features

### Architecture
- **Lightweight core**: Only application code + PostgreSQL client
- **External PostgreSQL**: Separate container for flexibility
- **Optional services**: Redis & MinIO via profiles
- **Single entry point**: HTTPS with reverse proxy

### Multi-Stage Build
1. **web-builder**: Build Next.js frontend
2. **python-base**: Install Python dependencies
3. **auth-builder**: Build auth service
4. **identity-builder**: Build identity service
5. **guardian-builder**: Build guardian service
6. **runtime**: Combine everything (Debian Trixie, Python 3.13)

### Process Management
Supervisor manages 5 processes:
- `auth-service` (port 5001)
- `identity-service` (port 5002)
- `guardian-service` (port 5003)
- `web-service` (port 3000)
- `nginx` (ports 80, 443)

### Docker Compose Profiles
- **Default** (no profile): PostgreSQL + Waterfall
- **cache**: +Redis for performance
- **storage**: +MinIO for object storage
- **Future**: monitoring, communication, backup

## 🚀 Quick Commands

```bash
# Validate setup
./validate.sh

# Start core services
docker compose up -d

# Start with Redis
docker compose --profile cache up -d

# Start with MinIO
docker compose --profile storage up -d

# Start everything
docker compose --profile cache --profile storage up -d

# View logs
docker compose logs -f waterfall

# Check status
docker compose ps

# Stop (keep data)
docker compose down

# Stop and remove data
docker compose down -v
```

## 🔐 Security Configuration

Generated on first run (stored in `/app/secrets`):
- `JWT_SECRET` - Token signing key
- `INTERNAL_AUTH_TOKEN` - Service-to-service auth
- `server.crt` / `server.key` - Self-signed SSL

User must configure in `.env`:
- `POSTGRES_PASSWORD` - Database password
- Optional: `REDIS_PASSWORD`, `MINIO_ROOT_PASSWORD`

## 🌐 Exposed Ports

| Service | Internal | External | Purpose |
|---------|----------|----------|---------|
| Nginx HTTP | 80 | 8080 | HTTP (redirects to HTTPS) |
| Nginx HTTPS | 443 | 8443 | HTTPS with SSL |
| PostgreSQL | 5432 | - | Database (internal only) |
| Redis | 6379 | - | Cache (profile: cache) |
| MinIO | 9000 | 9000 | S3 API (profile: storage) |
| MinIO Console | 9001 | 9001 | Web UI (profile: storage) |

## 📊 Resource Usage

| Component | CPU | Memory | Disk |
|-----------|-----|--------|------|
| PostgreSQL | ~5% | ~100MB | ~500MB |
| Waterfall | ~15% | ~1.5GB | ~2GB (image) |
| Redis (opt) | ~2% | ~50MB | ~100MB |
| MinIO (opt) | ~5% | ~200MB | Variable |
| **Total** | ~27% | ~2GB | ~3GB |

*Based on idle/light usage on 4-core, 8GB system*

## 🔄 Lifecycle

### First Run
1. Docker builds image from parent directories
2. Container starts, runs `entrypoint.sh`
3. Generates secrets (JWT, SSL)
4. Waits for PostgreSQL
5. Runs database migrations
6. Configures services (Gunicorn, Next.js)
7. Starts Supervisor → all services
8. Nginx proxy routes traffic
9. Application ready!

### Restart
1. Reads secrets from `/app/secrets` volume
2. Validates PostgreSQL connection
3. Runs pending migrations (if any)
4. Starts all services
5. Ready!

### Upgrade
1. Pull new image: `docker compose pull`
2. Recreate container: `docker compose up -d`
3. Entrypoint runs new migrations automatically
4. Zero-downtime (with proper orchestration)

## 🎨 Customization Points

### Environment Variables
All configurable in `.env`:
- Database credentials
- Ports
- Service URLs
- Optional service settings

### Volumes
- `postgres_data` - PostgreSQL data (persistent)
- `waterfall_secrets` - Application secrets (persistent)
- `redis_data` - Redis persistence (optional)
- `minio_data` - Object storage (optional)

### Build Arguments
Can be customized in `Dockerfile`:
- Python version
- Node.js version
- Debian base
- Package versions

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Quick start guide |
| `CONTRIBUTING.md` | How to contribute |
| `profiles/README.md` | Profile documentation |
| `.env.example` | Configuration template |
| This file | Technical overview |

## 🔧 CI/CD Workflows

### build-and-test.yml
- Triggers: Push to main/develop, PRs
- Actions:
  1. Checkout code
  2. Build Docker image
  3. Start with docker-compose
  4. Wait for healthy
  5. Test endpoints
  6. Cleanup

### publish-image.yml
- Triggers: Releases, version tags
- Actions:
  1. Build multi-arch (amd64, arm64)
  2. Push to GitHub Container Registry
  3. Push to Docker Hub (on release)
  4. Generate attestation
  5. Update Docker Hub description
  6. Test published image

## 🎯 Design Principles

1. **Simplicity First**: `docker compose up` just works
2. **Flexibility**: Add features via profiles
3. **Production-Ready**: But clearly marked as trial
4. **Well-Documented**: For non-technical users
5. **Maintainable**: Clear structure, validated setup
6. **Secure Defaults**: Auto-generate secrets, HTTPS by default
7. **Observable**: Logs, healthchecks, status endpoints

## 📦 Distribution Strategy

### This Repository (try-waterfall)
- Trial/demo distribution
- Focus on ease of use
- Pre-configured defaults
- Single-container simplicity

### Main Repository (waterfall)
- Development repository
- Separate services
- Kubernetes manifests
- Production configuration

## 🚧 Future Enhancements

Planned profiles:
- **monitoring**: Prometheus + Grafana
- **communication**: Jitsi Meet integration
- **backup**: Automated backup service
- **logs**: Centralized logging (ELK/Loki)

Planned features:
- One-click cloud deployment (DigitalOcean, AWS, GCP)
- ARM64 builds for Raspberry Pi
- Helm chart for Kubernetes
- Ansible playbook for bare metal

## ✅ Validation

Run `./validate.sh` to check:
- All required files present
- Configuration files valid
- Docker Compose syntax correct
- Environment variables defined
- Documentation complete
- Parent directories accessible
- Executables have correct permissions

Exit codes:
- `0` - All checks passed
- `0` - Passed with warnings (can proceed)
- `1` - Failed (must fix errors)

---

**Last Updated**: 2025-01-XX  
**Version**: 1.0.0-beta  
**Status**: Ready for testing
