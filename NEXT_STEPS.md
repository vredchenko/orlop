# Next Steps for npm Publishing

## Current State ✅

**Branch:** `claude/review-repo-state-011CUuRycziGLpDMjBe68rro`
- ✅ Rebased on latest main
- ✅ Contains critical sandboxing fix
- ✅ Build passing
- ✅ Ready for PR

**What's Ready:**
- Complete npm package implementation (`@vredchenko/orlop`)
- 17 CLI tools with TypeScript/JavaScript wrappers
- Node.js API, CLI router, and zx integration
- **Critical:** Proper sandboxing using absolute paths
- CI/CD workflow for npm publishing
- Comprehensive documentation

## Step 1: Create PR ⏭️ (Do This Now)

1. Go to: https://github.com/vredchenko/orlop/compare/main...claude/review-repo-state-011CUuRycziGLpDMjBe68rro

2. Use the PR description from `PR_DESCRIPTION.md` in this repo

3. Title: **Fix zx Integration Sandboxing - Use Absolute Paths**

4. Create the PR

## Step 2: Review & Merge

- Review the changes (especially `src/zx/index.ts`)
- Verify build passes
- Merge to main

## Step 3: Set Up npm Publishing

### Add NPM_TOKEN to GitHub Secrets

1. Get your npm access token:
   ```bash
   npm login
   npm token create --read-only=false
   ```

2. Add to GitHub:
   - Go to: https://github.com/vredchenko/orlop/settings/secrets/actions
   - Click "New repository secret"
   - Name: `NPM_TOKEN`
   - Value: Your token from step 1
   - Click "Add secret"

## Step 4: Publish to npm

### Option A: Manual Workflow Trigger (Recommended for First Publish)

1. Go to: https://github.com/vredchenko/orlop/actions/workflows/npm-publish.yml
2. Click "Run workflow"
3. Set version: `0.1.0` (or desired version)
4. Set tag: `latest`
5. Click "Run workflow"

### Option B: Create GitHub Release (Automated)

1. Update `VERSION` file if needed: `echo "0.1.0" > VERSION`
2. Create git tag: `git tag v0.1.0 && git push origin v0.1.0`
3. Create release on GitHub
4. CI/CD will automatically publish to npm

## Step 5: Test in Your Projects

After publishing:

```bash
# In your other projects
npm install @vredchenko/orlop

# Test Node.js API
node -e "const { ripgrep } = require('@vredchenko/orlop'); ripgrep('test').then(r => console.log(r.stdout))"

# Test CLI
npx @vredchenko/orlop rg --version

# Test in zx script
# Create test.mjs:
cat > test.mjs << 'EOF'
#!/usr/bin/env zx
import { rg, bat, toolPaths } from '@vredchenko/orlop/zx';

console.log('Tool paths:', toolPaths);
await rg('--version');
EOF

# Run it:
npx zx test.mjs
```

## Troubleshooting

### If npm publish fails:

1. **Check NPM_TOKEN:**
   - Make sure secret is set correctly
   - Token needs publish permissions (not read-only)

2. **Package name conflicts:**
   - `@vredchenko/orlop` should be available
   - You own the `@vredchenko` org on npm

3. **Version conflicts:**
   - Can't publish same version twice
   - Increment version if needed

### If binaries don't download:

1. Check postinstall script runs:
   ```bash
   npm install @vredchenko/orlop --verbose
   ```

2. Check binary directory:
   ```bash
   ls -la node_modules/@vredchenko/orlop/bin/
   ```

3. Manually trigger download:
   ```bash
   node node_modules/@vredchenko/orlop/dist/scripts/download-binaries.js
   ```

## Success Criteria

You'll know it's working when:

✅ `npm install @vredchenko/orlop` succeeds
✅ Binaries download during postinstall
✅ `npx @vredchenko/orlop rg --version` works
✅ Node.js API works: `require('@vredchenko/orlop').ripgrep`
✅ zx integration works: `import { rg } from '@vredchenko/orlop/zx'`
✅ No conflicts with system-installed tools

## Your Primary Goal 🎯

> "My primary objective with orlop is to publish to npm so I can use it as a dependency in my other projects"

After following these steps, you'll have:
- ✅ `@vredchenko/orlop` published to npm
- ✅ Ready to use in all your projects
- ✅ Fully sandboxed - no conflicts
- ✅ 17 powerful CLI tools at your fingertips

## Questions?

If you run into issues:
1. Check GitHub Actions logs
2. Check npm publish output
3. Verify NPM_TOKEN permissions
4. Test locally first with `npm pack` and `npm install ./vredchenko-orlop-0.1.0.tgz`
