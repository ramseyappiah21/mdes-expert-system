%==============================================================================
% HTTP JSON API for the Multi-Domain Expert System website
%==============================================================================

:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(lists)).

:- consult(api_core).

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

api_options(_Request) :-
    options_dict(Out),
    reply_json_dict(Out).

api_adv_sample(Request) :-
    http_read_json_dict(Request, In),
    api_guard((adv_sample_out(In, Out), reply_json_dict(Out))).

api_adv_consult(Request) :-
    http_read_json_dict(Request, In),
    api_guard((adv_consult_out(In, Out), reply_json_dict(Out))).

api_adv_eligible(Request) :-
    http_read_json_dict(Request, In),
    api_guard((adv_eligible_out(In, Out), reply_json_dict(Out))).

api_adv_prereqs(Request) :-
    http_read_json_dict(Request, In),
    api_guard((adv_prereqs_out(In, Out), reply_json_dict(Out))).

api_adv_forward(Request) :-
    http_read_json_dict(Request, In),
    api_guard((adv_forward_out(In, Out), reply_json_dict(Out))).

api_adv_whatif(Request) :-
    http_read_json_dict(Request, In),
    api_guard((adv_whatif_out(In, Out), reply_json_dict(Out))).

api_generic(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((domain_assess(Domain, In, Out), reply_json_dict(Out))).

api_bw(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((domain_backward(Domain, In, Out), reply_json_dict(Out))).

api_rec(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((domain_recursive(Domain, In, Out), reply_json_dict(Out))).

api_fw(Domain, Request) :-
    http_read_json_dict(Request, In),
    api_guard((domain_forward(Domain, In, Out), reply_json_dict(Out))).
