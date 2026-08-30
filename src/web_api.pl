%==============================================================================
% HTTP JSON API for the Multi-Domain Expert System website
%==============================================================================

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).
:- use_module(library(lists)).

:- http_handler(root(api/health), api_health, []).
:- http_handler(root(api/options), api_options, []).
:- http_handler(root(api/advising/sample), api_adv_sample, [method(post)]).
:- http_handler(root(api/advising/consult), api_adv_consult, [method(post)]).
:- http_handler(root(api/advising/eligible), api_adv_eligible, [method(post)]).
:- http_handler(root(api/advising/prereqs), api_adv_prereqs, [method(post)]).
:- http_handler(root(api/advising/forward), api_adv_forward, [method(post)]).
:- http_handler(root(api/advising/whatif), api_adv_whatif, [method(post)]).
:- http_handler(root(api/medical/assess), api_generic(medical), [method(post)]).
:- http_handler(root(api/career/assess), api_generic(career), [method(post)]).
:- http_handler(root(api/library/assess), api_generic(library), [method(post)]).
:- http_handler(root(api/cyber/assess), api_generic(cyber), [method(post)]).
:- http_handler(root(api/farming/assess), api_generic(farming), [method(post)]).
:- http_handler(root(api/vehicle/assess), api_generic(vehicle), [method(post)]).
:- http_handler(root(api/hotel/assess), api_generic(hotel), [method(post)]).
:- http_handler(root(api/legal/assess), api_generic(legal), [method(post)]).
:- http_handler(root(api/admission/assess), api_generic(admission), [method(post)]).
:- http_handler(root(api/medical/backward), api_bw(medical), [method(post)]).
:- http_handler(root(api/career/backward), api_bw(career), [method(post)]).
:- http_handler(root(api/library/backward), api_bw(library), [method(post)]).
:- http_handler(root(api/cyber/backward), api_bw(cyber), [method(post)]).
:- http_handler(root(api/farming/backward), api_bw(farming), [method(post)]).
:- http_handler(root(api/vehicle/backward), api_bw(vehicle), [method(post)]).
:- http_handler(root(api/hotel/backward), api_bw(hotel), [method(post)]).
:- http_handler(root(api/legal/backward), api_bw(legal), [method(post)]).
:- http_handler(root(api/admission/backward), api_bw(admission), [method(post)]).
:- http_handler(root(api/medical/recursive), api_rec(medical), [method(post)]).
:- http_handler(root(api/career/recursive), api_rec(career), [method(post)]).
:- http_handler(root(api/library/recursive), api_rec(library), [method(post)]).
:- http_handler(root(api/cyber/recursive), api_rec(cyber), [method(post)]).
:- http_handler(root(api/farming/recursive), api_rec(farming), [method(post)]).
:- http_handler(root(api/vehicle/recursive), api_rec(vehicle), [method(post)]).
:- http_handler(root(api/hotel/recursive), api_rec(hotel), [method(post)]).
:- http_handler(root(api/legal/recursive), api_rec(legal), [method(post)]).
:- http_handler(root(api/admission/recursive), api_rec(admission), [method(post)]).
:- http_handler(root(api/medical/forward), api_fw(medical), [method(post)]).
:- http_handler(root(api/career/forward), api_fw(career), [method(post)]).
:- http_handler(root(api/library/forward), api_fw(library), [method(post)]).
:- http_handler(root(api/cyber/forward), api_fw(cyber), [method(post)]).
:- http_handler(root(api/farming/forward), api_fw(farming), [method(post)]).
:- http_handler(root(api/vehicle/forward), api_fw(vehicle), [method(post)]).
:- http_handler(root(api/hotel/forward), api_fw(hotel), [method(post)]).
:- http_handler(root(api/legal/forward), api_fw(legal), [method(post)]).
:- http_handler(root(api/admission/forward), api_fw(admission), [method(post)]).

api_health(_Request) :-
    reply_json_dict(_{ok: true, system: 'MDES', domains: 10}).

api_guard(Goal) :-
    catch(with_mutex(mdes_web, Goal), Error, api_fail(Error)).

api_fail(Error) :-
    message_to_string(Error, Msg),
    reply_json_dict(_{error: Msg}, [status(400)]).

atomize(V, V) :-
    atom(V), !.
atomize(V, A) :-
    string(V), !,
    atom_string(A, V).
