const fs = require("fs");
const path = require("path");

const directory = path.resolve(__dirname, "../src");

const names = fs
  .readdirSync(directory)
  .filter((f) => f.endsWith(".mo") && f !== "lib.mo")
  .map((f) => f.slice(0, -".mo".length));

const libSource = `
${names.map((n) => `import ${n}_ "${n}";`).join("\n")}

module Base {
${names.map((n) => `  public let ${n} = ${n}_;`).join("\n")}
}
`;

fs.writeFileSync(path.join(directory, "lib.mo"), libSource);

console.log(libSource);
