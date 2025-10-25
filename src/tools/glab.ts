import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * glab - GitLab CLI tool
 * @see https://github.com/profclems/glab
 */

export async function glab(command: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = [command, ...(options.args || [])];
  return execTool('glab', 'glab', args, options);
}

export function stream(command: string, options: ToolOptions = {}) {
  const args = [command, ...(options.args || [])];
  return execToolStream('glab', 'glab', args, options);
}

glab.stream = stream;

export default glab;
