const DOMAINS = [
  { id: "advising", n: "01", title: "Academic advising", blurb: "Courses, standing, internship and graduation for CSE students." },
  { id: "medical", n: "02", title: "Medical diagnosis", blurb: "Symptom interview and explained conditions. Educational only." },
  { id: "career", n: "03", title: "Career recommendation", blurb: "Match skills and interests to computing and related jobs." },
  { id: "library", n: "04", title: "Library recommendation", blurb: "Suggest titles from topic, reading level and a subject tree." },
  { id: "cyber", n: "05", title: "Cybersecurity response", blurb: "Classify an incident and emit a first-response playbook." },
  { id: "farming", n: "06", title: "Smart farming", blurb: "Crops, soil, rainfall, pests and rotation paths." },
  { id: "vehicle", n: "07", title: "Vehicle faults", blurb: "Workshop-style diagnosis from symptoms." },
  { id: "hotel", n: "08", title: "Hotel recommendation", blurb: "City, budget, purpose and amenities across Ghana." },
  { id: "legal", n: "09", title: "Legal consultation", blurb: "Classify a matter and list next steps. Educational only." },
  { id: "admission", n: "10", title: "University admission", blurb: "Programme eligibility from SHS track, aggregate and subjects." }
];

const state = { options: null, domain: null, view: "home" };

const $ = (id) => document.getElementById(id);

function route() {
  const hash = (location.hash || "#/").replace(/^#/, "") || "/";
  const path = hash.startsWith("/") ? hash : `/${hash}`;
  if (path === "/" || path === "") return showHome();
  if (path === "/about") return showAbout();
  const id = path.replace(/^\//, "").split("/")[0];
  if (DOMAINS.some((d) => d.id === id)) return showDomain(id);
  showHome();
}

function label(v) {
  return String(v).replaceAll("_", " ");
}

function sel(id, opts, extra = "") {
  return `<label for="${id}">${extra || label(id)}</label><select id="${id}">${opts.map((o) => `<option value="${o}">${label(o)}</option>`).join("")}</select>`;
}

function checks(id, opts) {
  return `<div class="checks" id="${id}">${opts.map((o) => `<label><input type="checkbox" value="${o}" /><span>${label(o)}</span></label>`).join("")}</div>`;
}

function checked(id) {
  return [...$(id).querySelectorAll("input:checked")].map((x) => x.value);
}

function yesMap(id) {
  const out = {};
  $(id).querySelectorAll("input").forEach((x) => { out[x.value] = x.checked ? "yes" : "no"; });
  return out;
}

async function api(path, body) {
  const res = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body || {})
  });
  const data = await res.json();
  if (!res.ok || data.error) throw new Error(data.error || res.statusText);
  return data;
}

function showResult(html) {
  $("result").innerHTML = html;
}

function banner(kind, text) {
  return `<div class="banner ${kind}">${text}</div>`;
}

function list(items) {
  if (!items || !items.length) return `<p class="muted">None.</p>`;
  return `<ul class="clean">${items.map((i) => `<li>${typeof i === "object" ? JSON.stringify(i) : label(i)}</li>`).join("")}</ul>`;
}

function showHome() {
  state.view = "home";
  state.domain = null;
  $("home").hidden = false;
  $("domainView").hidden = true;
  $("aboutView").hidden = true;
  $("domainGrid").innerHTML = DOMAINS.map((d) => `
    <article class="card pick" data-id="${d.id}">
      <div class="num">DOMAIN ${d.n}</div>
      <h3>${d.title}</h3>
      <p>${d.blurb}</p>
    </article>`).join("");
  $("domainGrid").onclick = (e) => {
    const card = e.target.closest("[data-id]");
    if (card) location.hash = `#/${card.dataset.id}`;
  };
}

function showAbout() {
  state.view = "about";
  $("home").hidden = true;
  $("domainView").hidden = true;
  $("aboutView").hidden = false;
}

