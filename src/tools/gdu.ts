import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * gdu - Fast disk usage analyzer with console interface
 * @see https://github.com/dundee/gdu
 */

export async function gdu(path?: string, options: ToolOptions = {}): Promise<ToolResult> {
  // Use --non-interactive flag for scripting
  const args = [
    '--non-interactive',
    ...(path ? [path] : []),
    ...(options.args || []),
  ];
  return execTool('gdu', 'gdu', args, options);
}

export function stream(path?: string, options: ToolOptions = {}) {
  const args = [
    '--non-interactive',
    ...(path ? [path] : []),
    ...(options.args || []),
  ];
  return execToolStream('gdu', 'gdu', args, options);
}

gdu.stream = stream;

export default gdu;
