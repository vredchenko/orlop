import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * gh - GitHub CLI tool
 * @see https://github.com/cli/cli
 */

export async function gh(command: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = [command, ...(options.args || [])];
  return execTool('gh', 'gh', args, options);
}

export function stream(command: string, options: ToolOptions = {}) {
  const args = [command, ...(options.args || [])];
  return execToolStream('gh', 'gh', args, options);
}

gh.stream = stream;

export default gh;
