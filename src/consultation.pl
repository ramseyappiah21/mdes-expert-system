%==============================================================================
% CAAES — interactive consultation
% Asks context-dependent questions, asserts a session student, then advises.
%==============================================================================

:- use_module(library(lists)).

:- dynamic current_student/1.
:- dynamic session_flag/1.

session_student(guest).

clear_session :-
    retractall(current_student(_)),
    retractall(session_flag(_)),
    retractall(student(guest)),
    retractall(passed(guest, _)),
    retractall(declared_gpa(guest, _)),
    retractall(student_year(guest, _)),
    retractall(student_interest(guest, _)),
    retractall(grade(guest, _, _)).

begin_session :-
    clear_session,
    assertz(current_student(guest)),
    assertz(student(guest)).

%------------------------------------------------------------------------------
% Context-dependent interview
%------------------------------------------------------------------------------
run_consultation :-
    nl,
    banner_line,
    format('Interactive advising session~n', []),
    format('You may type quit at most prompts to return to the menu.~n', []),
    banner_line,
    begin_session,
    (   collect_profile
    ->  produce_advice(guest)
    ;   format('~nSession cancelled. Returning to the menu.~n', [])
    ),
    (   student(guest), \+ sample_student(guest)
    ->  retractall(student(guest))
    ;   true
    ).

sample_student(S) :-
    member(S, [ama, kwame, akosua, kofi, yaw, abena, kojo, efua]).

collect_profile :-
    ask_integer('What is your year of study?', 1, 4, Year),
    Year \= quit,
    assertz(student_year(guest, Year)),
    ask_float('What is your current CGPA? Type unknown if you are unsure', 0.0, 4.0, GPA0),
    GPA0 \= quit,
    (   GPA0 == unknown
    ->  default_gpa(unknown, GPA),
        format('Using a neutral default CGPA of ~2f until a real value is known.~n', [GPA])
    ;   GPA = GPA0
    ),
    assertz(declared_gpa(guest, GPA)),
    ask_choice('Which semester are you planning for?', [first, second], Semester),
    Semester \= quit,
    retractall(session_flag(semester(_))),
    assertz(session_flag(semester(Semester))),
    collect_completed_courses(Year),
    collect_interests(Year, GPA),
    collect_followups(Year, GPA), !.

collect_completed_courses(Year) :-
    (   Year =:= 1
    ->  Prompt = 'Which Level 100 courses have you already passed?'
    ;   Year =:= 2
    ->  Prompt = 'List Level 100/200 courses you have already passed.'
    ;   Prompt = 'List the major courses you have already passed (especially cores).'
    ),
    ask_course_list(Prompt, Codes),
    Codes \= quit,
    forall(member(C, Codes),
           (   passed(guest, C)
           ->  true
           ;   assertz(passed(guest, C))
           )).

collect_interests(Year, GPA) :-
    ask_choice('Which area interests you most right now?',
               [software, ai, security, networks, data, embedded, web, research],
               Interest0),
    Interest0 \= quit,
    assertz(student_interest(guest, Interest0)),
    (   Year >= 3
    ->  ask_yes_no('Would you like to add a second specialisation interest?', More),
        More \= quit,
        (   More == yes
        ->  ask_choice('Second interest?',
                       [software, ai, security, networks, data, embedded, web, research],
                       Interest1),
            Interest1 \= quit,
            (   Interest1 == Interest0
            ->  true
            ;   assertz(student_interest(guest, Interest1))
            )
        ;   true
        )
    ;   true
    ),
    (   GPA < 2.0
    ->  true
    ;   Year >= 3,
        Interest0 == ai
    ->  ask_yes_no('Are you comfortable with probability and statistics (MA202)?', Stats),
        Stats \= quit,
        (   Stats == yes
        ->  maybe_assert_passed(ma202)
        ;   Stats == no
        ->  assertz(session_flag(weak_statistics))
        ;   true
        )
    ;   true
    ).

