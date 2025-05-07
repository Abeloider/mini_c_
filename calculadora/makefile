calcE:lex.yy.c   calcE.tab.c 
	gcc  lex.yy.c calcE.tab.c -lfl -o calcE

calcE.tab.c calcE.tab.h : calcE.y
	bison -d calcE.y 


lex.yy.c: calcE.l
	flex calcE.l

limpiar :
	rm lex.yy.c calcE