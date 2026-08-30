%==============================================================================
% CAAES — inference engine
% Demonstrates backward (goal-driven), forward (data-driven), and recursive
% reasoning over the knowledge base.
%==============================================================================

:- use_module(library(lists)).

:- dynamic derived/2.
:- dynamic forward_trace/1.
:- dynamic current_student/1.

%------------------------------------------------------------------------------
% Backward reasoning
%   A goal such as eligible_for(Student, Course) is proven by matching rules
%   from the goal back to known facts (passed/2, prerequisite/2, ...).
%------------------------------------------------------------------------------
backward_query(eligible(Student, Course), yes) :-
    eligible_for(Student, Course), !.
backward_query(eligible(Student, Course), no) :-
    course(Course, _, _, _),
    student_known(Student),
    \+ eligible_for(Student, Course).

backward_query(graduate(Student), yes) :-
    can_graduate(Student), !.
backward_query(graduate(Student), no) :-
    student_known(Student),
    \+ can_graduate(Student).

backward_query(internship(Student), yes) :-
    internship_ready(Student), !.
backward_query(internship(Student), no) :-
    student_known(Student),
    \+ internship_ready(Student).

student_known(Student) :-
    student(Student).
student_known(Student) :-
    current_student(Student).

%------------------------------------------------------------------------------
% Recursive reasoning helpers used by explanations and demos
%------------------------------------------------------------------------------
prerequisite_path(Course, Required, [Course, Required]) :-
    prerequisite(Course, Required).
prerequisite_path(Course, Required, [Course|Path]) :-
    prerequisite(Course, Mid),
    prerequisite_path(Mid, Required, Path).

shortest_prerequisite_path(Course, Required, Path) :-
    findall(P, prerequisite_path(Course, Required, P), Paths),
    Paths \= [],
    map_list_to_pairs(length, Paths, Pairs),
    keysort(Pairs, [_-Path|_]).

missing_chain(Student, Course, MissingPath) :-
    findall(P, (
        ancestor_prerequisite(Course, Miss),
        \+ has_passed(Student, Miss),
        shortest_prerequisite_path(Course, Miss, P)
    ), Paths),
    Paths \= [],
    map_list_to_pairs(length, Paths, Pairs),
    keysort(Pairs, [_-MissingPath|_]).

%------------------------------------------------------------------------------
% Forward reasoning
%   Starting from known facts about a student, derive standing, unlocked
%   courses, milestones, and support actions. Newly derived conclusions are
%   asserted as derived/2 so the process is visibly data-driven.
%------------------------------------------------------------------------------
clear_derived(Student) :-
    retractall(derived(Student, _)),
    retractall(forward_trace(_)).

record_derived(Student, Fact) :-
    derived(Student, Fact), !.
record_derived(Student, Fact) :-
    assertz(derived(Student, Fact)),
    assertz(forward_trace(derived(Student, Fact))).

forward_infer(Student) :-
    clear_derived(Student),
    credits_completed(Student, Credits),
    record_derived(Student, credits(Credits)),
    gpa(Student, GPA),
    record_derived(Student, gpa(GPA)),
    academic_standing(Student, Standing),
    record_derived(Student, standing(Standing)),
    remaining_core_count(Student, Remaining),
    record_derived(Student, remaining_cores(Remaining)),
    findall(C, unlocked_course(Student, C), Unlocked0),
    sort(Unlocked0, Unlocked),
    record_derived(Student, unlocked(Unlocked)),
    (   internship_ready(Student)
    ->  record_derived(Student, internship_ready)
    ;   true
    ),
    (   fyp_eligible(Student)
    ->  record_derived(Student, fyp_eligible)
    ;   true
    ),
    (   fyp_in_progress(Student)
    ->  record_derived(Student, fyp_in_progress)
    ;   true
    ),
    (   can_graduate(Student)
    ->  record_derived(Student, can_graduate)
    ;   true
    ),
    (   near_graduation(Student)
    ->  record_derived(Student, near_graduation)
    ;   true
    ),
    (   honors_eligible(Student)
    ->  record_derived(Student, honors_eligible)
    ;   true
    ),
    (   primary_track(Student, Track)
    ->  record_derived(Student, primary_track(Track))
    ;   true
    ),
    findall(A, support_action(Student, A), Actions0),
    sort(Actions0, Actions),
    record_derived(Student, support_actions(Actions)),
    findall(M, next_milestone(Student, M), Miles0),
    sort(Miles0, Miles),
    record_derived(Student, milestones(Miles)).

derived_facts(Student, Facts) :-
    findall(F, derived(Student, F), Facts).

%------------------------------------------------------------------------------
% Agenda-style forward step used in the live demo
%   Each pass looks for a conclusion that is not yet recorded.
%------------------------------------------------------------------------------
forward_step(Student, standing(Standing)) :-
    \+ derived(Student, standing(_)),
    academic_standing(Student, Standing).
forward_step(Student, unlocked(Course)) :-
    unlocked_course(Student, Course),
    \+ derived(Student, unlocked(Course)).
forward_step(Student, internship_ready) :-
    internship_ready(Student),
    \+ derived(Student, internship_ready).
forward_step(Student, can_graduate) :-
    can_graduate(Student),
    \+ derived(Student, can_graduate).
forward_step(Student, support(Action)) :-
    support_action(Student, Action),
    \+ derived(Student, support(Action)).

run_forward_steps(Student, Derived) :-
    clear_derived(Student),
    forward_loop(Student),
    findall(F, derived(Student, F), Derived).

forward_loop(Student) :-
    forward_step(Student, Fact),
    record_derived(Student, Fact),
    !,
    forward_loop(Student).
forward_loop(_).
