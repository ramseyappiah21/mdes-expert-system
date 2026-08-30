%==============================================================================
% CAAES — logical rule base (expert reasoning patterns)
% Each named rule encodes an advising decision used by inference and explanation.
%==============================================================================

:- use_module(library(lists)).

%------------------------------------------------------------------------------
% R01  has_passed/2
%------------------------------------------------------------------------------
has_passed(Student, Course) :-
    passed(Student, Course).

%------------------------------------------------------------------------------
% R02  missing_prerequisite/3
%------------------------------------------------------------------------------
missing_prerequisite(Student, Course, Missing) :-
    prerequisite(Course, Missing),
    \+ has_passed(Student, Missing).

%------------------------------------------------------------------------------
% R03  all_prerequisites_satisfied/2
%------------------------------------------------------------------------------
all_prerequisites_satisfied(Student, Course) :-
    forall(prerequisite(Course, Required), has_passed(Student, Required)).

%------------------------------------------------------------------------------
% R04  ancestor_prerequisite/2  (recursive prerequisite chain)
%------------------------------------------------------------------------------
ancestor_prerequisite(Course, Required) :-
    prerequisite(Course, Required).
ancestor_prerequisite(Course, Required) :-
    prerequisite(Course, Mid),
    ancestor_prerequisite(Mid, Required).

%------------------------------------------------------------------------------
% R05  prerequisite_depth/3  (recursive depth of a required course)
%------------------------------------------------------------------------------
prerequisite_depth(Course, Required, 1) :-
    prerequisite(Course, Required).
prerequisite_depth(Course, Required, Depth) :-
    prerequisite(Course, Mid),
    prerequisite_depth(Mid, Required, D0),
    Depth is D0 + 1.

%------------------------------------------------------------------------------
% R06  longest_prerequisite_path/2
%------------------------------------------------------------------------------
longest_prerequisite_path(Course, Depth) :-
    findall(D, prerequisite_depth(Course, _, D), Depths),
    (   Depths = []
    ->  Depth = 0
    ;   max_list(Depths, Depth)
    ).

%------------------------------------------------------------------------------
% R07  blocked_by_chain/3
%     Student cannot take Course because an ancestor prerequisite is missing.
%------------------------------------------------------------------------------
blocked_by_chain(Student, Course, Missing) :-
    ancestor_prerequisite(Course, Missing),
    \+ has_passed(Student, Missing).

%------------------------------------------------------------------------------
% R08  course_offered_now/2
%------------------------------------------------------------------------------
course_offered_now(Course, Semester) :-
    offered(Course, Semester).
course_offered_now(Course, _) :-
    offered(Course, both).

%------------------------------------------------------------------------------
% R09  eligible_for/2   (goal-driven / backward reasoning target)
%------------------------------------------------------------------------------
eligible_for(Student, Course) :-
    course(Course, _, _, CourseLevel),
    \+ has_passed(Student, Course),
    all_prerequisites_satisfied(Student, Course),
    progression_level(Student, StudentLevel),
    (   at_risk(Student)
    ->  CourseLevel =< StudentLevel
    ;   CourseLevel =< StudentLevel + 100
    ).

%------------------------------------------------------------------------------
% R10  eligible_this_semester/3
%------------------------------------------------------------------------------
eligible_this_semester(Student, Course, Semester) :-
    eligible_for(Student, Course),
    course_offered_now(Course, Semester).

%------------------------------------------------------------------------------
% R11  unlocked_course/2   (data-driven conclusion from passed courses)
%------------------------------------------------------------------------------
unlocked_course(Student, Course) :-
    eligible_for(Student, Course).

%------------------------------------------------------------------------------
% R12  credits_completed/2
%------------------------------------------------------------------------------
credits_completed(Student, Total) :-
    findall(C, (has_passed(Student, Code), course(Code, _, C, _)), Credits),
    sum_list(Credits, Total).

