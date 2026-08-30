%==============================================================================
% Shared helpers for every expert-system domain
%==============================================================================

:- dynamic session_answer/3.

clear_answers(Domain) :-
    retractall(session_answer(Domain, _, _)).

set_answer(Domain, Key, Value) :-
    retractall(session_answer(Domain, Key, _)),
    assertz(session_answer(Domain, Key, Value)).

answered_yes(Domain, Key) :-
    session_answer(Domain, Key, yes).

answered_no(Domain, Key) :-
    session_answer(Domain, Key, no).

store_yes_no(Domain, Key, Answer) :-
    (   Answer == quit
    ->  fail
    ;   Answer == unknown
    ->  set_answer(Domain, Key, unknown)
    ;   set_answer(Domain, Key, Answer)
    ).

hub_banner(Title) :-
    nl,
    format('----------------------------------------------------------------~n', []),
    format('  ~w~n', [Title]),
    format('----------------------------------------------------------------~n', []).

print_lines([]) :-
    format('  (none)~n', []).
print_lines(Lines) :-
    Lines \= [],
    forall(member(L, Lines), format('  - ~w~n', [L])).

ask_known(Prompt, Check, Value) :-
    format('~w: ', [Prompt]),
    flush_output,
    read_atom_line(Atom),
    (   quit_token(Atom)
    ->  Value = quit
    ;   call(Check, Atom)
    ->  Value = Atom
    ;   format('Unknown name "~w". Try again or type quit.~n', [Atom]),
        ask_known(Prompt, Check, Value)
    ).

% Standard six-option domain submenu. Each argument is a 0-ary goal.
standard_domain_menu(Title, Consult, Sample, Backward, Recursive, Forward) :-
    nl,
    format('===============================================================~n', []),
    format('  ~w~n', [Title]),
    format('===============================================================~n', []),
    format('  1  Interactive consultation~n', []),
    format('  2  Run a built-in sample case~n', []),
    format('  3  Backward query (goal-driven)~n', []),
    format('  4  Recursive reasoning~n', []),
    format('  5  Forward inference demo~n', []),
    format('  6  Back to domain list~n', []),
    format('---------------------------------------------------------------~n', []),
    ask_integer('Select an option', 1, 6, Choice),
    (   Choice == quit
    ->  true
    ;   Choice =:= 6
    ->  true
    ;   domain_action(Choice, Consult, Sample, Backward, Recursive, Forward),
        standard_domain_menu(Title, Consult, Sample, Backward, Recursive, Forward)
    ).

domain_action(1, Consult, _, _, _, _) :- call(Consult).
domain_action(2, _, Sample, _, _, _) :- call(Sample).
domain_action(3, _, _, Backward, _, _) :- call(Backward).
domain_action(4, _, _, _, Recursive, _) :- call(Recursive).
domain_action(5, _, _, _, _, Forward) :- call(Forward).

check_line(Pass, Message) :-
    (   Pass
    ->  format('  PASS  ~w~n', [Message])
    ;   format('  FAIL  ~w~n', [Message])
    ).
