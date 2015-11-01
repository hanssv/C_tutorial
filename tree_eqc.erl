-module(tree_eqc).
-include_lib("eqc/include/eqc.hrl").
-include_lib("eqc/include/eqc_statem.hrl").
-compile(export_all).

%% -- Initial state ----------------------------------------------------------
initial_state() ->
  [].

%% -- Operations -------------------------------------------------------------

%% --- Operation: insert ---
insert_args(S) ->
  [key(S), nat()].

insert(K, V) ->
  tree:insert(K, V).

insert_next(S, _, [K, V]) ->
  case lists:keymember(K, 1, S) of
    true  ->
      S;
    false ->
      lists:keystore(K, 1, S, {K, V})
  end.

%% --- Operation: lookup ---
lookup_args(S) ->
  [key(S)].

lookup(K) ->
  tree:lookup(K).

lookup_post(S, [K], Res) ->
  eq(Res, proplists:get_value(K, S, -1)).

%% --- Operation: update ---
update_args(S) ->
  [key(S), int()].

update_pre(S, [K, _]) ->
  lists:keymember(K, 1, S).

update(K,V) ->
  tree:update(K,V).

update_next(S, _, [K, V]) ->
  lists:keystore(K, 1, S, {K, V}).

%% --- Operation: delete ---
delete_args(S) ->
  [key(S)].

delete_pre(S, [K]) ->
  lists:keymember(K, 1, S).

delete(K) ->
  tree:delete(K).

delete_next(S, _, [K]) ->
  lists:keydelete(K, 1, S).

%% -- generators -------------------------------------------------------------
-define(KEYS, ["a", "b", "c", "d", "aa", "aaa", "bb", "bbb"]).

%% Make it slightly more probable for keys to collide
key([]) ->
  elements(?KEYS);
key(S) ->
  frequency([{1, elements([K || {K, _} <- S])},
             {1, key([])}]).

%% -- Property ---------------------------------------------------------------
%% Fine tune the weights
weight(_S, lookup) -> 3;
weight(_S, insert) -> 2;
weight(_S, _Op) -> 1.

prop_tree() ->
  eqc:testing_time(10,
  ?SETUP(fun() ->
             compile(),
             fun() -> cleanup() end
         end,
  ?FORALL(Cmds, commands(?MODULE),
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

