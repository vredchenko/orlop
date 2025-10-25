import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * dust - A more intuitive version of du
 * @see https://github.com/bootandy/dust
 */

export async function dust(path?: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = path ? [path, ...(options.args || [])] : [...(options.args || [])];
  return execTool('dust', 'dust', args, options);
}

export function stream(path?: string, options: ToolOptions = {}) {
  const args = path ? [path, ...(options.args || [])] : [...(options.args || [])];
  return execToolStream('dust', 'dust', args, options);
}

dust.stream = stream;

export default dust;
