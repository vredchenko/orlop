/**
 * zx integration for @vredchenko/orlop
 *
 * Provides direct tool executors for zx scripts using absolute paths.
 * No PATH modification - fully sandboxed to avoid conflicts with system tools.
 *
 * @example
 * ```typescript
 * #!/usr/bin/env zx
 * import { rg, bat, fd, $ } from '@vredchenko/orlop/zx';
 *
 * // Use direct tool functions (recommended)
 * await rg('TODO', './src');
 * await bat('README.md');
 *
 * // Or use toolPaths with zx $
 * import { toolPaths } from '@vredchenko/orlop/zx';
 * await $`${toolPaths.ripgrep} "TODO" ./src`;
 * ```
 */

import { getAllToolPaths } from '../utils/paths.js';
import { $ } from 'zx';

// Export $ from zx for convenience
export { $ };

// Export tool paths for direct access
export const toolPaths = getAllToolPaths();

/**
 * Create a zx-compatible executor for a specific tool
 */
function createToolExecutor(toolPath: string) {
  return async (...args: (string | number | boolean)[]) => {
    const stringArgs = args.map(arg => String(arg));
    return $`${toolPath} ${stringArgs}`;
  };
}

// Create direct executors for all tools (using absolute paths)
export const rg = createToolExecutor(toolPaths.ripgrep);
export const ripgrep = rg;

export const bat = createToolExecutor(toolPaths.bat);

export const fd = createToolExecutor(toolPaths.fd);

export const delta = createToolExecutor(toolPaths.delta);

export const lsd = createToolExecutor(toolPaths.lsd);

export const gdu = createToolExecutor(toolPaths.gdu);

export const fzf = createToolExecutor(toolPaths.fzf);

export const starship = createToolExecutor(toolPaths.starship);

export const tokei = createToolExecutor(toolPaths.tokei);

export const hexyl = createToolExecutor(toolPaths.hexyl);

export const hyperfine = createToolExecutor(toolPaths.hyperfine);

export const procs = createToolExecutor(toolPaths.procs);

export const gron = createToolExecutor(toolPaths.gron);

export const glab = createToolExecutor(toolPaths.glab);

export const gh = createToolExecutor(toolPaths.gh);

export const dust = createToolExecutor(toolPaths.dust);

export const mc = createToolExecutor(toolPaths.mc);

/**
 * Helper object with all orlop tools
 */
export const orlop = {
  rg,
  ripgrep,
  bat,
  fd,
  delta,
  lsd,
  gdu,
  fzf,
  starship,
  tokei,
  hexyl,
  hyperfine,
  procs,
  gron,
  glab,
  gh,
  dust,
  mc,
  /**
   * Get absolute path for any tool
   */
  path: (toolName: keyof typeof toolPaths) => toolPaths[toolName],
};

// Set verbose mode for debugging (optional)
if (process.env.ORLOP_DEBUG) {
  $.verbose = true;
}

export default orlop;
