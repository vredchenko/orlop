import { execa, type Options as ExecaOptions, type ExecaReturnValue } from 'execa';
import { getToolPath } from './paths.js';

export interface ExecOptions {
  cwd?: string;
  args?: string[];
  input?: string;
  env?: Record<string, string>;
  timeout?: number;
  encoding?: BufferEncoding;
}

export interface ExecResult {
  stdout: string;
  stderr: string;
  exitCode: number;
  command: string;
}

/**
 * Execute a tool binary with arguments
 */
export async function execTool(
  toolName: string,
  binaryName: string,
  args: string[] = [],
  options: ExecOptions = {}
): Promise<ExecResult> {
  const binaryPath = getToolPath(toolName, binaryName);

  const execaOptions: ExecaOptions = {
    cwd: options.cwd || process.cwd(),
    input: options.input,
    env: { ...process.env, ...options.env },
    timeout: options.timeout,
    encoding: (options.encoding || 'utf8') as 'utf8',
    reject: false, // Don't throw on non-zero exit codes
  };

  const result: ExecaReturnValue = await execa(binaryPath, args, execaOptions);

  return {
    stdout: result.stdout,
    stderr: result.stderr,
    exitCode: result.exitCode || 0,
    command: result.command,
  };
}

/**
 * Execute a tool binary and stream output
 */
export function execToolStream(
  toolName: string,
  binaryName: string,
  args: string[] = [],
  options: ExecOptions = {}
) {
  const binaryPath = getToolPath(toolName, binaryName);

  const execaOptions: ExecaOptions = {
    cwd: options.cwd || process.cwd(),
    input: options.input,
    env: { ...process.env, ...options.env },
    timeout: options.timeout,
    encoding: (options.encoding || 'utf8') as 'utf8',
    buffer: false, // Stream output instead of buffering
  };

  return execa(binaryPath, args, execaOptions);
}

/**
 * Check if a tool binary exists
 */
export async function toolExists(toolName: string, binaryName: string): Promise<boolean> {
  try {
    const binaryPath = getToolPath(toolName, binaryName);
    // Try to execute with --version or --help
    await execa(binaryPath, ['--version'], { timeout: 5000, reject: false });
    return true;
  } catch {
    return false;
  }
}
