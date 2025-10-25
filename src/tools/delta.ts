import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * delta - A syntax-highlighting pager for git, diff, and grep output
 * @see https://github.com/dandavison/delta
 */

export async function delta(options: ToolOptions = {}): Promise<ToolResult> {
  return execTool('delta', 'delta', options.args || [], options);
}

export function stream(options: ToolOptions = {}) {
  return execToolStream('delta', 'delta', options.args || [], options);
}

delta.stream = stream;

export default delta;
