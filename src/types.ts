export interface ToolOptions {
  /**
   * Working directory for the command
   */
  cwd?: string;

  /**
   * Additional arguments to pass to the tool
   */
  args?: string[];

  /**
   * Input to pipe to stdin
   */
  input?: string;

  /**
   * Environment variables
   */
  env?: Record<string, string>;

  /**
   * Timeout in milliseconds
   */
  timeout?: number;

  /**
   * Text encoding (default: 'utf8')
   */
  encoding?: BufferEncoding;
}

export interface ToolResult {
  /**
   * Standard output from the command
   */
  stdout: string;

  /**
   * Standard error from the command
   */
  stderr: string;

  /**
   * Exit code (0 = success)
   */
  exitCode: number;

  /**
   * Full command that was executed
   */
  command: string;
}

export interface StreamOptions extends ToolOptions {
  /**
   * Whether to buffer output (default: false for streaming)
   */
  buffer?: boolean;
}
