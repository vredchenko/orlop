import { describe, it, expect } from 'vitest';
import { getPlatformKey, isSupported } from './platform';

describe('platform utilities', () => {
  describe('getPlatformKey', () => {
    it('should return a valid platform key', () => {
      const key = getPlatformKey();
      expect(key).toMatch(/^(linux|darwin)-(x64|arm64)$/);
    });
  });

  describe('isSupported', () => {
    it('should return a boolean', () => {
      const supported = isSupported();
      expect(typeof supported).toBe('boolean');
    });
  });
});
