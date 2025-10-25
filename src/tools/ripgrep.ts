import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * ripgrep (rg) - Fast text search tool
 * @see https://github.com/BurntSushi/ripgrep
 */

export async function ripgrep(pattern: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = [pattern, ...(options.args || [])];
  return execTool('ripgrep', 'rg', args, options);
}

export function stream(pattern: string, options: ToolOptions = {}) {
  const args = [pattern, ...(options.args || [])];
  return execToolStream('ripgrep', 'rg', args, options);
}

ripgrep.stream = stream;

export default ripgrep;
