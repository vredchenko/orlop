import { execTool, execToolStream } from '../utils/exec.js';
import type { ToolOptions, ToolResult } from '../types.js';

/**
 * mc - MinIO Client for cloud storage and filesystems
 * @see https://github.com/minio/mc
 */

export async function mc(command: string, options: ToolOptions = {}): Promise<ToolResult> {
  const args = [command, ...(options.args || [])];
  return execTool('mc', 'mc', args, options);
}

export function stream(command: string, options: ToolOptions = {}) {
  const args = [command, ...(options.args || [])];
  return execToolStream('mc', 'mc', args, options);
}

mc.stream = stream;

export default mc;
