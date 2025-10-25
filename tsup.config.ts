import { defineConfig } from 'tsup';

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
});