function showDomain(id) {
  const d = DOMAINS.find((x) => x.id === id);
  state.view = "domain";
  state.domain = id;
  $("home").hidden = true;
  $("aboutView").hidden = true;
  $("domainView").hidden = false;
  if (!state.options) {
    $("panels").innerHTML = `<p class="err">Could not load the Prolog API.</p>`;
    $("tabs").innerHTML = "";
    return;
  }
  $("domainKicker").textContent = `Domain ${d.n}`;
  $("domainTitle").textContent = d.title;
  $("domainBlurb").textContent = d.blurb;
  $("result").innerHTML = "";
  const tabs = [
    ["consult", "Consult"],
    ["sample", "Sample case"],
    ["backward", "Backward"],
    ["recursive", "Recursive"],
    ["forward", "Forward"]
  ];
  $("tabs").innerHTML = tabs.map(([k, n], i) => `<button type="button" data-tab="${k}" class="${i === 0 ? "on" : ""}">${n}</button>`).join("");
  $("panels").innerHTML = tabs.map(([k], i) => `<div class="panel ${i === 0 ? "on" : ""}" id="panel-${k}">${panelHtml(id, k)}</div>`).join("");
  $("tabs").onclick = (e) => {
    const b = e.target.closest("button");
    if (!b) return;
    [...$("tabs").children].forEach((x) => x.classList.toggle("on", x === b));
    [...$("panels").children].forEach((p) => p.classList.toggle("on", p.id === `panel-${b.dataset.tab}`));
    $("result").innerHTML = "";
  };
  bindDomain(id);
}

function panelHtml(id, tab) {
  const o = state.options;
  if (id === "advising") return advisingHtml(tab, o);
  const spec = SPECS[id];
  if (!spec) return "";
  return spec[tab](o);
}

function advisingHtml(tab, o) {
  if (tab === "consult") {
    return `<div class="row">${sel("year", [1, 2, 3, 4], "Year")}${sel("semester", o.semesters, "Semester")}</div>
      <div class="row"><label>CGPA</label><input id="gpa" type="number" min="0" max="4" step="0.01" value="3.2" />${sel("interest", o.interests, "Interest")}</div>
      <label>Passed courses</label>${checks("courses", o.courses.map((c) => c.id))}
      <p><button class="btn primary" id="go">Get advice</button></p>`;
  }
  if (tab === "sample") {
    return `${sel("student", o.students, "Sample student")}${sel("semester2", o.semesters, "Semester")}
      <p><button class="btn primary" id="go">Advise</button></p>`;
  }
  if (tab === "backward") {
    return `${sel("student", o.students, "Student")}${sel("course", o.courses.map((c) => c.id), "Course")}
      <p><button class="btn primary" id="go">Ask eligibility</button></p>`;
  }
  if (tab === "recursive") {
    return `${sel("course", o.courses.map((c) => c.id), "Course")}
      <p><button class="btn primary" id="go">Show prerequisite chain</button></p>`;
  }
  return `${sel("student", o.students, "Student")}${sel("extra", o.courses.map((c) => c.id), "What-if passed course")}
    <p><button class="btn primary" id="goFwd">Forward demo</button>
       <button class="btn" id="goIf">What-if unlocks</button></p>`;
}

