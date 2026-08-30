%==============================================================================
% MDES website — SWI-Prolog HTTP server
%   swipl -s src/web_server.pl
% then open http://127.0.0.1:8080/
% Hosts bind 0.0.0.0 and honour the PORT environment variable.
%==============================================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).

:- prolog_load_context(directory, Src),
   directory_file_path(Src, 'loader.pl', Loader),
   consult(Loader),
   consult(web_api),
   file_directory_name(Src, Root),
   directory_file_path(Root, web, WebDir),
   assertz(mdes_web_root(WebDir)).

:- http_handler(root(.), serve_index, []).
:- http_handler(root('index.html'), serve_index, []).
:- http_handler('/css/app.css', serve_rel('css/app.css'), []).
:- http_handler('/js/app.js', serve_rel('js/app.js'), []).
:- http_handler('/favicon.svg', serve_rel('favicon.svg'), []).

:- initialization(start_web, main).

server_port(Port) :-
    getenv('PORT', Atom),
    atom_number(Atom, Port), !.
server_port(8080).

start_web :-
    catch(mutex_create(mdes_web), _, true),
    mdes_web_root(WebDir),
    server_port(Port),
    (   catch(http_server(http_dispatch, [port(Port), ip(0.0.0.0)]), _, fail)
    ->  true
    ;   http_server(http_dispatch, [port(Port)])
    ),
    format('~nMDES website is running.~n', []),
    format('Open http://127.0.0.1:~w/~n', [Port]),
    format('Listening on 0.0.0.0:~w~n', [Port]),
    format('Static files from ~w~n', [WebDir]),
    format('Press Ctrl+C to stop.~n~n', []),
    thread_get_message(_).

serve_index(Request) :-
    serve_rel('index.html', Request).

serve_rel(Rel, Request) :-
    mdes_web_root(WebDir),
    directory_file_path(WebDir, Rel, File),
    exists_file(File),
    http_reply_file(File, [unsafe(true)], Request).
