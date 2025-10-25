export function getPlatformKey(): string {
  const platform = process.platform;
  const arch = process.arch;

  const platformMap: Record<string, string> = {
    'linux-x64': 'linux-x64',
    'linux-arm64': 'linux-arm64',
    'darwin-x64': 'darwin-x64',
    'darwin-arm64': 'darwin-arm64',
  };

  const key = `${platform}-${arch}`;
  if (!platformMap[key]) {
    throw new Error(
      `Unsupported platform: ${platform}-${arch}. Supported: ${Object.keys(platformMap).join(', ')}`
    );
  }

  return platformMap[key];
}

export function isSupported(): boolean {
  try {
    getPlatformKey();
    return true;
  } catch {
    return false;
  }
}