const SPECS = {
  medical: {
    consult: (o) => `<p class="muted">Tick symptoms and risk factors.</p>${checks("answers", ["fever","chills","headache","body_pain","photophobia","neck_stiffness","cough","sore_throat","shortness_of_breath","loss_of_smell","abdominal_pain","nausea","diarrhea","heartburn","mosquito_area","unsafe_water","recent_travel"])}<p><button class="btn primary" id="go">Assess</button></p>`,
    sample: (o) => `${sel("patient", o.medical_patients, "Patient")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("patient", o.medical_patients, "Patient")}${sel("target", o.medical_diseases, "Disease")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.medical_complications, "Start")}<p><button class="btn primary" id="go">Complication chain</button></p>`,
    forward: (o) => `${sel("patient", o.medical_patients, "Patient")}<p><button class="btn primary" id="go">Derive</button></p>`
  },
  career: {
    consult: (o) => `${sel("interest", o.career_interests, "Interest")}<label>Skills you have</label>${checks("answers", o.career_skills)}<p><button class="btn primary" id="go">Recommend</button></p>`,
    sample: (o) => `${sel("person", o.career_people, "Person")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("person", o.career_people, "Person")}${sel("target", o.career_jobs, "Job")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.career_ladder, "Start role")}<p><button class="btn primary" id="go">Ladder</button></p>`,
    forward: (o) => `${sel("person", o.career_people, "Person")}<p><button class="btn primary" id="go">Derive jobs</button></p>`
  },
  library: {
    consult: (o) => `${sel("topic", o.library_topics, "Topic")}${sel("level", [1, 2, 3, 4, 5], "Reading level")}<p><button class="btn primary" id="go">Recommend</button></p>`,
    sample: (o) => `${sel("reader", o.library_readers, "Reader")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("reader", o.library_readers, "Reader")}${sel("target", o.library_books, "Book")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.library_topics, "Topic")}<p><button class="btn primary" id="go">Broader topics</button></p>`,
    forward: (o) => `${sel("reader", o.library_readers, "Reader")}<p><button class="btn primary" id="go">Derive titles</button></p>`
  },
  cyber: {
    consult: (o) => `${checks("answers", o.cyber_indicators)}<p><button class="btn primary" id="go">Assess</button></p>`,
    sample: (o) => `${sel("case", o.cyber_cases, "Case")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("case", o.cyber_cases, "Case")}${sel("target", o.cyber_types, "Type")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.cyber_stages, "Stage")}<p><button class="btn primary" id="go">Later stages</button></p>`,
    forward: (o) => `${sel("case", o.cyber_cases, "Case")}<p><button class="btn primary" id="go">Playbook</button></p>`
  },
  farming: {
    consult: (o) => `${sel("soil", o.farm_soils, "Soil")}${sel("rain", o.farm_rains, "Rain")}<label>Pests seen</label>${checks("answers", o.farm_pests)}<p><button class="btn primary" id="go">Advise</button></p>`,
    sample: (o) => `${sel("plot", o.farm_plots, "Plot")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("plot", o.farm_plots, "Plot")}${sel("target", o.farm_crops, "Crop")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.farm_crops, "Start crop")}<p><button class="btn primary" id="go">Rotation</button></p>`,
    forward: (o) => `${sel("plot", o.farm_plots, "Plot")}<p><button class="btn primary" id="go">Derive crops</button></p>`
  },
  vehicle: {
    consult: (o) => `${checks("answers", o.veh_symptoms)}<p><button class="btn primary" id="go">Diagnose</button></p>`,
    sample: (o) => `${sel("car", o.vehicles, "Car")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("car", o.vehicles, "Car")}${sel("target", o.veh_faults, "Fault")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.veh_components, "Component")}<p><button class="btn primary" id="go">Dependencies</button></p>`,
    forward: (o) => `${sel("car", o.vehicles, "Car")}<p><button class="btn primary" id="go">Derive faults</button></p>`
  },
  hotel: {
    consult: (o) => `${sel("city", o.hotel_places, "Place")}<label>Budget (GHS)</label><input id="budget" type="number" value="500" />${sel("purpose", o.hotel_purposes, "Purpose")}<label>Required amenities</label>${checks("answers", o.hotel_amenities)}<p><button class="btn primary" id="go">Find hotels</button></p>`,
    sample: (o) => `${sel("guest", o.hotel_guests, "Guest")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("guest", o.hotel_guests, "Guest")}${sel("target", o.hotel_ids, "Hotel")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.hotel_places, "Place")}<p><button class="btn primary" id="go">Containing areas</button></p>`,
    forward: (o) => `${sel("guest", o.hotel_guests, "Guest")}<p><button class="btn primary" id="go">Derive hotels</button></p>`
  },
  legal: {
    consult: (o) => `<p class="muted">Educational only — not a lawyer.</p>${checks("answers", o.legal_facts)}<p><button class="btn primary" id="go">Classify</button></p>`,
    sample: (o) => `${sel("client", o.legal_clients, "Client")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("client", o.legal_clients, "Client")}${sel("target", o.legal_matters, "Matter")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.legal_courts, "Court")}<p><button class="btn primary" id="go">Higher courts</button></p>`,
    forward: (o) => `${sel("client", o.legal_clients, "Client")}<p><button class="btn primary" id="go">Derive matters</button></p>`
  },
  admission: {
    consult: (o) => `${sel("track", o.adm_tracks, "SHS track")}<label>Aggregate (lower is better)</label><input id="aggregate" type="number" min="6" max="36" value="12" /><label>Credit subjects</label>${checks("answers", o.adm_subjects)}<p><button class="btn primary" id="go">Check programmes</button></p>`,
    sample: (o) => `${sel("applicant", o.adm_applicants, "Applicant")}<p><button class="btn primary" id="go">Run case</button></p>`,
    backward: (o) => `${sel("applicant", o.adm_applicants, "Applicant")}${sel("target", o.adm_programmes, "Programme")}<p><button class="btn primary" id="go">Query</button></p>`,
    recursive: (o) => `${sel("start", o.adm_tracks, "Track")}<p><button class="btn primary" id="go">Feeder closure</button></p>`,
    forward: (o) => `${sel("applicant", o.adm_applicants, "Applicant")}<p><button class="btn primary" id="go">Derive programmes</button></p>`
  }
};