collect_followups(Year, GPA) :-
    (   GPA < 2.0
    ->  ask_yes_no('Have you failed or scored D/E in a programming course (CE102/CE104)?', FailedProg),
        FailedProg \= quit,
        (   FailedProg == yes
        ->  assertz(session_flag(weak_programming))
        ;   true
        )
    ;   true
    ),
    (   Year >= 2
    ->  ask_yes_no('Have you passed Computer Programming II (CE104)?', P104),
        P104 \= quit,
        (   P104 == yes
        ->  maybe_assert_passed(ce104)
        ;   true
        )
    ;   true
    ),
    (   Year >= 3
    ->  ask_yes_no('Have you completed Software Engineering I (CE207)?', P207),
        P207 \= quit,
        (   P207 == yes
        ->  maybe_assert_passed(ce207)
        ;   true
        ),
        ask_yes_no('Are you aiming for an industrial internship this year?', Intern),
        Intern \= quit,
        (   Intern == yes
        ->  assertz(session_flag(wants_internship))
        ;   true
        )
    ;   true
    ),
    (   Year =:= 4
    ->  ask_yes_no('Have you passed Mini Project (CE310)?', P310),
        P310 \= quit,
        (   P310 == yes
        ->  maybe_assert_passed(ce310)
        ;   true
        ),
        ask_yes_no('Have you already registered Final Year Project I (CE406)?', P406),
        P406 \= quit,
        (   P406 == yes
        ->  maybe_assert_passed(ce406)
        ;   true
        )
    ;   true
    ),
    ask_yes_no('Do you want the system to keep your credit load conservative if you are at risk?', Conservative),
    Conservative \= quit,
    (   Conservative == no
    ->  assertz(session_flag(prefer_full_load))
    ;   true
    ).

maybe_assert_passed(Course) :-
    (   passed(guest, Course)
    ->  true
    ;   assertz(passed(guest, Course))
    ).

%------------------------------------------------------------------------------
% Advice report
%------------------------------------------------------------------------------
produce_advice(Student) :-
    session_flag(semester(Semester)),
    !,
    produce_advice(Student, Semester).
produce_advice(Student) :-
    produce_advice(Student, first).

produce_advice(Student, Semester) :-
    nl,
    banner_line,
    format('ADVISING REPORT~n', []),
    banner_line,
    print_profile(Student, Semester),
    nl,
    format('Academic standing~n', []),
    explain_standing(Student, StandLines),
    forall(member(L, StandLines), format('  ~w~n', [L])),
    nl,
    format('Next milestone~n', []),
    forall(next_milestone(Student, M), format('  - ~w~n', [M])),
    nl,
    format('Recommended actions~n', []),
    (   findall(A, support_action(Student, A), Actions),
        Actions \= []
    ->  forall(member(A, Actions), format('  - ~w~n', [A]))
    ;   format('  - Continue on the standard progression path.~n', [])
    ),
    (   session_flag(weak_programming)
    ->  format('  - Repeat or tutor CE102/CE104 before adding new programming electives.~n', [])
    ;   true
    ),
    (   session_flag(weak_statistics)
    ->  format('  - Take or revise MA202 before CE305/CE311.~n', [])
    ;   true
    ),
    nl,
    format('Semester plan (~w semester)~n', [Semester]),
    semester_plan_credits(Student, Semester, Plan, PlanCredits),
    (   Plan == []
    ->  format('  No eligible courses found for this semester. Check prerequisites.~n', [])
    ;   forall(member(C, Plan), (nl, print_course_card(Student, C))),
        format('~n  Planned load: ~w credits.~n', [PlanCredits])
    ),
    nl,
    format('Career alignment~n', []),
    (   primary_track(Student, Track)
    ->  format('  Suggested track: ~w~n', [Track]),
        forall(industry_suggestion(Student, Ind),
               format('  Related industry: ~w~n', [Ind]))
    ;   format('  Not enough interest data to lock a track. Software engineering is a safe default.~n', [])
    ),
    nl,
    format('Graduation snapshot~n', []),
    explain_graduation(Student, GradLines),
    forall(member(L, GradLines), format('  ~w~n', [L])),
    nl,
    banner_line,
    format('End of report. Ask a specific course from the menu if you want a deeper why/why-not.~n', []),
    banner_line,
    nl.

print_profile(Student, Semester) :-
    student_year(Student, Year),
    gpa(Student, GPA),
    credits_completed(Student, Credits),
    courses_completed_count(Student, Count),
    consultation_focus(Student, Focus),
    format('Student : ~w~n', [Student]),
    format('Year    : ~w     Semester: ~w     Focus: ~w~n', [Year, Semester, Focus]),
    format('CGPA    : ~2f   Credits completed: ~w (~w courses)~n', [GPA, Credits, Count]),
    findall(I, student_interest(Student, I), Interests),
    format('Interests: ~w~n', [Interests]).

