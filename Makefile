all: tree_eqc.beam 

tree_eqc.beam: tree_eqc.erl
	erlc tree_eqc.erl 

