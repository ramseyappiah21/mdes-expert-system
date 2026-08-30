%==============================================================================
% Domain 6 — Smart farming advisory
%==============================================================================

farm_crop(maize).
farm_crop(cassava).
farm_crop(cocoa).
farm_crop(rice).
farm_crop(tomato).
farm_crop(pepper).
farm_crop(plantain).
farm_crop(groundnut).

farm_soil(sandy).
farm_soil(loam).
farm_soil(clay).
farm_soil(laterite).

farm_rain(low).
farm_rain(medium).
farm_rain(high).

farm_likes_soil(maize, loam).
farm_likes_soil(maize, sandy).
farm_likes_soil(cassava, sandy).
farm_likes_soil(cassava, laterite).
farm_likes_soil(cocoa, loam).
farm_likes_soil(rice, clay).
farm_likes_soil(tomato, loam).
farm_likes_soil(pepper, loam).
farm_likes_soil(plantain, loam).
farm_likes_soil(groundnut, sandy).

farm_likes_rain(maize, medium).
farm_likes_rain(cassava, low).
farm_likes_rain(cassava, medium).
farm_likes_rain(cocoa, high).
farm_likes_rain(rice, high).
farm_likes_rain(tomato, medium).
farm_likes_rain(pepper, medium).
farm_likes_rain(plantain, high).
farm_likes_rain(groundnut, low).

farm_pest(fall_armyworm).
farm_pest(black_pod).
farm_pest(stem_borer).
farm_pest(mosaic_virus).
farm_pest(aphids).

farm_threatens(fall_armyworm, maize).
farm_threatens(stem_borer, maize).
farm_threatens(black_pod, cocoa).
farm_threatens(mosaic_virus, cassava).
farm_threatens(aphids, tomato).
farm_threatens(aphids, pepper).

farm_rotate(maize, groundnut).
farm_rotate(groundnut, maize).
farm_rotate(tomato, maize).
farm_rotate(rice, groundnut).
farm_rotate(pepper, cassava).

farm_rotation_path(A, B, Path) :-
    farm_rot_walk(A, B, [A], Path).

farm_rot_walk(A, B, _, [A, B]) :-
    farm_rotate(A, B).
farm_rot_walk(A, B, Seen, [A|Rest]) :-
    farm_rotate(A, Mid),
    \+ member(Mid, Seen),
    farm_rot_walk(Mid, B, [Mid|Seen], Rest).

farm_plot(plot_north).
farm_plot(plot_wet).
farm_plot(plot_dry).

farm_has_soil(plot_north, loam).
farm_has_rain(plot_north, medium).
farm_has_pest(plot_north, fall_armyworm).
farm_has_soil(plot_wet, clay).
farm_has_rain(plot_wet, high).
farm_has_soil(plot_dry, sandy).
farm_has_rain(plot_dry, low).

farm_has_soil(guest, S) :-
    session_answer(farming, soil, S).
farm_has_rain(guest, R) :-
    session_answer(farming, rain, R).
farm_has_pest(guest, P) :-
    answered_yes(farming, P).

farm_suitable(Plot, Crop) :-
    farm_crop(Crop),
    farm_has_soil(Plot, Soil),
    farm_likes_soil(Crop, Soil),
    farm_has_rain(Plot, Rain),
    farm_likes_rain(Crop, Rain).

farm_warning(Plot, Crop, pest(Pest)) :-
    farm_suitable(Plot, Crop),
    farm_has_pest(Plot, Pest),
    farm_threatens(Pest, Crop).

farm_advice(Plot, Crop, grow) :-
    farm_suitable(Plot, Crop),
    \+ farm_warning(Plot, Crop, _).
farm_advice(Plot, Crop, grow_with_pest_control(Pest)) :-
    farm_warning(Plot, Crop, pest(Pest)).
farm_advice(Plot, irrigate) :-
    farm_has_rain(Plot, low).
farm_advice(Plot, drain_or_ridge) :-
    farm_has_rain(Plot, high),
    farm_has_soil(Plot, clay).

