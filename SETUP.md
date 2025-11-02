# Setup Guide for Try Waterfall

## 🚀 First-Time Setup

### Step 1: Initialize Submodules

Run the initialization script to add all service submodules:

```bash
./init-submodules.sh
```

This will:
- Create `services/` and `web/` directories
- Add 4 Git submodules (web, auth, identity, guardian)
- Create `.gitmodules` file

### Step 2: Verify Submodules

Check that all submodules were added:

```bash
git submodule status
```

You should see:
```
-<hash> services/auth_service
-<hash> services/guardian_service
-<hash> services/identity_service
-<hash> web
```

### Step 3: Commit Submodules

```bash
git add .
git commit -m "Add service submodules"
git push origin main
```

### Step 4: Test the Build

```bash
# Copy environment file
cp .env.example .env

# Build the image
docker compose build

# Start services
docker compose up -d

# Check logs
docker compose logs -f waterfall

# Test
curl http://localhost:8080/health
```

## �� For Users Cloning the Repository

Users should clone with submodules:

```bash
git clone --recursive https://github.com/bengeek06/try-waterfall.git
```

Or if already cloned:

```bash
cd try-waterfall
git submodule update --init --recursive
```

## 📦 Updating Submodules

When a service is updated in its repository:

```bash
# Update specific submodule
git submodule update --remote services/auth_service

# Or update all
git submodule update --remote --merge

# Commit the changes
git add .
git commit -m "Update auth service to latest version"
git push
```

This will trigger GitHub Actions to build a new Docker image.

## 🏗️ Architecture

```
try-waterfall/
├── services/                    # Submodules
│   ├── auth_service/           → auth-api-waterfall
│   ├── identity_service/       → identity-api-waterfall
│   └── guardian_service/       → guardian-api-waterfall
├── web/                        → web-waterfall
├── config/                     # Configuration files
├── Dockerfile                  # Multi-stage build
└── docker-compose.yml          # Orchestration
```

## 🔍 Troubleshooting

### Submodule is empty after clone

```bash
git submodule update --init --recursive
```

### Wrong submodule version

```bash
# Check current commit
cd services/auth_service
git log -1

# Update to specific commit
git checkout <commit-hash>
cd ../..
git add services/auth_service
git commit -m "Pin auth service to specific version"
```

### Remove and re-add submodule

```bash
git submodule deinit -f services/auth_service
git rm -f services/auth_service
rm -rf .git/modules/services/auth_service
git submodule add https://github.com/bengeek06/auth-api-waterfall.git services/auth_service
```

## 📚 References

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Main Repository](https://github.com/bengeek06/waterfall)
- [Contributing Guide](CONTRIBUTING.md)
