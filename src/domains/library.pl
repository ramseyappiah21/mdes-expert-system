%==============================================================================
% Domain 4 — Library recommendation
%==============================================================================

lib_book(b01, 'Programming in Prolog', 3).
lib_book(b02, 'Bratko: Prolog for AI', 4).
lib_book(b03, 'Discrete Mathematics', 2).
lib_book(b04, 'Introduction to Algorithms', 5).
lib_book(b05, 'Clean Code', 3).
lib_book(b06, 'Database System Concepts', 4).
lib_book(b07, 'Computer Networks (Tanenbaum)', 4).
lib_book(b08, 'Security Engineering', 5).
lib_book(b09, 'Hands-On Machine Learning', 4).
lib_book(b10, 'The Design of Everyday Things', 2).
lib_book(b11, 'Things Fall Apart', 1).
lib_book(b12, 'Homegoing', 2).
lib_book(b13, 'Farmers of West Africa', 2).
lib_book(b14, 'Ghana Legal System Primer', 3).
lib_book(b15, 'How to Apply to University', 1).
lib_book(b16, 'Python Crash Course', 2).
lib_book(b17, 'Story of Mathematics', 1).
lib_book(b18, 'Malaria Case Notes', 3).
lib_book(b19, 'Hotel Operations', 2).
lib_book(b20, 'Vehicle Electrics', 3).

lib_topic(prolog).
lib_topic(logic).
lib_topic(ai).
lib_topic(algorithms).
lib_topic(software).
lib_topic(databases).
lib_topic(networks).
lib_topic(security).
lib_topic(design).
lib_topic(literature).
lib_topic(agriculture).
lib_topic(law).
lib_topic(admissions).
lib_topic(python).
lib_topic(maths).
lib_topic(medicine).
lib_topic(hospitality).
lib_topic(autos).
lib_topic(cs).

lib_about(b01, prolog).
lib_about(b02, prolog).
lib_about(b02, ai).
lib_about(b03, maths).
lib_about(b04, algorithms).
lib_about(b05, software).
lib_about(b06, databases).
lib_about(b07, networks).
lib_about(b08, security).
lib_about(b09, ai).
lib_about(b10, design).
lib_about(b11, literature).
lib_about(b12, literature).
lib_about(b13, agriculture).
lib_about(b14, law).
lib_about(b15, admissions).
lib_about(b16, python).
lib_about(b17, maths).
lib_about(b18, medicine).
lib_about(b19, hospitality).
lib_about(b20, autos).

lib_broader(prolog, logic).
lib_broader(logic, cs).
lib_broader(algorithms, cs).
lib_broader(software, cs).
lib_broader(databases, cs).
lib_broader(networks, cs).
lib_broader(security, cs).
lib_broader(python, software).
lib_broader(ai, cs).
lib_broader(maths, cs).

lib_covers(Book, Topic) :-
    lib_about(Book, Topic).
lib_covers(Book, Topic) :-
    lib_about(Book, T0),
    lib_ancestor_topic(T0, Topic).

lib_ancestor_topic(T, Anc) :-
    lib_broader(T, Anc).
lib_ancestor_topic(T, Anc) :-
    lib_broader(T, Mid),
    lib_ancestor_topic(Mid, Anc).

lib_reader(ama_lib).
lib_reader(kofi_lib).
lib_reader(efua_lib).

lib_wants(ama_lib, ai).
lib_level(ama_lib, 3).
lib_wants(kofi_lib, literature).
lib_level(kofi_lib, 1).
lib_wants(efua_lib, maths).
lib_level(efua_lib, 2).

lib_wants(guest, T) :-
    session_answer(library, topic, T).
lib_level(guest, L) :-
    session_answer(library, level, L).

lib_suitable(Reader, Book) :-
    lib_book(Book, _, Difficulty),
    lib_wants(Reader, Topic),
    lib_covers(Book, Topic),
    lib_level(Reader, Level),
    Difficulty =< Level + 1.

lib_reason(Reader, Book, Reason) :-
    lib_wants(Reader, Topic),
    lib_about(Book, Topic),
    format(atom(Reason), 'Book is directly about ~w.', [Topic]).
lib_reason(Reader, Book, Reason) :-
    lib_wants(Reader, Topic),
    lib_about(Book, T0),
    lib_ancestor_topic(T0, Topic),
    format(atom(Reason), '~w is filed under the broader topic ~w.', [T0, Topic]).
lib_reason(Reader, Book, Reason) :-
    lib_book(Book, _, D),
    lib_level(Reader, L),
    format(atom(Reason), 'Difficulty ~w is near your reading level ~w.', [D, L]).

run_library_domain :-
    standard_domain_menu('Domain 4  Library recommendation',
        library_consult, library_sample, library_backward,
        library_recursive, library_forward).

library_consult :-
    clear_answers(library),
    hub_banner('Library interview'),
    ask_choice('What topic do you want?',
               [prolog, ai, software, databases, networks, security,
                literature, agriculture, law, admissions, python,
                maths, medicine, hospitality, autos, cs], T),
    T \= quit,
    set_answer(library, topic, T),
    ask_integer('Reading level (1 beginner ... 5 advanced)', 1, 5, L),
    L \= quit,
    set_answer(library, level, L),
    library_report(guest).

library_report(Reader) :-
    nl,
    hub_banner('Recommended titles'),
    findall(Book, lib_suitable(Reader, Book), Books0),
    sort(Books0, Books),
    (   Books == []
    ->  format('No title matched that topic and level.~n', [])
    ;   forall(member(B, Books), (
            lib_book(B, Title, D),
            format('  ~w  ~w (difficulty ~w)~n', [B, Title, D])
        )),
        Books = [Top|_],
        format('~nWhy ~w is a reasonable first pick:~n', [Top]),
        findall(R, lib_reason(Reader, Top, R), Rs),
        sort(Rs, UR),
        print_lines(UR)
    ),
    nl.

library_sample :-
    ask_known('Reader (ama_lib, kofi_lib, efua_lib)', lib_reader, R),
    (R == quit -> true ; library_report(R)).

library_backward :-
    ask_known('Reader (ama_lib, kofi_lib, efua_lib)', lib_reader, R),
    R \= quit, !,
    ask_choice('Book id',
               [b01, b02, b04, b09, b11, b16, b17], B),
    B \= quit, !,
    format('~nBackward goal: lib_suitable(~w, ~w)~n', [R, B]),
    (   lib_suitable(R, B)
    ->  format('Result: YES~n', []),
        findall(X, lib_reason(R, B, X), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', [])
    ).
library_backward.

library_recursive :-
    ask_choice('Topic whose broader subjects you want',
               [prolog, logic, python, algorithms, ai, software], T),
    (   T == quit
    ->  true
    ;   format('~nBroader subjects of ~w:~n', [T]),
        findall(A, lib_ancestor_topic(T, A), As),
        print_lines(As)
    ).

library_forward :-
    ask_known('Reader (ama_lib, kofi_lib, efua_lib)', lib_reader, R),
    (   R == quit
    ->  true
    ;   findall(B, lib_suitable(R, B), Books),
        format('~nForward: titles unlocked by ~w interests:~n', [R]),
        print_lines(Books)
    ).

library_self_check :-
    check_line(lib_suitable(ama_lib, b09), 'ama_lib gets ML book'),
    check_line(lib_suitable(kofi_lib, b11), 'kofi_lib gets literature'),
    check_line(\+ lib_suitable(kofi_lib, b04), 'kofi_lib not CLRS'),
    check_line(lib_ancestor_topic(prolog, cs), 'prolog ancestor is cs').
