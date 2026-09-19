# orlop Documentation

Technical documentation for the orlop CLI toolkit project.

## Publishing & Distribution

### npm Publishing (Start Here!)

**Quick Setup:**
- 📋 [**Setup Checklist**](./NPM_TRUSTED_PUBLISHER_SETUP.md) - Step-by-step guide to configure trusted publishers
- 📚 [**Complete Publishing Guide**](./NPM_PUBLISHING_GUIDE.md) - Comprehensive reference for both OIDC and token methods
- 🔄 [**Tokens vs. OIDC Comparison**](./NPM_TOKEN_VS_OIDC.md) - Visual comparison and migration guide

**Recommended approach:** Use **Trusted Publishers with OIDC** for secure, zero-maintenance publishing from GitHub Actions.

### Implementation Details

- 📦 [**npm Implementation Summary**](./NPM_IMPLEMENTATION_SUMMARY.md) - Original npm package implementation notes

## Technical Documentation

### Security & Sandboxing

- 🔒 [**Sandboxing Guide**](./SANDBOXING.md) - How orlop handles tool isolation and security

## Quick Links

- Main repository: https://github.com/vredchenko/orlop
- npm package: https://www.npmjs.com/package/@vredchenko/orlop
- Example scripts: [`examples/`](./examples/)

## Contributing

When updating documentation:
1. Keep guides concise and actionable
2. Include real-world examples from this project
3. Update the "Last updated" date at the bottom
4. No sensitive information (tokens, secrets, etc.)

---

Last updated: November 2025