atomize(V, V) :-
    number(V), !.
atomize(true, yes) :- !.
atomize(false, no) :- !.
atomize(V, A) :-
    term_to_atom(V, A).

atomize_list([], []).
atomize_list([H|T], [A|R]) :-
    atomize(H, A),
    atomize_list(T, R).

need(Dict, Key, Atom) :-
    get_dict(Key, Dict, Raw),
    atomize(Raw, Atom).

need_num(Dict, Key, Num) :-
    get_dict(Key, Dict, Num),
    number(Num).

opt(Dict, Key, Default, Value) :-
    (   get_dict(Key, Dict, Raw)
    ->  atomize(Raw, Value)
    ;   Value = Default
    ).

text_list(Terms, Atoms) :-
    maplist(term_to_atom, Terms, Atoms).

apply_yes_map(Domain, Dict) :-
    findall(K-V, get_dict(K, Dict, V), Pairs),
    forall(member(K-V, Pairs), (
        atomize(K, KA),
        atomize(V, VA),
        (   VA == true
        ->  set_answer(Domain, KA, yes)
        ;   VA == yes
        ->  set_answer(Domain, KA, yes)
        ;   VA == false
        ->  set_answer(Domain, KA, no)
        ;   set_answer(Domain, KA, VA)
        )
    )).

%------------------------------------------------------------------------------
% Options catalogue for the website
%------------------------------------------------------------------------------
api_options(_Request) :-
    findall(_{id: C, title: T, credits: Cr, level: L},
            course(C, T, Cr, L), Courses),
    reply_json_dict(_{
        students: [ama, kwame, akosua, kofi, yaw, abena, kojo, efua],
        semesters: [first, second],
        interests: [software, ai, security, networks, data, embedded, web, research],
        courses: Courses,
        medical_patients: [kwaku, adwoa, fiifi],
        medical_diseases: [malaria, typhoid, influenza, migraine, covid19, asthma, gastritis, dengue, anemia, meningitis],
        medical_complications: [malaria, anemia, typhoid, covid19, pneumonia, dengue, meningitis, asthma],
        career_people: [kwesi, akua, yawb],
        career_jobs: [software_engineer, data_scientist, cybersecurity_analyst, network_engineer, product_manager, lecturer, ui_designer, agritech_officer, database_administrator, technical_writer],
        career_skills: [python, statistics, networks, security, writing, leadership, design, farming_knowledge, databases, communication],
        career_interests: [software, ai, security, teaching, design, agriculture],
        career_ladder: [junior_developer, developer, senior_developer, lead_engineer, analyst, assistant_lecturer],
        library_readers: [ama_lib, kofi_lib, efua_lib],
        library_topics: [prolog, ai, software, databases, networks, security, literature, agriculture, law, admissions, python, maths, medicine, hospitality, autos, cs],
        library_books: [b01, b02, b04, b09, b11, b16, b17],
        cyber_cases: [case_phish, case_ransom, case_ddos],
        cyber_types: [phishing, ransomware, ddos, insider_misuse, malware, data_breach, brute_force],
        cyber_indicators: [suspicious_email, credential_harvest_page, encrypted_files, ransom_note, high_traffic, service_outage, odd_login_hour, large_export, unknown_process, failed_logins],
        cyber_stages: [recon, weaponize, deliver, exploit, install, command_control],
        farm_plots: [plot_north, plot_wet, plot_dry],
        farm_crops: [maize, cassava, cocoa, rice, tomato, pepper, plantain, groundnut],
        farm_soils: [sandy, loam, clay, laterite],
        farm_rains: [low, medium, high],
        farm_pests: [fall_armyworm, black_pod, stem_borer, mosaic_virus, aphids],
        vehicles: [car_a, car_b, car_c],
        veh_faults: [dead_battery, bad_alternator, worn_brake_pads, overheating, flat_tyre, clogged_air_filter, bad_spark_plugs, empty_fuel],
        veh_symptoms: [no_start, dim_lights, clicking_start, grinding_brakes, long_stopping, steam_from_bonnet, temp_gauge_high, pulling_left, low_power, rough_idle, squeal_on_start, fuel_gauge_empty],
        veh_components: [engine, starter, brakes, cooling, battery, charging],
        hotel_guests: [g_business, g_beach, g_student],
        hotel_ids: [h_tarkwa_crest, h_tarkwa_inn, h_accra_gold, h_accra_beach, h_accra_host, h_cape_surf, h_cape_hist],
        hotel_places: [tarkwa, accra, kumasi, cape_coast, takoradi, tamale, western_region, ghana],
        hotel_purposes: [business, leisure, budget],
        hotel_amenities: [wifi, parking, restaurant, conference, pool, beach, airport_shuttle],
        legal_clients: [c_rent, c_job, c_land],
        legal_matters: [tenancy, employment, land, family, contract, cybercrime, traffic, consumer],
        legal_facts: [unpaid_rent, illegal_eviction, dismissal_no_notice, unpaid_wages, boundary_dispute, family_maintenance, broken_agreement, online_fraud, accident_injury, defective_product],
        legal_courts: [magistrate, circuit, high_court, court_of_appeal],
        adm_applicants: [app_strong, app_arts, app_border],
        adm_programmes: [computer_engineering, mining_engineering, electrical_engineering, business_admin, nursing, mathematics, geomatic_engineering],
        adm_tracks: [science, general_arts, home_economics, business, technical],
        adm_subjects: [core_maths, english, physics, elective_maths, chemistry, science_core, geography, government]
    }).

