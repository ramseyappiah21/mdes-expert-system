%==============================================================================
% CAAES — explanation facility
% Collects the conditions that justified a recommendation or decision.
%==============================================================================

:- use_module(library(lists)).

%------------------------------------------------------------------------------
% Why a student may take a course
%------------------------------------------------------------------------------
reason_for_course(Student, Course, 'All listed prerequisites have been passed.') :-
    all_prerequisites_satisfied(Student, Course).
reason_for_course(Student, Course, Reason) :-
    core_course(Course),
    \+ has_passed(Student, Course),
    upcase_course(Course, Display),
    format(atom(Reason), '~w is a core graduation requirement.', [Display]).
reason_for_course(Student, Course, Reason) :-
    catch_up_course(Student, Course),
    course(Course, _, _, Level),
    format(atom(Reason),
           'This ~w-level course is outstanding and should be completed before advancing.',
           [Level]).
reason_for_course(Student, Course, Reason) :-
    matches_interest(Student, Course),
    student_interest(Student, Interest),
    course_interest(Course, Interest),
    format(atom(Reason), 'The course matches your stated interest in ~w.', [Interest]).
reason_for_course(Student, Course, Reason) :-
    needed_for_later(Student, Course),
    unlocks_count(Student, Course, Count),
    format(atom(Reason),
           'Passing it unlocks ~w later course(s) in the curriculum graph.',
           [Count]).
reason_for_course(Student, Course, Reason) :-
    level_appropriate(Student, Course),
    course(Course, _, _, Level),
    format(atom(Reason), 'The course sits at level ~w, which matches your progression.', [Level]).

explain_course(Student, Course, Reasons) :-
    findall(R, reason_for_course(Student, Course, R), Raw),
    sort(Raw, Reasons).

%------------------------------------------------------------------------------
% Why a student is NOT eligible
%------------------------------------------------------------------------------
ineligibility_reason(Student, Course, Reason) :-
    has_passed(Student, Course),
    upcase_course(Course, Display),
    format(atom(Reason), 'You have already passed ~w.', [Display]).
ineligibility_reason(Student, Course, Reason) :-
    \+ has_passed(Student, Course),
    missing_prerequisite(Student, Course, Missing),
    upcase_course(Missing, MissDisplay),
    upcase_course(Course, CourseDisplay),
    format(atom(Reason), '~w is a direct prerequisite of ~w and is not yet passed.',
           [MissDisplay, CourseDisplay]).
ineligibility_reason(Student, Course, Reason) :-
    \+ has_passed(Student, Course),
    \+ missing_prerequisite(Student, Course, _),
    blocked_by_chain(Student, Course, Missing),
    missing_chain(Student, Course, Path),
    atomic_list_concat(Path, ' <- ', Chain),
    upcase_course(Missing, MissDisplay),
    format(atom(Reason),
           '~w is missing on the prerequisite chain ~w.',
           [MissDisplay, Chain]).

explain_ineligible(Student, Course, Reasons) :-
    findall(R, ineligibility_reason(Student, Course, R), Raw),
    sort(Raw, Reasons).

%------------------------------------------------------------------------------
% Standing / milestone explanations
%------------------------------------------------------------------------------
explain_standing(Student, Lines) :-
    gpa(Student, GPA),
    academic_standing(Student, Standing),
    format(atom(GPALine), 'Computed/declared GPA is ~2f.', [GPA]),
    standing_phrase(Standing, Phrase),
    format(atom(StandLine), 'Academic standing is classified as ~w (~w).', [Standing, Phrase]),
    findall(W, warning_reason(Student, W), Warnings),
    maplist(warning_line, Warnings, WarnLines),
    append([GPALine, StandLine], WarnLines, Lines).

standing_phrase(first_class, 'excellent — first class').
standing_phrase(second_upper, 'very good — second class upper').
standing_phrase(second_lower, 'good — second class lower').
standing_phrase(third_class, 'satisfactory — third class').
standing_phrase(warning, 'academic warning').
standing_phrase(probation, 'academic probation').

warning_line(low_gpa(GPA), Line) :-
    format(atom(Line), 'GPA ~2f is below the good-standing threshold of 2.00.', [GPA]).
warning_line(missing_lower_level(Course), Line) :-
    upcase_course(Course, Display),
    format(atom(Line), 'Outstanding lower-level course: ~w.', [Display]).
warning_line(weak_prerequisite(Course), Line) :-
    upcase_course(Course, Display),
    format(atom(Line), 'Weak grade in a gating prerequisite: ~w. A repeat is advised.', [Display]).
warning_line(many_outstanding_cores(Count), Line) :-
    format(atom(Line), 'There are still ~w outstanding core courses.', [Count]).

explain_graduation(Student, Lines) :-
    credits_completed(Student, Credits),
    graduation_credit_minimum(MinCredits),
    remaining_core_count(Student, Remaining),
    electives_completed_count(Student, Electives),
    min_electives_required(MinElectives),
    gpa(Student, GPA),
    format(atom(C1), 'Credits completed: ~w (minimum ~w).', [Credits, MinCredits]),
    format(atom(C2), 'Outstanding core courses: ~w.', [Remaining]),
    format(atom(C3), 'Electives completed: ~w (minimum ~w).', [Electives, MinElectives]),
    format(atom(C4), 'GPA: ~2f (minimum 2.00).', [GPA]),
    fyp_status_line(Student, C5),
    (   can_graduate(Student)
    ->  Verdict = 'Verdict: eligible to apply for graduation.'
    ;   Verdict = 'Verdict: not yet eligible for graduation.'
    ),
    Lines = [C1, C2, C3, C4, C5, Verdict].

fyp_status_line(Student, Line) :-
    has_passed(Student, ce406),
    has_passed(Student, ce407), !,
    Line = 'Final Year Project I and II are complete.'.
fyp_status_line(Student, Line) :-
    has_passed(Student, ce406), !,
    Line = 'Final Year Project I is complete; Project II is still outstanding.'.
fyp_status_line(_, 'Final Year Project I and II are outstanding.').

%------------------------------------------------------------------------------
% Pretty-print helpers
%------------------------------------------------------------------------------
upcase_course(Code, Display) :-
    upcase_atom(Code, Display).

print_reason_list([]) :-
    format('  (no additional reasons recorded)~n', []).
print_reason_list(Reasons) :-
    forall(member(R, Reasons), format('  - ~w~n', [R])).

print_course_card(Student, Course) :-
    course(Course, Title, Credits, Level),
    upcase_course(Course, Display),
    course_priority_score(Student, Course, Score),
    (   core_course(Course)
    ->  Kind = core
    ;   elective(Course, Group),
        Kind = Group
    ),
    format('  ~w  ~w~n', [Display, Title]),
    format('      ~w credits, level ~w, type ~w, priority score ~w~n',
           [Credits, Level, Kind, Score]),
    explain_course(Student, Course, Reasons),
    print_reason_list(Reasons).