farm_reason(Plot, Crop, Reason) :-
    farm_has_soil(Plot, S),
    farm_likes_soil(Crop, S),
    format(atom(Reason), 'Soil ~w suits ~w.', [S, Crop]).
farm_reason(Plot, Crop, Reason) :-
    farm_has_rain(Plot, R),
    farm_likes_rain(Crop, R),
    format(atom(Reason), 'Rainfall band ~w suits ~w.', [R, Crop]).

run_farming_domain :-
    standard_domain_menu('Domain 6  Smart farming advisory',
        farming_consult, farming_sample, farming_backward,
        farming_recursive, farming_forward).

farming_consult :-
    clear_answers(farming),
    hub_banner('Farm interview'),
    ask_choice('Soil type', [sandy, loam, clay, laterite], S),
    S \= quit,
    set_answer(farming, soil, S),
    ask_choice('Recent rainfall', [low, medium, high], R),
    R \= quit,
    set_answer(farming, rain, R),
    forall(member(P, [fall_armyworm, black_pod, stem_borer, mosaic_virus, aphids]),
           ask_farm_pest(P)),
    farming_report(guest).

ask_farm_pest(P) :-
    format(atom(Q), 'Have you seen signs of ~w?', [P]),
    ask_yes_no(Q, A),
    A \= quit,
    store_yes_no(farming, P, A).

farming_report(Plot) :-
    nl,
    hub_banner('Farm advice'),
    findall(C, farm_suitable(Plot, C), Crops0),
    sort(Crops0, Crops),
    format('Suitable crops:~n', []),
    print_lines(Crops),
    findall(A, farm_advice(Plot, A), Generic),
    findall(grow_with_pest_control(P)-C,
            farm_advice(Plot, C, grow_with_pest_control(P)), Warned),
    format('~nGeneral actions:~n', []),
    print_lines(Generic),
    (   Crops == []
    ->  true
    ;   Crops = [Top|_],
        format('~nWhy ~w is a candidate:~n', [Top]),
        findall(R, farm_reason(Plot, Top, R), Rs),
        print_lines(Rs)
    ),
    (   Warned == []
    ->  true
    ;   format('~nPest cautions:~n', []),
        forall(member(W-C, Warned), format('  ~w on ~w~n', [W, C]))
    ),
    nl.

farming_sample :-
    ask_known('Plot (plot_north, plot_wet, plot_dry)', farm_plot, P),
    (P == quit -> true ; farming_report(P)).

farming_backward :-
    ask_known('Plot (plot_north, plot_wet, plot_dry)', farm_plot, P),
    P \= quit, !,
    ask_choice('Crop', [maize, cassava, cocoa, rice, tomato, pepper, plantain, groundnut], C),
    C \= quit, !,
    format('~nBackward goal: farm_suitable(~w, ~w)~n', [P, C]),
    (   farm_suitable(P, C)
    ->  format('Result: YES~n', []),
        findall(R, farm_reason(P, C, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO — soil or rainfall does not match.~n', [])
    ).
farming_backward.

farming_recursive :-
    ask_choice('Start crop for rotation paths',
               [maize, groundnut, tomato, rice, pepper], C),
    (   C == quit
    ->  true
    ;   format('~nCrops reachable in a rotation from ~w:~n', [C]),
        findall(X, farm_rotation_path(C, X, _), Xs0),
        sort(Xs0, Xs),
        print_lines(Xs)
    ).

farming_forward :-
    ask_known('Plot (plot_north, plot_wet, plot_dry)', farm_plot, P),
    (   P == quit
    ->  true
    ;   findall(C, farm_suitable(P, C), Crops),
        format('~nForward: crops derived from ~w conditions:~n', [P]),
        print_lines(Crops)
    ).

farming_self_check :-
    check_line(farm_suitable(plot_north, maize), 'north plot maize'),
    check_line(farm_suitable(plot_wet, rice), 'wet plot rice'),
    check_line(\+ farm_suitable(plot_dry, cocoa), 'dry plot not cocoa'),
    check_line(farm_rotation_path(maize, maize, _), 'maize-groundnut-maize cycle').
