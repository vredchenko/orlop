#!/usr/bin/env node
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { createWriteStream } from 'fs';
import { pipeline } from 'stream/promises';
import fetch from 'node-fetch';
import tar from 'tar';
import toolsMetadata from './tools-metadata.json' assert { type: 'json' };

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

interface PlatformConfig {
  pattern: string;
  extractPath: string;
  noExtract?: boolean;
}

interface ToolMetadata {
  repo: string;
  binary: string;
  platforms: Record<string, PlatformConfig>;
}

const TOOLS: Record<string, ToolMetadata> = toolsMetadata as any;

function getPlatformKey(): string {
  const platform = process.platform;
  const arch = process.arch;

  const platformMap: Record<string, string> = {
    'linux-x64': 'linux-x64',
    'linux-arm64': 'linux-arm64',
    'darwin-x64': 'darwin-x64',
    'darwin-arm64': 'darwin-arm64',
  };

  const key = `${platform}-${arch}`;
  if (!platformMap[key]) {
    throw new Error(
      `Unsupported platform: ${platform}-${arch}. Supported: ${Object.keys(platformMap).join(', ')}`
    );
  }

  return platformMap[key];
}

async function fetchLatestRelease(repo: string): Promise<any> {
  const url = `https://api.github.com/repos/${repo}/releases/latest`;
  console.log(`Fetching latest release for ${repo}...`);

  const response = await fetch(url, {
    headers: {
      'User-Agent': '@vredchenko/orlop',
      Accept: 'application/vnd.github.v3+json',
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch release for ${repo}: ${response.statusText}`);
  }

  return response.json();
}

function findAsset(release: any, pattern: string, version: string): any {
  // Replace {version} placeholder with actual version (without 'v' prefix)
  const versionNumber = version.replace(/^v/, '');
  const regex = new RegExp(
    pattern
      .replace('{version}', versionNumber)
      .replace(/\./g, '\\.')
      .replace(/\{datetime\}/g, '\\d{4}-\\d{2}-\\d{2}T\\d{2}-\\d{2}-\\d{2}')
      .replace(/\{time\}/g, '\\d{2}:\\d{2}:\\d{2}')
  );

  const asset = release.assets.find((a: any) => regex.test(a.name));

  if (!asset) {
    console.error(`Available assets for ${release.name}:`);
    release.assets.forEach((a: any) => console.error(`  - ${a.name}`));
    throw new Error(`No asset found matching pattern: ${pattern}`);
  }

  return asset;
}

async function downloadFile(url: string, dest: string): Promise<void> {
  console.log(`Downloading to ${dest}...`);

  const response = await fetch(url, {
    headers: {
      'User-Agent': '@vredchenko/orlop',
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to download: ${response.statusText}`);
  }

  await fs.mkdir(path.dirname(dest), { recursive: true });
  await pipeline(response.body!, createWriteStream(dest));
}

async function extractTarGz(archivePath: string, outputDir: string, extractPath: string): Promise<string> {
  console.log(`Extracting ${archivePath}...`);

  await fs.mkdir(outputDir, { recursive: true });

  // Extract the archive
  await tar.x({
    file: archivePath,
    cwd: outputDir,
  });

  // Find the binary at the specified extract path
  const binaryPath = path.join(outputDir, extractPath);

  // Check if binary exists
  try {
    await fs.access(binaryPath);
  } catch (error) {
    throw new Error(`Binary not found at expected path: ${extractPath}`);
  }

  return binaryPath;
}

async function downloadTool(toolName: string, config: ToolMetadata, platformKey: string): Promise<void> {
  console.log(`\n📦 Installing ${toolName}...`);

  const platformConfig = config.platforms[platformKey];
  if (!platformConfig) {
    console.warn(`⚠️  ${toolName} not available for ${platformKey}, skipping`);
    return;
  }

  try {
    // Fetch latest release
    const release = await fetchLatestRelease(config.repo);
    const version = release.tag_name;

    console.log(`   Latest version: ${version}`);

    // Find matching asset
    const asset = findAsset(release, platformConfig.pattern, version);
    console.log(`   Found asset: ${asset.name}`);

    // Prepare download paths
    const rootDir = path.resolve(__dirname, '../..');
    const binDir = path.join(rootDir, 'bin', platformKey, toolName);
    const downloadPath = path.join(binDir, asset.name);

    // Download asset
    await downloadFile(asset.browser_download_url, downloadPath);

    // Extract or move binary
    let binaryPath: string;

    if (platformConfig.noExtract) {
      // No extraction needed (e.g., mc binary)
      binaryPath = path.join(binDir, config.binary);
      await fs.rename(downloadPath, binaryPath);
    } else if (asset.name.endsWith('.tar.gz') || asset.name.endsWith('.tgz')) {
      // Extract tar.gz
      binaryPath = await extractTarGz(downloadPath, binDir, platformConfig.extractPath);
      const finalPath = path.join(binDir, config.binary);
      await fs.rename(binaryPath, finalPath);
      binaryPath = finalPath;

      // Clean up archive
      await fs.unlink(downloadPath);
    } else if (asset.name.endsWith('.zip')) {
      // For .zip files (procs), we need unzip functionality
      // For now, skip or handle separately
      console.warn(`⚠️  ZIP extraction not yet implemented for ${toolName}`);
      return;
    } else {
      throw new Error(`Unsupported archive format: ${asset.name}`);
    }

    // Make binary executable
    await fs.chmod(binaryPath, 0o755);

    console.log(`   ✅ Installed ${toolName} → ${binaryPath}`);
  } catch (error) {
    console.error(`   ❌ Failed to install ${toolName}:`, error);
    throw error;
  }
}

async function main() {
  console.log('🚀 Orlop Binary Downloader\n');

  const platformKey = getPlatformKey();
  console.log(`Platform: ${platformKey}\n`);

  // Create bin directory
  const rootDir = path.resolve(__dirname, '../..');
  const binDir = path.join(rootDir, 'bin', platformKey);
  await fs.mkdir(binDir, { recursive: true });

  // Download all tools
  const errors: string[] = [];

  for (const [toolName, config] of Object.entries(TOOLS)) {
    try {
      await downloadTool(toolName, config, platformKey);
    } catch (error) {
      errors.push(toolName);
      console.error(`Failed to download ${toolName}:`, error);
    }
  }

  if (errors.length > 0) {
    console.error(`\n❌ Failed to download ${errors.length} tool(s): ${errors.join(', ')}`);
    process.exit(1);
  }

  console.log('\n✅ All tools downloaded successfully!');
}

// Run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

export { downloadTool, getPlatformKey, TOOLS };
