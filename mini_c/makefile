
mini_binario: main.c lexico.tab.c lex.yy.c lexico.tab.h  listaCodigo.h listaCodigo.c  listaSimbolos.h listaSimbolos.c
	gcc lex.yy.c main.c lexico.tab.c     listaCodigo.c  listaSimbolos.c -lfl -o mini_binario 
lexico.tab.c lexico.tab.h: lexico.y
	bison -d -v lexico.y
lex.yy.c: p1.l
	flex p1.l

