#!/usr/bin/env zx

/**
 * Example zx script using @vredchenko/orlop
 *
 * This demonstrates the sandboxed approach - all tools use absolute paths
 * and won't conflict with system installations.
 *
 * Run with: zx docs/examples/zx-example.mjs
 */

import { rg, bat, fd, tokei, lsd, toolPaths, $ } from '@vredchenko/orlop/zx';

console.log('🚀 @vredchenko/orlop zx Integration Example\n');

// Example 1: Using direct tool functions
console.log('📁 Example 1: Search for TODOs in source code');
try {
  const todos = await rg('TODO', './src', '--count', '--color=never');
  console.log('Found TODOs:');
  console.log(todos.stdout);
} catch (error) {
  console.log('No TODOs found or search failed');
}

console.log('\n' + '='.repeat(60) + '\n');

// Example 2: Find TypeScript files
console.log('📄 Example 2: Find all TypeScript files');
try {
  const tsFiles = await fd('\\.ts$', './src', '--type', 'f');
  const fileList = tsFiles.stdout.split('\n').filter(Boolean);
  console.log(`Found ${fileList.length} TypeScript files:`);
  fileList.slice(0, 5).forEach(f => console.log(`  - ${f}`));
  if (fileList.length > 5) {
    console.log(`  ... and ${fileList.length - 5} more`);
  }
} catch (error) {
  console.log('No TypeScript files found');
}

console.log('\n' + '='.repeat(60) + '\n');

// Example 3: Code statistics
console.log('📊 Example 3: Code statistics');
try {
  const stats = await tokei('./src', '--output', 'json');
  const data = JSON.parse(stats.stdout);
  console.log('Code statistics:');
  console.log(JSON.stringify(data, null, 2).slice(0, 500) + '...');
} catch (error) {
  console.log('Could not generate statistics');
}

console.log('\n' + '='.repeat(60) + '\n');

// Example 4: Using toolPaths for complex piping
console.log('🔧 Example 4: Using absolute paths with zx $');
console.log('Tool paths being used:');
console.log(`  ripgrep: ${toolPaths.ripgrep}`);
console.log(`  bat:     ${toolPaths.bat}`);
console.log(`  fd:      ${toolPaths.fd}`);

console.log('\n' + '='.repeat(60) + '\n');

// Example 5: List files with lsd
console.log('📂 Example 5: List current directory with lsd');
try {
  const listing = await lsd('.', '-la', '--color=never');
  console.log(listing.stdout.split('\n').slice(0, 10).join('\n'));
  console.log('...');
} catch (error) {
  console.log('Could not list directory');
}

console.log('\n✅ Examples completed!\n');

// Show that system tools are unaffected
console.log('🔒 Sandboxing verification:');
console.log('Orlop tools use absolute paths - your system tools are safe!');
console.log(`System PATH: ${process.env.PATH?.split(':').slice(0, 3).join(':')}...`);
console.log('(Orlop bin directory is NOT in PATH - we use absolute paths instead)');
