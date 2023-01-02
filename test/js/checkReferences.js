"use strict";

const { join } = require("path");
const { readFileSync } = require("fs");
const glob = require("fast-glob");

const srcDirectory = join(__dirname, "../../src");

// Detect "mo:base/..." imports within the base library itself (https://github.com/dfinity/motoko-base/pull/487)

glob.sync(join(srcDirectory, "**/*.mo")).forEach((srcPath) => {
  const source = readFileSync(srcPath, "utf8");
  source.split("\n").forEach((line, i) => {
    line = line.trim();
    if (
      line.includes('"mo:base') &&
      !line.startsWith("//") &&
      !line.endsWith("// ignore-reference-check")
    ) {
      console.error(
        `A possible reference to \`mo:base\` was found at ${srcPath}:${
          i + 1
        }\n\nIf this was intentional, consider adding an \`// ignore-reference-check\` comment to the end of the line.\nOtherwise, try removing the "mo:base/..." prefix in favor of a relative path.`
      );
      process.exit(1);
    }
  });
});
