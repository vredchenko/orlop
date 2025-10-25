import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * hyperfine - A command-line benchmarking tool
 * @see https://github.com/sharkdp/hyperfine
 */

export async function hyperfine(commands: string | string[], options: ToolOptions = {}): Promise<ToolResult> {
  const commandArgs = Array.isArray(commands) ? commands : [commands];
  const args = [...commandArgs, ...(options.args || [])];
  return execTool('hyperfine', 'hyperfine', args, options);
}

export function stream(commands: string | string[], options: ToolOptions = {}) {
  const commandArgs = Array.isArray(commands) ? commands : [commands];
  const args = [...commandArgs, ...(options.args || [])];
  return execToolStream('hyperfine', 'hyperfine', args, options);
}

hyperfine.stream = stream;

export default hyperfine;
