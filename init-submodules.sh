#!/bin/bash
# ==============================================================================
# Initialize Git Submodules for Try Waterfall
# ==============================================================================

set -e

echo "🔧 Initializing Try Waterfall submodules..."

# Add web submodule
echo "📦 Adding web-waterfall..."
git submodule add https://github.com/bengeek06/web-waterfall.git web

# Add auth service submodule
echo "📦 Adding auth-api-waterfall..."
git submodule add https://github.com/bengeek06/auth-api-waterfall.git services/auth_service

# Add identity service submodule
echo "📦 Adding identity-api-waterfall..."
git submodule add https://github.com/bengeek06/identity-api-waterfall.git services/identity_service

# Add guardian service submodule
echo "📦 Adding guardian-api-waterfall..."
git submodule add https://github.com/bengeek06/guardian-api-waterfall.git services/guardian_service

echo ""
echo "✅ All submodules added!"
echo ""
echo "📝 Next steps:"
echo "  1. Review .gitmodules file"
echo "  2. Commit: git add . && git commit -m 'Add service submodules'"
echo "  3. Push: git push origin main"
echo ""
echo "🔄 To update submodules later:"
echo "  git submodule update --remote --merge"
