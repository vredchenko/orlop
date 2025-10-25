import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * starship - The minimal, blazing-fast, and infinitely customizable prompt for any shell
 * @see https://github.com/starship/starship
 */

export async function starship(command: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = [command, ...(options.args || [])];
  return execTool('starship', 'starship', args, options);
}

export function stream(command: string, options: ToolOptions = {}) {
  const args = [command, ...(options.args || [])];
  return execToolStream('starship', 'starship', args, options);
}

starship.stream = stream;

export default starship;
