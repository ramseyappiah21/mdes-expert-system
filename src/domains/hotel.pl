%==============================================================================
% Domain 8 — Hotel recommendation
%==============================================================================

hotel(h_tarkwa_crest, 'Tarkwa Crest Lodge', tarkwa, 3, 450, business).
hotel(h_tarkwa_inn, 'Mine Road Inn', tarkwa, 2, 220, budget).
hotel(h_accra_gold, 'Accra Gold Hotel', accra, 4, 900, business).
hotel(h_accra_beach, 'Labadi Beach Stay', accra, 4, 1100, leisure).
hotel(h_accra_host, 'Accra Hostel Plus', accra, 1, 150, budget).
hotel(h_kumasi_city, 'Kumasi City Hotel', kumasi, 3, 500, business).
hotel(h_cape_surf, 'Cape Coast Surf Inn', cape_coast, 3, 400, leisure).
hotel(h_cape_hist, 'Castle View Guest House', cape_coast, 2, 280, leisure).
hotel(h_tak_port, 'Takoradi Port Hotel', takoradi, 3, 480, business).
hotel(h_tamale, 'Tamale Savannah Lodge', tamale, 2, 260, budget).

hotel_amenity(h_tarkwa_crest, wifi).
hotel_amenity(h_tarkwa_crest, parking).
hotel_amenity(h_tarkwa_crest, restaurant).
hotel_amenity(h_tarkwa_inn, wifi).
hotel_amenity(h_accra_gold, wifi).
hotel_amenity(h_accra_gold, conference).
hotel_amenity(h_accra_gold, airport_shuttle).
hotel_amenity(h_accra_beach, wifi).
hotel_amenity(h_accra_beach, pool).
hotel_amenity(h_accra_beach, beach).
hotel_amenity(h_accra_host, wifi).
hotel_amenity(h_kumasi_city, wifi).
hotel_amenity(h_kumasi_city, conference).
hotel_amenity(h_cape_surf, beach).
hotel_amenity(h_cape_surf, wifi).
hotel_amenity(h_cape_hist, wifi).
hotel_amenity(h_tak_port, parking).
hotel_amenity(h_tak_port, wifi).
hotel_amenity(h_tamale, wifi).

% Geographic hierarchy: place is inside a larger place.
hotel_inside(tarkwa, western_region).
hotel_inside(takoradi, western_region).
hotel_inside(western_region, ghana).
hotel_inside(accra, greater_accra).
hotel_inside(greater_accra, ghana).
hotel_inside(kumasi, ashanti).
hotel_inside(ashanti, ghana).
hotel_inside(cape_coast, central_region).
hotel_inside(central_region, ghana).
hotel_inside(tamale, northern_region).
hotel_inside(northern_region, ghana).

hotel_in_area(Place, Place).
hotel_in_area(Place, Area) :-
    hotel_inside(Place, Mid),
    hotel_in_area(Mid, Area).

hotel_guest(g_business).
hotel_guest(g_beach).
hotel_guest(g_student).

hotel_wants_city(g_business, tarkwa).
hotel_budget(g_business, 500).
hotel_purpose(g_business, business).
hotel_needs(g_business, wifi).
hotel_wants_city(g_beach, cape_coast).
hotel_budget(g_beach, 450).
hotel_purpose(g_beach, leisure).
hotel_needs(g_beach, beach).
hotel_wants_city(g_student, accra).
hotel_budget(g_student, 200).
hotel_purpose(g_student, budget).
hotel_needs(g_student, wifi).

hotel_wants_city(guest, C) :-
    session_answer(hotel, city, C).
hotel_budget(guest, B) :-
    session_answer(hotel, budget, B).
hotel_purpose(guest, P) :-
    session_answer(hotel, purpose, P).
hotel_needs(guest, A) :-
    answered_yes(hotel, A).

hotel_city_ok(Guest, Hotel) :-
    hotel(Hotel, _, City, _, _, _),
    hotel_wants_city(Guest, Wanted),
    hotel_in_area(City, Wanted).

hotel_suitable(Guest, Hotel) :-
    hotel(Hotel, _, _, _, Price, Style),
    hotel_city_ok(Guest, Hotel),
    hotel_budget(Guest, Budget),
    Price =< Budget,
    hotel_purpose(Guest, Purpose),
    (   Style == Purpose
    ;   Purpose == budget
    ),
    forall(hotel_needs(Guest, Amen), hotel_amenity(Hotel, Amen)).

