%==============================================================================
% MDES — Multi-Domain Expert System hub
% All ten assignment domains live in one program.
%==============================================================================

start_system :-
    catch(hub_menu, Error, (
        print_message(error, Error),
        format('~nAn unexpected error occurred. Returning to the domain list.~n', []),
        hub_menu
    )).

hub_menu :-
    nl,
    format('===============================================================~n', []),
    format('  MDES  Multi-Domain Expert System~n', []),
    format('  CE 474  Logic of Computer Science  |  Group Project 1~n', []),
    format('===============================================================~n', []),
    format('  Ten knowledge bases, one Prolog program.~n~n', []),
    format('   1  Academic advising (CSE)~n', []),
    format('   2  Medical diagnosis~n', []),
    format('   3  Career recommendation~n', []),
    format('   4  Library recommendation~n', []),
    format('   5  Cybersecurity incident response~n', []),
    format('   6  Smart farming advisory~n', []),
    format('   7  Vehicle fault diagnosis~n', []),
    format('   8  Hotel recommendation~n', []),
    format('   9  Legal consultation assistant~n', []),
    format('  10  University admission advisory~n', []),
    format('  11  Help~n', []),
    format('  12  Run all domain self-checks~n', []),
    format('  13  Exit~n', []),
    format('---------------------------------------------------------------~n', []),
    ask_integer('Select a domain or action', 1, 13, Choice),
    (   Choice == quit
    ->  shutdown_system
    ;   hub_action(Choice),
        (   Choice =:= 13
        ->  true
        ;   hub_menu
        )
    ).

hub_action(1)  :- advising_menu.
hub_action(2)  :- run_medical_domain.
hub_action(3)  :- run_career_domain.
hub_action(4)  :- run_library_domain.
hub_action(5)  :- run_cyber_domain.
hub_action(6)  :- run_farming_domain.
hub_action(7)  :- run_vehicle_domain.
hub_action(8)  :- run_hotel_domain.
hub_action(9)  :- run_legal_domain.
hub_action(10) :- run_admission_domain.
hub_action(11) :- hub_help.
hub_action(12) :- run_all_domain_checks.
hub_action(13) :- shutdown_system.

shutdown_system :-
    format('~nThank you for using the Multi-Domain Expert System. Goodbye.~n', []),
    halt.

hub_help :-
    nl,
    hub_banner('HOW THE COMBINED SYSTEM WORKS'),
    format('Each domain is a separate knowledge base and rule set. The hub~n', []),
    format('only selects which expert you are talking to. Shared validation~n', []),
    format('(yes/no/unknown, ranges, quit) is used by every interview.~n~n', []),
    format('In every domain you can demonstrate:~n', []),
    format('  Backward  - a yes/no goal such as a diagnosis or eligibility~n', []),
    format('  Forward   - conclusions pushed from known case facts~n', []),
    format('  Recursive - a hierarchy (prerequisites, complications,~n', []),
    format('              kill-chain, career ladder, court levels, ...)~n', []),
    format('  Explain   - why the recommendation or refusal was made~n~n', []),
    format('Type quit at most prompts to go back one level.~n~n', []),
    format('This software is an academic expert-system demonstration.~n', []),
    format('It is not a doctor, lawyer, registrar, or mechanic.~n', []).

run_all_domain_checks :-
    nl,
    format('Running self-checks for every domain...~n~n', []),
    format('[Academic advising]~n', []),
    consult_self_check,
    format('~n[Medical]~n', []),
    medical_self_check,
    format('~n[Career]~n', []),
    career_self_check,
    format('~n[Library]~n', []),
    library_self_check,
    format('~n[Cybersecurity]~n', []),
    cyber_self_check,
    format('~n[Farming]~n', []),
    farming_self_check,
    format('~n[Vehicle]~n', []),
    vehicle_self_check,
    format('~n[Hotel]~n', []),
    hotel_self_check,
    format('~n[Legal]~n', []),
    legal_self_check,
    format('~n[Admission]~n', []),
    admission_self_check,
    format('~nAll domain self-checks finished.~n', []).
