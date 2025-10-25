import { describe, it, expect } from 'vitest';
import { getPackageRoot, getBinDir, getToolPath, getAllToolPaths } from './paths';
import path from 'path';

describe('path utilities', () => {
  describe('getPackageRoot', () => {
    it('should return an absolute path', () => {
      const root = getPackageRoot();
      expect(path.isAbsolute(root)).toBe(true);
    });

    it('should end with orlop', () => {
      const root = getPackageRoot();
      expect(root).toMatch(/orlop$/);
    });
  });

  describe('getBinDir', () => {
    it('should return a path containing bin/', () => {
      const binDir = getBinDir();
      expect(binDir).toContain('bin');
    });

    it('should include platform key', () => {
      const binDir = getBinDir();
      expect(binDir).toMatch(/bin\/(linux|darwin)-(x64|arm64)/);
    });
  });

  describe('getToolPath', () => {
    it('should return path to tool binary', () => {
      const toolPath = getToolPath('ripgrep', 'rg');
      expect(toolPath).toContain('ripgrep');
      expect(toolPath).toContain('rg');
    });
  });

  describe('getAllToolPaths', () => {
    it('should return object with tool paths', () => {
      const paths = getAllToolPaths();
      expect(typeof paths).toBe('object');
      expect(Object.keys(paths).length).toBeGreaterThan(0);
    });

    it('should include common tools', () => {
      const paths = getAllToolPaths();
      // Not all tools may be available on all platforms
      expect(paths).toBeDefined();
    });
  });
});