%------------------------------------------------------------------------------
% Advising
%------------------------------------------------------------------------------
advising_dict(Student, Semester, Dict) :-
    student_year(Student, Year),
    gpa(Student, GPA),
    credits_completed(Student, Credits),
    courses_completed_count(Student, Count),
    consultation_focus(Student, Focus),
    findall(I, student_interest(Student, I), Interests),
    explain_standing(Student, StandLines),
    findall(M, next_milestone(Student, M), Miles),
    findall(A, support_action(Student, A), Actions),
    semester_plan_credits(Student, Semester, Plan, PlanCredits),
    maplist(adv_card(Student), Plan, Cards),
    (   primary_track(Student, Track)
    ->  true
    ;   Track = unknown
    ),
    findall(Ind, industry_suggestion(Student, Ind), Inds),
    explain_graduation(Student, GradLines),
    text_list(Miles, MileAtoms),
    text_list(Actions, ActAtoms),
    Dict = _{
        student: Student,
        year: Year,
        semester: Semester,
        gpa: GPA,
        credits: Credits,
        courses_completed: Count,
        focus: Focus,
        interests: Interests,
        standing: StandLines,
        milestones: MileAtoms,
        actions: ActAtoms,
        plan: Cards,
        plan_credits: PlanCredits,
        track: Track,
        industries: Inds,
        graduation: GradLines
    }.

adv_card(Student, Course, Card) :-
    course(Course, Title, Credits, Level),
    upcase_course(Course, Display),
    (   core_course(Course)
    ->  Kind = core
    ;   elective(Course, Kind)
    ->  true
    ;   Kind = other
    ),
    (   catch(course_priority_score(Student, Course, Score), _, fail)
    ->  true
    ;   Score = 0
    ),
    explain_course(Student, Course, Reasons),
    Card = _{
        id: Course,
        code: Display,
        title: Title,
        credits: Credits,
        level: Level,
        kind: Kind,
        score: Score,
        reasons: Reasons
    }.

api_adv_sample(Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        need(In, student, Student),
        opt(In, semester, first, Semester),
        student(Student),
        advising_dict(Student, Semester, Out),
        reply_json_dict(Out)
    )).

api_adv_consult(Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        begin_session,
        need_num(In, year, Year),
        (   get_dict(gpa, In, GPA), number(GPA)
        ->  true
        ;   GPA = 2.5
        ),
        opt(In, semester, first, Semester),
        opt(In, interest, software, Interest),
        (   get_dict(courses, In, Cs0)
        ->  atomize_list(Cs0, Courses)
        ;   Courses = []
        ),
        assertz(student_year(guest, Year)),
        assertz(declared_gpa(guest, GPA)),
        assertz(session_flag(semester(Semester))),
        assertz(student_interest(guest, Interest)),
        forall(member(C, Courses), (
            course(C, _, _, _)
        ->  (passed(guest, C) -> true ; assertz(passed(guest, C)))
        ;   true
        )),
        advising_dict(guest, Semester, Out),
        clear_session,
        retractall(student(guest)),
        reply_json_dict(Out)
    )).

