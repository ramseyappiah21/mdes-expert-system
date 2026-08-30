%==============================================================================
% MDES — load advising core plus all other domains (no interactive start)
%==============================================================================

:- use_module(library(lists)).
:- use_module(library(readutil)).

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
:- consult(hub).
