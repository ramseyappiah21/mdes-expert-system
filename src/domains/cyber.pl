%==============================================================================
% Domain 5 — Cybersecurity incident response advisor
%==============================================================================

cy_incident(phishing).
cy_incident(ransomware).
cy_incident(ddos).
cy_incident(insider_misuse).
cy_incident(malware).
cy_incident(data_breach).
cy_incident(brute_force).

cy_indicator(suspicious_email).
cy_indicator(credential_harvest_page).
cy_indicator(encrypted_files).
cy_indicator(ransom_note).
cy_indicator(high_traffic).
cy_indicator(service_outage).
cy_indicator(odd_login_hour).
cy_indicator(large_export).
cy_indicator(unknown_process).
cy_indicator(failed_logins).

cy_points_to(phishing, suspicious_email).
cy_points_to(phishing, credential_harvest_page).
cy_points_to(ransomware, encrypted_files).
cy_points_to(ransomware, ransom_note).
cy_points_to(ddos, high_traffic).
cy_points_to(ddos, service_outage).
cy_points_to(insider_misuse, odd_login_hour).
cy_points_to(insider_misuse, large_export).
cy_points_to(malware, unknown_process).
cy_points_to(data_breach, large_export).
cy_points_to(brute_force, failed_logins).

cy_severity(phishing, medium).
cy_severity(ransomware, critical).
cy_severity(ddos, high).
cy_severity(insider_misuse, high).
cy_severity(malware, high).
cy_severity(data_breach, critical).
cy_severity(brute_force, medium).

cy_action(phishing, reset_credentials).
cy_action(phishing, isolate_mailbox).
cy_action(ransomware, isolate_host).
cy_action(ransomware, restore_from_backup).
cy_action(ransomware, notify_management).
cy_action(ddos, enable_traffic_filter).
cy_action(insider_misuse, revoke_access).
cy_action(malware, isolate_host).
cy_action(data_breach, notify_management).
cy_action(data_breach, preserve_logs).
cy_action(brute_force, lock_account).

cy_stage(recon).
cy_stage(weaponize).
cy_stage(deliver).
cy_stage(exploit).
cy_stage(install).
cy_stage(command_control).
cy_stage(actions_on_objective).

cy_next_stage(recon, weaponize).
cy_next_stage(weaponize, deliver).
cy_next_stage(deliver, exploit).
cy_next_stage(exploit, install).
cy_next_stage(install, command_control).
cy_next_stage(command_control, actions_on_objective).

cy_later_stage(A, B) :-
    cy_next_stage(A, B).
cy_later_stage(A, B) :-
    cy_next_stage(A, M),
    cy_later_stage(M, B).

cy_case(case_phish).
cy_case(case_ransom).
cy_case(case_ddos).

cy_seen(case_phish, suspicious_email).
cy_seen(case_phish, credential_harvest_page).
cy_seen(case_ransom, encrypted_files).
cy_seen(case_ransom, ransom_note).
cy_seen(case_ddos, high_traffic).
cy_seen(case_ddos, service_outage).

cy_seen(guest, Ind) :-
    answered_yes(cyber, Ind).

cy_score(Case, Type, Score) :-
    cy_incident(Type),
    findall(I, (cy_points_to(Type, I), cy_seen(Case, I)), Hits),
    length(Hits, Score).

cy_likely(Case, Type) :-
    cy_score(Case, Type, Score),
    Score >= 2.

cy_primary(Case, Type) :-
    findall(S-T, cy_likely(Case, T), Pairs),
    Pairs \= [],
    sort(0, @>=, Pairs, [_-Type|_]).

cy_playbook(Case, Action) :-
    cy_primary(Case, Type),
    cy_action(Type, Action).

cy_reason(Case, Type, Reason) :-
    cy_points_to(Type, I),
    cy_seen(Case, I),
    format(atom(Reason), 'Indicator present: ~w.', [I]).

run_cyber_domain :-
    standard_domain_menu('Domain 5  Cybersecurity incident response',
        cyber_consult, cyber_sample, cyber_backward,
        cyber_recursive, cyber_forward).

cyber_consult :-
    clear_answers(cyber),
    hub_banner('Incident intake'),
    forall(member(I, [suspicious_email, credential_harvest_page, encrypted_files,
                      ransom_note, high_traffic, service_outage, odd_login_hour,
                      large_export, unknown_process, failed_logins]),
           ask_cy(I)),
    cyber_report(guest).

ask_cy(I) :-
    format(atom(P), 'Have you observed ~w?', [I]),
    ask_yes_no(P, A),
    A \= quit,
    store_yes_no(cyber, I, A).

cyber_report(Case) :-
    nl,
    hub_banner('Incident assessment'),
    findall(S-T, (cy_likely(Case, T), cy_score(Case, T, S)), Pairs),
    sort(0, @>=, Pairs, Sorted),
    (   Sorted == []
    ->  format('No incident type reached two matching indicators. Keep collecting evidence.~n', [])
    ;   forall(member(S-T, Sorted), (
            cy_severity(T, Sev),
            format('  ~w  ~w  (severity ~w)~n', [S, T, Sev])
        )),
        cy_primary(Case, Top),
        format('~nPrimary type: ~w~nWhy:~n', [Top]),
        findall(R, cy_reason(Case, Top, R), Rs),
        print_lines(Rs),
        format('~nImmediate playbook:~n', []),
        findall(A, cy_action(Top, A), Acts),
        print_lines(Acts)
    ),
    nl.

cyber_sample :-
    ask_known('Case (case_phish, case_ransom, case_ddos)', cy_case, C),
    (C == quit -> true ; cyber_report(C)).

cyber_backward :-
    ask_known('Case (case_phish, case_ransom, case_ddos)', cy_case, C),
    C \= quit, !,
    ask_choice('Incident type',
               [phishing, ransomware, ddos, insider_misuse, malware,
                data_breach, brute_force], T),
    T \= quit, !,
    format('~nBackward goal: cy_likely(~w, ~w)~n', [C, T]),
    (   cy_likely(C, T)
    ->  format('Result: YES~n', []),
        findall(R, cy_reason(C, T, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', [])
    ).
cyber_backward.

cyber_recursive :-
    ask_choice('Kill-chain stage',
               [recon, weaponize, deliver, exploit, install, command_control], S),
    (   S == quit
    ->  true
    ;   format('~nLater kill-chain stages after ~w:~n', [S]),
        findall(L, cy_later_stage(S, L), Ls),
        print_lines(Ls)
    ).

cyber_forward :-
    ask_known('Case (case_phish, case_ransom, case_ddos)', cy_case, C),
    (   C == quit
    ->  true
    ;   findall(A, cy_playbook(C, A), Acts),
        format('~nForward: playbook actions derived for ~w:~n', [C]),
        print_lines(Acts)
    ).

cyber_self_check :-
    check_line(cy_likely(case_phish, phishing), 'phish case'),
    check_line(cy_likely(case_ransom, ransomware), 'ransom case'),
    check_line(\+ cy_likely(case_ddos, ransomware), 'ddos is not ransomware'),
    check_line(cy_later_stage(recon, actions_on_objective), 'full kill chain').
