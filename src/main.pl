%==============================================================================
% MDES — Multi-Domain Expert System
% Entry point: swipl -s src/main.pl
%==============================================================================

:- prolog_load_context(directory, Dir),
   directory_file_path(Dir, 'loader.pl', Loader),
   consult(Loader).

:- initialization(start_system, main).

% Academic advising is domain 1. Its old top-level menu is now a submenu.
advising_menu :-
    nl,
    format('===============================================================~n', []),
    format('  Domain 1  CSE Academic Advising~n', []),
    format('===============================================================~n', []),
    format('  1  Interactive advising session~n', []),
    format('  2  Advise a sample student (Ama, Kwame, Akosua, ...)~n', []),
    format('  3  Backward query: is a student eligible for a course?~n', []),
    format('  4  Recursive query: prerequisite chain~n', []),
    format('  5  Forward inference demo~n', []),
    format('  6  What-if analysis (pass a course, see what unlocks)~n', []),
    format('  7  Catalogue / help~n', []),
    format('  8  Run built-in self checks~n', []),
    format('  9  Back to domain list~n', []),
    format('---------------------------------------------------------------~n', []),
    ask_integer('Select an option', 1, 9, Choice),
    (   Choice == quit
    ->  true
    ;   Choice =:= 9
    ->  true
    ;   handle_advising(Choice),
        advising_menu
    ).

handle_advising(1) :- run_consultation.
handle_advising(2) :- query_known_student.
handle_advising(3) :- query_eligibility.
handle_advising(4) :- query_prereq_chain.
handle_advising(5) :- demo_forward.
handle_advising(6) :- query_what_if.
handle_advising(7) :- show_help.
handle_advising(8) :- run_self_checks.

show_help :-
    nl,
    banner_line,
    format('HELP AND COURSE CATALOGUE~n', []),
    banner_line,
    format('CAAES recommends semester courses from a Computer Engineering~n', []),
    format('curriculum using prerequisites, academic standing, and interests.~n~n', []),
    format('Reasoning modes~n', []),
    format('  Backward : option 3 asks a yes/no eligibility goal and proves it.~n', []),
    format('  Forward  : option 5 derives standing, unlocks, and actions.~n', []),
    format('  Recursive: option 4 walks ancestor prerequisite chains.~n~n', []),
    format('Sample students: ama kwame akosua kofi yaw abena kojo efua~n~n', []),
    findall(Code, course(Code, _, _, _), Codes),
    length(Codes, N),
    format('Catalogue (~w courses):~n', [N]),
    sort(Codes, Sorted),
    forall(member(Code, Sorted), (
        course(Code, Title, Credits, Level),
        upcase_course(Code, Display),
        format('  ~w  L~w  ~wcr  ~w~n', [Display, Level, Credits, Title])
    )),
    nl.

run_self_checks :-
    nl,
    format('Running academic-advising consistency checks...~n', []),
    consult_self_check,
    format('Self-check finished.~n~n', []).

consult_self_check :-
    (   eligible_for(ama, ce301)
    ->  format('  PASS  ama is eligible for CE301~n', [])
    ;   format('  FAIL  ama should be eligible for CE301~n', [])
    ),
    (   \+ eligible_for(yaw, ce301)
    ->  format('  PASS  yaw is not eligible for CE301~n', [])
    ;   format('  FAIL  yaw must not be eligible for CE301~n', [])
    ),
    (   at_risk(kofi)
    ->  format('  PASS  kofi is at academic risk~n', [])
    ;   format('  FAIL  kofi should be at risk~n', [])
    ),
    (   ancestor_prerequisite(ce407, ce101)
    ->  format('  PASS  recursive chain CE407 requires CE101~n', [])
    ;   format('  FAIL  recursive chain CE407 -> CE101 missing~n', [])
    ),
    (   \+ can_graduate(kojo)
    ->  format('  PASS  kojo cannot yet graduate~n', [])
    ;   format('  FAIL  kojo should not graduate yet~n', [])
    ),
    (   internship_ready(ama)
    ->  format('  PASS  ama is internship-ready~n', [])
    ;   format('  FAIL  ama should be internship-ready~n', [])
    ).
