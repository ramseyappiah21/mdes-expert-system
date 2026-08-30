# Assignment checkpoints — CAAES

## 1. Chosen domain

**CSE Academic Advising Expert System (CAAES).**

The target user is an undergraduate Computer Engineering / Computer Science student (or a faculty advisor acting on that student’s behalf). The system helps them decide:

- which courses they are eligible to take next semester
- what credit load is safe given their standing
- whether they are ready for internship, Final Year Project, or graduation
- which career track and electives match their interests

Academic advising is a natural expert-system domain: the knowledge is a mix of rigid regulations (prerequisites, credit minima) and softer expert judgement (priority scoring, recovery advice).

## 2. Backward reasoning example

Asking “Is Ama eligible for CE301?” is naturally **backward** (goal-driven). The system starts from the goal `eligible_for(ama, ce301)` and works back to facts: the course exists, Ama has not already passed it, and every `prerequisite(ce301, Required)` is covered by `passed(ama, Required)`. Forward chaining from Ama’s entire transcript would also eventually notice CE301, but that is wasteful when the user already has one concrete question. Eligibility, graduation, and internship checks in the menu are all backward queries of this kind.

## 3. Explanation design

Every recommendation stores the conditions that fired, not a canned sentence.

- For an eligible course, `explain_course/3` collects satisfied rules: prerequisites met, core requirement, catch-up, interest match, gating value, level fit.
- For a rejected course, `explain_ineligible/3` lists already-passed status, missing direct prerequisites, and the shortest blocked ancestor path from the recursive graph.
- Standing and graduation reports print the numeric evidence (GPA, credits, outstanding cores, FYP status) and a one-line verdict.

The consultation report prints these lists under each recommended course so the live demo can show *why*, not only *what*.

## 4. Architecture (one page)

```
User  --questions-->  Consultation layer (validation + context)
                         |
                         v
                  Inference engine
                  (backward / forward / recursive)
                         |
                         v
                  Knowledge base  (facts + rules)
                         |
                         v
                  Explanation facility  -->  report / why-not
```

User answers become session facts (`passed(guest, ...)`, `declared_gpa(guest, ...)`, interests). The engine never asks the knowledge base to “guess”: missing input is either rejected, accepted as `unknown`, or replaced by a documented default (neutral CGPA 2.50).

## 5. Group roles

See `docs/Group_Roles.md`. Assign real names before submission.

## 6. Project plan

See `docs/Project_Plan.md`. Milestones map onto the 50-mark scheme: definition, knowledge base, rules, implementation, testing, documentation, demonstration.
