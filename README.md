# Try Waterfall - Quick Start Demo

🚀 **Try Waterfall in under 5 minutes!** This is a ready-to-use demo/trial deployment of the Waterfall authentication and identity management platform.

## 🎯 Quick Start

```bash
# 1. Clone with submodules
git clone --recursive https://github.com/bengeek06/try-waterfall.git
cd try-waterfall

# Or if already cloned, initialize submodules
git submodule update --init --recursive

# 2. Copy environment file
cp .env.example .env

# 3. Start everything (PostgreSQL + Waterfall)
docker compose up -d

# 4. Access the application
open https://localhost:8443
```

That's it! The application is now running with:
- ✅ Web interface on https://localhost:8443
- ✅ API endpoints on https://localhost:8443/api
- ✅ PostgreSQL database
- ✅ All three microservices (Auth, Identity, Guardian)

## 📋 Prerequisites

- Docker Engine 24.0+ or Docker Desktop
- Docker Compose V2
- Git (for cloning with submodules)
- 4GB RAM minimum (8GB recommended)
- Ports 8080, 8443 available (or customize in .env)

## 🔗 About Submodules

This repository uses Git submodules to reference the individual service repositories:
- `web/` → [web-waterfall](https://github.com/bengeek06/web-waterfall)
- `services/auth_service/` → [auth-api-waterfall](https://github.com/bengeek06/auth-api-waterfall)
- `services/identity_service/` → [identity-api-waterfall](https://github.com/bengeek06/identity-api-waterfall)
- `services/guardian_service/` → [guardian-api-waterfall](https://github.com/bengeek06/guardian-api-waterfall)

**Important**: Always clone with `--recursive` flag or run `git submodule update --init --recursive` after cloning.

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Waterfall Container             │
│  ┌────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Nginx  │  │ Next.js  │  │ Python  │ │
│  │ Proxy  │─▶│   Web    │  │Services │ │
│  └────────┘  └──────────┘  └─────────┘ │
└──────────────────┬──────────────────────┘
                   │
       ┌───────────▼──────────────┐
       │  PostgreSQL Container    │
       │  ┌──────────────────┐    │
       │  │ 3 Databases:     │    │
       │  │ • waterfall_auth │    │
       │  │ • waterfall_identity│ │
       │  │ • waterfall_guardian│ │
       │  └──────────────────┘    │
       └──────────────────────────┘
```

## 🎛️ Optional Services (Profiles)

Enable optional features with Docker Compose profiles:

### Redis Cache
```bash
docker compose --profile cache up -d
```

### MinIO Object Storage
```bash
docker compose --profile storage up -d
```

### Everything
```bash
docker compose --profile cache --profile storage up -d
```

## 🔧 Configuration

### Environment Variables

Key settings in `.env`:

```bash
# Security (auto-generated if empty)
JWT_SECRET=                    # Leave empty on first run
INTERNAL_AUTH_TOKEN=          # Leave empty on first run

# Database
POSTGRES_PASSWORD=waterfall_secure_password_change_me  # ⚠️ Change this!

# Ports (customize if needed)
HTTP_PORT=8080
HTTPS_PORT=8443
```

### Changing Ports

Edit `.env`:
```bash
HTTP_PORT=9080
HTTPS_PORT=9443
```

Then restart:
```bash
docker compose down
docker compose up -d
```

## 📊 Service Status

Check if everything is running:

```bash
# View all containers
docker compose ps

# Check healthchecks
docker compose ps --format "table {{.Name}}\t{{.Status}}"

# View logs
docker compose logs -f waterfall
docker compose logs -f postgres

# Check specific service logs
docker compose exec waterfall supervisorctl status
```

## 🔍 API Endpoints

Once running, the following endpoints are available:

### Auth Service
- `POST /api/auth/login` - User authentication
- `POST /api/auth/register` - User registration
- `GET /api/auth/health` - Service health check

### Identity Service
- `GET /api/identity/users` - List users
- `GET /api/identity/users/:id` - Get user details
- `PATCH /api/identity/users/:id` - Update user

### Guardian Service
- `GET /api/guardian/policies` - List access policies
- `POST /api/guardian/policies` - Create policy
- `POST /api/guardian/evaluate` - Evaluate access

### API Documentation
- Interactive docs: https://localhost:8443/docs
- OpenAPI specs: https://localhost:8443/openapi.json

## 🐛 Troubleshooting

### Services won't start

```bash
# Check logs
docker compose logs waterfall

# Check database connection
docker compose exec postgres psql -U waterfall -d waterfall_auth -c "\dt"

# Restart everything
docker compose restart
```

### SSL Certificate Warnings

The demo uses self-signed certificates. In your browser:
- Click "Advanced" → "Proceed to localhost (unsafe)"
- Or add exception for localhost

For production, use proper SSL certificates!

### Port Already in Use

```bash
# Find what's using the port
lsof -i :8443

# Or change ports in .env
HTTP_PORT=9080
HTTPS_PORT=9443
```

### Database Connection Issues

```bash
# Check if PostgreSQL is ready
docker compose exec postgres pg_isready

# View PostgreSQL logs
docker compose logs postgres

# Reset database (⚠️ deletes all data!)
docker compose down -v
docker compose up -d
```

## 🔄 Updating Submodules

To get the latest versions of all services:

```bash
# Update all submodules to their latest commits
git submodule update --remote --merge

# Check what changed
git status

# Commit the submodule updates
git add .
git commit -m "Update submodules to latest versions"
git push
```

This will trigger a new Docker image build via GitHub Actions.

## 🧹 Cleanup

```bash
# Stop containers (keeps data)
docker compose down

# Stop and remove everything including volumes (⚠️ deletes data!)
docker compose down -v

# Remove images too
docker compose down -v --rmi all
```

## 📚 What's Next?

This is a **trial/demo deployment** for evaluation. For production use:

1. **Review the main repository**: https://github.com/YourOrg/waterfall
2. **Read deployment guides**: See `/docs` in main repo
3. **Set up proper infrastructure**: Kubernetes, managed databases, etc.
4. **Configure production security**: Real SSL, secrets management, etc.
5. **Enable monitoring**: Prometheus, Grafana, etc.

## 🔒 Security Notice

⚠️ **This trial setup is NOT production-ready!**

- Uses self-signed SSL certificates
- Default passwords in `.env.example`
- No rate limiting or DDoS protection
- Simplified configuration for ease of use
- No backup or disaster recovery

**For production**: See the main repository's deployment documentation.

## 📄 License

See [LICENSE](LICENSE) for details.

## 🆘 Support

- 📖 Documentation: https://docs.waterfall.dev
- 💬 Issues: https://github.com/YourOrg/waterfall/issues
- 🌐 Website: https://waterfall.dev

## 🤝 Contributing

This is a trial distribution repository. For contributions, see the main development repository.

---

**Enjoy your Waterfall trial!** 🌊
