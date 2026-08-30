%==============================================================================
% Domain 10 — University admission advisory
% WASSCE-style aggregates: lower is better.
%==============================================================================

adm_programme(computer_engineering).
adm_programme(mining_engineering).
adm_programme(electrical_engineering).
adm_programme(business_admin).
adm_programme(nursing).
adm_programme(mathematics).
adm_programme(geomatic_engineering).

adm_track(science).
adm_track(general_arts).
adm_track(home_economics).
adm_track(business).
adm_track(technical).

adm_feeder(science, computer_engineering).
adm_feeder(science, mining_engineering).
adm_feeder(science, electrical_engineering).
adm_feeder(science, mathematics).
adm_feeder(science, geomatic_engineering).
adm_feeder(science, nursing).
adm_feeder(general_arts, business_admin).
adm_feeder(business, business_admin).
adm_feeder(home_economics, nursing).
adm_feeder(technical, computer_engineering).
adm_feeder(technical, electrical_engineering).
adm_feeder(technical, mining_engineering).

% Broader feeder: technical students may also be treated as science-capable.
adm_track_broader(technical, science).
adm_track_reaches(Track, Track).
adm_track_reaches(Track, Super) :-
    adm_track_broader(Track, Super).
adm_track_reaches(Track, Super) :-
    adm_track_broader(Track, Mid),
    adm_track_reaches(Mid, Super).

adm_cutoff(computer_engineering, 12).
adm_cutoff(mining_engineering, 14).
adm_cutoff(electrical_engineering, 13).
adm_cutoff(business_admin, 18).
adm_cutoff(nursing, 16).
adm_cutoff(mathematics, 15).
adm_cutoff(geomatic_engineering, 15).

adm_requires(computer_engineering, core_maths).
adm_requires(computer_engineering, english).
adm_requires(computer_engineering, physics).
adm_requires(computer_engineering, elective_maths).
adm_requires(mining_engineering, core_maths).
adm_requires(mining_engineering, english).
adm_requires(mining_engineering, physics).
adm_requires(electrical_engineering, core_maths).
adm_requires(electrical_engineering, physics).
adm_requires(business_admin, english).
adm_requires(business_admin, core_maths).
adm_requires(nursing, english).
adm_requires(nursing, science_core).
adm_requires(mathematics, elective_maths).
adm_requires(mathematics, core_maths).
adm_requires(geomatic_engineering, core_maths).
adm_requires(geomatic_engineering, geography).

adm_applicant(app_strong).
adm_applicant(app_arts).
adm_applicant(app_border).

adm_track_of(app_strong, science).
adm_aggregate(app_strong, 10).
adm_has_subject(app_strong, core_maths).
adm_has_subject(app_strong, english).
adm_has_subject(app_strong, physics).
adm_has_subject(app_strong, elective_maths).
adm_has_subject(app_strong, chemistry).

adm_track_of(app_arts, general_arts).
adm_aggregate(app_arts, 14).
adm_has_subject(app_arts, english).
adm_has_subject(app_arts, core_maths).
adm_has_subject(app_arts, government).

adm_track_of(app_border, science).
adm_aggregate(app_border, 16).
adm_has_subject(app_border, core_maths).
adm_has_subject(app_border, english).
adm_has_subject(app_border, physics).

adm_track_of(guest, T) :-
    session_answer(admission, track, T).
adm_aggregate(guest, A) :-
    session_answer(admission, aggregate, A).
adm_has_subject(guest, S) :-
    answered_yes(admission, S).

adm_track_ok(App, Prog) :-
    adm_track_of(App, Track),
    adm_track_reaches(Track, Super),
    adm_feeder(Super, Prog).

adm_subjects_ok(App, Prog) :-
    forall(adm_requires(Prog, Sub), adm_has_subject(App, Sub)).

adm_eligible(App, Prog) :-
    adm_programme(Prog),
    adm_track_ok(App, Prog),
    adm_aggregate(App, Agg),
    adm_cutoff(Prog, Cut),
    Agg =< Cut,
    adm_subjects_ok(App, Prog).

adm_reason(App, Prog, Reason) :-
    adm_track_of(App, T),
    format(atom(Reason), 'SHS track ~w feeds this programme.', [T]).
adm_reason(App, Prog, Reason) :-
    adm_aggregate(App, A),
    adm_cutoff(Prog, C),
    format(atom(Reason), 'Aggregate ~w meets cutoff ~w (lower is better).', [A, C]).
