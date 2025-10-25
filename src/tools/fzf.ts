import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * fzf - A command-line fuzzy finder
 * @see https://github.com/junegunn/fzf
 */

export async function fzf(options: ToolOptions = {}): Promise<ToolResult> {
  return execTool('fzf', 'fzf', options.args || [], options);
}

export function stream(options: ToolOptions = {}) {
  return execToolStream('fzf', 'fzf', options.args || [], options);
}

fzf.stream = stream;

export default fzf;
