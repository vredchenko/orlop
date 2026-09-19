# npm Publishing: Tokens vs. Trusted Publishers (OIDC)

Visual comparison of the two methods for automated npm publishing from GitHub Actions.

## Architecture Comparison

### Method 1: Granular Access Tokens (Legacy/Fallback)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Initial Setup (One-time)                     │
└─────────────────────────────────────────────────────────────────┘
                                ↓
    ┌───────────────────────────────────────────────────┐
    │  1. Developer creates token on npmjs.com          │
    │     - Configure permissions                       │
    │     - Set 90-day expiration                       │
    │     - Copy token (shown once!)                    │
    └───────────────────────┬───────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  2. Add token to GitHub Secrets                   │
    │     - Repository Settings → Secrets               │
    │     - Name: NPM_TOKEN                             │
    │     - Value: [long-lived token]                   │
    └───────────────────────┬───────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Every 90 Days (Maintenance)                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  3. Token expires - regenerate manually           │
    │     - Create new token on npmjs.com               │
    │     - Update GitHub secret again                  │
    │     - Risk: Forgot to rotate? Publishing breaks!  │
    └───────────────────────┬───────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Publishing Flow                             │
└─────────────────────────────────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  GitHub Actions Workflow                          │
    │  ┌─────────────────────────────────────────────┐  │
    │  │ steps:                                      │  │
    │  │   - run: npm publish                        │  │
    │  │     env:                                    │  │
    │  │       NODE_AUTH_TOKEN: ${{ secrets.TOKEN }} │  │
    │  └─────────────────────────────────────────────┘  │
    └───────────────────────┬───────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  npm Registry                                     │
    │  - Validates long-lived token                     │
    │  - Publishes package                              │
    │  - ⚠️ No automatic provenance                     │
    └───────────────────────────────────────────────────┘

⚠️  Security Concerns:
    - Token stored in GitHub (potential leak)
    - Valid for 90 days (larger attack window)
    - Manual rotation required (human error risk)
    - No built-in provenance
```

---

### Method 2: Trusted Publishers with OIDC (Recommended)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Initial Setup (One-time)                     │
└─────────────────────────────────────────────────────────────────┘
                                ↓
    ┌───────────────────────────────────────────────────┐
    │  1. Configure trusted publisher on npmjs.com      │
    │     - Organization: vredchenko                    │
    │     - Repository: orlop                           │
    │     - Workflow: npm-publish.yml                   │
    │     - No tokens needed!                           │
    └───────────────────────┬───────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  2. Workflow has id-token permission              │
    │     permissions:                                  │
    │       id-token: write  # OIDC                     │
    │     - Already in your workflow! ✓                 │
    └───────────────────────┬───────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Maintenance Required                        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                    ✅ NONE! Set it and forget it.
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Publishing Flow                             │
└─────────────────────────────────────────────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  GitHub Actions Workflow                          │
    │  ┌─────────────────────────────────────────────┐  │
    │  │ steps:                                      │  │
    │  │   - run: npm publish                        │  │
    │  │     # No env vars needed!                   │  │
    │  └─────────────────────────────────────────────┘  │
    └───────────────────────┬───────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  GitHub OIDC Provider                             │
    │  - Generates temporary JWT token                  │
    │  - Scoped to specific workflow run                │
    │  - Includes: repo, workflow, commit SHA           │
    │  - Valid for ~1 hour only                         │
    └───────────────────────┬───────────────────────────┘
                            ↓
    ┌───────────────────────────────────────────────────┐
    │  npm Registry                                     │
    │  1. Receives OIDC token from GitHub               │
    │  2. Validates token signature                     │
    │  3. Checks trusted publisher config:              │
    │     ✓ Repo: vredchenko/orlop                      │
    │     ✓ Workflow: npm-publish.yml                   │
    │     ✓ Token not expired                           │
    │  4. Publishes package                             │
    │  5. ✅ Auto-generates provenance attestation      │
    └───────────────────────────────────────────────────┘

✅  Security Benefits:
    - No secrets stored anywhere
    - Tokens valid for ~1 hour only
    - Zero maintenance (no rotation)
    - Automatic provenance included
    - Verifiable supply chain
```

## Feature Comparison Matrix

