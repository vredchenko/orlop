import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * lsd - The next gen ls command
 * @see https://github.com/lsd-rs/lsd
 */

export async function lsd(path?: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = path ? [path, ...(options.args || [])] : [...(options.args || [])];
  return execTool('lsd', 'lsd', args, options);
}

export function stream(path?: string, options: ToolOptions = {}) {
  const args = path ? [path, ...(options.args || [])] : [...(options.args || [])];
  return execToolStream('lsd', 'lsd', args, options);
}

lsd.stream = stream;

export default lsd;
