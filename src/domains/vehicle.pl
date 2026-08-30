%==============================================================================
% Domain 7 — Vehicle fault diagnosis
%==============================================================================

veh_fault(dead_battery).
veh_fault(bad_alternator).
veh_fault(worn_brake_pads).
veh_fault(overheating).
veh_fault(flat_tyre).
veh_fault(clogged_air_filter).
veh_fault(bad_spark_plugs).
veh_fault(low_brake_fluid).
veh_fault(loose_fan_belt).
veh_fault(empty_fuel).

veh_symptom(no_start).
veh_symptom(dim_lights).
veh_symptom(clicking_start).
veh_symptom(grinding_brakes).
veh_symptom(long_stopping).
veh_symptom(steam_from_bonnet).
veh_symptom(temp_gauge_high).
veh_symptom(pulling_left).
veh_symptom(low_power).
veh_symptom(rough_idle).
veh_symptom(squeal_on_start).
veh_symptom(fuel_gauge_empty).

veh_points(dead_battery, no_start).
veh_points(dead_battery, dim_lights).
veh_points(dead_battery, clicking_start).
veh_points(bad_alternator, dim_lights).
veh_points(bad_alternator, no_start).
veh_points(worn_brake_pads, grinding_brakes).
veh_points(worn_brake_pads, long_stopping).
veh_points(low_brake_fluid, long_stopping).
veh_points(overheating, steam_from_bonnet).
veh_points(overheating, temp_gauge_high).
veh_points(flat_tyre, pulling_left).
veh_points(clogged_air_filter, low_power).
veh_points(bad_spark_plugs, rough_idle).
veh_points(bad_spark_plugs, no_start).
veh_points(loose_fan_belt, squeal_on_start).
veh_points(loose_fan_belt, overheating_risk).
veh_points(empty_fuel, no_start).
veh_points(empty_fuel, fuel_gauge_empty).

% Component dependency: a parent will not work if a child is failed.
veh_depends(starter, battery).
veh_depends(engine, starter).
veh_depends(engine, fuel_system).
veh_depends(charging, alternator).
veh_depends(battery, charging).
veh_depends(brakes, brake_pads).
veh_depends(brakes, brake_fluid).
veh_depends(cooling, fan_belt).
veh_depends(cooling, radiator).

veh_needs(Comp, Base) :-
    veh_depends(Comp, Base).
veh_needs(Comp, Base) :-
    veh_depends(Comp, Mid),
    veh_needs(Mid, Base).

veh_car(car_a).
veh_car(car_b).
veh_car(car_c).

veh_seen(car_a, no_start).
veh_seen(car_a, dim_lights).
veh_seen(car_a, clicking_start).
veh_seen(car_b, grinding_brakes).
veh_seen(car_b, long_stopping).
veh_seen(car_c, steam_from_bonnet).
veh_seen(car_c, temp_gauge_high).

veh_seen(guest, S) :-
    answered_yes(vehicle, S).

veh_score(Car, Fault, Score) :-
    veh_fault(Fault),
    findall(S, (veh_points(Fault, S), veh_seen(Car, S)), Hits),
    length(Hits, Score).

veh_likely(Car, Fault) :-
    veh_score(Car, Fault, Score),
    Score >= 2.

veh_primary(Car, Fault) :-
    findall(S-F, (veh_likely(Car, F), veh_score(Car, F, S)), Pairs),
    Pairs \= [],
    sort(0, @>=, Pairs, [_-Fault|_]).

veh_action(dead_battery, charge_or_replace_battery).
veh_action(bad_alternator, test_alternator_output).
veh_action(worn_brake_pads, replace_brake_pads).
veh_action(low_brake_fluid, inspect_leaks_and_top_up).
veh_action(overheating, stop_engine_check_coolant).
veh_action(flat_tyre, change_or_repair_tyre).
veh_action(clogged_air_filter, replace_air_filter).
veh_action(bad_spark_plugs, replace_spark_plugs).
veh_action(loose_fan_belt, tension_or_replace_belt).
veh_action(empty_fuel, refuel).