function bindDomain(id) {
  $("panels").onclick = async (e) => {
    if (e.target.id !== "go" && e.target.id !== "goFwd" && e.target.id !== "goIf") return;
    try {
      showResult(`<p class="muted">Reasoning…</p>`);
      if (id === "advising") await runAdvising(e.target.id);
      else await runSpec(id, e.target.id);
    } catch (err) {
      showResult(`<p class="err">${err.message}</p>`);
    }
  };
}

function renderAdvice(d) {
  const plan = (d.plan || []).map((c) => `
    <div class="course"><strong>${c.code}</strong> ${c.title}
      <div class="muted">${c.credits} credits · level ${c.level} · ${label(c.kind)} · score ${c.score}</div>
      ${list(c.reasons)}</div>`).join("");
  return `${banner("ok", `${label(d.student)} · year ${d.year} · CGPA ${Number(d.gpa).toFixed(2)} · ${d.plan_credits} planned credits`)}
    <div class="card"><h3>Standing</h3>${list(d.standing)}</div>
    <div class="card"><h3>Milestones and actions</h3>${list(d.milestones)}${list(d.actions)}</div>
    <div class="card"><h3>Semester plan</h3>${plan || "<p class='muted'>No eligible courses.</p>"}</div>
    <div class="card"><h3>Career / graduation</h3><p>Track: ${label(d.track)}</p>${list(d.industries)}${list(d.graduation)}</div>`;
}