%------------------------------------------------------------------------------
% R13  courses_completed_count/2
%------------------------------------------------------------------------------
courses_completed_count(Student, Count) :-
    findall(Code, has_passed(Student, Code), Codes),
    sort(Codes, Unique),
    length(Unique, Count).

%------------------------------------------------------------------------------
% R14  computed_gpa/2
%------------------------------------------------------------------------------
computed_gpa(Student, GPA) :-
    findall(Point, (
        grade(Student, Course, Letter),
        has_passed(Student, Course),
        grade_point(Letter, Point)
    ), Points),
    Points \= [],
    sum_list(Points, Sum),
    length(Points, N),
    GPA is Sum / N.

%------------------------------------------------------------------------------
% R15  gpa/2   declared GPA overrides computed GPA when present
%------------------------------------------------------------------------------
gpa(Student, GPA) :-
    declared_gpa(Student, GPA), !.
gpa(Student, GPA) :-
    computed_gpa(Student, GPA), !.
gpa(_, 0.00).

%------------------------------------------------------------------------------
% R16  academic_standing/2
%------------------------------------------------------------------------------
academic_standing(Student, first_class) :-
    gpa(Student, GPA),
    standing_threshold(first_class, T),
    GPA >= T, !.
academic_standing(Student, second_upper) :-
    gpa(Student, GPA),
    standing_threshold(second_upper, T),
    GPA >= T, !.
academic_standing(Student, second_lower) :-
    gpa(Student, GPA),
    standing_threshold(second_lower, T),
    GPA >= T, !.
academic_standing(Student, third_class) :-
    gpa(Student, GPA),
    standing_threshold(third_class, T),
    GPA >= T, !.
academic_standing(Student, warning) :-
    gpa(Student, GPA),
    standing_threshold(warning, T),
    GPA >= T, !.
academic_standing(_, probation).

%------------------------------------------------------------------------------
% R17  at_risk/1
%------------------------------------------------------------------------------
at_risk(Student) :-
    academic_standing(Student, warning).
at_risk(Student) :-
    academic_standing(Student, probation).

%------------------------------------------------------------------------------
% R18  progression_level/2
%------------------------------------------------------------------------------
progression_level(Student, Level) :-
    student_year(Student, Year),
    year_level(Year, Level).

%------------------------------------------------------------------------------
% R19  catch_up_course/2
%     A lower-level unpassed course the student should complete first.
%------------------------------------------------------------------------------
catch_up_course(Student, Course) :-
    progression_level(Student, Level),
    course(Course, _, _, CourseLevel),
    CourseLevel < Level,
    core_course(Course),
    eligible_for(Student, Course).

%------------------------------------------------------------------------------
% R20  remaining_core/2
%------------------------------------------------------------------------------
remaining_core(Student, Course) :-
    core_course(Course),
    \+ has_passed(Student, Course).

%------------------------------------------------------------------------------
% R21  remaining_core_count/2
%------------------------------------------------------------------------------
remaining_core_count(Student, Count) :-
    findall(C, remaining_core(Student, C), Cs),
    sort(Cs, Unique),
    length(Unique, Count).

%------------------------------------------------------------------------------
% R22  electives_completed_count/2
%------------------------------------------------------------------------------
electives_completed_count(Student, Count) :-
    findall(C, (has_passed(Student, C), elective(C, _)), Cs),
    sort(Cs, Unique),
    length(Unique, Count).

%------------------------------------------------------------------------------
% R23  elective_requirement_met/1
%------------------------------------------------------------------------------
elective_requirement_met(Student) :-
    electives_completed_count(Student, Count),
    min_electives_required(Min),
    Count >= Min.

%------------------------------------------------------------------------------
% R24  matches_interest/2
%------------------------------------------------------------------------------
matches_interest(Student, Course) :-
    student_interest(Student, Interest),
    course_interest(Course, Interest).

