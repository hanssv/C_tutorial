-module(tree_eqc).
-include_lib("eqc/include/eqc.hrl").
-include_lib("eqc/include/eqc_statem.hrl").
-compile(export_all).

initial_state() ->
  [].


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
             fun() -> cleanup()  %% must stop eqc_c in order to not get error "tree.gcda:stamp mismatch with notes file"
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
  eqc_c_cover_start(tree).

eqc_c_cover_start(File) ->
  eqc_c:start(File, [definitions_only, {cflags, "-coverage"}]).

cleanup() ->
  eqc_c_cover_stop().

eqc_c_cover_stop() ->
  eqc_c:stop().
