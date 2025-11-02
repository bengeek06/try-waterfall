# Docker Compose Profiles

This directory contains documentation for optional Docker Compose profiles.

## Available Profiles

### 🚀 Core Services (No Profile Needed)

The default `docker compose up` includes:
- **PostgreSQL**: Database for all services
- **Waterfall**: Main application (web + API services)

### 📦 Optional Profiles

#### `cache` - Redis Caching

Enables Redis for improved performance.

```bash
docker compose --profile cache up -d
```

**Use case**: High-traffic scenarios, reducing database load.

**Environment variables** (in `.env`):
```bash
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password
REDIS_DB=0
```

#### `storage` - MinIO Object Storage

Enables MinIO for file uploads and object storage.

```bash
docker compose --profile storage up -d
```

**Use case**: User file uploads, avatars, documents.

**Access**: MinIO Console at http://localhost:9001

**Environment variables** (in `.env`):
```bash
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin_secure_password
MINIO_HOST=minio
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001
```

### 🎯 Combining Profiles

Enable multiple profiles:

```bash
# Everything
docker compose --profile cache --profile storage up -d

# Or using COMPOSE_PROFILES
export COMPOSE_PROFILES=cache,storage
docker compose up -d
```

## Future Profiles (Planned)

### `monitoring` - Prometheus + Grafana
- Application metrics
- Performance monitoring
- Custom dashboards

### `communication` - Jitsi Meet
- Video conferencing
- Real-time collaboration

### `backup` - Automated Backups
- Database backups
- Configuration backups
- S3-compatible storage

## Profile Architecture

```
Core (Always On)
├── PostgreSQL (database)
└── Waterfall (web + APIs)

Optional Profiles
├── cache
│   └── Redis
├── storage
│   └── MinIO
├── monitoring (future)
│   ├── Prometheus
│   └── Grafana
├── communication (future)
│   └── Jitsi
└── backup (future)
    └── Backup service
```

## Best Practices

1. **Start simple**: Use core services first
2. **Add as needed**: Enable profiles when you need features
3. **Monitor resources**: Each profile adds CPU/memory usage
4. **Secure secrets**: Change default passwords in `.env`

## Resource Requirements

| Profile | Memory | Disk | Notes |
|---------|--------|------|-------|
| Core | 2GB | 5GB | Minimum for trial |
| + cache | +256MB | +100MB | Redis overhead |
| + storage | +512MB | +1GB | MinIO + storage |
| All | ~4GB | ~10GB | Comfortable setup |

## Troubleshooting

### Profile not starting

```bash
# Check if profile is enabled
docker compose --profile cache config

# View logs
docker compose logs redis
```

### Profile service unhealthy

```bash
# Check status
docker compose ps

# Restart specific service
docker compose restart redis
```

### Remove profile service

```bash
# Stop and remove
docker compose --profile cache down

# Or remove volumes too
docker compose --profile cache down -v
```

## Contributing

Want to add a new profile? See [CONTRIBUTING.md](../CONTRIBUTING.md)
