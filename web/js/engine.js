(() => {
  const FILES = [
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

  let ready;
  let swipl;

  async function boot() {
    if (!window.SWIPL) throw new Error("SWI-Prolog WASM bundle is not loaded.");
    const engine = await window.SWIPL({ arguments: ["-q"] });
    try { engine.FS.mkdir("/src"); } catch { /* exists */ }
    try { engine.FS.mkdir("/src/domains"); } catch { /* exists */ }
    await Promise.all(FILES.map(async (rel) => {
      const res = await fetch(`/prolog/${rel}`);
      if (!res.ok) throw new Error(`Missing Prolog file ${rel}`);
      engine.FS.writeFile(`/src/${rel}`, await res.text());
    }));
    const loaded = engine.prolog.query("consult('/src/vercel_loader.pl').").once();
    if (loaded === false) throw new Error("Failed to consult the knowledge bases.");
    swipl = engine;
    window.mdesReady = true;
    return engine;
  }

  window.mdesBoot = () => {
    if (!ready) ready = boot();
    return ready;
  };

  window.mdesCall = async (method, path, body) => {
    await window.mdesBoot();
    swipl.FS.writeFile("/tmp/in.json", JSON.stringify(body || {}));
    const answer = swipl.prolog.query(
      "dispatch_files(Method, Path, '/tmp/in.json', '/tmp/out.json', Status).",
      { Method: method || "GET", Path: path }
    ).once();
    if (answer === false) throw new Error("API dispatch failed.");
    const raw = swipl.FS.readFile("/tmp/out.json", { encoding: "utf8" });
    const data = JSON.parse(raw);
    if ((Number(answer.Status) || 200) >= 400) {
      throw new Error(data.error || "Request failed.");
    }
    return data;
  };
})();
