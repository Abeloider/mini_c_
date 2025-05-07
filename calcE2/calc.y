%{
#include <stdio.h>
void yyerror();
extern int yylex();
%}
//convertimos los datos al tipo de datos que elegimos para ello tambien necesitamos su respectivo token
%union{ 
int e;
char *c;
}


%token PARI PARD FIN ASIG 
%token <e> NUM 
%token <c> ID

%left MAS MENOS //asociatividad por la izquierda 
%left POR DIV MOD //asociatividadd por la izquierda con mas precedencia aun que los de arriba
%left UMENOS // añadimos para que el - tenga mas preferencia que el POR (-$2)

%type <e> expresion entrada


%%

entrada : 	                    {$$=1;} // inicializamos a 1
	| entrada {printf("Expr. %d:", $1);} linea {$$=$1+1;} // incrementa, bison permite añadir codigo c (printf)
       ;

linea : expresion FIN {printf(" %d\n",$1);} // enumeramos las expresions la declaramos en variables
	| ID ASIG expresion FIN {printf(" La variable %s toma el valor %d\n",$1,$3);} 
       | error FIN                               {} 
	; 

expresion : expresion MAS expresion {$$ = $1 + $3; }
          | expresion MENOS expresion {$$ = $1 - $3;}
          | expresion POR expresion {$$ = $1 * $3;}
           | expresion DIV expresion {$$ = $1 / $3;}
        | expresion MOD expresion {$$ = $1 % $3;}
        | PARI expresion PARD {$$ = $2;}
	| MENOS expresion %prec UMENOS {$$=-$2;} // %prec MENOS tiene la misma preferencia que el POR para corregirlo añadimos un nueo token UNMENOS
       | NUM {$$=$1;};

       // Repasar preferencias de bison (examen)

%%

void yyerror()
{
printf("Se ha producido un error en esta expresion\n");
}

