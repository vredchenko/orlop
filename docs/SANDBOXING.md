# Binary Sandboxing in @vredchenko/orlop

## Overview

`@vredchenko/orlop` uses **absolute path execution** to ensure installed binaries never conflict with system tools. This document explains the sandboxing architecture.

---

## How Sandboxing Works

### 1. Binary Storage Structure

Binaries are stored in nested directories within the package:

```
node_modules/@vredchenko/orlop/
├── bin/
│   └── {platform}/              # e.g., linux-x64, darwin-arm64
│       ├── ripgrep/
│       │   └── rg               # actual binary
│       ├── bat/
│       │   └── bat
│       ├── fd/
│       │   └── fd
│       └── ...
```

### 2. Absolute Path Resolution

**All execution uses absolute paths** - no reliance on `$PATH`:

```typescript
// src/utils/paths.ts
export function getToolPath(toolName: string, binaryName?: string): string {
  const binDir = getBinDir();  // /path/to/node_modules/@vredchenko/orlop/bin/linux-x64
  const binary = binaryName || toolName;
  return path.join(binDir, toolName, binary);
  // Returns: /path/to/node_modules/@vredchenko/orlop/bin/linux-x64/ripgrep/rg
}
```

### 3. Execution Methods

**All three usage methods use absolute paths:**

#### Node.js API
```typescript
// src/utils/exec.ts
const binaryPath = getToolPath('ripgrep', 'rg');  // Absolute path
const result = await execa(binaryPath, args);     // Direct invocation
```

#### CLI Router
```typescript
// src/cli.ts
const binaryPath = getToolPath(toolConfig.toolName, toolConfig.binary);
const child = spawn(binaryPath, args);  // Absolute path
```

#### zx Integration
```typescript
// src/zx/index.ts
export const toolPaths = getAllToolPaths();  // { ripgrep: '/abs/path/to/rg', ... }
export const rg = (...args) => $`${toolPaths.ripgrep} ${args}`;  // Absolute path
```

---

## Collision Prevention

### ✅ What's Protected

Your system tools are **completely safe**:

- System `rg` at `/usr/bin/rg` → **unchanged**
- Orlop `rg` at `node_modules/@vredchenko/orlop/bin/linux-x64/ripgrep/rg` → **isolated**

### Example Scenarios

**Scenario 1: System has ripgrep installed**
```bash
# System ripgrep (unchanged)
which rg           # /usr/bin/rg
rg --version       # ripgrep 14.0.3

# Orlop ripgrep (sandboxed)
npx @vredchenko/orlop rg --version  # Uses absolute path to orlop's rg
```

**Scenario 2: Using in Node.js scripts**
```typescript
import { ripgrep } from '@vredchenko/orlop';

// Always uses /path/to/node_modules/@vredchenko/orlop/bin/.../rg
// Never uses system /usr/bin/rg
const result = await ripgrep('pattern', { cwd: './src' });
```

**Scenario 3: zx scripts**
```typescript
#!/usr/bin/env zx
import { rg, toolPaths } from '@vredchenko/orlop/zx';

// Option 1: Direct function (uses absolute path internally)
await rg('pattern', './src');

// Option 2: Explicit absolute path
await $`${toolPaths.ripgrep} pattern ./src`;

// System rg is NEVER used
```

---

## PATH Behavior

### ❌ What We DON'T Do

We **do not** modify `$PATH`:
- No `process.env.PATH = ...`
- No symlinks in `/usr/local/bin`
- No global installation conflicts

### ✅ What We DO

We use **direct binary invocation**:
```javascript
// Instead of:
spawn('rg', args);  // ❌ Searches $PATH

// We do:
spawn('/abs/path/to/node_modules/@vredchenko/orlop/bin/linux-x64/ripgrep/rg', args);  // ✅
```

---

## Guarantees

1. **No System Pollution**: Installing `@vredchenko/orlop` never modifies system tools or `$PATH`
2. **Predictable Behavior**: Always uses the exact binaries installed by the package
3. **Multiple Versions**: Different projects can use different orlop versions without conflicts
4. **Uninstall is Clean**: `npm uninstall` removes everything - no leftover binaries

---

## Testing Sandboxing

You can verify sandboxing works:

```bash
# Check system rg location (if installed)
which rg  # /usr/bin/rg or not found

# Use orlop rg
npx @vredchenko/orlop rg --version

# System rg still unchanged
which rg  # Still /usr/bin/rg (if it was there before)
```

Or in Node.js:

```typescript
import { ripgrep } from '@vredchenko/orlop';
import { getToolPath } from '@vredchenko/orlop';

console.log(getToolPath('ripgrep', 'rg'));
// Prints absolute path like:
// /home/user/project/node_modules/@vredchenko/orlop/bin/linux-x64/ripgrep/rg

const result = await ripgrep('--version');
console.log(result.stdout);  // orlop's ripgrep version
```

---

## Implementation Details

### Binary Download (postinstall)

```typescript
// Downloads to isolated directories
const binDir = path.join(root, 'bin', platformKey, toolName);
await downloadFile(asset.url, path.join(binDir, asset.name));
// Creates: bin/linux-x64/ripgrep/rg
```

### Execution Wrapper

```typescript
// All execution goes through getToolPath() first
export async function execTool(toolName: string, binaryName: string, args: string[]) {
  const binaryPath = getToolPath(toolName, binaryName);  // Absolute path
  return execa(binaryPath, args);  // Direct invocation
}
```

### CLI Binaries

Even the `package.json` bin entries are sandboxed:

```json
{
  "bin": {
    "orlop": "dist/cli.js",
    "orlop-rg": "dist/bin-wrapper.js"
  }
}
```

Each wrapper resolves to absolute paths internally - they're just convenient entry points.

---

## Best Practices

### ✅ Recommended Usage

```typescript
// Node.js API - always sandboxed
import { ripgrep, bat } from '@vredchenko/orlop';
await ripgrep('pattern', { cwd: './src' });

// zx with direct functions - always sandboxed
import { rg, bat } from '@vredchenko/orlop/zx';
await rg('pattern', './src');

// CLI via npx - always sandboxed
npx @vredchenko/orlop rg 'pattern' ./src
```

### ⚠️ What to Avoid

Don't try to use orlop binaries via PATH manipulation:

```typescript
// ❌ Don't do this
process.env.PATH = `${orlopBinDir}:${process.env.PATH}`;
exec('rg pattern');  // Might work but defeats sandboxing

// ✅ Do this instead
import { rg } from '@vredchenko/orlop/zx';
await rg('pattern');  // Properly sandboxed
```

---

## Summary

**@vredchenko/orlop is fully sandboxed** - it will never interfere with your system tools, and multiple projects can use different versions simultaneously without conflicts.

The implementation uses **absolute path execution** for all tools, ensuring complete isolation from system binaries and `$PATH`.
