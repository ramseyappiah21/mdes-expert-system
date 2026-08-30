# MDES — Multi-Domain Expert System

CE 474 Logic of Computer Science, Group Project 1  
University of Mines and Technology (UMaT)

One SWI-Prolog program with **all ten suggested domains** behind a single hub menu. Academic advising (CAAES) is domain 1; the other nine sit beside it with their own facts, rules, interviews, and explanations.

1. Academic advising (CSE)
2. Medical diagnosis
3. Career recommendation
4. Library recommendation
5. Cybersecurity incident response
6. Smart farming advisory
7. Vehicle fault diagnosis
8. Hotel recommendation
9. Legal consultation assistant
10. University admission advisory

Every domain can demonstrate backward, forward, and recursive reasoning. Shared validation handles yes/no/unknown, ranges, and quit. Medical and legal output is educational only.

## Requirements met

| Brief item | In this project |
| --- | --- |
| ≥ 80 facts | 529 knowledge-base fact clauses |
| ≥ 40 logical rules | 50 named rules in `src/rules.pl` |
| Forward reasoning | Menu 5; `forward_infer/1`, `run_forward_steps/2` |
| Backward reasoning | Menu 3; `eligible_for/2`, `can_graduate/1` |
| Recursive reasoning | Menu 4; `ancestor_prerequisite/2`, prerequisite paths |
| Interactive, context-dependent questions | Menu 1 |
| Explanations | Course cards, why-not lists, standing and graduation reports |
| Error handling | `src/validation.pl` |
| Tests | `test.bat` / `tests/test_suite.pl` |
| System documentation | `docs/System_Documentation.html` (print to PDF, 20–30 pages) |
| User manual | `docs/User_Manual.md` |
| Slides | `presentation/slides.html` |
| Demo video script | `presentation/demo_script.md` |

## Website

The public interface is a browser app served by the same SWI-Prolog engine. Each domain form posts to `/api/...`; the server proves the goal and returns the recommendation with explanations.

**Repository:** https://github.com/ramseyappiah21/mdes-expert-system

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/ramseyappiah21/mdes-expert-system)

Locally:

1. Install [SWI-Prolog](https://www.swi-prolog.org/Download.html).
2. Run `run-web.bat`, then open http://127.0.0.1:8080/
3. Or run the container:

```text
docker build -t mdes .
docker run --rm -p 8080:8080 mdes
```

The published image is `ghcr.io/ramseyappiah21/mdes-expert-system:latest` after the first successful Actions build. The server listens on `0.0.0.0` and uses the `PORT` environment variable (default 8080). For a permanent hostname, deploy the Dockerfile with the Render button above or `fly deploy`.

## Quick start (terminal)

1. Install SWI-Prolog and ensure `swipl` is on your PATH.
2. Run `run.bat`, or `swipl -s src/main.pl`.
3. Run `test.bat` before the live demonstration.

## Project layout

```text
src/            Advising core, hub menu, shared validation
src/domains/    The other nine expert-system domains
tests/          Automated test suite
docs/           Report, user manual, plan, roles, checkpoints
presentation/   Slides and 5–10 minute video script
examples/       Sample queries and a sample interview transcript
web/            Professional website
src/web_server.pl  HTTP server and JSON API
Dockerfile      Container image for hosting
run.bat         Start the terminal hub
run-web.bat     Start the website
test.bat        Run the test suite
```

## Sample students

`ama` `kwame` `akosua` `kofi` `yaw` `abena` `kojo` `efua`

Kofi demonstrates academic warning and a reduced load. Ama demonstrates internship readiness and an AI-aligned plan. Yaw demonstrates a failed backward eligibility query. CE407 demonstrates a long recursive prerequisite chain.

## Before you submit

1. Put real names in `docs/Group_Roles.md`.
2. Open `docs/System_Documentation.html` in a browser and print / save as PDF (A4).
3. Record the demonstration video from `presentation/demo_script.md`.
4. Rehearse the live demo: interaction, inference, explanation, and one invalid-input recovery.
