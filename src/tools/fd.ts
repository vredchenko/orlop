import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * fd - A simple, fast and user-friendly alternative to find
 * @see https://github.com/sharkdp/fd
 */

export async function fd(pattern?: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = pattern ? [pattern, ...(options.args || [])] : [...(options.args || [])];
  return execTool('fd', 'fd', args, options);
}

export function stream(pattern?: string, options: ToolOptions = {}) {
  const args = pattern ? [pattern, ...(options.args || [])] : [...(options.args || [])];
  return execToolStream('fd', 'fd', args, options);
}

fd.stream = stream;

export default fd;
