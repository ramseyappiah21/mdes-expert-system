import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");
const dest = path.join(root, "public");
fs.rmSync(dest, { recursive: true, force: true });
fs.cpSync(path.join(root, "web"), dest, { recursive: true });

const prolog = path.join(dest, "prolog");
fs.mkdirSync(path.join(prolog, "domains"), { recursive: true });
const files = [
  "api_core.pl",
  "consultation.pl",
  "domain_kit.pl",
  "explanation.pl",
  "inference.pl",
  "knowledge_base.pl",
  "rules.pl",
  "validation.pl",
  "vercel_loader.pl",
  "domains/admission.pl",
  "domains/career.pl",
  "domains/cyber.pl",
  "domains/farming.pl",
  "domains/hotel.pl",
  "domains/legal.pl",
  "domains/library.pl",
  "domains/medical.pl",
  "domains/vehicle.pl"
];
for (const rel of files) {
  fs.copyFileSync(path.join(root, "src", rel), path.join(prolog, rel));
}

const swiplDir = path.join(dest, "swipl");
fs.mkdirSync(swiplDir, { recursive: true });
fs.copyFileSync(
  path.join(root, "node_modules", "swipl-wasm", "dist", "swipl", "swipl-bundle.js"),
  path.join(swiplDir, "swipl-bundle.js")
);
console.log(`Prepared static site in ${dest}`);
