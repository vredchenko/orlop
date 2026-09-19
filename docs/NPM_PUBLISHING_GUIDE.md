# npm Publishing Guide for orlop

This guide explains how to publish the `@vredchenko/orlop` package to npm using modern security practices.

## Table of Contents

1. [Publishing Methods Overview](#publishing-methods-overview)
2. [Recommended: Trusted Publishers with OIDC](#recommended-trusted-publishers-with-oidc)
3. [Alternative: Granular Access Tokens](#alternative-granular-access-tokens)
4. [Troubleshooting](#troubleshooting)

## Publishing Methods Overview

As of 2025, npm supports two primary methods for automated publishing:

| Method | Security | Maintenance | Recommended |
|--------|----------|-------------|-------------|
| **Trusted Publishers (OIDC)** | Highest - No long-lived tokens | Zero - No token rotation needed | ✅ Yes |
| **Granular Access Tokens** | Medium - Requires token management | High - Max 90-day expiration | ⚠️ Fallback only |

**Important Security Update (November 2025):**
- Classic tokens are **completely disabled** as of November 19, 2025
- Granular tokens now have a **90-day maximum lifetime** (previously unlimited)
- npm strongly recommends migrating to **Trusted Publishers**

## Recommended: Trusted Publishers with OIDC

Trusted Publishers use OpenID Connect (OIDC) to authenticate GitHub Actions directly with npm, eliminating the need for stored tokens entirely.

### Prerequisites

- npm CLI **v11.5.1 or later** (included in Node.js 20+)
- Package must exist on npm (publish first version manually or configure before first publish)
- GitHub-hosted runners (self-hosted runners not yet supported)

### Step 1: Configure Trusted Publisher on npmjs.com

1. **Navigate to your package settings:**
   - Go to https://www.npmjs.com/package/@vredchenko/orlop
   - Click on **Settings** tab
   - Find **"Publishing access"** or **"Trusted publishers"** section

2. **Add GitHub Actions as trusted publisher:**
   - Click **"Add trusted publisher"** or **"Configure publisher"**
   - Select **"GitHub Actions"**

3. **Fill in the required fields:**

   | Field | Value | Notes |
   |-------|-------|-------|
   | **Organization/User** | `vredchenko` | Your GitHub username or org |
   | **Repository** | `orlop` | Repository name (without owner) |
   | **Workflow filename** | `npm-publish.yml` | Must match exactly (case-sensitive, including `.yml`) |
   | **Environment name** | `production` (optional) | Leave blank or specify deployment environment |

4. **Save the configuration**

### Step 2: Update GitHub Actions Workflow

Your workflow needs the `id-token: write` permission to generate OIDC tokens:

```yaml
jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # Required for OIDC trusted publishing

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'

      - run: npm ci
      - run: npm run build
      - run: npm test

      - name: Publish to npm with provenance
        run: npm publish --access public
        # No NODE_AUTH_TOKEN needed with trusted publishers!
```

**Key points:**
- **Remove** `NODE_AUTH_TOKEN` environment variable
- **Remove** `secrets.NPM_TOKEN` from the workflow
- `--provenance` flag is **automatic** with trusted publishers
- `id-token: write` permission is **required**

### Step 3: Verify Configuration

1. **Test the workflow:**
   - Create a GitHub release or trigger workflow manually
   - GitHub Actions will authenticate via OIDC
   - npm will verify the workflow matches your trusted publisher config

2. **Check for provenance:**
   - After successful publish, visit your package page
   - Look for the provenance attestation (shows verified publish origin)

### Benefits

- ✅ **No token management** - No secrets to store or rotate
- ✅ **Automatic provenance** - Build transparency included
- ✅ **Better security** - Temporary, scoped credentials per run
- ✅ **Zero maintenance** - No 90-day token expiration concerns

## Alternative: Granular Access Tokens

Use this method only if Trusted Publishers cannot be configured (e.g., self-hosted runners, other CI/CD platforms).

### Creating a Granular Access Token

1. **Navigate to token creation:**
   - Go to https://www.npmjs.com/settings/YOUR_USERNAME/tokens
   - Click **"Generate New Token"** → **"Granular Access Token"**

2. **Configure the token:**

   | Field | Configuration | Notes |
   |-------|--------------|-------|
   | **Token name** | `GitHub Actions CI/CD` | Descriptive name |
   | **Description** | `Token for publishing @vredchenko/orlop from GitHub Actions` | Optional but helpful |
   | **Expiration** | `90 days` | Maximum allowed |
   | **Bypass 2FA** | ✅ **Checked** | Required for automation |
   | **Allowed IP ranges** | Leave blank | GitHub Actions uses dynamic IPs |
   | **Packages - Permissions** | **Read and write** | Required to publish |
   | **Organizations - Permissions** | No access | Unless using npm org |

3. **Generate and copy:**
   - Click **"Generate token"**
   - **Copy immediately** - you'll only see it once!

### Adding Token to GitHub

1. **Go to repository settings:**
   - Navigate to https://github.com/vredchenko/orlop/settings/secrets/actions

2. **Add repository secret:**
   - Click **"New repository secret"**
   - **Name:** `NPM_TOKEN`
   - **Value:** Paste the token from npm
   - Click **"Add secret"**

3. **Use in workflow:**
   ```yaml
   - name: Publish to npm
     run: npm publish --provenance --access public
     env:
       NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
   ```

### Token Maintenance

⚠️ **Important:** Granular tokens now expire after maximum 90 days.

**Set a reminder to:**
1. Regenerate token every 90 days (before expiration)
2. Update `NPM_TOKEN` secret in GitHub repository settings
3. Consider migrating to Trusted Publishers to eliminate this maintenance

## Troubleshooting

### Trusted Publishers

**Error: "Unable to authenticate with npm registry"**
- Verify workflow filename matches **exactly** on npmjs.com (including `.yml`)
- Ensure `id-token: write` permission is set
- Check that npm CLI version is 11.5.1+ (`npm --version`)
- Verify you're using GitHub-hosted runners (not self-hosted)

**Error: "No trusted publisher configured"**
- Package must exist on npm first
- Double-check organization/repository names match exactly
- Try publishing one version manually first, then configure trusted publisher

### Granular Tokens

**Error: "401 Unauthorized"**
- Token may be expired (check npm settings)
- Secret name must be `NPM_TOKEN` (or match `NODE_AUTH_TOKEN` usage)
- Verify token has **Read and write** permissions for packages

**Error: "403 Forbidden"**
- Token lacks write permissions
- Token may be scoped to wrong packages/scopes
- Bypass 2FA might not be enabled on the token

**Publishing succeeds but no provenance:**
- Add `--provenance` flag explicitly to `npm publish` command
- Ensure `id-token: write` permission is set in workflow
- Requires npm CLI v9.5.0+

## Additional Resources

- [npm Trusted Publishers Documentation](https://docs.npmjs.com/trusted-publishers)
- [npm Security Changes Announcement](https://github.blog/changelog/2025-09-29-strengthening-npm-security-important-changes-to-authentication-and-token-management/)
- [npm Provenance Documentation](https://docs.npmjs.com/generating-provenance-statements)
- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

## Current Configuration

This repository is configured to use:
- **Method:** Trusted Publishers with OIDC (recommended)
- **Workflow:** `.github/workflows/npm-publish.yml`
- **Provenance:** Automatically enabled
- **Token rotation:** Not required

Last updated: November 2025
