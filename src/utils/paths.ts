import path from 'path';
import { fileURLToPath } from 'url';
import { getPlatformKey } from './platform.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Get the root directory of the package
 */
export function getPackageRoot(): string {
  // From src/utils/paths.ts, go up to package root
  return path.resolve(__dirname, '../..');
}

/**
 * Get the binary directory for the current platform
 */
export function getBinDir(): string {
  const root = getPackageRoot();
  const platformKey = getPlatformKey();
  return path.join(root, 'bin', platformKey);
}

/**
 * Get the path to a specific tool binary
 */
export function getToolPath(toolName: string, binaryName?: string): string {
  const binDir = getBinDir();
  const binary = binaryName || toolName;
  return path.join(binDir, toolName, binary);
}

/**
 * Get all tool binaries for the current platform
 */
export function getAllToolPaths(): Record<string, string> {
  const tools = [
    'ripgrep',
    'bat',
    'fd',
    'delta',
    'lsd',
    'gdu',
    'fzf',
    'starship',
    'tokei',
    'hexyl',
    'hyperfine',
    'procs',
    'gron',
    'glab',
    'gh',
    'dust',
    'mc',
  ];

  const binaryNames: Record<string, string> = {
    ripgrep: 'rg',
    bat: 'bat',
    fd: 'fd',
    delta: 'delta',
    lsd: 'lsd',
    gdu: 'gdu',
    fzf: 'fzf',
    starship: 'starship',
    tokei: 'tokei',
    hexyl: 'hexyl',
    hyperfine: 'hyperfine',
    procs: 'procs',
    gron: 'gron',
    glab: 'glab',
    gh: 'gh',
    dust: 'dust',
    mc: 'mc',
  };

  const paths: Record<string, string> = {};

  for (const tool of tools) {
    try {
      paths[tool] = getToolPath(tool, binaryNames[tool]);
    } catch (error) {
      // Tool might not be available on this platform
      console.warn(`Tool ${tool} not available: ${error}`);
    }
  }

  return paths;
}
