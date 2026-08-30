# MDES / CAAES user manual

**Multi-Domain Expert System** (academic advising plus nine other domains)  
CE 474 — Logic of Computer Science, Group Project 1

## 0. Combined program

**Website:** run `run-web.bat`, then open http://127.0.0.1:8080/ in a browser. The page talks to the same Prolog knowledge bases.

**Terminal:** `run.bat` opens a hub. Choose one of the ten domains. Each domain has the same six actions: interactive interview, sample case, backward query, recursive query, forward demo, back to the hub.

| # | Domain | Built-in sample names |
| ---: | --- | --- |
| 1 | Academic advising | ama, kwame, akosua, kofi, yaw, abena, kojo, efua |
| 2 | Medical diagnosis | kwaku, adwoa, fiifi |
| 3 | Career recommendation | kwesi, akua, yawb |
| 4 | Library recommendation | ama_lib, kofi_lib, efua_lib |
| 5 | Cybersecurity | case_phish, case_ransom, case_ddos |
| 6 | Smart farming | plot_north, plot_wet, plot_dry |
| 7 | Vehicle faults | car_a, car_b, car_c |
| 8 | Hotel recommendation | g_business, g_beach, g_student |
| 9 | Legal consultation | c_rent, c_job, c_land |
| 10 | University admission | app_strong, app_arts, app_border |

Medical and legal modules are teaching tools, not professional advice. Hub option 12 runs a self-check on every domain.

## 1. What the advising domain does

CAAES (domain 1) advises undergraduate Computer Engineering students. It answers questions such as:

- Which courses may I take this semester, and why?
- Am I eligible for a named course?
- What is my academic standing and safe credit load?
- If I pass one more course, what becomes unlocked?
- Am I ready for internship, Final Year Project, or graduation?

It does **not** replace the official faculty handbook. Treat recommendations as reasoned advice over the project knowledge base.

## 2. Requirements

