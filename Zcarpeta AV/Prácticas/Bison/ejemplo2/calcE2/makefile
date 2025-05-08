calc: calc_main.c calc.tab.c lex.yy.c calc.tab.h
	gcc lex.yy.c calc_main.c calc.tab.c -lfl -o calc
calc.tab.c calc.tab.h: calc.y
	bison -d -v calc.y
lex.yy.c: calc.l
	flex calc.l
limpia:
	rm lex.yy.c calc.tab.c calc.tab.h calc
run: 
	./calc p