hotel_reason(Guest, Hotel, Reason) :-
    hotel(Hotel, Name, City, Stars, Price, _),
    format(atom(Reason), '~w in ~w, ~w star(s), GHS ~w.', [Name, City, Stars, Price]).
hotel_reason(Guest, Hotel, Reason) :-
    hotel_needs(Guest, A),
    hotel_amenity(Hotel, A),
    format(atom(Reason), 'Has required amenity ~w.', [A]).
hotel_reason(Guest, Hotel, Reason) :-
    hotel(Hotel, _, City, _, _, _),
    hotel_wants_city(Guest, Wanted),
    hotel_in_area(City, Wanted),
    format(atom(Reason), 'Location ~w sits in requested area ~w.', [City, Wanted]).

run_hotel_domain :-
    standard_domain_menu('Domain 8  Hotel recommendation',
        hotel_consult, hotel_sample, hotel_backward,
        hotel_recursive, hotel_forward).

hotel_consult :-
    clear_answers(hotel),
    hub_banner('Hotel interview'),
    ask_choice('Destination city or region',
               [tarkwa, accra, kumasi, cape_coast, takoradi, tamale,
                western_region, ghana], C),
    C \= quit,
    set_answer(hotel, city, C),
    ask_integer('Maximum budget per night (GHS)', 100, 2000, B),
    B \= quit,
    set_answer(hotel, budget, B),
    ask_choice('Trip purpose', [business, leisure, budget], P),
    P \= quit,
    set_answer(hotel, purpose, P),
    forall(member(A, [wifi, parking, restaurant, conference, pool, beach, airport_shuttle]),
           ask_hotel_amenity(A)),
    hotel_report(guest).

ask_hotel_amenity(A) :-
    format(atom(Q), 'Must the hotel have ~w?', [A]),
    ask_yes_no(Q, Ans),
    Ans \= quit,
    store_yes_no(hotel, A, Ans).

hotel_report(Guest) :-
    nl,
    hub_banner('Hotel matches'),
    findall(Hotel, hotel_suitable(Guest, Hotel), Hs0),
    sort(Hs0, Hs),
    (   Hs == []
    ->  format('No hotel matched city, budget, purpose and amenities.~n', []),
        format('Try a higher budget or fewer required amenities.~n', [])
    ;   forall(member(H, Hs), (
            hotel(H, Name, City, Stars, Price, Style),
            format('  ~w  ~w (~w, ~w*, GHS ~w, ~w)~n',
                   [H, Name, City, Stars, Price, Style])
        )),
        Hs = [Top|_],
        format('~nWhy ~w fits:~n', [Top]),
        findall(R, hotel_reason(Guest, Top, R), Rs),
        print_lines(Rs)
    ),
    nl.

hotel_sample :-
    ask_known('Guest (g_business, g_beach, g_student)', hotel_guest, G),
    (G == quit -> true ; hotel_report(G)).

hotel_backward :-
    ask_known('Guest (g_business, g_beach, g_student)', hotel_guest, G),
    G \= quit, !,
    ask_choice('Hotel',
               [h_tarkwa_crest, h_tarkwa_inn, h_accra_gold, h_accra_beach,
                h_accra_host, h_cape_surf, h_cape_hist], H),
    H \= quit, !,
    format('~nBackward goal: hotel_suitable(~w, ~w)~n', [G, H]),
    (   hotel_suitable(G, H)
    ->  format('Result: YES~n', []),
        findall(R, hotel_reason(G, H, R), Rs),
        print_lines(Rs)
    ;   format('Result: NO~n', [])
    ).
hotel_backward.

hotel_recursive :-
    ask_choice('Place',
               [tarkwa, takoradi, accra, kumasi, cape_coast, tamale, western_region], P),
    (   P == quit
    ->  true
    ;   format('~n~w is inside:~n', [P]),
        findall(A, (hotel_in_area(P, A), A \= P), As),
        print_lines(As)
    ).

hotel_forward :-
    ask_known('Guest (g_business, g_beach, g_student)', hotel_guest, G),
    (   G == quit
    ->  true
    ;   findall(H, hotel_suitable(G, H), Hs),
        format('~nForward: hotels derived for ~w:~n', [G]),
        print_lines(Hs)
    ).

hotel_self_check :-
    check_line(hotel_suitable(g_business, h_tarkwa_crest), 'business tarkwa crest'),
    check_line(hotel_suitable(g_beach, h_cape_surf), 'beach cape surf'),
    check_line(\+ hotel_suitable(g_student, h_accra_gold), 'student cannot afford gold'),
    check_line(hotel_in_area(tarkwa, ghana), 'tarkwa is in ghana').