- Windows 10/11 (macOS and Linux also work)
- [SWI-Prolog](https://www.swi-prolog.org/Download.html) 8.x or newer
- This project folder

Confirm the installation:

```text
swipl --version
```

If that command is not found, add the SWI-Prolog `bin` directory to your PATH, then open a new terminal.

## 3. How to start

From the project root (`LOCS 2`):

```text
run.bat
```

or:

```text
swipl -s src/main.pl
```

The main menu appears:

```text
  1  Interactive advising session
  2  Advise a sample student (Ama, Kwame, Akosua, ...)
  3  Backward query: is a student eligible for a course?
  4  Recursive query: prerequisite chain
  5  Forward inference demo
  6  What-if analysis (pass a course, see what unlocks)
  7  Catalogue / help
  8  Run built-in self checks
  9  Exit
```

Type `quit` at most prompts to return to the menu or leave the program.

## 4. Menu options

### 4.1 Interactive advising (option 1)

Use this for a new student who is not already in the knowledge base.

The system asks, in order:

1. Year of study (1–4)
2. CGPA (0.00–4.00, or `unknown`)
3. Planning semester (`first` or `second`)
4. Passed course codes
5. Primary interest (and a second interest from year 3)
6. Follow-up questions that depend on year, GPA, and interest

**Context-dependent examples**

- Year 1 is not asked about internships or Final Year Project.
- CGPA below 2.00 triggers a programming-failure check.
- An AI-interested year-3 student is asked about MA202 comfort.
- Year 4 is asked about CE310 and CE406.

After the interview, CAAES prints a report: profile, standing, milestone, actions, a scored semester plan with reasons, career alignment, and a graduation snapshot.

### 4.2 Sample student (option 2)

Eight demonstration students are built in:

| Name | Year | Situation |
| --- | ---: | --- |
| ama | 3 | Strong record, AI / research, internship-ready |
| kwame | 2 | Level 100 complete, software / web |
| akosua | 4 | Near graduation, data track |
| kofi | 2 | Academic warning (CGPA 1.70) |
| yaw | 1 | Just starting |
| abena | 3 | Security / networks |
| kojo | 4 | Missing several cores |
| efua | 2 | Data-oriented |

Choose a name and a semester. The same report format as option 1 is used.

### 4.3 Backward eligibility query (option 3)

Ask a yes/no goal such as “Is Yaw eligible for CE301?”

- **YES** lists the rules that support registration.
- **NO** lists missing prerequisites and, when useful, the shortest blocked chain.

This is the cleanest way to demonstrate goal-driven (backward) inference.

### 4.4 Prerequisite chain (option 4)

Enter a course code. CAAES prints every ancestor prerequisite (recursive closure) and the length of the longest path. CE407 is a good live-demo example: it reaches back to CE101.

### 4.5 Forward inference demo (option 5)

Pick a sample student. The engine derives standing, unlocked courses, internship/FYP/graduation flags, support actions, and milestones from that student’s facts alone — data-driven inference.

### 4.6 What-if analysis (option 6)

Suppose Kwame passes CE201. The system lists courses that *become* eligible only after that extra fact, for example CE301 and CE303.

### 4.7 Help / catalogue (option 7)

Prints reasoning-mode notes, the sample-student list, and every course in the catalogue.

### 4.8 Self checks (option 8)

Runs a short on-screen sanity test (eligibility, risk, recursion, graduation, internship). For the full automated suite use `test.bat`.

## 5. How to answer prompts

| Prompt type | Accepted input | Rejected / recovered |
| --- | --- | --- |
| Yes / no | `yes`, `y`, `no`, `n`, `unknown`, `maybe`, `skip`, `quit` | Any other word is rejected and the question is repeated |
| Year | Integers 1–4 | `9` is rejected |
| CGPA | Number 0.00–4.00 or `unknown` | Out-of-range values are rejected; `unknown` becomes 2.50 |
| Course code | `CE301`, `ce301` | Codes not in the catalogue are rejected |
| Course list | Space- or comma-separated codes, or `none` | Unknown codes are listed; you may keep the valid ones |
| Menu number | Integer in the published range | Other text is rejected |

Empty answers are not treated as “yes”. The system asks again.

## 6. Reading a recommendation

Each planned course is printed as a card:

```text
  CE301  Algorithms
      3 credits, level 300, type core, priority score 12
  - All listed prerequisites have been passed.
  - CE301 is a core graduation requirement.
  - The course matches your stated interest in ...
  - Passing it unlocks N later course(s) in the curriculum graph.
```

**Priority score** (higher is better) adds points for: core status, interest match, gating value (unlocks later courses), catch-up of a lower level, and level fit.

**Safe load** is 18 credits in good standing, 15 on warning, and 12 on probation. Overload above the normal plan is only considered conceptually when CGPA ≥ 3.00 and the student is not at risk.

## 7. Query mode for developers

```text
swipl
?- consult('src/loader.pl').
?- eligible_for(ama, ce301).
?- ancestor_prerequisite(ce407, ce101).
?- academic_standing(kofi, S).
?- top_recommendations(ama, first, 5, Courses).
?- explain_ineligible(yaw, ce301, Reasons).
```

Ready-made demonstrations live in `examples/sample_queries.pl`.

## 8. Running the tests

```text
test.bat
```

or:

```text
swipl -q -s tests/test_suite.pl
```

A zero exit code means every automated case passed. The suite also prints the counted fact clauses and the number of named logical rules.

## 9. Troubleshooting

| Symptom | What to try |
| --- | --- |
| `'swipl' is not recognized` | Install SWI-Prolog and reopen the terminal; confirm `swipl --version` |
| System asks for `loader.pl` and fails | Start from the project root, not from a random folder |
| No courses in the semester plan | The student may lack prerequisites, or nothing is offered in that semester |
| Guest session seems to remember old answers | Restart option 1; the session store is cleared at the beginning of each interview |
| Prolog prints a permission error on `assertz` | Ensure you are using the project files as shipped (`:- dynamic` is declared for session predicates) |

## 10. Limits you should mention in a demo

- The curriculum is a self-contained teaching model inspired by a CSE programme; codes are not an official UMaT extract.
- Grades are used when present; otherwise a declared CGPA is trusted.
- `unknown` answers use documented defaults rather than inventing a transcript.
- Career-track suggestions are interest matches, not labour-market forecasts.