async function runAdvising(btn) {
  const tab = document.querySelector(".tabs button.on").dataset.tab;
  if (tab === "consult" || (tab === "sample" && btn === "go")) {
    const data = tab === "consult"
      ? await api("/api/advising/consult", {
          year: Number($("year").value),
          gpa: Number($("gpa").value),
          semester: $("semester").value,
          interest: $("interest").value,
          courses: checked("courses")
        })
      : await api("/api/advising/sample", { student: $("student").value, semester: $("semester2").value });
    showResult(renderAdvice(data));
    return;
  }
  if (tab === "backward") {
    const d = await api("/api/advising/eligible", { student: $("student").value, course: $("course").value });
    showResult(`${banner(d.result === "yes" ? "ok" : "no", `${d.result.toUpperCase()} — ${d.course} ${d.title}`)}${list(d.reasons)}`);
    return;
  }
  if (tab === "recursive") {
    const d = await api("/api/advising/prereqs", { course: $("course").value });
    showResult(`${banner("ok", `${d.course} · longest path ${d.longest_path}`)}${list((d.ancestors || []).map((a) => `${a.id} — ${a.title} (${a.kind})`))}`);
    return;
  }
  if (btn === "goIf") {
    const d = await api("/api/advising/whatif", { student: $("student").value, course: $("extra").value });
    showResult(`${banner("ok", `If ${d.student} passes ${d.passed}`)}${list((d.unlocked || []).map((x) => `${x.id} — ${x.title}`))}`);
    return;
  }
  const d = await api("/api/advising/forward", { student: $("student").value });
  showResult(`<div class="card"><h3>Derived steps</h3>${list(d.steps)}</div><div class="card"><h3>Profile</h3>${list(d.profile)}</div>`);
}

function prettyGeneric(d) {
  const parts = [];
  if (d.disclaimer) parts.push(banner("warn", d.disclaimer));
  if (d.emergency === true) parts.push(banner("no", "Emergency-pattern symptoms are present."));
  if (d.result) parts.push(banner(d.result === "yes" ? "ok" : "no", `Result: ${d.result.toUpperCase()}`));
  if (d.primary && d.primary !== "none") parts.push(`<p><strong>Primary:</strong> ${label(d.primary)}</p>`);
  if (d.best && d.best !== "none") parts.push(`<p><strong>Best match:</strong> ${label(d.best)}</p>`);
  if (d.forum && d.forum !== "none") parts.push(`<p><strong>Forum:</strong> ${label(d.forum)}</p>`);
  const arrays = ["reasons", "complications", "matches", "books", "hotels", "programmes", "ranked", "playbook", "actions", "steps", "crops", "warnings", "jobs", "faults", "matters", "nodes", "facts", "tracks", "missing"];
  for (const k of arrays) {
    if (d[k] && d[k].length) {
      const items = d[k].map((x) => {
        if (typeof x !== "object") return label(x);
        return Object.entries(x).map(([a, b]) => `${label(a)}: ${label(b)}`).join(" · ");
      });
      parts.push(`<div class="card"><h3>${label(k)}</h3>${list(items)}</div>`);
    }
  }
  if (d.note) parts.push(`<p class="muted">${d.note}</p>`);
  return parts.join("") || `<pre>${JSON.stringify(d, null, 2)}</pre>`;
}

async function runSpec(id, btn) {
  const tab = document.querySelector(".tabs button.on").dataset.tab;
  const body = {};
  const grab = (key) => { const el = $(key); if (el) body[key] = el.type === "number" ? Number(el.value) : el.value; };
  ["patient", "person", "reader", "case", "plot", "car", "guest", "client", "applicant", "target", "start", "interest", "topic", "soil", "rain", "city", "purpose", "track"].forEach(grab);
  if ($("level")) body.level = Number($("level").value);
  if ($("budget")) body.budget = Number($("budget").value);
  if ($("aggregate")) body.aggregate = Number($("aggregate").value);
  if ($("answers")) body.answers = yesMap("answers");
  const path = tab === "sample" || tab === "consult" ? `/api/${id}/assess` : `/api/${id}/${tab}`;
  const data = await api(path, body);
  showResult(prettyGeneric(data));
}

async function boot() {
  $("homeBtn").onclick = () => { location.hash = "#/"; };
  $("brandLink").onclick = (e) => { e.preventDefault(); location.hash = "#/"; };
  window.addEventListener("hashchange", route);
  try {
    const res = await fetch("/api/options");
    state.options = await res.json();
  } catch (e) {
    $("domainGrid").innerHTML = `<p class="err">Could not load the Prolog API. Start the site with run-web.bat or the Docker image.</p>`;
    showHome();
    return;
  }
  route();
}

boot();