%------------------------------------------------------------------------------
% R25  suggested_track/2
%------------------------------------------------------------------------------
suggested_track(Student, Track) :-
    career_track(Track),
    student_interest(Student, Interest),
    track_interest(Track, Interest).

%------------------------------------------------------------------------------
% R26  track_match_count/3
%------------------------------------------------------------------------------
track_match_count(Student, Track, Count) :-
    career_track(Track),
    findall(I, (
        student_interest(Student, I),
        track_interest(Track, I)
    ), Matches),
    length(Matches, Count),
    Count > 0.

%------------------------------------------------------------------------------
% R27  primary_track/2
%------------------------------------------------------------------------------
primary_track(Student, Track) :-
    findall(Count-T, track_match_count(Student, T, Count), Pairs),
    Pairs \= [],
    sort(0, @>=, Pairs, [BestCount-Track|_]),
    BestCount > 0.

%------------------------------------------------------------------------------
% R28  unlocks_count/2
%     How many not-yet-passed courses list Course as a direct prerequisite.
%------------------------------------------------------------------------------
unlocks_count(Student, Course, Count) :-
    findall(Next, (
        prerequisite(Next, Course),
        \+ has_passed(Student, Next)
    ), Nexts),
    sort(Nexts, Unique),
    length(Unique, Count).

%------------------------------------------------------------------------------
% R29  needed_for_later/2
%------------------------------------------------------------------------------
needed_for_later(Student, Course) :-
    unlocks_count(Student, Course, Count),
    Count >= 2.

%------------------------------------------------------------------------------
% R30  course_priority_score/3
%------------------------------------------------------------------------------
course_priority_score(Student, Course, Score) :-
    eligible_for(Student, Course),
    (core_course(Course) -> CorePts = 5 ; CorePts = 1),
    (matches_interest(Student, Course) -> InterestPts = 3 ; InterestPts = 0),
    (needed_for_later(Student, Course) -> GatePts = 2 ; GatePts = 0),
    (catch_up_course(Student, Course) -> CatchPts = 4 ; CatchPts = 0),
    course(Course, _, _, CourseLevel),
    progression_level(Student, StudentLevel),
    (   CourseLevel =:= StudentLevel
    ->  LevelPts = 2
    ;   CourseLevel < StudentLevel
    ->  LevelPts = 3
    ;   LevelPts = 0
    ),
    Score is CorePts + InterestPts + GatePts + CatchPts + LevelPts.

%------------------------------------------------------------------------------
% R31  recommended_course/3
%------------------------------------------------------------------------------
recommended_course(Student, Semester, Course) :-
    eligible_this_semester(Student, Course, Semester),
    course_priority_score(Student, Course, Score),
    Score >= 3.

%------------------------------------------------------------------------------
% R32  top_recommendations/4
%------------------------------------------------------------------------------
top_recommendations(Student, Semester, Limit, Courses) :-
    findall(Score-Course, (
        eligible_this_semester(Student, Course, Semester),
        course_priority_score(Student, Course, Score)
    ), Pairs),
    sort(0, @>=, Pairs, Sorted),
    extract_unique_courses(Sorted, [], Unique),
    prefix_limit(Unique, Limit, Courses).

extract_unique_courses([], Acc, Courses) :-
    reverse(Acc, Courses).
extract_unique_courses([_-Course|Rest], Acc, Courses) :-
    (   member(Course, Acc)
    ->  extract_unique_courses(Rest, Acc, Courses)
    ;   extract_unique_courses(Rest, [Course|Acc], Courses)
    ).

prefix_limit(List, Limit, Prefix) :-
    length(List, Len),
    (   Len =< Limit
    ->  Prefix = List
    ;   length(Prefix, Limit),
        append(Prefix, _, List)
    ).

%------------------------------------------------------------------------------
% R33  recommended_load/2
%------------------------------------------------------------------------------
recommended_load(Student, Credits) :-
    at_risk(Student),
    academic_standing(Student, Standing),
    recommended_credits(Standing, Credits), !.
