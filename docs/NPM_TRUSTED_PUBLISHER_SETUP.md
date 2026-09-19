# npm Trusted Publisher Setup Checklist

Quick setup guide for configuring npm Trusted Publishers (OIDC) for the `@vredchenko/orlop` package.

## Prerequisites

- [ ] Package published to npm at least once (can be done manually)
- [ ] npm CLI v11.5.1+ installed
- [ ] GitHub repository: `vredchenko/orlop`
- [ ] Using GitHub-hosted runners (not self-hosted)

## Setup Steps

### 1. Configure on npmjs.com

- [ ] Go to https://www.npmjs.com/package/@vredchenko/orlop
- [ ] Click **Settings** tab
- [ ] Navigate to **"Publishing access"** or **"Trusted publishers"** section
- [ ] Click **"Add trusted publisher"** or **"Configure publisher"**
- [ ] Select **"GitHub Actions"**

#### Required Fields

Fill in exactly as shown:

```
Organization/User:    vredchenko
Repository:           orlop
Workflow filename:    npm-publish.yml
Environment name:     (leave blank or use "production")
```

**Critical:** Workflow filename is **case-sensitive** and must match exactly!

- [ ] Save the trusted publisher configuration

### 2. Verify GitHub Actions Workflow

Your workflow at `.github/workflows/npm-publish.yml` already has:

- [x] `id-token: write` permission (line 23)
- [x] `npm publish` without `NODE_AUTH_TOKEN` (lines 57-62)
- [x] Automatic provenance (no `--provenance` flag needed)

**No changes needed** - workflow is already configured correctly!

### 3. Remove Old Token (Optional)

If you previously used granular access tokens:

- [ ] Go to https://github.com/vredchenko/orlop/settings/secrets/actions
- [ ] Delete the `NPM_TOKEN` secret (no longer needed)
- [ ] Go to https://www.npmjs.com/settings/USERNAME/tokens
- [ ] Revoke any tokens created for this package

### 4. Test Publishing

Option A: Create a Release
- [ ] Tag a new version: `git tag v0.1.1 && git push --tags`
- [ ] Create GitHub release for the tag
- [ ] Workflow triggers automatically

Option B: Manual Trigger
- [ ] Go to https://github.com/vredchenko/orlop/actions/workflows/npm-publish.yml
- [ ] Click **"Run workflow"**
- [ ] Enter version (or leave blank to use VERSION file)
- [ ] Click **"Run workflow"**

### 5. Verify Success

- [ ] Check workflow run completed successfully
- [ ] Visit https://www.npmjs.com/package/@vredchenko/orlop
- [ ] Verify new version is published
- [ ] Look for **provenance badge** on package page (shows verified origin)

## Troubleshooting

### Common Issues

**"Unable to authenticate with npm registry"**

Possible causes:
- Workflow filename doesn't match exactly on npmjs.com
- Missing `id-token: write` permission
- npm CLI version too old (need 11.5.1+)
- Using self-hosted runner (not supported yet)

**Fix:**
1. Double-check workflow filename: `npm-publish.yml` (exact match)
2. Verify permission in workflow file (line 23)
3. Check npm version in workflow logs
4. Ensure using `runs-on: ubuntu-latest`

---

**"Package not found" or "No trusted publisher configured"**

Possible causes:
- Package doesn't exist on npm yet
- Wrong package name in trusted publisher config
- Repository/organization name mismatch

**Fix:**
1. Publish version manually first: `npm publish --access public`
2. Verify package name matches exactly: `@vredchenko/orlop`
3. Check GitHub org/user and repo names match configuration

---

**Publishing works but no provenance shown**

This shouldn't happen with trusted publishers (automatic), but if it does:
- Verify npm CLI version is 11.5.1+ in workflow logs
- Check that `id-token: write` permission is set
- Ensure using GitHub-hosted runner

## Benefits Checklist

After setup, you'll have:

- [x] No npm tokens to manage or rotate
- [x] Automatic provenance attestations on every publish
- [x] Enhanced security through OIDC authentication
- [x] No 90-day token expiration concerns
- [x] Transparent build and publish history

## Additional Resources

- Full guide: [`docs/NPM_PUBLISHING_GUIDE.md`](./NPM_PUBLISHING_GUIDE.md)
- npm docs: https://docs.npmjs.com/trusted-publishers
- GitHub OIDC docs: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect

## Support

If you encounter issues:
1. Check npm's status page: https://status.npmjs.org
2. Review GitHub Actions logs for detailed error messages
3. Consult the full guide in `docs/NPM_PUBLISHING_GUIDE.md`

---

Last updated: November 2025
