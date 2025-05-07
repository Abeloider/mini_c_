calc:	lex.yy.c calcE1.tab.c
	gcc lex.yy.c calcE1.tab.c -lfl -o calcE1

lex.yy.c: calcE1.tab.h calcE1.l	
	flex calcE1.l

calcE1.tab.h calcE1.tab.c: calcE1.y
	bison -d calcE1.y

limpiar:
	rm lex.yy.c calcE1.tab.h calcE1.tab.c

	
