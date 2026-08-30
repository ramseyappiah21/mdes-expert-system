%==============================================================================
% Load the knowledge bases and JSON API core for Vercel / WASM
%==============================================================================

:- use_module(library(lists)).

:- prolog_load_context(directory, Dir),
   working_directory(_, Dir).

:- style_check(-discontiguous).
:- style_check(-singleton).

:- consult(knowledge_base).
:- consult(rules).
:- consult(inference).
:- consult(explanation).
:- consult(validation).
:- consult(consultation).
:- consult(domain_kit).
:- consult('domains/medical').
:- consult('domains/career').
:- consult('domains/library').
:- consult('domains/cyber').
:- consult('domains/farming').
:- consult('domains/vehicle').
:- consult('domains/hotel').
:- consult('domains/legal').
:- consult('domains/admission').
:- consult(api_core).
