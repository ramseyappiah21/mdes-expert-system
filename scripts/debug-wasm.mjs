import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";

const SWIPL = createRequire(import.meta.url)("swipl-wasm");
const s = await SWIPL({ arguments: ["-q"] });

function list(p) {
  try {
    console.log(p, s.FS.readdir(p));
  } catch (e) {
    console.log(p, "ERR", e.errno, e.message);
  }
}

list("/");
try {
  s.FS.mkdir("/src");
  console.log("mkdir src ok");
} catch (e) {
  console.log("mkdir src", e.errno, e.message);
}
try {
  s.FS.mkdir("/src/domains");
  console.log("mkdir domains ok");
} catch (e) {
  console.log("mkdir domains", e.errno, e.message);
}
list("/src");

const root = path.resolve("src");
function walk(dir, rel = "") {
  const out = [];
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name);
    const next = rel ? `${rel}/${name}` : name;
    if (fs.statSync(full).isDirectory()) out.push(...walk(full, next));
    else if (name.endsWith(".pl")) out.push({ rel: next, full });
  }
  return out;
}

for (const file of walk(root)) {
  try {
    s.FS.writeFile(`/src/${file.rel}`, fs.readFileSync(file.full));
    console.log("wrote", file.rel);
  } catch (e) {
    console.log("WRITE FAIL", file.rel, e.errno, e.message);
    throw e;
  }
}

const loaded = s.prolog.query("consult('/src/vercel_loader.pl').").once();
console.log("consult", loaded);
