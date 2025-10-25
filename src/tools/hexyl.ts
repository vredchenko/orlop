import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * hexyl - A command-line hex viewer
 * @see https://github.com/sharkdp/hexyl
 */

export async function hexyl(file: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = [file, ...(options.args || [])];
  return execTool('hexyl', 'hexyl', args, options);
}

export function stream(file: string, options: ToolOptions = {}) {
  const args = [file, ...(options.args || [])];
  return execToolStream('hexyl', 'hexyl', args, options);
}

hexyl.stream = stream;

export default hexyl;
