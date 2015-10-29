-module(tree_eqc).
-include_lib("eqc/include/eqc.hrl").
-include_lib("eqc/include/eqc_statem.hrl").
-compile(export_all).

initial_state() ->
  [].

%% insert

insert_args(S) ->
  [key(S),int()].

%% insert_pre(S,[K,V]) ->
%%   not lists:keymember(K,1,S).

insert(K,V) ->
  tree:insert(K,V).

insert_next(S,_,[K,V]) ->
  lists:keystore(K,1,S,{K,V}).

%% lookup

lookup_args(S) ->
  [key(S)].

lookup(K) ->
  tree:lookup(K).

lookup_post(S,[K],Res) ->
  eq(Res,proplists:get_value(K,S,-1)).

%% update

update_args(S) ->
  [key(S),int()].

update_pre(S,[K,_]) ->
  lists:keymember(K,1,S).

update(K,V) ->
  tree:update(K,V).

update_next(S,_,[K,V]) ->
  lists:keystore(K,1,S,{K,V}).

%% delete

delete_args(S) ->
  [key(S)].

delete_pre(S,[K]) ->
  lists:keymember(K,1,S).

delete(K) ->
  tree:delete(K).

delete_next(S,_,[K]) ->
  lists:keydelete(K,1,S).

%% generators

key([]) ->
  non_empty(list(choose($a,$z)));
key(S) ->
  oneof([elements([K || {K,_} <- S]),
         key([])]).

%% @doc Default generated property
prop_tree() ->
  ?SETUP(fun() ->
             compile(),
             fun() -> cleanup() 
             end
         end,
  ?FORALL(Cmds, commands(?MODULE),
          ?ALWAYS(1000,
                  begin
                    tree:init(),
                    {H, S, Res} = run_commands(?MODULE,Cmds),
                    pretty_commands(?MODULE, Cmds, {H, S, Res},
                                    aggregate(command_names(Cmds),Res == ok))
                  end))).


compile() ->
  eqc_c:start(tree, [definitions_only, {cflags, "-coverage"}]).

cleanup() ->
  eqc_c:stop().

