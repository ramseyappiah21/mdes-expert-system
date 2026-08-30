# CAAES demonstration script (5–10 minutes)

Record this sequence for the course video, then reuse it in the live session. Speak the **bold** lines; do the actions in `code`.

**Setup (before recording):** install SWI-Prolog, open a large terminal font, run `test.bat` once off-camera, then `run.bat`.

---

## 0:00–0:40  Opening

**“This is CAAES, a Prolog expert system for Computer Engineering academic advising. It uses more than five hundred facts and fifty logical rules. We will show user interaction, backward and forward inference, a recursive prerequisite chain, explanations, and error handling.”**

Show the main menu. Do not rush.

## 0:40–2:10  Backward reasoning + explanation

Choose `3`.

- Student: `yaw`
- Course: `CE301`

**“Yaw is a first-year student. The goal is eligible_for(yaw, ce301). Prolog works backward from that goal to the facts. The answer is no, because the prerequisite chain is incomplete. The explanation lists the missing courses rather than a single error code.”**

Leave the why-not list on screen for three seconds.

## 2:10–3:20  Recursive reasoning

Choose `4`. Course: `CE407`.

**“Final Year Project II does not name Introduction to Computing as a direct prerequisite. A recursive rule walks the graph: CE407 needs CE406, which needs CE310, and so on down to CE101. That is hierarchical reasoning over the curriculum.”**

Point at the longest-path length.

## 3:20–4:40  Forward reasoning

Choose `5`. Student: `kofi`.

**“Kofi’s transcript and declared CGPA of 1.70 are the data. Forward inference derives academic warning, a reduced credit load, catch-up courses, and support actions. We did not ask ‘is Kofi at risk?’ — the engine pushed that conclusion from the facts.”**

Optional: run Ama on the same menu if time remains, and contrast internship_ready.

## 4:40–6:40  Interactive session (happy path)

Choose `1`. Use a short, prepared transcript (year `3`, CGPA `3.4`, first semester, paste a compact passed-course list, interest `ai`).

**“Questions change with context. A third-year student is asked about internship and specialisation. A first-year student would not see those prompts.”**

Scroll the report. Read one course card out loud, including the reason bullets.

**“Each recommendation carries the satisfied rules: core requirement, interest match, and how many later courses it unlocks.”**

## 6:40–7:40  Error handling

From the menu, choose `3`.

- Type student `nobody` — show the rejection.
- Then student `ama`, course `ZZ100` — show the unknown-code message.
- Optionally type year `9` on a fresh option-1 session.

**“Unknown people, unknown courses, and out-of-range numbers are rejected with a repair prompt. The program does not crash and does not silently accept garbage.”**

## 7:40–8:40  What-if or sample plan

Choose `6`. Student `kwame`, course `CE201`.

**“If Kwame passes Data Structures, Algorithms and Theory of Computation become newly eligible. That is a hypothetical forward step used in planning.”**

or choose `2` / `ama` / `first` and show the semester plan.

## 8:40–9:30  Close

Choose `8` and let the self-checks print PASS lines.

**“The automated suite covers knowledge-base size, backward and recursive queries, standing, recommendations, and explanations. Documentation, the user manual, and slides are in the project folder. Thank you.”**

Exit with `9`.

---

## Live-session extras (if the examiner asks)

| Question | Where to go |
| --- | --- |
| Show a student who can almost graduate | Menu 2, `akosua` |
| Show missing cores in final year | Menu 2, `kojo` |
| Show graduation rule evidence | Any report’s graduation snapshot |
| Show the fact/rule files | Open `src/knowledge_base.pl` and `src/rules.pl` |
| Show architecture | `docs/System_Documentation.html` chapter 4 |

Keep one spare terminal with `swipl` already loaded (`consult('src/loader.pl')`) so a typed query such as `ancestor_prerequisite(ce407, X).` can be shown if asked.
