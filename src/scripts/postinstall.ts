#!/usr/bin/env node

async function main() {
  console.log('\n🔧 @vredchenko/orlop postinstall\n');

  // Platform validation
  const platform = process.platform;
  const arch = process.arch;

  console.log(`Detected platform: ${platform}-${arch}`);

  // Check if platform is supported
  const supportedPlatforms = ['linux'];
  const supportedArchs = ['x64'];

  if (!supportedPlatforms.includes(platform)) {
    console.error(`\n❌ ERROR: Unsupported platform "${platform}"`);
    console.error(`   @vredchenko/orlop currently supports: ${supportedPlatforms.join(', ')}`);
    console.error(`   Future support for macOS and Windows is planned.\n`);
    process.exit(1);
  }

  if (!supportedArchs.includes(arch)) {
    console.error(`\n❌ ERROR: Unsupported architecture "${arch}"`);
    console.error(`   @vredchenko/orlop currently supports: ${supportedArchs.join(', ')}`);
    console.error(`   Future support for ARM64 is planned.\n`);
    process.exit(1);
  }

  console.log('✅ Platform supported\n');

  // Download binaries
  console.log('Downloading CLI tool binaries...\n');

  try {
    // Dynamic import and run download-binaries
    await import('./download-binaries.js');

    console.log('\n✅ Installation complete!');
    console.log('\nYou can now use orlop tools:');
    console.log('  - Via npx: npx @vredchenko/orlop rg "pattern"');
    console.log('  - Via Node.js: import { ripgrep } from "@vredchenko/orlop"\n');
  } catch (error) {
    console.error('\n❌ Failed to download binaries:', error);
    console.error('\nYou can try manually running:');
    console.error('  node node_modules/@vredchenko/orlop/dist/scripts/download-binaries.js\n');
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('Postinstall error:', error);
  process.exit(1);
});
