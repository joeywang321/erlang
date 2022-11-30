-module(afile_server).
-export([start/1,loop/1]).

start(Dir) -> spawn(?MODULE, loop, [Dir]).

loop(Dir) -> 
    receive 
        {Client, list_dir} ->
            Client ! {self(), file:list_dir(Dir)},
            loop(Dir);
        {Client, {get_file, File}} ->
            Full = filename:join(Dir, File),
            Client ! {self(), file:read_file(Full)},
            loop(Dir);
        {Client, {put_file, File, Content}} ->
            Full = filename:join(Dir, File),
            case file:write_file(Full, list_to_binary(Content)) of
                ok ->
                    Client ! {self(), successfully};
                {error, Reason} ->
                    io:format("~p~n", Reason)
                end,
            loop(Dir);
        {Client, true} ->
            Client ! {exit},
            true
        end.