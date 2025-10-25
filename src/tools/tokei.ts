import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * tokei - Count your code, quickly
 * @see https://github.com/XAMPPRocky/tokei
 */

export async function tokei(path?: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = path ? [path, ...(options.args || [])] : [...(options.args || [])];
  return execTool('tokei', 'tokei', args, options);
}

export function stream(path?: string, options: ToolOptions = {}) {
  const args = path ? [path, ...(options.args || [])] : [...(options.args || [])];
  return execToolStream('tokei', 'tokei', args, options);
}

tokei.stream = stream;

export default tokei;