adm_reason(App, Prog, Reason) :-
    adm_requires(Prog, S),
    adm_has_subject(App, S),
    format(atom(Reason), 'Required subject present: ~w.', [S]).

adm_missing(App, Prog, Sub) :-
    adm_requires(Prog, Sub),
    \+ adm_has_subject(App, Sub).

run_admission_domain :-
    standard_domain_menu('Domain 10  University admission advisory',
        admission_consult, admission_sample, admission_backward,
        admission_recursive, admission_forward).

admission_consult :-
    clear_answers(admission),
    hub_banner('Admission interview'),
    format('Aggregates follow WASSCE convention: a smaller number is better.~n~n', []),
    ask_choice('SHS track',
               [science, general_arts, home_economics, business, technical], T),
    T \= quit,
    set_answer(admission, track, T),
    ask_integer('Best-six aggregate (6 to 36)', 6, 36, Agg),
    Agg \= quit,
    set_answer(admission, aggregate, Agg),
    forall(member(S, [core_maths, english, physics, elective_maths,
                      chemistry, science_core, geography, government]),
           ask_adm_subject(S)),
    admission_report(guest).

ask_adm_subject(S) :-
    format(atom(Q), 'Do you have a credit in ~w?', [S]),
    ask_yes_no(Q, A),
    A \= quit,
    store_yes_no(admission, S, A).

admission_report(App) :-
    nl,
    hub_banner('Admission options'),
    format('Illustrative cutoffs for teaching — not an official UMaT list.~n~n', []),
    findall(Prog, adm_eligible(App, Prog), Ps0),
    sort(Ps0, Ps),
    (   Ps == []
    ->  format('No programme is currently eligible. Check track, aggregate and subjects.~n', []),
        findall(Prog, adm_programme(Prog), All),
        format('~nClosest blockers:~n', []),
        forall(member(P, All), admission_blockers(App, P))
    ;   forall(member(P, Ps), (
            adm_cutoff(P, C),
            format('  ~w  (cutoff ~w)~n', [P, C])
        )),
        Ps = [Top|_],
        format('~nWhy ~w is open:~n', [Top]),
        findall(R, adm_reason(App, Top, R), Rs),
        print_lines(Rs)
    ),
    nl.

admission_blockers(App, Prog) :-
    findall(S, adm_missing(App, Prog, S), Miss),
    (   Miss == []
    ->  true
    ;   format('  ~w missing: ~w~n', [Prog, Miss])
    ).

admission_sample :-
    ask_known('Applicant (app_strong, app_arts, app_border)', adm_applicant, A),
    (A == quit -> true ; admission_report(A)).

admission_backward :-
    ask_known('Applicant (app_strong, app_arts, app_border)', adm_applicant, A),
    A \= quit, !,
    ask_choice('Programme',
               [computer_engineering, mining_engineering, electrical_engineering,
                business_admin, nursing, mathematics, geomatic_engineering], P),
    P \= quit, !,
    format('~nBackward goal: adm_eligible(~w, ~w)~n', [A, P]),
    (   adm_eligible(A, P)
    ->  format('Result: YES~n', []),
        findall(R, adm_reason(A, P, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', []),
        findall(S, adm_missing(A, P, S), Miss),
        format('Missing subjects: ~w~n', [Miss])
    ).
admission_backward.

admission_recursive :-
    ask_choice('SHS track',
               [science, technical, general_arts, business, home_economics], T),
    (   T == quit
    ->  true
    ;   format('~nTracks treated as reaching from ~w:~n', [T]),
        findall(S, adm_track_reaches(T, S), Ss),
        print_lines(Ss),
        format('~nProgrammes those tracks can feed:~n', []),
        findall(P, (adm_track_reaches(T, Super), adm_feeder(Super, P)), Ps0),
        sort(Ps0, Ps),
        print_lines(Ps)
    ).

admission_forward :-
    ask_known('Applicant (app_strong, app_arts, app_border)', adm_applicant, A),
    (   A == quit
    ->  true
    ;   findall(P, adm_eligible(A, P), Ps),
        format('~nForward: programmes derived for ~w:~n', [A]),
        print_lines(Ps)
    ).

admission_self_check :-
    check_line(adm_eligible(app_strong, computer_engineering), 'strong -> CE'),
    check_line(adm_eligible(app_arts, business_admin), 'arts -> business'),
    check_line(\+ adm_eligible(app_arts, computer_engineering), 'arts not CE'),
    check_line(adm_track_reaches(technical, science), 'technical reaches science').
