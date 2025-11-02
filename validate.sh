#!/bin/bash
# ==============================================================================
# Try Waterfall Validation Script
# ==============================================================================
# This script validates the try-waterfall setup before building/testing

set -e

echo "🔍 Validating Try Waterfall Setup..."
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

check_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ==============================================================================
# Check Required Files
# ==============================================================================
echo "📁 Checking required files..."

required_files=(
    "Dockerfile"
    "docker-compose.yml"
    ".env.example"
    "README.md"
    ".gitignore"
    ".dockerignore"
    "config/entrypoint.sh"
    "config/init-db.sh"
    "config/supervisord.conf"
    "config/nginx.conf"
    "config/waterfall.conf"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        check_pass "$file exists"
    else
        check_fail "$file is missing!"
    fi
done

echo ""

# ==============================================================================
# Check Configuration Files
# ==============================================================================
echo "⚙️  Checking configuration files..."

# Check entrypoint is executable
if [ -x "config/entrypoint.sh" ]; then
    check_pass "entrypoint.sh is executable"
else
    check_fail "entrypoint.sh is not executable!"
fi

if [ -x "config/init-db.sh" ]; then
    check_pass "init-db.sh is executable"
else
    check_fail "init-db.sh is not executable!"
fi

# Check for parent directory references in Dockerfile
if grep -q "\.\./services" Dockerfile && grep -q "\.\./web" Dockerfile; then
    check_pass "Dockerfile references parent directories correctly"
else
    check_warn "Dockerfile may not reference parent directories correctly"
fi

echo ""

# ==============================================================================
# Check Docker Compose
# ==============================================================================
echo "🐳 Checking Docker Compose configuration..."

if command -v docker compose &> /dev/null; then
    if docker compose config > /dev/null 2>&1; then
        check_pass "docker-compose.yml syntax is valid"
    else
        check_fail "docker-compose.yml has syntax errors!"
        docker compose config
    fi
else
    check_warn "Docker Compose not found (can't validate syntax)"
fi

# Check for required services
if grep -q "postgres:" docker-compose.yml && \
   grep -q "waterfall:" docker-compose.yml; then
    check_pass "Required services defined (postgres, waterfall)"
else
    check_fail "Missing required services in docker-compose.yml"
fi

# Check for profiles
if grep -q "profiles:" docker-compose.yml; then
    check_pass "Optional profiles configured"
else
    check_warn "No optional profiles found"
fi

echo ""

# ==============================================================================
# Check Environment Example
# ==============================================================================
echo "🔐 Checking environment configuration..."

required_env_vars=(
    "POSTGRES_USER"
    "POSTGRES_PASSWORD"
    "DATABASE_URL_AUTH"
    "DATABASE_URL_IDENTITY"
    "DATABASE_URL_GUARDIAN"
    "HTTP_PORT"
    "HTTPS_PORT"
)

for var in "${required_env_vars[@]}"; do
    if grep -q "^$var=" .env.example || grep -q "^#.*$var=" .env.example; then
        check_pass "$var defined in .env.example"
    else
        check_fail "$var missing from .env.example!"
    fi
done

echo ""

# ==============================================================================
# Check Documentation
# ==============================================================================
echo "📚 Checking documentation..."

readme_sections=(
    "Quick Start"
    "Prerequisites"
    "Architecture"
    "Troubleshooting"
)

for section in "${readme_sections[@]}"; do
    if grep -qi "$section" README.md; then
        check_pass "README has '$section' section"
    else
        check_warn "README missing '$section' section"
    fi
done

echo ""

# ==============================================================================
# Check GitHub Actions
# ==============================================================================
echo "🚀 Checking GitHub Actions..."

if [ -f ".github/workflows/build-and-test.yml" ]; then
    check_pass "Build and test workflow exists"
else
    check_warn "No build-and-test workflow found"
fi

if [ -f ".github/workflows/publish-image.yml" ]; then
    check_pass "Publish image workflow exists"
else
    check_warn "No publish-image workflow found"
fi

echo ""

# ==============================================================================
# Check Submodules Structure
# ==============================================================================
echo "📂 Checking submodules structure..."

if [ -d "services/auth_service" ] && \
   [ -d "services/identity_service" ] && \
   [ -d "services/guardian_service" ]; then
    check_pass "Services submodules exist"
else
    check_fail "Services submodules not found (run ./init-submodules.sh)"
fi

if [ -d "web" ]; then
    check_pass "Web submodule exists"
else
    check_fail "Web submodule not found (run ./init-submodules.sh)"
fi

# Check .gitmodules file
if [ -f ".gitmodules" ]; then
    check_pass ".gitmodules file exists"
else
    check_warn ".gitmodules not found (submodules not initialized)"
fi

echo ""

# ==============================================================================
# Summary
# ==============================================================================
echo "════════════════════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC} Ready to build."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Passed with $WARNINGS warning(s)${NC}"
    echo "  You can proceed, but consider fixing warnings."
    exit 0
else
    echo -e "${RED}✗ Failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo "  Please fix the errors before building."
    exit 1
fi
