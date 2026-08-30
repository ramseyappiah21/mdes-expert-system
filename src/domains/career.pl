%==============================================================================
% Domain 3 — Career recommendation
%==============================================================================

career_job(software_engineer).
career_job(data_scientist).
career_job(cybersecurity_analyst).
career_job(network_engineer).
career_job(product_manager).
career_job(lecturer).
career_job(ui_designer).
career_job(agritech_officer).
career_job(database_administrator).
career_job(technical_writer).

career_skill(python).
career_skill(statistics).
career_skill(networks).
career_skill(security).
career_skill(writing).
career_skill(leadership).
career_skill(design).
career_skill(farming_knowledge).
career_skill(databases).
career_skill(communication).

career_needs(software_engineer, python).
career_needs(software_engineer, databases).
career_needs(data_scientist, python).
career_needs(data_scientist, statistics).
career_needs(cybersecurity_analyst, security).
career_needs(cybersecurity_analyst, networks).
career_needs(network_engineer, networks).
career_needs(product_manager, leadership).
career_needs(product_manager, communication).
career_needs(lecturer, writing).
career_needs(lecturer, communication).
career_needs(ui_designer, design).
career_needs(agritech_officer, farming_knowledge).
career_needs(database_administrator, databases).
career_needs(technical_writer, writing).

career_interest(software).
career_interest(ai).
career_interest(security).
career_interest(teaching).
career_interest(design).
career_interest(agriculture).

career_fits_interest(software_engineer, software).
career_fits_interest(data_scientist, ai).
career_fits_interest(cybersecurity_analyst, security).
career_fits_interest(network_engineer, security).
career_fits_interest(lecturer, teaching).
career_fits_interest(ui_designer, design).
career_fits_interest(agritech_officer, agriculture).
career_fits_interest(product_manager, software).
career_fits_interest(technical_writer, teaching).

career_next(junior_developer, developer).
career_next(developer, senior_developer).
career_next(senior_developer, lead_engineer).
career_next(lead_engineer, engineering_manager).
career_next(engineering_manager, director_of_engineering).
career_next(analyst, senior_analyst).
career_next(senior_analyst, lead_analyst).
career_next(assistant_lecturer, lecturer_rank).
career_next(lecturer_rank, senior_lecturer).

career_person(kwesi).
career_person(akua).
career_person(yawb).

career_has(kwesi, python).
career_has(kwesi, statistics).
career_has(kwesi, databases).
career_likes(kwesi, ai).
career_has(akua, security).
career_has(akua, networks).
career_likes(akua, security).
career_has(yawb, writing).
career_has(yawb, communication).
career_likes(yawb, teaching).

career_has(guest, Skill) :-
    answered_yes(career, Skill).
career_likes(guest, Interest) :-
    session_answer(career, interest, Interest).

career_match_count(Person, Job, Count) :-
    career_job(Job),
    findall(S, (career_needs(Job, S), career_has(Person, S)), Skills),
    length(Skills, Count).

career_suitable(Person, Job) :-
    career_match_count(Person, Job, Count),
    Count >= 1,
    (   career_likes(Person, I),
        career_fits_interest(Job, I)
    ->  true
    ;   Count >= 2
    ).

career_score(Person, Job, Score) :-
    career_suitable(Person, Job),
    career_match_count(Person, Job, C),
    (   career_likes(Person, I), career_fits_interest(Job, I)
    ->  Bonus = 2
    ;   Bonus = 0
    ),
    Score is C + Bonus.

career_top(Person, Job) :-
    findall(S-J, career_score(Person, J, S), Pairs),
    Pairs \= [],
    sort(0, @>=, Pairs, [_-Job|_]).

career_path(From, To, [From, To]) :-
    career_next(From, To).
career_path(From, To, [From|Rest]) :-
    career_next(From, Mid),
    career_path(Mid, To, Rest).

career_reaches(From, To) :-
    career_path(From, To, _).

career_reason(Person, Job, Reason) :-
    career_needs(Job, S),
    career_has(Person, S),
    format(atom(Reason), 'You have the skill ~w.', [S]).
career_reason(Person, Job, Reason) :-
    career_likes(Person, I),
    career_fits_interest(Job, I),
    format(atom(Reason), 'The role matches your interest in ~w.', [I]).

run_career_domain :-
    standard_domain_menu('Domain 3  Career recommendation',
        career_consult, career_sample, career_backward,
        career_recursive, career_forward).

career_consult :-
    clear_answers(career),
    hub_banner('Career interview'),
    ask_choice('Main interest',
               [software, ai, security, teaching, design, agriculture], I),
    I \= quit,
    set_answer(career, interest, I),
    forall(member(Sk, [python, statistics, networks, security, writing,
                       leadership, design, farming_knowledge, databases, communication]),
           ask_career_skill(Sk)),
    career_report(guest).

ask_career_skill(Sk) :-
    format(atom(P), 'Do you have skill/experience in ~w?', [Sk]),
    ask_yes_no(P, A),
    A \= quit,
    store_yes_no(career, Sk, A).

career_report(Person) :-
    nl,
    hub_banner('Career recommendations'),
    findall(S-J, career_score(Person, J, S), Pairs),
    sort(0, @>=, Pairs, Sorted),
    (   Sorted == []
    ->  format('No role crossed the match threshold. Add skills or pick another interest.~n', [])
    ;   forall(member(S-J, Sorted), format('  ~w  ~w~n', [S, J])),
        Sorted = [_-Top|_],
        format('~nBest match: ~w~nWhy:~n', [Top]),
        findall(R, career_reason(Person, Top, R), Rs),
        print_lines(Rs)
    ),
    nl.

career_sample :-
    ask_known('Sample person (kwesi, akua, yawb)', career_person, P),
    (P == quit -> true ; career_report(P)).

career_backward :-
    ask_known('Person (kwesi, akua, yawb)', career_person, P),
    P \= quit, !,
    ask_choice('Job to test',
               [software_engineer, data_scientist, cybersecurity_analyst,
                network_engineer, product_manager, lecturer, ui_designer,
                agritech_officer, database_administrator, technical_writer], J),
    J \= quit, !,
    format('~nBackward goal: career_suitable(~w, ~w)~n', [P, J]),
    (   career_suitable(P, J)
    ->  format('Result: YES~n', []),
        findall(R, career_reason(P, J, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', [])
    ).
career_backward.

career_recursive :-
    ask_choice('Start role on the ladder',
               [junior_developer, developer, senior_developer, lead_engineer,
                analyst, assistant_lecturer], From),
    (   From == quit
    ->  true
    ;   format('~nRoles reachable from ~w:~n', [From]),
        findall(T, career_reaches(From, T), Ts),
        print_lines(Ts)
    ).

career_forward :-
    ask_known('Person (kwesi, akua, yawb)', career_person, P),
    (   P == quit
    ->  true
    ;   findall(J, career_suitable(P, J), Jobs),
        format('~nForward: jobs derived from ~w skills/interests:~n', [P]),
        print_lines(Jobs)
    ).

career_self_check :-
    check_line(career_suitable(kwesi, data_scientist), 'kwesi -> data scientist'),
    check_line(career_suitable(akua, cybersecurity_analyst), 'akua -> cyber analyst'),
    check_line(\+ career_suitable(yawb, data_scientist), 'yawb not data scientist'),
    check_line(career_reaches(junior_developer, director_of_engineering), 'ladder to director').
