/**
 * zx integration for @vredchenko/orlop
 *
 * Import this module to automatically add orlop binaries to PATH for zx scripts.
 *
 * @example
 * ```typescript
 * #!/usr/bin/env zx
 * import '@vredchenko/orlop/zx';
 * import { $ } from 'zx';
 *
 * // All orlop tools now available in zx
 * const files = await $`rg "TODO" ./src`;
 * const content = await $`bat README.md`;
 * ```
 */

import { getBinDir, getAllToolPaths } from '../utils/paths.js';
import { $ } from 'zx';

// Add orlop bin directory to PATH
const binDir = getBinDir();
const currentPath = process.env.PATH || '';

if (!currentPath.includes(binDir)) {
  process.env.PATH = `${binDir}:${currentPath}`;
}

// Export enhanced $ with orlop tools in PATH
export { $ };

// Export tool paths for direct access
export const toolPaths = getAllToolPaths();

// Export utility to get binary directory
export { getBinDir };

/**
 * Create a tagged template for a specific orlop tool
 */
export function createToolTemplate(toolBinary: string) {
  return async (strings: TemplateStringsArray, ...values: any[]) => {
    const command = strings.reduce((acc, str, i) => {
      return acc + str + (values[i] !== undefined ? String(values[i]) : '');
    }, '');

    return $`${toolBinary} ${command}`;
  };
}

// Create convenience tagged templates for common tools
export const rg = createToolTemplate('rg');
export const bat = createToolTemplate('bat');
export const fd = createToolTemplate('fd');
export const lsd = createToolTemplate('lsd');
export const gdu = createToolTemplate('gdu');
export const tokei = createToolTemplate('tokei');
export const dust = createToolTemplate('dust');

/**
 * Helper to run orlop tools with zx
 */
export const orlop = {
  rg,
  bat,
  fd,
  lsd,
  gdu,
  tokei,
  dust,
  /**
   * Run any orlop tool
   */
  run: async (tool: string, ...args: string[]) => {
    return $`${tool} ${args}`;
  },
};

// Set verbose mode for debugging (optional)
if (process.env.ORLOP_DEBUG) {
  $.verbose = true;
}

export default orlop;
