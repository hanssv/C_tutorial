
all: tree_eqc.beam 

tree: tree.c
	gcc -c tree.c -coverage

tree_eqc.beam: tree_eqc.erl
	erlc tree_eqc.erl 
