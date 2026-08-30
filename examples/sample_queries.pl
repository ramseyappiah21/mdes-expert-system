%==============================================================================
% Sample queries for the live demonstration and the documentation appendix.
% Start SWI-Prolog, consult the loader, then copy any query below.
%
%   swipl
%   ?- consult('src/loader.pl').
%==============================================================================

% --- Backward reasoning (goal-driven) ---
demo_backward :-
    format('Is Ama eligible for CE301?~n', []),
    (   eligible_for(ama, ce301)
    ->  format('  yes~n', [])
    ;   format('  no~n', [])
    ),
    format('Can Kojo graduate?~n', []),
    (   can_graduate(kojo)
    ->  format('  yes~n', [])
    ;   format('  no~n', [])
    ).

% --- Forward reasoning (data-driven) ---
demo_forward_ama :-
    forward_infer(ama),
    derived_facts(ama, Facts),
    forall(member(F, Facts), format('~w~n', [F])).

% --- Recursive reasoning ---
demo_recursive :-
    format('All ancestor prerequisites of CE407:~n', []),
    forall(ancestor_prerequisite(ce407, P), format('  ~w~n', [P])),
    (   shortest_prerequisite_path(ce407, ce101, Path)
    ->  format('A path from CE407 back to CE101: ~w~n', [Path])
    ;   format('No path found.~n', [])
    ).

% --- Recommendations ---
demo_plan_kofi :-
    semester_plan_credits(kofi, first, Courses, Credits),
    format('Kofi first-semester plan (~w credits): ~w~n', [Credits, Courses]).

demo_plan_ama :-
    semester_plan_credits(ama, first, Courses, Credits),
    format('Ama first-semester plan (~w credits): ~w~n', [Credits, Courses]).

% --- Explanations ---
demo_explain_yaw :-
    format('Why Yaw cannot take CE301:~n', []),
    explain_ineligible(yaw, ce301, Reasons),
    print_reason_list(Reasons).

demo_explain_ama :-
    format('Why Ama should take CE301:~n', []),
    explain_course(ama, ce301, Reasons),
    print_reason_list(Reasons).

% --- What-if ---
demo_what_if :-
    what_if_unlocks(kwame, ce201, Newly),
    format('If Kwame passes CE201, newly unlocked: ~w~n', [Newly]).