veh_reason(Car, Fault, Reason) :-
    veh_points(Fault, S),
    veh_seen(Car, S),
    format(atom(Reason), 'Observed symptom: ~w.', [S]).

run_vehicle_domain :-
    standard_domain_menu('Domain 7  Vehicle fault diagnosis',
        vehicle_consult, vehicle_sample, vehicle_backward,
        vehicle_recursive, vehicle_forward).

vehicle_consult :-
    clear_answers(vehicle),
    hub_banner('Vehicle interview'),
    ask_veh(no_start),
    (   answered_yes(vehicle, no_start)
    ->  ask_veh(dim_lights), ask_veh(clicking_start),
        ask_veh(fuel_gauge_empty), ask_veh(rough_idle)
    ;   true
    ),
    ask_veh(grinding_brakes),
    (   answered_yes(vehicle, grinding_brakes)
    ->  ask_veh(long_stopping)
    ;   ask_veh(long_stopping)
    ),
    ask_veh(steam_from_bonnet),
    (   answered_yes(vehicle, steam_from_bonnet)
    ->  ask_veh(temp_gauge_high)
    ;   true
    ),
    ask_veh(pulling_left),
    ask_veh(low_power),
    ask_veh(squeal_on_start),
    vehicle_report(guest).

ask_veh(S) :-
    format(atom(P), 'Is this happening: ~w?', [S]),
    ask_yes_no(P, A),
    A \= quit,
    store_yes_no(vehicle, S, A).

vehicle_report(Car) :-
    nl,
    hub_banner('Fault assessment'),
    format('Educational workshop aid — not a substitute for a mechanic.~n~n', []),
    findall(S-F, veh_likely(Car, F), Pairs),
    sort(0, @>=, Pairs, Sorted),
    (   Sorted == []
    ->  format('No fault rule reached two matching symptoms.~n', [])
    ;   forall(member(S-F, Sorted), format('  ~w  ~w~n', [S, F])),
        veh_primary(Car, Top),
        format('~nPrimary suspicion: ~w~nWhy:~n', [Top]),
        findall(R, veh_reason(Car, Top, R), Rs),
        print_lines(Rs),
        findall(A, veh_action(Top, A), Acts),
        format('~nSuggested checks:~n', []),
        print_lines(Acts)
    ),
    nl.

vehicle_sample :-
    ask_known('Car (car_a, car_b, car_c)', veh_car, C),
    (C == quit -> true ; vehicle_report(C)).

vehicle_backward :-
    ask_known('Car (car_a, car_b, car_c)', veh_car, C),
    C \= quit, !,
    ask_choice('Fault',
               [dead_battery, bad_alternator, worn_brake_pads, overheating,
                flat_tyre, clogged_air_filter, bad_spark_plugs, empty_fuel], F),
    F \= quit, !,
    format('~nBackward goal: veh_likely(~w, ~w)~n', [C, F]),
    (   veh_likely(C, F)
    ->  format('Result: YES~n', []),
        findall(R, veh_reason(C, F, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', [])
    ).
vehicle_backward.

vehicle_recursive :-
    ask_choice('Component',
               [engine, starter, brakes, cooling, battery, charging], Comp),
    (   Comp == quit
    ->  true
    ;   format('~n~w recursively depends on:~n', [Comp]),
        findall(B, veh_needs(Comp, B), Bs0),
        sort(Bs0, Bs),
        print_lines(Bs)
    ).

vehicle_forward :-
    ask_known('Car (car_a, car_b, car_c)', veh_car, C),
    (   C == quit
    ->  true
    ;   findall(F, veh_likely(C, F), Faults),
        format('~nForward: faults derived from ~w symptoms:~n', [C]),
        print_lines(Faults)
    ).

vehicle_self_check :-
    check_line(veh_likely(car_a, dead_battery), 'car_a battery'),
    check_line(veh_likely(car_b, worn_brake_pads), 'car_b pads'),
    check_line(\+ veh_likely(car_a, overheating), 'car_a not overheating'),
    check_line(veh_needs(engine, battery), 'engine depends on battery').
