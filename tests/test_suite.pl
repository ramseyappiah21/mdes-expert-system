%==============================================================================
% CAAES test suite
% Run from the project root:
%   swipl -q -s tests/test_suite.pl
%==============================================================================

:- prolog_load_context(directory, Here),
   file_directory_name(Here, Root),
   directory_file_path(Root, 'src/loader.pl', Loader),
   consult(Loader).

:- dynamic failed/1.
:- initialization(run_all_tests, main).

run_all_tests :-
    retractall(failed(_)),
    format('~nCAAES test suite~n', []),
    format('----------------~n', []),
    run_group('Knowledge base size', [
        test_course_count,
        test_minimum_facts,
        test_minimum_rules
    ]),
    run_group('Backward reasoning', [
        test_ama_eligible_ce301,
        test_yaw_not_eligible_ce301,
        test_kwame_eligible_ce201,
        test_already_passed_not_eligible
    ]),
    run_group('Recursive reasoning', [
        test_chain_ce407_to_ce101,
        test_direct_vs_ancestor,
        test_longest_path_positive
    ]),
    run_group('Forward / derived conclusions', [
        test_kofi_at_risk,
        test_kofi_not_400_level,
        test_ama_internship,
        test_kojo_not_graduate,
        test_akosua_near_graduation,
        test_yaw_foundations_focus
    ]),
    run_group('Recommendations and scoring', [
        test_top_recs_ama_first,
        test_kofi_reduced_load,
        test_what_if_kwame_ce201
    ]),
    run_group('Explanations', [
        test_explain_eligible,
        test_explain_ineligible
    ]),
    run_group('Validation helpers', [
        test_yes_no_tokens,
        test_course_normalise
    ]),
    run_group('Other domains', [
        test_medical_malaria,
        test_career_data_science,
        test_library_topic_tree,
        test_cyber_ransomware,
        test_farming_rice,
        test_vehicle_battery,
        test_hotel_tarkwa,
        test_legal_tenancy,
        test_admission_ce
    ]),
    summarise.

run_group(Title, Tests) :-
    format('~n[~w]~n', [Title]),
    maplist(run_one, Tests).

run_one(Test) :-
    (   catch(call(Test), Error, (print_message(error, Error), fail))
    ->  format('  PASS  ~w~n', [Test])
    ;   format('  FAIL  ~w~n', [Test]),
        assertz(failed(Test))
    ).

summarise :-
    findall(T, failed(T), Failed),
    length(Failed, N),
    nl,
    (   N =:= 0
    ->  format('All tests passed.~n~n', []),
        halt(0)
    ;   format('~w test(s) failed: ~w~n~n', [N, Failed]),
        halt(1)
    ).

%------------------------------------------------------------------------------
% Size checks (assignment: >= 80 facts, >= 40 rules)
%------------------------------------------------------------------------------
kb_fact_head(department(_)).
kb_fact_head(career_track(_)).
kb_fact_head(interest(_)).
kb_fact_head(track_interest(_, _)).
kb_fact_head(industry(_)).
kb_fact_head(track_industry(_, _)).
kb_fact_head(course(_, _, _, _)).
kb_fact_head(offered(_, _)).
kb_fact_head(course_department(_, _)).
kb_fact_head(core_course(_)).
kb_fact_head(elective(_, _)).
kb_fact_head(prerequisite(_, _)).
kb_fact_head(course_interest(_, _)).
kb_fact_head(skill(_)).
kb_fact_head(course_skill(_, _)).
kb_fact_head(lecturer(_, _)).
kb_fact_head(standing_threshold(_, _)).
kb_fact_head(year_level(_, _)).
kb_fact_head(grade_point(_, _)).
kb_fact_head(student(_)).
kb_fact_head(student_year(_, _)).
kb_fact_head(student_interest(_, _)).
kb_fact_head(passed(_, _)).
kb_fact_head(grade(_, _, _)).

test_course_count :-
    findall(C, course(C, _, _, _), Cs),
    length(Cs, N),
    N >= 40.

count_matching_facts(Count) :-
    findall(1, (kb_fact_head(H), clause(H, true)), L),
    length(L, Count).

test_minimum_facts :-
    count_matching_facts(N),
    format('       fact clauses counted: ~w~n', [N]),
    N >= 80.

