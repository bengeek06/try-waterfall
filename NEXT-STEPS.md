# ✅ Next Steps Checklist

## 📝 Phase 1: Initialize Submodules

```bash
cd /home/benjamin/projects/try-waterfall

# Run the initialization script
./init-submodules.sh

# Verify submodules were added
git submodule status
ls -la services/
ls -la web/
```

**Expected output:**
- `.gitmodules` file created
- 4 submodule directories populated
- Git shows submodule references

## 🔍 Phase 2: Validate Setup

```bash
# Run validation script
./validate.sh

# Check Dockerfile context
grep -A 2 "COPY" Dockerfile

# Check docker-compose context
grep -A 3 "build:" docker-compose.yml
```

**Expected:**
- All validation checks pass
- Dockerfile copies from `web/` and `services/`
- docker-compose context is `.` (not `..`)

## 🏗️ Phase 3: Test Build

```bash
# Copy environment file
cp .env.example .env

# Edit if needed (optional for testing)
# nano .env

# Build the image
docker compose build

# Check image size
docker images | grep try-waterfall
```

**Expected:**
- Build succeeds without errors
- Image created (~2GB)
- All stages complete

## 🚀 Phase 4: Test Deployment

```bash
# Start services
docker compose up -d

# Wait for healthy status
sleep 30
docker compose ps

# Check logs
docker compose logs waterfall | tail -50

# Test endpoints
curl http://localhost:8080/health
curl -k https://localhost:8443/health
```

**Expected:**
- All services healthy
- PostgreSQL running
- HTTP/HTTPS endpoints responding

## 📦 Phase 5: Commit and Push

```bash
# Check status
git status

# Add all files
git add .

# Commit
git commit -m "Initial try-waterfall setup with submodules"

# Push
git push origin main
```

**Expected:**
- `.gitmodules` committed
- Submodule references committed
- GitHub Actions triggered

## 🔄 Phase 6: Monitor GitHub Actions

1. Go to: https://github.com/bengeek06/try-waterfall/actions
2. Check "Build and Test" workflow
3. Verify all steps pass:
   - ✅ Checkout with submodules
   - ✅ Docker build
   - ✅ Services start
   - ✅ Health checks pass

## 🧪 Phase 7: Test from Fresh Clone

```bash
# In a different directory
cd /tmp

# Clone with submodules
git clone --recursive https://github.com/bengeek06/try-waterfall.git test-clone
cd test-clone

# Verify submodules populated
ls -la services/auth_service
ls -la web

# Test build
cp .env.example .env
docker compose build
docker compose up -d
```

**Expected:**
- Submodules auto-populated
- Build works from fresh clone
- Services start correctly

## 🎯 Phase 8: Create First Release

```bash
# Tag a release
git tag -a v0.1.0-beta -m "First beta release of try-waterfall"
git push origin v0.1.0-beta
```

**Expected:**
- GitHub Actions publishes Docker image
- Image available on GHCR: `ghcr.io/bengeek06/try-waterfall:v0.1.0-beta`
- Release created on GitHub

## 🧹 Phase 9: Clean Up Waterfall Repo

Back in the main waterfall repository:

```bash
cd /home/benjamin/projects/waterfall

# Remove obsolete allinone files
git rm -r docker/allinone/
git rm compose/docker-compose.allinone.yml

# Update main README
# Add link to try-waterfall repo

git commit -m "Remove allinone setup (moved to try-waterfall repo)"
git push
```

## 📚 Phase 10: Documentation

Update READMEs in both repos:

**waterfall repo:**
- Add link to try-waterfall for quick demo
- Mention try-waterfall in main README

**try-waterfall repo:**
- Update GitHub description: "Try Waterfall in 5 minutes - Demo deployment"
- Set topics: docker, trial, demo, authentication, identity-management

## 🎉 Success Criteria

- ✅ Submodules initialized and working
- ✅ Docker build succeeds
- ✅ Services start and pass health checks
- ✅ GitHub Actions workflow passes
- ✅ Fresh clone works for users
- ✅ First release published
- ✅ Main repo cleaned up
- ✅ Documentation updated

## 🐛 Known Issues to Test

1. Submodule permissions (public vs private repos)
2. GitHub Actions secrets (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN)
3. SSL certificate generation on first run
4. Database migrations on first start
5. Port conflicts (8080/8443)

---

**Current Status:** Ready to run Phase 1 (Initialize Submodules)

**Run:** `cd /home/benjamin/projects/try-waterfall && ./init-submodules.sh`
