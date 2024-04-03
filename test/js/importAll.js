"use strict";

// Generate a test file named `ImportAll.test.mo`

const { join, resolve } = require("path");
const { existsSync, writeFileSync, mkdirSync } = require("fs");
const glob = require("fast-glob");
const execa = require("execa");

const outDir = resolve(__dirname, "../generated");
if (!existsSync(outDir)) {
  mkdirSync(outDir);
}

const baseFilename = "ImportAll.test";
const outFile = resolve(outDir, `${baseFilename}.mo`);

const moFiles = glob.sync("**/*.mo", { cwd: resolve(__dirname, "../../src") });
if (moFiles.length === 0) {
  throw new Error("Expected at least one Motoko file in `src` directory");
}
const source =
  moFiles
    .map((f) => {
      const name = f.replace(/\.mo$/, "");
      return `import _${name} "../../src/${name}";\n`;
    })
    .join("") + "\nactor {};";

writeFileSync(outFile, source, "utf8");

(async () => {
  const mocPath = process.env.DFX_MOC_PATH || "moc";
  const wasmFile = join(outDir, `${baseFilename}.wasm`);
  const { stdout, stderr } = await execa(mocPath, [outFile, "-o", wasmFile], {
    stdio: "pipe",
    encoding: "utf8",
  });
  console.log(stdout);
  if (stderr.trim()) {
    throw new Error(`Warning message while importing modules:\n${stderr}`);
  }
})();