%------------------------------------------------------------------------------
% Query a catalogue student
%------------------------------------------------------------------------------
query_known_student :-
    nl,
    ask_student('Which sample student should I advise?', Student),
    (   Student == quit
    ->  true
    ;   ask_choice('Which semester?', [first, second], Semester),
        (   Semester == quit
        ->  true
        ;   produce_advice(Student, Semester)
        )
    ).

%------------------------------------------------------------------------------
% Goal-driven eligibility check with explanation
%------------------------------------------------------------------------------
query_eligibility :-
    nl,
    ask_student('Student name', Student),
    Student \= quit, !,
    ask_course('Course to check', Course),
    Course \= quit,
    Course \= unknown, !,
    nl,
    upcase_course(Course, Display),
    course(Course, Title, Credits, Level),
    format('Backward query: eligible_for(~w, ~w)~n', [Student, Course]),
    format('~w — ~w (~w credits, level ~w)~n~n', [Display, Title, Credits, Level]),
    (   eligible_for(Student, Course)
    ->  format('Result: YES — ~w may register for ~w.~n~nWhy:~n', [Student, Display]),
        explain_course(Student, Course, Reasons),
        print_reason_list(Reasons)
    ;   format('Result: NO — ~w is not eligible for ~w.~n~nWhy not:~n', [Student, Display]),
        explain_ineligible(Student, Course, Reasons),
        print_reason_list(Reasons),
        (   missing_chain(Student, Course, Path)
        ->  format('~nShortest blocked prerequisite path:~n  ~w~n', [Path])
        ;   true
        )
    ),
    nl.
query_eligibility :-
    format('Query cancelled.~n', []).

%------------------------------------------------------------------------------
% What-if analysis
%------------------------------------------------------------------------------
query_what_if :-
    nl,
    ask_student('Student name', Student),
    Student \= quit, !,
    ask_course('Suppose this course is passed', Extra),
    Extra \= quit,
    Extra \= unknown, !,
    what_if_unlocks(Student, Extra, Newly),
    upcase_course(Extra, Display),
    format('~nIf ~w passes ~w, newly unlocked courses:~n', [Student, Display]),
    (   Newly == []
    ->  format('  None. Other prerequisites are still missing, or nothing waits on this course.~n', [])
    ;   forall(member(C, Newly), (
            course(C, Title, _, _),
            upcase_course(C, D),
            format('  - ~w  ~w~n', [D, Title])
        ))
    ),
    nl.
query_what_if :-
    format('Query cancelled.~n', []).

%------------------------------------------------------------------------------
% Prerequisite explorer (recursive)
%------------------------------------------------------------------------------
query_prereq_chain :-
    nl,
    ask_course('Show the prerequisite tree for which course?', Course),
    (   Course == quit
    ->  true
    ;   Course == unknown
    ->  format('A specific course code is required.~n', [])
    ;   upcase_course(Course, Display),
        format('~nRecursive prerequisite closure of ~w:~n', [Display]),
        findall(P, ancestor_prerequisite(Course, P), Raw),
        sort(Raw, Ancestors),
        (   Ancestors == []
        ->  format('  No prerequisites. This is a foundation course.~n', [])
        ;   forall(member(P, Ancestors), (
                upcase_course(P, D),
                course(P, Title, _, _),
                (   prerequisite(Course, P)
                ->  Tag = direct
                ;   Tag = ancestor
                ),
                format('  - ~w  ~w  (~w)~n', [D, Title, Tag])
            )),
            longest_prerequisite_path(Course, Depth),
            format('~nLongest prerequisite path length: ~w~n', [Depth])
        )
    ).

%------------------------------------------------------------------------------
% Forward inference demo
%------------------------------------------------------------------------------
demo_forward :-
    nl,
    ask_student('Run forward inference for which sample student?', Student),
    (   Student == quit
    ->  true
    ;   format('~nForward chaining from known facts about ~w...~n~n', [Student]),
        run_forward_steps(Student, StepFacts),
        forall(member(F, StepFacts), format('  Derived: ~w~n', [F])),
        nl,
        format('Aggregated profile (second forward pass):~n', []),
        forward_infer(Student),
        derived_facts(Student, Facts),
        forall(member(F, Facts), format('  ~w~n', [F])),
        nl
    ).

banner_line :-
    format('----------------------------------------------------------------~n', []).
