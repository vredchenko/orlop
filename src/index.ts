/**
 * @vredchenko/orlop - Modern CLI development tools with Node.js wrapper
 *
 * A collection of modern CLI tools packaged as an npm module with TypeScript/JavaScript wrappers.
 * All tools are downloaded during installation and work offline.
 *
 * @example
 * ```typescript
 * import { ripgrep, bat, fd } from '@vredchenko/orlop';
 *
 * // Search for pattern
 * const results = await ripgrep('TODO', { cwd: './src' });
 *
 * // View file with syntax highlighting
 * const content = await bat('README.md');
 *
 * // Find files
 * const files = await fd('\\.ts$', { cwd: './src' });
 * ```
 */

// Export all tool wrappers
export { default as ripgrep } from './tools/ripgrep.js';
export { default as bat } from './tools/bat.js';
export { default as fd } from './tools/fd.js';
export { default as delta } from './tools/delta.js';
export { default as lsd } from './tools/lsd.js';
export { default as gdu } from './tools/gdu.js';
export { default as fzf } from './tools/fzf.js';
export { default as starship } from './tools/starship.js';
export { default as tokei } from './tools/tokei.js';
export { default as hexyl } from './tools/hexyl.js';
export { default as hyperfine } from './tools/hyperfine.js';
export { default as procs } from './tools/procs.js';
export { default as gron } from './tools/gron.js';
export { default as glab } from './tools/glab.js';
export { default as gh } from './tools/gh.js';
export { default as dust } from './tools/dust.js';
export { default as mc } from './tools/mc.js';

// Export types
export type { ToolOptions, ToolResult, StreamOptions } from './types.js';

// Export utilities
export { getPlatformKey, isSupported } from './utils/platform.js';
export { getToolPath, getBinDir, getAllToolPaths } from './utils/paths.js';

// Named exports for individual tools (alternative import style)
import ripgrep from './tools/ripgrep.js';
import bat from './tools/bat.js';
import fd from './tools/fd.js';
import delta from './tools/delta.js';
import lsd from './tools/lsd.js';
import gdu from './tools/gdu.js';
import fzf from './tools/fzf.js';
import starship from './tools/starship.js';
import tokei from './tools/tokei.js';
import hexyl from './tools/hexyl.js';
import hyperfine from './tools/hyperfine.js';
import procs from './tools/procs.js';
import gron from './tools/gron.js';
import glab from './tools/glab.js';
import gh from './tools/gh.js';
import dust from './tools/dust.js';
import mc from './tools/mc.js';

export const tools = {
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
};

// Version (sync with package.json)
export const VERSION = '0.1.0';
