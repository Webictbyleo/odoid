import { defineConfig } from "tsup";

export default defineConfig([
  // ── Library builds: consumed by bundlers / Node.js ─────────────────────────
  {
    entry: ["src/index.ts"],
    format: ["esm", "cjs"],
    dts: true,
    clean: true,
    sourcemap: true,
    splitting: false,
    treeshake: true,
    minify: false,
  },

  // ── Browser IIFE — development (readable, source-mapped) ───────────────────
  {
    entry: ["src/index.ts"],
    format: ["iife"],
    globalName: "OdoID",
    outExtension: () => ({ js: ".iife.js" }),
    dts: false,
    sourcemap: true,
    splitting: false,
    treeshake: true,
    minify: false,
  },

  // ── Browser IIFE — production (minified, CDN default) ─────────────────────
  {
    entry: ["src/index.ts"],
    format: ["iife"],
    globalName: "OdoID",
    outExtension: () => ({ js: ".iife.min.js" }),
    dts: false,
    sourcemap: false,
    splitting: false,
    treeshake: true,
    minify: true,
  },
]);
