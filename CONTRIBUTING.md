# Contributing to Try Waterfall

Thank you for your interest in Try Waterfall! 🎉

## About This Repository

This repository contains the **trial/demo distribution** of Waterfall. It's designed to help users quickly evaluate the platform in under 5 minutes.

## Where to Contribute

### 🐛 Found a Bug in Try Waterfall?

If you found an issue with the trial deployment (Docker setup, documentation, etc.):

1. **Check existing issues**: https://github.com/YourOrg/try-waterfall/issues
2. **Create a new issue** with:
   - Clear description of the problem
   - Steps to reproduce
   - Your environment (OS, Docker version)
   - Logs if applicable

### 💡 Feature Requests

For feature requests about the **Waterfall platform itself**, please submit them to the main repository:
- Main repo: https://github.com/YourOrg/waterfall

For suggestions about the **trial experience** (documentation, ease of use, etc.), open an issue here.

### 🔧 Code Contributions

#### For Try Waterfall Distribution

We welcome improvements to:
- Documentation clarity
- Docker configuration
- Healthcheck scripts
- GitHub Actions workflows
- User experience

**Process**:
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/improve-docs`)
3. Make your changes
4. Test with `docker compose up`
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

#### For Waterfall Core Platform

Changes to the actual application code (auth service, identity service, etc.) should be submitted to:
- Main development repo: https://github.com/YourOrg/waterfall

## Development Setup

```bash
# Clone the repo
git clone https://github.com/YourOrg/try-waterfall.git
cd try-waterfall

# Make your changes

# Test locally
cp .env.example .env
docker compose build
docker compose up -d

# Check everything works
curl http://localhost:8080/health
docker compose logs -f

# Cleanup
docker compose down -v
```

## Coding Guidelines

### Docker Configuration
- Keep images lean (multi-stage builds)
- Use specific version tags, not `latest`
- Document all environment variables
- Include healthchecks

### Documentation
- Write for beginners
- Include examples
- Test all commands
- Keep README concise

### GitHub Actions
- Test before merge
- Use caching when possible
- Handle failures gracefully

## Pull Request Process

1. **Update documentation** if you changed behavior
2. **Test thoroughly** - it should work on first try
3. **Keep changes focused** - one feature/fix per PR
4. **Write clear commit messages**
5. **Respond to feedback** promptly

## Questions?

- 💬 Open a discussion: https://github.com/YourOrg/try-waterfall/discussions
- 📧 Email: support@waterfall.dev
- 📖 Docs: https://docs.waterfall.dev

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to make Waterfall better!

## License

By contributing, you agree that your contributions will be licensed under the same license as this project.

---

**Thank you for helping make Waterfall accessible to everyone!** 🌊
