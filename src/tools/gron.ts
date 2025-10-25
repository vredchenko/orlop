import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * gron - Make JSON greppable
 * @see https://github.com/tomnomnom/gron
 */

export async function gron(file?: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = file ? [file, ...(options.args || [])] : [...(options.args || [])];
  return execTool('gron', 'gron', args, options);
}

export function stream(file?: string, options: ToolOptions = {}) {
  const args = file ? [file, ...(options.args || [])] : [...(options.args || [])];
  return execToolStream('gron', 'gron', args, options);
}

gron.stream = stream;

export default gron;
