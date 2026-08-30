# Project plan — CAAES (CE 474 Group Project 1)

Milestones follow the official marking scheme so each scored item has a named owner and a freeze date.

| Week | Dates (2026) | Milestone | Marking item | Exit criterion |
| ---: | --- | --- | --- | --- |
| 1 | 6–12 Jul | Problem definition and domain approval | Problem Definition (5) | Written justification: user, decisions, why Prolog |
| 2 | 13–19 Jul | Knowledge-base inventory | Knowledge Base Design (10) | ≥80 facts listed; catalogue and sample students drafted |
| 3 | 20–26 Jul | Rule design | Logical Rule Design (10) | ≥40 named rules with preconditions and conclusions |
| 4–5 | 27 Jul–9 Aug | Implementation | Implementation (10) | Interactive system loads in SWI-Prolog; three reasoning modes work |
| 6 | 10–16 Aug | Testing | Testing (5) | `test.bat` green; error-handling cases recorded |
| 7 | 17–23 Aug | Documentation freeze | Documentation (5) | 20–30 page report + user manual reviewed |
| 8 | 24–30 Aug | Presentation and demo | Presentation & Demonstration (5) | Slides, 5–10 min video, live-demo script rehearsed |

## Work packages

1. **Domain and architecture** — lock the student/course/career model and the input → inference → knowledge-base loop.
2. **Fact authoring** — courses, prerequisites, offerings, tracks, and eight sample students.
3. **Rule authoring** — eligibility, standing, load, internship, FYP, graduation, scoring.
4. **Engine and interface** — backward queries, forward derivation, recursive chains, consultation, explanations.
5. **Quality** — automated tests, invalid-input cases, documentation, slides, video script.

## Risks

| Risk | Effect | Mitigation |
| --- | --- | --- |
| Prerequisite graph has a cycle | Recursive rules do not terminate | Graph is a DAG; tests walk CE407 → CE101 |
| Too few facts or rules | Marks lost on KB / rule design | Suite prints counts; both sit well above the minima |
| Live demo stalls on bad input | Weak demonstration mark | Validation layer; rehearsed unknown/invalid answers |
| Group names missing from report | Formal completeness | `docs/Group_Roles.md` filled before binding |

## Status at 30 August 2026

Implementation, automated tests, system documentation, user manual, slides, and demo script are in this repository. Remaining group work is: write member names into the roles table, record the 5–10 minute video from the demo script, and rehearse the live session.