recommended_load(_, Credits) :-
    recommended_credits(good_standing, Credits).

%------------------------------------------------------------------------------
% R34  overload_allowed/1
%------------------------------------------------------------------------------
overload_allowed(Student) :-
    gpa(Student, GPA),
    GPA >= 3.00,
    \+ at_risk(Student).

%------------------------------------------------------------------------------
% R35  internship_ready/1
%------------------------------------------------------------------------------
internship_ready(Student) :-
    student_year(Student, Year),
    Year >= 3,
    credits_completed(Student, Credits),
    internship_credit_minimum(Min),
    Credits >= Min,
    has_passed(Student, ce207),
    has_passed(Student, ce204),
    gpa(Student, GPA),
    GPA >= 2.50.

%------------------------------------------------------------------------------
% R36  fyp_eligible/1
%------------------------------------------------------------------------------
fyp_eligible(Student) :-
    student_year(Student, Year),
    Year >= 4,
    has_passed(Student, ce310),
    credits_completed(Student, Credits),
    fyp_credit_minimum(Min),
    Credits >= Min,
    \+ has_passed(Student, ce406).

%------------------------------------------------------------------------------
% R37  fyp_in_progress/1
%------------------------------------------------------------------------------
fyp_in_progress(Student) :-
    has_passed(Student, ce406),
    \+ has_passed(Student, ce407).

%------------------------------------------------------------------------------
% R38  can_graduate/1
%------------------------------------------------------------------------------
can_graduate(Student) :-
    credits_completed(Student, Credits),
    graduation_credit_minimum(MinCredits),
    Credits >= MinCredits,
    remaining_core_count(Student, 0),
    elective_requirement_met(Student),
    has_passed(Student, ce406),
    has_passed(Student, ce407),
    gpa(Student, GPA),
    good_standing_gpa(MinGPA),
    GPA >= MinGPA.

%------------------------------------------------------------------------------
% R39  near_graduation/1
%------------------------------------------------------------------------------
near_graduation(Student) :-
    student_year(Student, 4),
    remaining_core_count(Student, Remaining),
    Remaining =< 4,
    \+ can_graduate(Student).

%------------------------------------------------------------------------------
% R40  honors_eligible/1
%------------------------------------------------------------------------------
honors_eligible(Student) :-
    gpa(Student, GPA),
    honors_gpa(Min),
    GPA >= Min,
    remaining_core_count(Student, Remaining),
    Remaining =< 6.

%------------------------------------------------------------------------------
% R41  repeat_advised/2
%     A passed course with a weak grade that is a prerequisite for later work.
%------------------------------------------------------------------------------
repeat_advised(Student, Course) :-
    grade(Student, Course, Letter),
    grade_point(Letter, Point),
    Point =< 1.50,
    needed_for_later(Student, Course).

%------------------------------------------------------------------------------
% R42  suggested_elective/3
%------------------------------------------------------------------------------
suggested_elective(Student, Semester, Course) :-
    elective(Course, _),
    eligible_this_semester(Student, Course, Semester),
    matches_interest(Student, Course).

%------------------------------------------------------------------------------
% R43  level_appropriate/2
%------------------------------------------------------------------------------
level_appropriate(Student, Course) :-
    course(Course, _, _, CourseLevel),
    progression_level(Student, StudentLevel),
    CourseLevel =< StudentLevel.

%------------------------------------------------------------------------------
% R44  semester_plan_credits/4
%------------------------------------------------------------------------------
semester_plan_credits(Student, Semester, Courses, TotalCredits) :-
    recommended_load(Student, Target),
    max_credits_per_semester(Max),
    LimitCredits is min(Target, Max),
    top_recommendations(Student, Semester, 8, Ranked),
    pack_to_credit_limit(Ranked, LimitCredits, 0, [], Rev),
    reverse(Rev, Courses),
    findall(C, (member(Code, Courses), course(Code, _, C, _)), Cs),
    sum_list(Cs, TotalCredits).

