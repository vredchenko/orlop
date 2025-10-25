#!/usr/bin/env node

/**
 * Binary wrapper for individual tool executables
 * Maps orlop-<tool> to the actual binary
 */

import { spawn } from 'child_process';
import path from 'path';
import { getToolPath } from './utils/paths.js';

// Extract tool name from script name (e.g., orlop-rg -> rg)
const BINARY_MAP: Record<string, { toolName: string; binary: string }> = {
  'orlop-rg': { toolName: 'ripgrep', binary: 'rg' },
  'orlop-bat': { toolName: 'bat', binary: 'bat' },
  'orlop-fd': { toolName: 'fd', binary: 'fd' },
  'orlop-delta': { toolName: 'delta', binary: 'delta' },
  'orlop-lsd': { toolName: 'lsd', binary: 'lsd' },
  'orlop-gdu': { toolName: 'gdu', binary: 'gdu' },
  'orlop-fzf': { toolName: 'fzf', binary: 'fzf' },
  'orlop-starship': { toolName: 'starship', binary: 'starship' },
  'orlop-tokei': { toolName: 'tokei', binary: 'tokei' },
  'orlop-hexyl': { toolName: 'hexyl', binary: 'hexyl' },
  'orlop-hyperfine': { toolName: 'hyperfine', binary: 'hyperfine' },
  'orlop-procs': { toolName: 'procs', binary: 'procs' },
  'orlop-gron': { toolName: 'gron', binary: 'gron' },
  'orlop-glab': { toolName: 'glab', binary: 'glab' },
  'orlop-gh': { toolName: 'gh', binary: 'gh' },
  'orlop-dust': { toolName: 'dust', binary: 'dust' },
  'orlop-mc': { toolName: 'mc', binary: 'mc' },
};

function main() {
  // Determine which tool was invoked
  const invoked = path.basename(process.argv[1], '.js');
  const toolConfig = BINARY_MAP[invoked];

  if (!toolConfig) {
    console.error(`Unknown binary wrapper: ${invoked}`);
    process.exit(1);
  }

  const args = process.argv.slice(2);

  try {
    const binaryPath = getToolPath(toolConfig.toolName, toolConfig.binary);

    // Spawn the actual binary
    const child = spawn(binaryPath, args, {
      stdio: 'inherit',
      env: process.env,
    });

    child.on('exit', (code) => {
      process.exit(code || 0);
    });

    child.on('error', (error) => {
      console.error(`Failed to execute ${toolConfig.binary}:`, error.message);
      process.exit(1);
    });
  } catch (error: any) {
    console.error(`Failed to find ${toolConfig.binary}:`, error.message);
    console.error(`Try reinstalling: npm install @vredchenko/orlop`);
    process.exit(1);
  }
}

main();
