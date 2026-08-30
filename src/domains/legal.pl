%==============================================================================
% Domain 9 — Legal consultation assistant (educational, not legal advice)
%==============================================================================

legal_matter(tenancy).
legal_matter(employment).
legal_matter(land).
legal_matter(family).
legal_matter(contract).
legal_matter(cybercrime).
legal_matter(traffic).
legal_matter(consumer).

legal_fact(unpaid_rent).
legal_fact(illegal_eviction).
legal_fact(dismissal_no_notice).
legal_fact(unpaid_wages).
legal_fact(boundary_dispute).
legal_fact(family_maintenance).
legal_fact(broken_agreement).
legal_fact(online_fraud).
legal_fact(accident_injury).
legal_fact(defective_product).

legal_points(tenancy, unpaid_rent).
legal_points(tenancy, illegal_eviction).
legal_points(employment, dismissal_no_notice).
legal_points(employment, unpaid_wages).
legal_points(land, boundary_dispute).
legal_points(family, family_maintenance).
legal_points(contract, broken_agreement).
legal_points(cybercrime, online_fraud).
legal_points(traffic, accident_injury).
legal_points(consumer, defective_product).

legal_next_step(tenancy, gather_lease_and_receipts).
legal_next_step(tenancy, consider_rent_control_or_court).
legal_next_step(employment, collect_appointment_letter).
legal_next_step(employment, labour_office_complaint).
legal_next_step(land, survey_plan_and_indenture).
legal_next_step(family, family_tribunal_or_mediation).
legal_next_step(contract, written_demand_letter).
legal_next_step(cybercrime, report_to_cybercrime_unit).
legal_next_step(traffic, police_report_and_insurance).
legal_next_step(consumer, seller_complaint_then_agency).

legal_court(magistrate).
legal_court(circuit).
legal_court(high_court).
legal_court(court_of_appeal).
legal_court(supreme_court).

legal_appeals_to(magistrate, circuit).
legal_appeals_to(circuit, high_court).
legal_appeals_to(high_court, court_of_appeal).
legal_appeals_to(court_of_appeal, supreme_court).

legal_higher(A, B) :-
    legal_appeals_to(A, B).
legal_higher(A, B) :-
    legal_appeals_to(A, M),
    legal_higher(M, B).

legal_forum(tenancy, magistrate).
legal_forum(employment, magistrate).
legal_forum(land, high_court).
legal_forum(family, magistrate).
legal_forum(contract, circuit).
legal_forum(cybercrime, circuit).
legal_forum(traffic, magistrate).
legal_forum(consumer, magistrate).

legal_client(c_rent).
legal_client(c_job).
legal_client(c_land).

legal_has(c_rent, unpaid_rent).
legal_has(c_rent, illegal_eviction).
legal_has(c_job, dismissal_no_notice).
legal_has(c_job, unpaid_wages).
legal_has(c_land, boundary_dispute).

legal_has(guest, F) :-
    answered_yes(legal, F).

legal_score(Client, Matter, Score) :-
    legal_matter(Matter),
    findall(F, (legal_points(Matter, F), legal_has(Client, F)), Hits),
    length(Hits, Score).

legal_likely(Client, Matter) :-
    legal_score(Client, Matter, Score),
    Score >= 1.

legal_primary(Client, Matter) :-
    findall(S-M, legal_likely(Client, M), Pairs),
    Pairs \= [],
    sort(0, @>=, Pairs, [_-Matter|_]).

legal_reason(Client, Matter, Reason) :-
    legal_points(Matter, F),
    legal_has(Client, F),
    format(atom(Reason), 'Stated fact: ~w.', [F]).

run_legal_domain :-
    standard_domain_menu('Domain 9  Legal consultation assistant',
        legal_consult, legal_sample, legal_backward,
        legal_recursive, legal_forward).

legal_consult :-
    clear_answers(legal),
    hub_banner('Legal interview'),
    format('This is a teaching expert system. It is not a lawyer and~n', []),
    format('does not create an attorney-client relationship.~n~n', []),
    forall(member(F, [unpaid_rent, illegal_eviction, dismissal_no_notice,
                      unpaid_wages, boundary_dispute, family_maintenance,
                      broken_agreement, online_fraud, accident_injury,
                      defective_product]),
           ask_legal(F)),
    legal_report(guest).

ask_legal(F) :-
    format(atom(Q), 'Is this part of the problem: ~w?', [F]),
    ask_yes_no(Q, A),
    A \= quit,
    store_yes_no(legal, F, A).

legal_report(Client) :-
    nl,
    hub_banner('Matter classification'),
    format('Educational guidance only. Speak to a licensed lawyer.~n~n', []),
    findall(S-M, legal_likely(Client, M), Pairs),
    sort(0, @>=, Pairs, Sorted),
    (   Sorted == []
    ->  format('No matter type matched. Describe the facts to a lawyer directly.~n', [])
    ;   forall(member(S-M, Sorted), format('  ~w  ~w~n', [S, M])),
        legal_primary(Client, Top),
        legal_forum(Top, Forum),
        format('~nPrimary matter: ~w~nTypical first forum (illustrative): ~w~nWhy:~n',
               [Top, Forum]),
        findall(R, legal_reason(Client, Top, R), Rs),
        print_lines(Rs),
        format('~nPossible next steps to discuss with counsel:~n', []),
        findall(St, legal_next_step(Top, St), Steps),
        print_lines(Steps)
    ),
    nl.

legal_sample :-
    ask_known('Client (c_rent, c_job, c_land)', legal_client, C),
    (C == quit -> true ; legal_report(C)).

legal_backward :-
    ask_known('Client (c_rent, c_job, c_land)', legal_client, C),
    C \= quit, !,
    ask_choice('Matter',
               [tenancy, employment, land, family, contract, cybercrime, traffic, consumer], M),
    M \= quit, !,
    format('~nBackward goal: legal_likely(~w, ~w)~n', [C, M]),
    (   legal_likely(C, M)
    ->  format('Result: YES~n', []),
        findall(R, legal_reason(C, M, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', [])
    ).
legal_backward.

legal_recursive :-
    ask_choice('Court',
               [magistrate, circuit, high_court, court_of_appeal], Ct),
    (   Ct == quit
    ->  true
    ;   format('~nHigher courts above ~w:~n', [Ct]),
        findall(H, legal_higher(Ct, H), Hs),
        print_lines(Hs)
    ).

legal_forward :-
    ask_known('Client (c_rent, c_job, c_land)', legal_client, C),
    (   C == quit
    ->  true
    ;   findall(M, legal_likely(C, M), Ms),
        format('~nForward: matter types derived for ~w:~n', [C]),
        print_lines(Ms)
    ).

legal_self_check :-
    check_line(legal_likely(c_rent, tenancy), 'rent -> tenancy'),
    check_line(legal_likely(c_job, employment), 'job -> employment'),
    check_line(\+ legal_likely(c_land, tenancy), 'land not tenancy'),
    check_line(legal_higher(magistrate, supreme_court), 'appeal chain to supreme court').
