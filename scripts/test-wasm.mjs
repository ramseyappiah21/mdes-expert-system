import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const SWIPL = require("swipl-wasm");
const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "src");

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

const t0 = Date.now();
const swipl = await SWIPL({ arguments: ["-q"] });
try { swipl.FS.mkdir("/src"); } catch { /* exists */ }
try { swipl.FS.mkdir("/src/domains"); } catch { /* exists */ }
for (const file of walk(root)) {
  swipl.FS.writeFile(`/src/${file.rel}`, fs.readFileSync(file.full));
}
const loaded = swipl.prolog.query("consult('/src/vercel_loader.pl').").once();
if (loaded === false) throw new Error("consult failed");
console.log(`boot_ms=${Date.now() - t0}`);

swipl.FS.writeFile("/tmp/in.json", "{}");
const health = swipl.prolog.query(
  "dispatch_files('GET','/api/health','/tmp/in.json','/tmp/out.json',Status)."
).once();
console.log("health", health.Status, swipl.FS.readFile("/tmp/out.json", { encoding: "utf8" }));

swipl.FS.writeFile("/tmp/in.json", '{"student":"ama","semester":"first"}');
const ama = swipl.prolog.query(
  "dispatch_files('POST','/api/advising/sample','/tmp/in.json','/tmp/out.json',Status)."
).once();
console.log("ama", ama.Status, swipl.FS.readFile("/tmp/out.json", { encoding: "utf8" }).slice(0, 160));
