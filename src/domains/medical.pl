%==============================================================================
% Domain 2 — Medical diagnosis assistant (educational, not clinical advice)
%==============================================================================

med_disease(malaria).
med_disease(typhoid).
med_disease(influenza).
med_disease(migraine).
med_disease(covid19).
med_disease(asthma).
med_disease(gastritis).
med_disease(dengue).
med_disease(anemia).
med_disease(meningitis).

med_symptom(fever).
med_symptom(headache).
med_symptom(body_pain).
med_symptom(chills).
med_symptom(cough).
med_symptom(sore_throat).
med_symptom(nausea).
med_symptom(abdominal_pain).
med_symptom(diarrhea).
med_symptom(rash).
med_symptom(joint_pain).
med_symptom(photophobia).
med_symptom(wheeze).
med_symptom(shortness_of_breath).
med_symptom(chest_pain).
med_symptom(fatigue).
med_symptom(loss_of_smell).
med_symptom(neck_stiffness).
med_symptom(pale_skin).
med_symptom(dizziness).
med_symptom(heartburn).

med_symptom_of(malaria, fever).
med_symptom_of(malaria, headache).
med_symptom_of(malaria, body_pain).
med_symptom_of(malaria, chills).
med_symptom_of(typhoid, fever).
med_symptom_of(typhoid, headache).
med_symptom_of(typhoid, abdominal_pain).
med_symptom_of(typhoid, diarrhea).
med_symptom_of(influenza, fever).
med_symptom_of(influenza, cough).
med_symptom_of(influenza, body_pain).
med_symptom_of(influenza, sore_throat).
med_symptom_of(migraine, headache).
med_symptom_of(migraine, photophobia).
med_symptom_of(migraine, nausea).
med_symptom_of(covid19, fever).
med_symptom_of(covid19, cough).
med_symptom_of(covid19, fatigue).
med_symptom_of(covid19, loss_of_smell).
med_symptom_of(asthma, wheeze).
med_symptom_of(asthma, shortness_of_breath).
med_symptom_of(asthma, chest_pain).
med_symptom_of(gastritis, abdominal_pain).
med_symptom_of(gastritis, nausea).
med_symptom_of(gastritis, heartburn).
med_symptom_of(dengue, fever).
med_symptom_of(dengue, rash).
med_symptom_of(dengue, joint_pain).
med_symptom_of(dengue, headache).
med_symptom_of(anemia, fatigue).
med_symptom_of(anemia, pale_skin).
med_symptom_of(anemia, dizziness).
med_symptom_of(meningitis, fever).
med_symptom_of(meningitis, headache).
med_symptom_of(meningitis, neck_stiffness).
med_symptom_of(meningitis, photophobia).

med_must(malaria, fever).
med_must(typhoid, fever).
med_must(influenza, cough).
med_must(migraine, headache).
med_must(covid19, cough).
med_must(asthma, wheeze).
med_must(gastritis, abdominal_pain).
med_must(dengue, fever).
med_must(anemia, fatigue).
med_must(meningitis, neck_stiffness).

med_excludes(migraine, fever).
med_excludes(anemia, high_fever_only).

med_min_score(malaria, 3).
med_min_score(typhoid, 3).
med_min_score(influenza, 3).
med_min_score(migraine, 2).
med_min_score(covid19, 3).
med_min_score(asthma, 2).
med_min_score(gastritis, 2).
med_min_score(dengue, 3).
med_min_score(anemia, 2).
med_min_score(meningitis, 3).

med_risk(mosquito_area).
med_risk(unsafe_water).
med_risk(recent_travel).
med_risk(smoking).

med_risk_of(malaria, mosquito_area).
med_risk_of(typhoid, unsafe_water).
med_risk_of(dengue, mosquito_area).
med_risk_of(covid19, recent_travel).
med_risk_of(asthma, smoking).

med_complication(malaria, anemia).
med_complication(anemia, heart_strain).
med_complication(typhoid, intestinal_perforation).
med_complication(covid19, pneumonia).
med_complication(pneumonia, respiratory_failure).
med_complication(dengue, bleeding_risk).
med_complication(meningitis, brain_injury).
med_complication(asthma, respiratory_failure).

