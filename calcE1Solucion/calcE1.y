
%{
#include <stdio.h>
void main();
void yyerror();
extern int yylex();
%}

%token MAS MENOS POR DIV MOD PARI PARD NUM PC

%%
entrada : 
	| entrada linea;

linea : expresion '\n' {printf("%d\n",$1);} ;

expresion : expresion MAS termino  {$$ = $1 + $3; }
          | expresion MENOS termino {$$ = $1 - $3;}
          | termino ;

termino : termino POR factor {$$ = $1 * $3;}
        | termino DIV factor {$$ = $1 / $3;}
        | termino MOD factor {$$ = $1 % $3;}
        | factor ;

factor : PARI expresion PARD {$$ = $2;}
	| MENOS factor {$$=-$2;} 
       | NUM ;

%%

void yyerror()
{
printf("Error sintáctico");
}

void main()
{
 yyparse();
}