pack_to_credit_limit([], _, _, Acc, Acc).
pack_to_credit_limit([Course|Rest], Limit, Used, Acc, Out) :-
    course(Course, _, C, _),
    Next is Used + C,
    (   Next =< Limit
    ->  pack_to_credit_limit(Rest, Limit, Next, [Course|Acc], Out)
    ;   pack_to_credit_limit(Rest, Limit, Used, Acc, Out)
    ).

%------------------------------------------------------------------------------
% R45  what_if_unlocks/3
%     If Student hypothetically passed Extra, which new courses become eligible?
%------------------------------------------------------------------------------
what_if_unlocks(Student, Extra, NewlyEligible) :-
    course(Extra, _, _, _),
    findall(Next, (
        prerequisite(Next, Extra),
        \+ has_passed(Student, Next),
        \+ eligible_for(Student, Next),
        forall((prerequisite(Next, Req), Req \= Extra), has_passed(Student, Req))
    ), Raw),
    sort(Raw, NewlyEligible).

%------------------------------------------------------------------------------
% R46  support_action/2
%------------------------------------------------------------------------------
support_action(Student, reduce_load) :-
    at_risk(Student).
support_action(Student, meet_academic_counsellor) :-
    academic_standing(Student, probation).
support_action(Student, repeat_weak_prerequisites) :-
    repeat_advised(Student, _).
support_action(Student, apply_for_internship) :-
    internship_ready(Student).
support_action(Student, register_final_year_project) :-
    fyp_eligible(Student).
support_action(Student, complete_final_year_project) :-
    fyp_in_progress(Student).
support_action(Student, prepare_graduation_audit) :-
    near_graduation(Student).
support_action(Student, consider_honours_pathway) :-
    honors_eligible(Student).

%------------------------------------------------------------------------------
% R47  warning_reason/2
%------------------------------------------------------------------------------
warning_reason(Student, low_gpa(GPA)) :-
    at_risk(Student),
    gpa(Student, GPA).
warning_reason(Student, missing_lower_level(Course)) :-
    catch_up_course(Student, Course).
warning_reason(Student, weak_prerequisite(Course)) :-
    repeat_advised(Student, Course).
warning_reason(Student, many_outstanding_cores(Count)) :-
    remaining_core_count(Student, Count),
    Count >= 8.

%------------------------------------------------------------------------------
% R48  next_milestone/2
%------------------------------------------------------------------------------
next_milestone(Student, complete_level_100) :-
    student_year(Student, 1).
next_milestone(Student, build_level_200_foundations) :-
    student_year(Student, 2),
    \+ at_risk(Student).
next_milestone(Student, recover_academic_standing) :-
    student_year(Student, Year),
    Year =< 2,
    at_risk(Student).
next_milestone(Student, choose_specialisation_and_internship) :-
    student_year(Student, 3).
next_milestone(Student, complete_fyp_and_graduation_cores) :-
    student_year(Student, 4),
    \+ can_graduate(Student).
next_milestone(Student, apply_for_graduation) :-
    can_graduate(Student).

%------------------------------------------------------------------------------
% R49  industry_suggestion/2
%------------------------------------------------------------------------------
industry_suggestion(Student, Industry) :-
    primary_track(Student, Track),
    track_industry(Track, Industry).

%------------------------------------------------------------------------------
% R50  consultation_focus/2
%     Context switch used by the interactive question planner.
%------------------------------------------------------------------------------
consultation_focus(Student, recovery) :-
    at_risk(Student), !.
consultation_focus(Student, graduation) :-
    student_year(Student, 4), !.
consultation_focus(Student, specialisation) :-
    student_year(Student, 3), !.
consultation_focus(Student, foundations) :-
    student_year(Student, Year),
    Year =< 2.
