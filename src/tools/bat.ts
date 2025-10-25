import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * bat - A cat clone with syntax highlighting and Git integration
 * @see https://github.com/sharkdp/bat
 */

export async function bat(file?: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = file ? [file, ...(options.args || [])] : [...(options.args || [])];
  return execTool('bat', 'bat', args, options);
}

export function stream(file?: string, options: ToolOptions = {}) {
  const args = file ? [file, ...(options.args || [])] : [...(options.args || [])];
  return execToolStream('bat', 'bat', args, options);
}

bat.stream = stream;

export default bat;