api_adv_eligible(Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        need(In, student, Student),
        need(In, course, Course),
        student(Student),
        course(Course, Title, Credits, Level),
        upcase_course(Course, Display),
        (   eligible_for(Student, Course)
        ->  explain_course(Student, Course, Reasons),
            Result = yes
        ;   explain_ineligible(Student, Course, Reasons),
            Result = no
        ),
        reply_json_dict(_{
            result: Result,
            student: Student,
            course: Display,
            title: Title,
            credits: Credits,
            level: Level,
            reasons: Reasons
        })
    )).

api_adv_prereqs(Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        need(In, course, Course),
        course(Course, Title, _, _),
        findall(_{id: P, title: PT, kind: Kind}, (
            ancestor_prerequisite(Course, P),
            course(P, PT, _, _),
            (prerequisite(Course, P) -> Kind = direct ; Kind = ancestor)
        ), Nodes),
        longest_prerequisite_path(Course, Depth),
        reply_json_dict(_{course: Course, title: Title, ancestors: Nodes, longest_path: Depth})
    )).

api_adv_forward(Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        need(In, student, Student),
        student(Student),
        run_forward_steps(Student, StepFacts),
        maplist(term_to_atom, StepFacts, Steps),
        forward_infer(Student),
        derived_facts(Student, Facts),
        maplist(term_to_atom, Facts, Profile),
        reply_json_dict(_{student: Student, steps: Steps, profile: Profile})
    )).

api_adv_whatif(Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        need(In, student, Student),
        need(In, course, Extra),
        what_if_unlocks(Student, Extra, Newly),
        findall(_{id: C, title: T}, (member(C, Newly), course(C, T, _, _)), Rows),
        reply_json_dict(_{student: Student, passed: Extra, unlocked: Rows})
    )).

%------------------------------------------------------------------------------
% Generic domain assess / backward / recursive / forward
%------------------------------------------------------------------------------
api_generic(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        domain_assess(Domain, In, Out),
        reply_json_dict(Out)
    )).

api_bw(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        domain_backward(Domain, In, Out),
        reply_json_dict(Out)
    )).

api_rec(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        domain_recursive(Domain, In, Out),
        reply_json_dict(Out)
    )).