med_patient(kwaku).
med_patient(adwoa).
med_patient(fiifi).

med_case(kwaku, fever).
med_case(kwaku, headache).
med_case(kwaku, body_pain).
med_case(kwaku, chills).
med_case(kwaku, mosquito_area).
med_case(adwoa, headache).
med_case(adwoa, photophobia).
med_case(adwoa, nausea).
med_case(fiifi, fever).
med_case(fiifi, headache).
med_case(fiifi, neck_stiffness).
med_case(fiifi, photophobia).

med_presents(Person, Fact) :-
    med_case(Person, Fact).
med_presents(guest, Fact) :-
    answered_yes(medical, Fact).

med_score(Person, Disease, Score) :-
    findall(S, (med_symptom_of(Disease, S), med_presents(Person, S)), Hits),
    length(Hits, Score).

med_risk_bonus(Person, Disease, 1) :-
    med_risk_of(Disease, R),
    med_presents(Person, R), !.
med_risk_bonus(_, _, 0).

med_likely(Person, Disease) :-
    med_disease(Disease),
    med_min_score(Disease, Min),
    med_score(Person, Disease, Score),
    Score >= Min,
    forall(med_must(Disease, Must), med_presents(Person, Must)),
    \+ (med_excludes(Disease, Ex), med_presents(Person, Ex)).

med_ranked(Person, Disease, Total) :-
    med_likely(Person, Disease),
    med_score(Person, Disease, Score),
    med_risk_bonus(Person, Disease, Bonus),
    Total is Score + Bonus.

med_top(Person, Disease) :-
    findall(Total-D, med_ranked(Person, D, Total), Pairs),
    Pairs \= [],
    sort(0, @>=, Pairs, [Best-Disease|_]).

med_emergency(Person) :-
    med_presents(Person, neck_stiffness),
    med_presents(Person, fever).
med_emergency(Person) :-
    med_presents(Person, chest_pain),
    med_presents(Person, shortness_of_breath).

med_ancestor_complication(From, To) :-
    med_complication(From, To).
med_ancestor_complication(From, To) :-
    med_complication(From, Mid),
    med_ancestor_complication(Mid, To).

med_reason(Person, Disease, Reason) :-
    med_symptom_of(Disease, S),
    med_presents(Person, S),
    format(atom(Reason), 'Present symptom: ~w.', [S]).
med_reason(Person, Disease, Reason) :-
    med_risk_of(Disease, R),
    med_presents(Person, R),
    format(atom(Reason), 'Matching risk factor: ~w.', [R]).

med_forward_facts(Person, Facts) :-
    findall(likely(D), med_likely(Person, D), L1),
    findall(emergency, med_emergency(Person), L2),
    (   med_top(Person, Top)
    ->  L3 = [primary(Top)]
    ;   L3 = [primary(none)]
    ),
    append([L1, L2, L3], Facts).

run_medical_domain :-
    standard_domain_menu('Domain 2  Medical diagnosis',
        medical_consult, medical_sample, medical_backward,
        medical_recursive, medical_forward).

medical_consult :-
    clear_answers(medical),
    hub_banner('Medical interview (educational only — not a diagnosis)'),
    ask_med(fever),
    (   answered_yes(medical, fever)
    ->  ask_med(chills), ask_med(headache), ask_med(body_pain)
    ;   ask_med(headache)
    ),
    (   answered_yes(medical, headache)
    ->  ask_med(photophobia), ask_med(neck_stiffness)
    ;   true
    ),
    ask_med(cough),
    (   answered_yes(medical, cough)
    ->  ask_med(sore_throat), ask_med(shortness_of_breath), ask_med(loss_of_smell)
    ;   true
    ),
    ask_med(abdominal_pain),
    (   answered_yes(medical, abdominal_pain)
    ->  ask_med(nausea), ask_med(diarrhea), ask_med(heartburn)
    ;   true
    ),
    ask_med(mosquito_area),
    ask_med(unsafe_water),
    ask_med(recent_travel),
    medical_report(guest).

ask_med(Key) :-
    format_prompt(Key, Prompt),
    ask_yes_no(Prompt, A),
    A \= quit,
    store_yes_no(medical, Key, A).

