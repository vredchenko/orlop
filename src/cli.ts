#!/usr/bin/env node

/**
 * CLI router for orlop tools
 * Usage: orlop <tool> [args...]
 * Example: orlop rg "pattern" ./src
 */

import { spawn } from 'child_process';
import { getToolPath } from './utils/paths.js';

const TOOL_MAP: Record<string, { toolName: string; binary: string }> = {
  rg: { toolName: 'ripgrep', binary: 'rg' },
  ripgrep: { toolName: 'ripgrep', binary: 'rg' },
  bat: { toolName: 'bat', binary: 'bat' },
  fd: { toolName: 'fd', binary: 'fd' },
  delta: { toolName: 'delta', binary: 'delta' },
  lsd: { toolName: 'lsd', binary: 'lsd' },
  ls: { toolName: 'lsd', binary: 'lsd' },
  gdu: { toolName: 'gdu', binary: 'gdu' },
  fzf: { toolName: 'fzf', binary: 'fzf' },
  starship: { toolName: 'starship', binary: 'starship' },
  tokei: { toolName: 'tokei', binary: 'tokei' },
  hexyl: { toolName: 'hexyl', binary: 'hexyl' },
  hyperfine: { toolName: 'hyperfine', binary: 'hyperfine' },
  procs: { toolName: 'procs', binary: 'procs' },
  ps: { toolName: 'procs', binary: 'procs' },
  gron: { toolName: 'gron', binary: 'gron' },
  glab: { toolName: 'glab', binary: 'glab' },
  gh: { toolName: 'gh', binary: 'gh' },
  dust: { toolName: 'dust', binary: 'dust' },
  mc: { toolName: 'mc', binary: 'mc' },
};

function showHelp() {
  console.log(`
┌─────────────────────────────────────────────────────┐
│  @vredchenko/orlop - Modern CLI Development Tools   │
└─────────────────────────────────────────────────────┘

Usage: orlop <tool> [args...]

Available tools:
  rg, ripgrep       - Fast text search
  bat               - Syntax-highlighted file viewer
  fd                - Fast file finder
  delta             - Git diff viewer
  lsd, ls           - Modern ls replacement
  gdu               - Disk usage analyzer
  fzf               - Fuzzy finder
  starship          - Shell prompt
  tokei             - Code statistics
  hexyl             - Hex viewer
  hyperfine         - Benchmarking tool
  procs, ps         - Modern ps replacement
  gron              - JSON processor
  glab              - GitLab CLI
  gh                - GitHub CLI
  dust              - Disk usage analyzer
  mc                - MinIO/S3 client

Examples:
  orlop rg "TODO" ./src
  orlop bat README.md
  orlop fd "\\.ts$"
  orlop tokei ./src

For tool-specific help:
  orlop <tool> --help

Node.js API:
  import { ripgrep, bat, fd } from '@vredchenko/orlop';
  const results = await ripgrep('pattern', { cwd: './src' });

Learn more: https://github.com/vredchenko/orlop
`);
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    showHelp();
    process.exit(0);
  }

  if (args[0] === '--version' || args[0] === '-v') {
    console.log('0.1.0');
    process.exit(0);
  }

  const toolArg = args[0];
  const toolArgs = args.slice(1);

  const toolConfig = TOOL_MAP[toolArg];

  if (!toolConfig) {
    console.error(`Unknown tool: ${toolArg}`);
    console.error(`Run 'orlop --help' to see available tools`);
    process.exit(1);
  }

  try {
    const binaryPath = getToolPath(toolConfig.toolName, toolConfig.binary);

    // Spawn the tool binary with args
    const child = spawn(binaryPath, toolArgs, {
      stdio: 'inherit',
      env: process.env,
    });

    child.on('exit', (code) => {
      process.exit(code || 0);
    });

    child.on('error', (error) => {
      console.error(`Failed to execute ${toolArg}:`, error.message);
      process.exit(1);
    });
  } catch (error: any) {
    console.error(`Failed to find ${toolArg}:`, error.message);
    console.error(`Try reinstalling: npm install @vredchenko/orlop`);
    process.exit(1);
  }
}

main();
