import { defineConfig } from 'tsup';
import { copyFileSync, mkdirSync } from 'fs';
import { dirname } from 'path';

export default defineConfig({
  entry: {
    index: 'src/index.ts',
    cli: 'src/cli.ts',
    'bin-wrapper': 'src/bin-wrapper.ts',
    'zx/index': 'src/zx/index.ts',
    'scripts/postinstall': 'src/scripts/postinstall.ts',
    'scripts/download-binaries': 'src/scripts/download-binaries.ts',
  },
  format: ['esm', 'cjs'],
  dts: true,
  splitting: false,
  sourcemap: true,
  clean: true,
  shims: true,
  onSuccess: async () => {
    // Copy tools-metadata.json to dist
    const src = 'src/scripts/tools-metadata.json';
    const dest = 'dist/scripts/tools-metadata.json';
    mkdirSync(dirname(dest), { recursive: true });
    copyFileSync(src, dest);
    console.log('Copied tools-metadata.json to dist/scripts/');
  },
});