format_prompt(fever, 'Do you have fever?').
format_prompt(chills, 'Do you have chills or sweating?').
format_prompt(headache, 'Do you have headache?').
format_prompt(body_pain, 'Do you have body pain?').
format_prompt(photophobia, 'Does light make the headache worse?').
format_prompt(neck_stiffness, 'Is your neck stiff?').
format_prompt(cough, 'Do you have a cough?').
format_prompt(sore_throat, 'Do you have a sore throat?').
format_prompt(shortness_of_breath, 'Are you short of breath?').
format_prompt(loss_of_smell, 'Have you lost smell or taste?').
format_prompt(abdominal_pain, 'Do you have abdominal pain?').
format_prompt(nausea, 'Do you have nausea?').
format_prompt(diarrhea, 'Do you have diarrhea?').
format_prompt(heartburn, 'Do you have heartburn?').
format_prompt(mosquito_area, 'Have you been in a mosquito-heavy area?').
format_prompt(unsafe_water, 'Have you used untreated water or street food recently?').
format_prompt(recent_travel, 'Have you travelled or been in a crowded indoor place recently?').

medical_report(Person) :-
    nl,
    hub_banner('Medical assessment'),
    format('Educational output only. Seek a licensed clinician for care.~n~n', []),
    (   med_emergency(Person)
    ->  format('URGENT FLAG: emergency-pattern symptoms are present.~n', []),
        format('Advise immediate in-person medical care.~n~n', [])
    ;   true
    ),
    findall(T-D, med_ranked(Person, D, T), Pairs),
    sort(0, @>=, Pairs, Sorted),
    (   Sorted == []
    ->  format('No disease rule reached its threshold. Collect more signs or see a clinic.~n', [])
    ;   format('Possible conditions (score-disease):~n', []),
        forall(member(T-D, Sorted), format('  ~w  ~w~n', [T, D])),
        Sorted = [_-Top|_],
        format('~nPrimary suggestion: ~w~nWhy:~n', [Top]),
        findall(R, med_reason(Person, Top, R), Reasons),
        print_lines(Reasons),
        findall(C, med_ancestor_complication(Top, C), Comps),
        format('~nPossible complication chain:~n', []),
        print_lines(Comps)
    ),
    nl.

medical_sample :-
    ask_known('Sample patient (kwaku, adwoa, fiifi)', med_patient, P),
    (   P == quit
    ->  true
    ;   medical_report(P)
    ).

medical_backward :-
    ask_known('Patient (kwaku, adwoa, fiifi)', med_patient, P),
    P \= quit, !,
    ask_choice('Disease to test',
               [malaria, typhoid, influenza, migraine, covid19, asthma,
                gastritis, dengue, anemia, meningitis], D),
    D \= quit, !,
    format('~nBackward goal: med_likely(~w, ~w)~n', [P, D]),
    (   med_likely(P, D)
    ->  format('Result: YES~nWhy:~n', []),
        findall(R, med_reason(P, D, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO — required symptoms or score not met.~n', [])
    ).
medical_backward.

medical_recursive :-
    ask_choice('Start of complication chain',
               [malaria, anemia, typhoid, covid19, pneumonia, dengue, meningitis, asthma], D),
    (   D == quit
    ->  true
    ;   format('~nRecursive complications of ~w:~n', [D]),
        findall(C, med_ancestor_complication(D, C), Cs),
        print_lines(Cs)
    ).

medical_forward :-
    ask_known('Patient (kwaku, adwoa, fiifi)', med_patient, P),
    (   P == quit
    ->  true
    ;   format('~nForward conclusions from ~w facts:~n', [P]),
        med_forward_facts(P, Facts),
        print_lines(Facts)
    ).

medical_self_check :-
    check_line(med_likely(kwaku, malaria), 'kwaku matches malaria'),
    check_line(\+ med_likely(adwoa, malaria), 'adwoa is not malaria'),
    check_line(med_likely(adwoa, migraine), 'adwoa matches migraine'),
    check_line(med_emergency(fiifi), 'fiifi emergency flag'),
    check_line(med_ancestor_complication(malaria, heart_strain), 'malaria -> heart_strain chain').
