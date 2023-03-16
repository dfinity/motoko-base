"use strict";

const { resolve } = require("path");
const { existsSync, writeFileSync, mkdirSync } = require("fs");
const glob = require("fast-glob");

const outDir = resolve(__dirname, "../generated");
if (!existsSync(outDir)) {
  mkdirSync(outDir);
}

const outFile = resolve(outDir, "ImportAll.test.mo");

const moFiles = glob.sync("**/*.mo", { cwd: resolve(__dirname, "../../src") });
if (moFiles.length === 0) {
  throw new Error("Expected at least one Motoko file in `src` directory");
}
const source = moFiles
  .map((f) => {
    const name = f.replace(/\.mo$/, "");
    return `import Import_${name} "mo:base/${name}";\n`;
  })
  .join("");

writeFileSync(outFile, source, "utf8");
