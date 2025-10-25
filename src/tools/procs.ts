import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * procs - A modern replacement for ps
 * @see https://github.com/dalance/procs
 */

export async function procs(options: ToolOptions = {}): Promise<ToolResult> {
  return execTool('procs', 'procs', options.args || [], options);
}

export function stream(options: ToolOptions = {}) {
  return execToolStream('procs', 'procs', options.args || [], options);
}

procs.stream = stream;

export default procs;
