# @vredchenko/orlop

> Modern CLI development tools with Node.js/TypeScript wrapper - batteries included

[![npm version](https://badge.fury.io/js/%40vredchenko%2Forlop.svg)](https://www.npmjs.com/package/@vredchenko/orlop)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is Orlop?

Orlop packages **17 modern CLI development tools** as a single npm module with TypeScript/JavaScript wrappers. Install once, get all the tools you need for development, scripting, and automation.

**What's with the naming?** The orlop is the lowest deck in a ship - where all the essential tools and equipment are stored. Similarly, this package provides foundational CLI tools for your development workflow.

## Features

✅ **All-in-one**: 17 powerful CLI tools in one package
✅ **Node.js API**: TypeScript/JavaScript wrappers with async/await
✅ **zx Integration**: Built-in support for Google's zx scripting
✅ **Offline-ready**: Binaries downloaded during install, work offline
✅ **No conflicts**: Use via `npx` or Node.js API, no global pollution
✅ **Type-safe**: Full TypeScript support with type definitions

## Supported Platforms

Currently: **Linux x86_64 (Debian/Ubuntu)**
Planned: macOS (Intel & Apple Silicon), Linux ARM64, Windows

## Installation

```bash
# Local installation (recommended)
npm install @vredchenko/orlop

# Global installation
npm install -g @vredchenko/orlop

# One-time use with npx
npx @vredchenko/orlop rg "pattern"
```

## Included Tools

| Tool | Description | Replaces |
|------|-------------|----------|
| **ripgrep** (rg) | Fast text search | grep |
| **bat** | Syntax-highlighted file viewer | cat |
| **fd** | Fast file finder | find |
| **delta** | Git diff viewer with syntax highlighting | diff |
| **lsd** | Modern ls with colors/icons | ls |
| **gdu** | Disk usage analyzer | du |
| **dust** | Alternative disk usage analyzer | du |
| **fzf** | Fuzzy finder | - |
| **starship** | Cross-shell prompt | - |
| **tokei** | Code statistics analyzer | cloc |
| **hexyl** | Hex viewer | hexdump |
| **hyperfine** | Benchmarking tool | time |
| **procs** | Modern process viewer | ps |
| **gron** | JSON processor | - |
| **glab** | GitLab CLI | - |
| **gh** | GitHub CLI | - |
| **mc** | MinIO/S3 client | - |

## Usage

### CLI (via npx)

```bash
# Search for pattern in files
npx @vredchenko/orlop rg "TODO" ./src

# View file with syntax highlighting
npx @vredchenko/orlop bat README.md

# Find TypeScript files
npx @vredchenko/orlop fd "\.ts$"

# Analyze code statistics
npx @vredchenko/orlop tokei ./src

# Disk usage
npx @vredchenko/orlop dust ./

# Benchmark commands
npx @vredchenko/orlop hyperfine "npm test" "npm run test:fast"
```

### Node.js API

```typescript
import { ripgrep, bat, fd, tokei, dust } from '@vredchenko/orlop';

// Search for pattern
const results = await ripgrep('TODO', {
  cwd: './src',
  args: ['--json', '--no-ignore']
});
console.log(results.stdout);

// View file
const content = await bat('README.md', {
  args: ['--color=always', '--style=grid']
});

// Find files
const files = await fd('\\.ts$', {
  cwd: './src',
  args: ['--type', 'file']
});

// Code statistics
const stats = await tokei('./src', {
  args: ['--output', 'json']
});
const data = JSON.parse(stats.stdout);

// Disk usage
const usage = await dust('./', {
  args: ['--output-format', 'json']
});
```

### Streaming Output

```typescript
import { ripgrep } from '@vredchenko/orlop';

// Stream large results
const stream = ripgrep.stream('pattern', { cwd: './src' });

stream.stdout.on('data', (chunk) => {
  console.log(chunk.toString());
});

await stream;
```

### zx Scripting

```typescript
#!/usr/bin/env zx
import '@vredchenko/orlop/zx'; // Adds binaries to PATH
import { $ } from 'zx';

// All orlop tools now available
const todos = await $`rg "TODO" ./src`;
console.log(todos.stdout);

const files = await $`fd "\\.ts$" ./src`;
console.log(files.stdout);

const stats = await $`tokei ./src --output json`;
const data = JSON.parse(stats.stdout);
```

### Using with scripts

```typescript
// analyze-codebase.ts
import { tokei, ripgrep, fd } from '@vredchenko/orlop';

async function analyzeCodebase(path: string) {
  // Get code statistics
  const stats = await tokei(path, { args: ['--output', 'json'] });
  const codeStats = JSON.parse(stats.stdout);

  // Find all TODO comments
  const todos = await ripgrep('TODO', { cwd: path, args: ['--json'] });
  const todoList = todos.stdout.split('\n')
    .filter(Boolean)
    .map(line => JSON.parse(line));

  // Count TypeScript files
  const tsFiles = await fd('\\.ts$', { cwd: path });
  const fileCount = tsFiles.stdout.split('\n').filter(Boolean).length;

  return {
    stats: codeStats,
    todos: todoList,
    typeScriptFiles: fileCount,
  };
}

const analysis = await analyzeCodebase('./src');
console.log(analysis);
```

## API Reference

### Tool Functions

All tools follow this pattern:

```typescript
async function toolName(
  arg?: string,
  options?: ToolOptions
): Promise<ToolResult>
```

#### ToolOptions

```typescript
interface ToolOptions {
  cwd?: string;              // Working directory
  args?: string[];           // Additional CLI arguments
  input?: string;            // Input to pipe to stdin
  env?: Record<string, string>; // Environment variables
  timeout?: number;          // Timeout in milliseconds
  encoding?: BufferEncoding; // Text encoding (default: 'utf8')
}
```

#### ToolResult

```typescript
interface ToolResult {
  stdout: string;   // Standard output
  stderr: string;   // Standard error
  exitCode: number; // Exit code (0 = success)
  command: string;  // Executed command
}
```

### Streaming

All tools have a `.stream()` method for large outputs:

```typescript
const stream = toolName.stream(arg, options);
stream.stdout.on('data', (chunk) => { /* ... */ });
await stream;
```

### Utility Functions

```typescript
import {
  getPlatformKey,   // Get current platform key
  isSupported,      // Check if platform is supported
  getToolPath,      // Get path to specific tool binary
  getBinDir,        // Get binary directory
  getAllToolPaths   // Get all tool paths
} from '@vredchenko/orlop';
```

## Examples

### Search and Replace Workflow

```typescript
import { ripgrep, bat } from '@vredchenko/orlop';

// Find all occurrences
const matches = await ripgrep('oldValue', {
  cwd: './src',
  args: ['--files-with-matches']
});

const files = matches.stdout.split('\n').filter(Boolean);

// Preview each file
for (const file of files) {
  console.log(`\n=== ${file} ===`);
  const content = await bat(file, { cwd: './src' });
  console.log(content.stdout);
}
```

### Code Quality Check

```typescript
import { tokei, ripgrep, dust } from '@vredchenko/orlop';

async function codeQualityReport(projectPath: string) {
  // Lines of code
  const stats = await tokei(projectPath, {
    args: ['--output', 'json']
  });

  // Find TODOs, FIXMEs, HACKs
  const todos = await ripgrep('(TODO|FIXME|HACK)', {
    cwd: projectPath,
    args: ['--count']
  });

  // Project size
  const size = await dust(projectPath, {
    args: ['--output-format', 'json', '--depth', '1']
  });

  return {
    stats: JSON.parse(stats.stdout),
    technicalDebt: todos.stdout,
    size: JSON.parse(size.stdout),
  };
}
```

### Performance Benchmarking

```typescript
import { hyperfine } from '@vredchenko/orlop';

const results = await hyperfine(['npm test', 'npm run test:fast'], {
  args: ['--warmup', '3', '--runs', '10', '--export-json', 'benchmark.json']
});

console.log(results.stdout);
```

### Git Workflow with Delta

```typescript
import { execSync } from 'child_process';
import { delta } from '@vredchenko/orlop';

// Get git diff and pipe to delta
const diff = execSync('git diff', { encoding: 'utf8' });
const highlighted = await delta({ input: diff });

console.log(highlighted.stdout);
```

## Platform Support

### Current Support

- ✅ Linux x86_64 (Debian/Ubuntu)

### Planned Support

- 🚧 macOS Intel (darwin-x64)
- 🚧 macOS Apple Silicon (darwin-arm64)
- 🚧 Linux ARM64 (linux-arm64)
- 🚧 Windows x64 (win32-x64)

The package automatically downloads platform-specific binaries during installation.

## Troubleshooting

### Binary Download Fails

If postinstall fails to download binaries:

```bash
# Manually trigger download
node node_modules/@vredchenko/orlop/dist/scripts/download-binaries.js

# Or reinstall
npm install @vredchenko/orlop --force
```

### Platform Not Supported

Check your platform:

```typescript
import { getPlatformKey, isSupported } from '@vredchenko/orlop';

console.log('Platform:', getPlatformKey());
console.log('Supported:', isSupported());
```

### Tool Not Found

Ensure binaries are downloaded:

```bash
ls -la node_modules/@vredchenko/orlop/bin/
```

## Contributing

Contributions welcome! See the [main repository](https://github.com/vredchenko/orlop) for:

- Bug reports
- Feature requests
- Platform support additions
- Tool suggestions

## License

MIT © vredchenko

## Related Projects

- [Orlop Docker Container](https://github.com/vredchenko/orlop) - Same tools in a Docker container
- [Orlop Ansible Playbook](https://github.com/vredchenko/orlop) - Install tools on host systems

## Credits

This package bundles the following excellent open-source tools:

- [ripgrep](https://github.com/BurntSushi/ripgrep) by Andrew Gallant
- [bat](https://github.com/sharkdp/bat) by David Peter
- [fd](https://github.com/sharkdp/fd) by David Peter
- [delta](https://github.com/dandavison/delta) by Dan Davison
- [lsd](https://github.com/lsd-rs/lsd) by Peltoche
- [gdu](https://github.com/dundee/gdu) by Daniel Milde
- [dust](https://github.com/bootandy/dust) by Andy Boot
- [fzf](https://github.com/junegunn/fzf) by Junegunn Choi
- [starship](https://github.com/starship/starship) by Starship Team
- [tokei](https://github.com/XAMPPRocky/tokei) by Erin Power
- [hexyl](https://github.com/sharkdp/hexyl) by David Peter
- [hyperfine](https://github.com/sharkdp/hyperfine) by David Peter
- [procs](https://github.com/dalance/procs) by dalance
- [gron](https://github.com/tomnomnom/gron) by Tom Hudson
- [glab](https://github.com/profclems/glab) by Clement Sam
- [gh](https://github.com/cli/cli) by GitHub
- [mc](https://github.com/minio/mc) by MinIO

All tools remain under their respective licenses.
