import { describe, it, expect } from 'vitest';
import * as orlop from './index';

describe('orlop package exports', () => {
  it('should export tool functions', () => {
    expect(orlop.ripgrep).toBeDefined();
    expect(orlop.bat).toBeDefined();
    expect(orlop.fd).toBeDefined();
    expect(orlop.delta).toBeDefined();
    expect(orlop.lsd).toBeDefined();
    expect(orlop.gdu).toBeDefined();
    expect(orlop.fzf).toBeDefined();
    expect(orlop.starship).toBeDefined();
    expect(orlop.tokei).toBeDefined();
    expect(orlop.hexyl).toBeDefined();
    expect(orlop.hyperfine).toBeDefined();
    expect(orlop.procs).toBeDefined();
    expect(orlop.gron).toBeDefined();
    expect(orlop.glab).toBeDefined();
    expect(orlop.gh).toBeDefined();
    expect(orlop.dust).toBeDefined();
    expect(orlop.mc).toBeDefined();
  });

  it('should export utilities', () => {
    expect(orlop.getPlatformKey).toBeDefined();
    expect(orlop.isSupported).toBeDefined();
    expect(orlop.getToolPath).toBeDefined();
    expect(orlop.getBinDir).toBeDefined();
    expect(orlop.getAllToolPaths).toBeDefined();
  });

  it('should export VERSION', () => {
    expect(orlop.VERSION).toBeDefined();
    expect(typeof orlop.VERSION).toBe('string');
    expect(orlop.VERSION).toMatch(/^\d+\.\d+\.\d+$/);
  });

  it('should export tools object', () => {
    expect(orlop.tools).toBeDefined();
    expect(typeof orlop.tools).toBe('object');
    expect(Object.keys(orlop.tools).length).toBe(17);
  });
});
