
%{
#include <stdio.h>
void yyerror();
extern int yylex();
%}


%token PARI PARD FIN ASIG MAS MENOS POR DIV MOD NUM ID


%%

entrada : 	
	| entrada linea ;

linea : expresion FIN {printf("%d\n",$1);} 
	| ID ASIG expresion FIN {printf("La variable ID toma el valor %d\n",$3);}
	;

expresion : expresion MAS expresion {$$ = $1 + $3; }
          | expresion MENOS expresion {$$ = $1 - $3;}
          | expresion POR expresion {$$ = $1 * $3;}
       	  | expresion DIV expresion {$$ = $1 / $3;}
        | expresion MOD expresion {$$ = $1 % $3;}
        | PARI expresion PARD {$$ = $2;}
	| MENOS expresion {$$=-$2;} 
       | NUM ;

%%

void yyerror()
{
printf("Se ha producido un error en esta expresion\n");
}