api_fw(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((
        domain_forward(Domain, In, Out),
        reply_json_dict(Out)
    )).

%--- medical ---
domain_assess(medical, In, Out) :-
    (   need(In, patient, P),
        med_patient(P)
    ->  medical_out(P, Out)
    ;   clear_answers(medical),
        (get_dict(answers, In, A) -> apply_yes_map(medical, A) ; true),
        medical_out(guest, Out),
        clear_answers(medical)
    ).

medical_out(P, _{
        person: P,
        emergency: Emerg,
        ranked: Ranked,
        primary: Primary,
        reasons: Reasons,
        complications: Comps,
        disclaimer: 'Educational output only. Seek a licensed clinician for care.'
    }) :-
    (med_emergency(P) -> Emerg = true ; Emerg = false),
    findall(_{score: T, disease: D}, med_ranked(P, D, T), Pairs),
    sort(0, @>=, Pairs, Ranked),
    (   Ranked = [_{score:_, disease: Primary}|_]
    ->  findall(R, med_reason(P, Primary, R), Reasons),
        findall(C, med_ancestor_complication(Primary, C), Comps)
    ;   Primary = none,
        Reasons = [],
        Comps = []
    ).

domain_backward(medical, In, _{result: Result, reasons: Rs}) :-
    need(In, patient, P),
    need(In, target, D),
    (   med_likely(P, D)
    ->  Result = yes,
        findall(R, med_reason(P, D, R), Rs)
    ;   Result = no,
        Rs = ['Required symptoms or score not met.']
    ).

domain_recursive(medical, In, _{start: D, nodes: Cs}) :-
    need(In, start, D),
    findall(C, med_ancestor_complication(D, C), Cs).

domain_forward(medical, In, _{person: P, facts: Facts}) :-
    need(In, patient, P),
    med_forward_facts(P, Raw),
    maplist(term_to_atom, Raw, Facts).

%--- career ---
domain_assess(career, In, Out) :-
    (   need(In, person, P),
        career_person(P)
    ->  career_out(P, Out)
    ;   clear_answers(career),
        (get_dict(interest, In, I0) -> atomize(I0, I), set_answer(career, interest, I) ; true),
        (get_dict(answers, In, A) -> apply_yes_map(career, A) ; true),
        career_out(guest, Out),
        clear_answers(career)
    ).

career_out(P, _{person: P, matches: Matches, best: Best, reasons: Rs}) :-
    findall(_{score: S, job: J}, career_score(P, J, S), Pairs),
    sort(0, @>=, Pairs, Matches),
    (   Matches = [_{score:_, job: Best}|_]
    ->  findall(R, career_reason(P, Best, R), Rs)
    ;   Best = none, Rs = []
    ).

domain_backward(career, In, _{result: Result, reasons: Rs}) :-
    need(In, person, P), need(In, target, J),
    (career_suitable(P, J) -> Result = yes, findall(R, career_reason(P, J, R), Rs)
    ; Result = no, Rs = []).

domain_recursive(career, In, _{start: From, nodes: Ts}) :-
    need(In, start, From),
    findall(T, career_reaches(From, T), Ts).

domain_forward(career, In, _{person: P, jobs: Jobs}) :-
    need(In, person, P),
    findall(J, career_suitable(P, J), Jobs).

%--- library ---
domain_assess(library, In, Out) :-
    (   need(In, reader, R),
        lib_reader(R)
    ->  library_out(R, Out)
    ;   clear_answers(library),
        (get_dict(topic, In, T0) -> atomize(T0, T), set_answer(library, topic, T) ; true),
        (get_dict(level, In, L), number(L) -> set_answer(library, level, L) ; set_answer(library, level, 2)),
        library_out(guest, Out),
        clear_answers(library)
    ).

library_out(R, _{reader: R, books: Books, reasons: Rs}) :-
    findall(_{id: B, title: Title, difficulty: D},
            (lib_suitable(R, B), lib_book(B, Title, D)), Books),
    (   Books = [_{id: Top, title:_, difficulty:_}|_]
    ->  findall(X, lib_reason(R, Top, X), Rs0), sort(Rs0, Rs)
    ;   Rs = []
    ).

domain_backward(library, In, _{result: Result, reasons: Rs}) :-
    need(In, reader, R), need(In, target, B),
    (lib_suitable(R, B) -> Result = yes, findall(X, lib_reason(R, B, X), Rs)
    ; Result = no, Rs = []).

domain_recursive(library, In, _{start: T, nodes: As}) :-
    need(In, start, T),
    findall(A, lib_ancestor_topic(T, A), As).

domain_forward(library, In, _{reader: R, books: Books}) :-
    need(In, reader, R),
    findall(B, lib_suitable(R, B), Books).

%--- cyber ---
domain_assess(cyber, In, Out) :-
    (   need(In, case, C),
        cy_case(C)
    ->  cyber_out(C, Out)
    ;   clear_answers(cyber),
        (get_dict(answers, In, A) -> apply_yes_map(cyber, A) ; true),
        cyber_out(guest, Out),
        clear_answers(cyber)
    ).

cyber_out(C, _{case: C, ranked: Ranked, primary: Primary, reasons: Rs, playbook: Acts}) :-
    findall(_{score: S, type: T, severity: Sev},
            (cy_likely(C, T), cy_score(C, T, S), cy_severity(T, Sev)), Pairs),
    sort(0, @>=, Pairs, Ranked),
    (   cy_primary(C, Primary)
    ->  findall(R, cy_reason(C, Primary, R), Rs),
        findall(A, cy_action(Primary, A), Acts)
    ;   Primary = none, Rs = [], Acts = []
    ).

domain_backward(cyber, In, _{result: Result, reasons: Rs}) :-
    need(In, case, C), need(In, target, T),
    (cy_likely(C, T) -> Result = yes, findall(R, cy_reason(C, T, R), Rs)
    ; Result = no, Rs = []).

domain_recursive(cyber, In, _{start: S, nodes: Ls}) :-
    need(In, start, S),
    findall(L, cy_later_stage(S, L), Ls).

domain_forward(cyber, In, _{case: C, actions: Acts}) :-
    need(In, case, C),
    findall(A, cy_playbook(C, A), Acts).

%--- farming ---
domain_assess(farming, In, Out) :-
    (   need(In, plot, P),
        farm_plot(P)
    ->  farming_out(P, Out)
    ;   clear_answers(farming),
        (get_dict(soil, In, S0) -> atomize(S0, S), set_answer(farming, soil, S) ; true),
        (get_dict(rain, In, R0) -> atomize(R0, R), set_answer(farming, rain, R) ; true),
        (get_dict(answers, In, A) -> apply_yes_map(farming, A) ; true),
        farming_out(guest, Out),
        clear_answers(farming)
    ).

farming_out(P, _{plot: P, crops: Crops, actions: Acts, reasons: Rs, warnings: Warns}) :-
    findall(C, farm_suitable(P, C), Crops0), sort(Crops0, Crops),
    findall(A, farm_advice(P, A), Acts),
    findall(_{crop: C, pest: Pest}, farm_warning(P, C, pest(Pest)), Warns),
    (   Crops = [Top|_]
    ->  findall(R, farm_reason(P, Top, R), Rs)
    ;   Rs = []
    ).

domain_backward(farming, In, _{result: Result, reasons: Rs}) :-
    need(In, plot, P), need(In, target, C),
    (farm_suitable(P, C) -> Result = yes, findall(R, farm_reason(P, C, R), Rs)
    ; Result = no, Rs = ['Soil or rainfall does not match.']).

domain_recursive(farming, In, _{start: C, nodes: Xs}) :-
    need(In, start, C),
    findall(X, farm_rotation_path(C, X, _), Xs0), sort(Xs0, Xs).

domain_forward(farming, In, _{plot: P, crops: Crops}) :-
    need(In, plot, P),
    findall(C, farm_suitable(P, C), Crops).

%--- vehicle ---
domain_assess(vehicle, In, Out) :-
    (   need(In, car, C),
        veh_car(C)
    ->  vehicle_out(C, Out)
    ;   clear_answers(vehicle),
        (get_dict(answers, In, A) -> apply_yes_map(vehicle, A) ; true),
        vehicle_out(guest, Out),
        clear_answers(vehicle)
    ).

vehicle_out(C, _{
        car: C,
        ranked: Ranked,
        primary: Primary,
        reasons: Rs,
        actions: Acts,
        disclaimer: 'Educational workshop aid — not a substitute for a mechanic.'
    }) :-
    findall(_{score: S, fault: F}, (veh_likely(C, F), veh_score(C, F, S)), Pairs),
    sort(0, @>=, Pairs, Ranked),
    (   veh_primary(C, Primary)
    ->  findall(R, veh_reason(C, Primary, R), Rs),
        findall(A, veh_action(Primary, A), Acts)
    ;   Primary = none, Rs = [], Acts = []
    ).

domain_backward(vehicle, In, _{result: Result, reasons: Rs}) :-
    need(In, car, C), need(In, target, F),
    (veh_likely(C, F) -> Result = yes, findall(R, veh_reason(C, F, R), Rs)
    ; Result = no, Rs = []).

domain_recursive(vehicle, In, _{start: Comp, nodes: Bs}) :-
    need(In, start, Comp),
    findall(B, veh_needs(Comp, B), Bs0), sort(Bs0, Bs).

domain_forward(vehicle, In, _{car: C, faults: Faults}) :-
    need(In, car, C),
    findall(F, veh_likely(C, F), Faults).

%--- hotel ---
domain_assess(hotel, In, Out) :-
    (   need(In, guest, G),
        hotel_guest(G)
    ->  hotel_out(G, Out)
    ;   clear_answers(hotel),
        (get_dict(city, In, C0) -> atomize(C0, C), set_answer(hotel, city, C) ; true),
        (get_dict(budget, In, B), number(B) -> set_answer(hotel, budget, B) ; set_answer(hotel, budget, 400)),
        (get_dict(purpose, In, P0) -> atomize(P0, P), set_answer(hotel, purpose, P) ; true),
        (get_dict(answers, In, A) -> apply_yes_map(hotel, A) ; true),
        hotel_out(guest, Out),
        clear_answers(hotel)
    ).

hotel_out(G, _{guest: G, hotels: Hotels, reasons: Rs}) :-
    findall(_{id: H, name: Name, city: City, stars: Stars, price: Price, style: Style},
            (hotel_suitable(G, H), hotel(H, Name, City, Stars, Price, Style)), Hotels),
    (   Hotels = [_{id: Top, name:_, city:_, stars:_, price:_, style:_}|_]
    ->  findall(R, hotel_reason(G, Top, R), Rs)
    ;   Rs = []
    ).

domain_backward(hotel, In, _{result: Result, reasons: Rs}) :-
    need(In, guest, G), need(In, target, H),
    (hotel_suitable(G, H) -> Result = yes, findall(R, hotel_reason(G, H, R), Rs)
    ; Result = no, Rs = []).

domain_recursive(hotel, In, _{start: P, nodes: As}) :-
    need(In, start, P),
    findall(A, (hotel_in_area(P, A), A \= P), As).

domain_forward(hotel, In, _{guest: G, hotels: Hs}) :-
    need(In, guest, G),
    findall(H, hotel_suitable(G, H), Hs).

%--- legal ---
domain_assess(legal, In, Out) :-
    (   need(In, client, C),
        legal_client(C)
    ->  legal_out(C, Out)
    ;   clear_answers(legal),
        (get_dict(answers, In, A) -> apply_yes_map(legal, A) ; true),
        legal_out(guest, Out),
        clear_answers(legal)
    ).

legal_out(C, _{
        client: C,
        ranked: Ranked,
        primary: Primary,
        forum: Forum,
        reasons: Rs,
        steps: Steps,
        disclaimer: 'Educational guidance only. Speak to a licensed lawyer.'
    }) :-
    findall(_{score: S, matter: M}, (legal_likely(C, M), legal_score(C, M, S)), Pairs),
    sort(0, @>=, Pairs, Ranked),
    (   legal_primary(C, Primary)
    ->  legal_forum(Primary, Forum),
        findall(R, legal_reason(C, Primary, R), Rs),
        findall(St, legal_next_step(Primary, St), Steps)
    ;   Primary = none, Forum = none, Rs = [], Steps = []
    ).

domain_backward(legal, In, _{result: Result, reasons: Rs}) :-
    need(In, client, C), need(In, target, M),
    (legal_likely(C, M) -> Result = yes, findall(R, legal_reason(C, M, R), Rs)
    ; Result = no, Rs = []).

domain_recursive(legal, In, _{start: Ct, nodes: Hs}) :-
    need(In, start, Ct),
    findall(H, legal_higher(Ct, H), Hs).

domain_forward(legal, In, _{client: C, matters: Ms}) :-
    need(In, client, C),
    findall(M, legal_likely(C, M), Ms).

%--- admission ---
domain_assess(admission, In, Out) :-
    (   need(In, applicant, A),
        adm_applicant(A)
    ->  admission_out(A, Out)
    ;   clear_answers(admission),
        (get_dict(track, In, T0) -> atomize(T0, T), set_answer(admission, track, T) ; true),
        (get_dict(aggregate, In, Agg), number(Agg) -> set_answer(admission, aggregate, Agg) ; true),
        (get_dict(answers, In, Ans) -> apply_yes_map(admission, Ans) ; true),
        admission_out(guest, Out),
        clear_answers(admission)
    ).

admission_out(A, _{
        applicant: A,
        programmes: Progs,
        reasons: Rs,
        note: 'Illustrative cutoffs for teaching — not an official UMaT list. Lower aggregate is better.'
    }) :-
    findall(_{id: P, cutoff: C},
            (adm_eligible(A, P), adm_cutoff(P, C)), Progs),
    (   Progs = [_{id: Top, cutoff:_}|_]
    ->  findall(R, adm_reason(A, Top, R), Rs)
    ;   Rs = []
    ).

domain_backward(admission, In, _{result: Result, reasons: Rs, missing: Miss}) :-
    need(In, applicant, A), need(In, target, P),
    (   adm_eligible(A, P)
    ->  Result = yes, findall(R, adm_reason(A, P, R), Rs), Miss = []
    ;   Result = no, Rs = [], findall(S, adm_missing(A, P, S), Miss)
    ).

domain_recursive(admission, In, _{start: T, tracks: Ss, programmes: Ps}) :-
    need(In, start, T),
    findall(S, adm_track_reaches(T, S), Ss),
    findall(P, (adm_track_reaches(T, Super), adm_feeder(Super, P)), Ps0),
    sort(Ps0, Ps).

domain_forward(admission, In, _{applicant: A, programmes: Ps}) :-
    need(In, applicant, A),
    findall(P, adm_eligible(A, P), Ps).