| Feature | Granular Tokens | Trusted Publishers (OIDC) |
|---------|----------------|---------------------------|
| **Setup complexity** | Medium (token + secret) | Low (config on npm only) |
| **Secrets to manage** | 1 (NPM_TOKEN) | 0 |
| **Token lifetime** | 90 days max | ~1 hour per publish |
| **Rotation required** | Every 90 days | Never |
| **Provenance** | Manual (`--provenance` flag) | Automatic |
| **Attack surface** | High (long-lived token) | Minimal (temporary token) |
| **Works with** | Any CI/CD, self-hosted | GitHub/GitLab hosted runners |
| **npm CLI requirement** | Any version | v11.5.1+ |
| **Leaked token risk** | High (valid 90 days) | Low (expires in 1 hour) |
| **Supply chain transparency** | Optional | Built-in |
| **Recommended by npm** | ⚠️ Fallback only | ✅ Primary method |

## Migration Path

If you're currently using tokens, here's how to migrate:

```
Current State                    Target State
─────────────                    ────────────

GitHub Secrets:                  GitHub Secrets:
├── NPM_TOKEN                    └── (empty - no secrets needed!)
└── (value: npm_xxx...)

npmjs.com Settings:              npmjs.com Settings:
├── Access Tokens                ├── Access Tokens
│   └── "GitHub Actions"         │   └── (can delete old token)
│       [Expires in 45 days]     └── Trusted Publishers
└── Trusted Publishers               └── "GitHub Actions"
    (not configured)                     ├── Org: vredchenko
                                         ├── Repo: orlop
                                         └── Workflow: npm-publish.yml

Workflow (npm-publish.yml):      Workflow (npm-publish.yml):
- run: npm publish               - run: npm publish
  env:                             # No env needed!
    NODE_AUTH_TOKEN: ${{...}}
```

## Real-World Example: orlop

### Before (Using Tokens)

```yaml
# .github/workflows/npm-publish.yml
jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # For provenance only
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci && npm run build
      - run: npm publish --provenance --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}  # ❌ Token required
```

**Issues:**
- Need to create and store NPM_TOKEN secret
- Token expires every 90 days → manual rotation
- `--provenance` flag required explicitly

### After (Using Trusted Publishers)

```yaml
# .github/workflows/npm-publish.yml
jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # For OIDC authentication
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci && npm run build
      - run: npm publish --access public
        # ✅ No env vars needed!
        # ✅ No --provenance flag needed (automatic)
```

**Benefits:**
- No secrets to manage
- No token rotation needed
- Provenance automatic
- More secure by default

## Security Timeline

```
2024                      2025                      Future
──┬─────────────────────────┬─────────────────────────┬──────
  │                         │                         │
  ├─ Classic tokens OK      ├─ Nov 19: Classic       ├─ OIDC becomes
  │  (unlimited lifetime)   │  tokens DISABLED        │  the only method?
  │                         │                         │
  ├─ Granular tokens        ├─ Sep: Granular tokens  ├─ Self-hosted
  │  (unlimited lifetime)   │  max 90 days            │  runner support
  │                         │                         │
  └─ Jul: OIDC trusted      └─ OIDC recommended      └─ More CI/CD
     publishing GA              as primary method        providers
```

## Recommendation

**Use Trusted Publishers (OIDC) for:**
- ✅ GitHub Actions with hosted runners
- ✅ GitLab CI/CD with hosted runners
- ✅ Any new package setup
- ✅ When security and supply chain transparency matter

**Use Granular Tokens only for:**
- ⚠️ Self-hosted runners (OIDC not supported yet)
- ⚠️ CI/CD platforms without OIDC support
- ⚠️ Legacy systems requiring gradual migration

## Next Steps

For this repository (`@vredchenko/orlop`):

1. ✅ Workflow already configured for OIDC (has `id-token: write`)
2. ⏳ **Action needed:** Configure trusted publisher on npmjs.com
3. ✅ Publish and enjoy zero-maintenance security!

See [`NPM_TRUSTED_PUBLISHER_SETUP.md`](./NPM_TRUSTED_PUBLISHER_SETUP.md) for step-by-step instructions.

---

Last updated: November 2025
