%==============================================================================
% CAAES — input validation and recovery
% Unknown answers, invalid entries, and missing information are handled
% without crashing the consultation.
%==============================================================================

:- use_module(library(readutil)).

yes_token(y).
yes_token(yes).
yes_token(yeah).
yes_token(yep).

no_token(n).
no_token(no).
no_token(nope).

unknown_token(unknown).
unknown_token(unsure).
unknown_token(maybe).
unknown_token(skip).
unknown_token(idk).
unknown_token('i don\'t know').
unknown_token('dont know').
unknown_token('don\'t know').

quit_token(quit).
quit_token(exit).
quit_token(q).
quit_token(back).

read_raw_line(String) :-
    read_line_to_string(user_input, Raw),
    (   Raw == end_of_file
    ->  String = "quit"
    ;   normalize_space(string(String), Raw)
    ).

read_atom_line(Atom) :-
    read_raw_line(String),
    string_lower(String, Lower),
    atom_string(Atom, Lower).

%------------------------------------------------------------------------------
% Yes / no / unknown
%------------------------------------------------------------------------------
parse_yes_no(Atom, yes) :-
    yes_token(Atom).
parse_yes_no(Atom, no) :-
    no_token(Atom).
parse_yes_no(Atom, unknown) :-
    unknown_token(Atom).
parse_yes_no(Atom, quit) :-
    quit_token(Atom).

ask_yes_no(Prompt, Answer) :-
    format('~w (yes / no / unknown): ', [Prompt]),
    flush_output,
    read_atom_line(Atom),
    (   Atom == ''
    ->  format('Please type yes, no, or unknown.~n', []),
        ask_yes_no(Prompt, Answer)
    ;   parse_yes_no(Atom, Answer)
    ->  true
    ;   format('I did not recognise "~w". Try yes, no, or unknown.~n', [Atom]),
        ask_yes_no(Prompt, Answer)
    ).

%------------------------------------------------------------------------------
% Bounded integers
%------------------------------------------------------------------------------
ask_integer(Prompt, Min, Max, Value) :-
    format('~w [~w-~w]: ', [Prompt, Min, Max]),
    flush_output,
    read_raw_line(String),
    (   String == "quit"
    ->  Value = quit
    ;   String == ""
    ->  format('A number is required. Please try again.~n', []),
        ask_integer(Prompt, Min, Max, Value)
    ;   catch(number_string(Number, String), _, fail),
        integer(Number),
        Number >= Min,
        Number =< Max
    ->  Value = Number
    ;   format('Please enter a whole number between ~w and ~w.~n', [Min, Max]),
        ask_integer(Prompt, Min, Max, Value)
    ).

%------------------------------------------------------------------------------
% Bounded floats (GPA)
%------------------------------------------------------------------------------
ask_float(Prompt, Min, Max, Value) :-
    format('~w [~w-~w]: ', [Prompt, Min, Max]),
    flush_output,
    read_raw_line(String),
    (   String == "quit"
    ->  Value = quit
    ;   String == ""
    ->  format('A number is required. Enter unknown to use a default.~n', []),
        ask_float(Prompt, Min, Max, Value)
    ;   atom_string(Atom, String),
        unknown_token(Atom)
    ->  Value = unknown
    ;   catch(number_string(Number, String), _, fail),
        Number >= Min,
        Number =< Max
    ->  Value = Number
    ;   format('Please enter a number between ~w and ~w, or unknown.~n', [Min, Max]),
        ask_float(Prompt, Min, Max, Value)
    ).

%------------------------------------------------------------------------------
% Menu choice
%------------------------------------------------------------------------------
ask_choice(Prompt, Options, Choice) :-
    format('~w~n', [Prompt]),
    print_numbered(Options, 1),
    length(Options, N),
    ask_integer('Enter the number of your choice', 1, N, Index),
    (   Index == quit
    ->  Choice = quit
    ;   nth1(Index, Options, Choice)
    ).

print_numbered([], _).
print_numbered([H|T], I) :-
    format('  ~w) ~w~n', [I, H]),
    I2 is I + 1,
    print_numbered(T, I2).

%------------------------------------------------------------------------------
% Course codes
%------------------------------------------------------------------------------
normalise_course(Raw, Code) :-
    atom_string(Atom0, Raw),
    downcase_atom(Atom0, Code),
    course(Code, _, _, _).

ask_course(Prompt, Code) :-
    format('~w (e.g. CE201, or unknown): ', [Prompt]),
    flush_output,
    read_raw_line(String),
    string_lower(String, Lower),
    atom_string(Atom, Lower),
    (   quit_token(Atom)
    ->  Code = quit
    ;   unknown_token(Atom)
    ->  Code = unknown
    ;   Atom == ''
    ->  format('Please type a course code such as CE201.~n', []),
        ask_course(Prompt, Code)
    ;   normalise_course(Lower, Code)
    ->  true
    ;   format('Unknown course code "~w". Check the catalogue or type unknown.~n', [String]),
        ask_course(Prompt, Code)
    ).

ask_course_list(Prompt, Codes) :-
    format('~w~n', [Prompt]),
    format('Type course codes separated by spaces or commas. Type none if empty.~n> ', []),
    flush_output,
    read_raw_line(String),
    string_lower(String, Lower),
    atom_string(Atom, Lower),
    (   quit_token(Atom)
    ->  Codes = quit
    ;   (Atom == none ; Atom == '' ; unknown_token(Atom))
    ->  Codes = []
    ;   split_course_tokens(Lower, Tokens),
        partition_valid_courses(Tokens, Valid, Invalid),
        (   Invalid == []
        ->  Codes = Valid
        ;   format('These codes are not in the catalogue: ~w~n', [Invalid]),
            format('Accepted: ~w~n', [Valid]),
            ask_yes_no('Keep the accepted codes and ignore the rest?', Keep),
            (   Keep == yes
            ->  Codes = Valid
            ;   Keep == quit
            ->  Codes = quit
            ;   ask_course_list(Prompt, Codes)
            )
        )
    ).

split_course_tokens(String, Tokens) :-
    split_string(String, " ,;", " \t", Parts),
    exclude(==( ""), Parts, Tokens).

partition_valid_courses([], [], []).
partition_valid_courses([Tok|Rest], [Code|Valid], Invalid) :-
    normalise_course(Tok, Code),
    !,
    partition_valid_courses(Rest, Valid, Invalid).
partition_valid_courses([Tok|Rest], Valid, [Tok|Invalid]) :-
    partition_valid_courses(Rest, Valid, Invalid).

%------------------------------------------------------------------------------
% Known sample-student names
%------------------------------------------------------------------------------
ask_student(Prompt, Student) :-
    format('~w (ama, kwame, akosua, kofi, yaw, abena, kojo, efua): ', [Prompt]),
    flush_output,
    read_atom_line(Atom),
    (   quit_token(Atom)
    ->  Student = quit
    ;   student(Atom)
    ->  Student = Atom
    ;   format('No student record named "~w". Try one of the listed names.~n', [Atom]),
        ask_student(Prompt, Student)
    ).

%------------------------------------------------------------------------------
% Missing-information defaults
%------------------------------------------------------------------------------
default_gpa(unknown, 2.50).
default_semester(unknown, first).
default_interest(unknown, software).