% Rules are defined as named predicates in rules.pl; count compiled clauses
% that are not unit facts from the knowledge base.
rule_pred(has_passed/2).
rule_pred(missing_prerequisite/3).
rule_pred(all_prerequisites_satisfied/2).
rule_pred(ancestor_prerequisite/2).
rule_pred(prerequisite_depth/3).
rule_pred(longest_prerequisite_path/2).
rule_pred(blocked_by_chain/3).
rule_pred(course_offered_now/2).
rule_pred(eligible_for/2).
rule_pred(eligible_this_semester/3).
rule_pred(unlocked_course/2).
rule_pred(credits_completed/2).
rule_pred(courses_completed_count/2).
rule_pred(computed_gpa/2).
rule_pred(gpa/2).
rule_pred(academic_standing/2).
rule_pred(at_risk/1).
rule_pred(progression_level/2).
rule_pred(catch_up_course/2).
rule_pred(remaining_core/2).
rule_pred(remaining_core_count/2).
rule_pred(electives_completed_count/2).
rule_pred(elective_requirement_met/1).
rule_pred(matches_interest/2).
rule_pred(suggested_track/2).
rule_pred(track_match_count/3).
rule_pred(primary_track/2).
rule_pred(unlocks_count/3).
rule_pred(needed_for_later/2).
rule_pred(course_priority_score/3).
rule_pred(recommended_course/3).
rule_pred(top_recommendations/4).
rule_pred(recommended_load/2).
rule_pred(overload_allowed/1).
rule_pred(internship_ready/1).
rule_pred(fyp_eligible/1).
rule_pred(fyp_in_progress/1).
rule_pred(can_graduate/1).
rule_pred(near_graduation/1).
rule_pred(honors_eligible/1).
rule_pred(repeat_advised/2).
rule_pred(suggested_elective/3).
rule_pred(level_appropriate/2).
rule_pred(semester_plan_credits/4).
rule_pred(what_if_unlocks/3).
rule_pred(support_action/2).
rule_pred(warning_reason/2).
rule_pred(next_milestone/2).
rule_pred(industry_suggestion/2).
rule_pred(consultation_focus/2).

test_minimum_rules :-
    findall(P, rule_pred(P), Ps),
    length(Ps, N),
    format('       named logical rules: ~w~n', [N]),
    N >= 40.

%------------------------------------------------------------------------------
% Backward
%------------------------------------------------------------------------------
test_ama_eligible_ce301 :-
    eligible_for(ama, ce301).

test_yaw_not_eligible_ce301 :-
    \+ eligible_for(yaw, ce301).

test_kwame_eligible_ce201 :-
    eligible_for(kwame, ce201).

test_already_passed_not_eligible :-
    \+ eligible_for(ama, ce101).

%------------------------------------------------------------------------------
% Recursive
%------------------------------------------------------------------------------
test_chain_ce407_to_ce101 :-
    ancestor_prerequisite(ce407, ce101).

test_direct_vs_ancestor :-
    prerequisite(ce407, ce406),
    ancestor_prerequisite(ce407, ce310),
    \+ prerequisite(ce407, ce310).

test_longest_path_positive :-
    longest_prerequisite_path(ce407, Depth),
    Depth >= 5.

%------------------------------------------------------------------------------
% Forward conclusions
%------------------------------------------------------------------------------
test_kofi_at_risk :-
    at_risk(kofi),
    academic_standing(kofi, warning).

test_kofi_not_400_level :-
    \+ eligible_for(kofi, ce408).

test_ama_internship :-
    internship_ready(ama).

test_kojo_not_graduate :-
    \+ can_graduate(kojo).

test_akosua_near_graduation :-
    near_graduation(akosua).

test_yaw_foundations_focus :-
    consultation_focus(yaw, foundations).

%------------------------------------------------------------------------------
% Recommendations
%------------------------------------------------------------------------------
test_top_recs_ama_first :-
    top_recommendations(ama, first, 5, Courses),
    member(ce301, Courses).

test_kofi_reduced_load :-
    recommended_load(kofi, Credits),
    Credits =< 15.

test_what_if_kwame_ce201 :-
    what_if_unlocks(kwame, ce201, Newly),
    member(ce301, Newly).

%------------------------------------------------------------------------------
% Explanation
%------------------------------------------------------------------------------
test_explain_eligible :-
    explain_course(ama, ce301, Reasons),
    Reasons \= [].

test_explain_ineligible :-
    explain_ineligible(yaw, ce301, Reasons),
    Reasons \= [].

%------------------------------------------------------------------------------
% Validation
%------------------------------------------------------------------------------
test_yes_no_tokens :-
    parse_yes_no(yes, yes),
    parse_yes_no(n, no),
    parse_yes_no(unknown, unknown),
    parse_yes_no(quit, quit).

test_course_normalise :-
    normalise_course('CE301', ce301),
    \+ normalise_course('ZZ999', _).

%------------------------------------------------------------------------------
% Combined-domain oracles
%------------------------------------------------------------------------------
test_medical_malaria :-
    med_likely(kwaku, malaria),
    med_ancestor_complication(malaria, heart_strain).

test_career_data_science :-
    career_suitable(kwesi, data_scientist),
    career_reaches(junior_developer, director_of_engineering).

test_library_topic_tree :-
    lib_suitable(ama_lib, b09),
    lib_ancestor_topic(prolog, cs).

test_cyber_ransomware :-
    cy_likely(case_ransom, ransomware),
    cy_later_stage(recon, actions_on_objective).

test_farming_rice :-
    farm_suitable(plot_wet, rice),
    farm_rotation_path(maize, maize, _).

test_vehicle_battery :-
    veh_likely(car_a, dead_battery),
    veh_needs(engine, battery).

test_hotel_tarkwa :-
    hotel_suitable(g_business, h_tarkwa_crest),
    hotel_in_area(tarkwa, ghana).

test_legal_tenancy :-
    legal_likely(c_rent, tenancy),
    legal_higher(magistrate, supreme_court).

test_admission_ce :-
    adm_eligible(app_strong, computer_engineering),
    \+ adm_eligible(app_arts, computer_engineering).
