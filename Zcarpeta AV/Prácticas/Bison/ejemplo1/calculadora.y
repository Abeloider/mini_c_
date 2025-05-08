%{
#include <stdio.h>
int yylex (void);
void yyerror (char const *);
%}

%token   DIGITO

%%
entrada	:	/*empty*/		{printf("Aplica entrada -> lambda \n");}
	|	entrada linea		{printf("Aplica entrada -> entrada linea \n");}
	;
linea	:	expr '\n'		{printf("Aplica linea -> expr \n");}
	;

expr	:	expr '+' termino	{printf("Aplica expr -> expr + termino \n");}
	|	termino			{printf("Aplica expr->termino\n");}
	;
termino	:	termino '*' factor	{printf("Aplica termino -> termino * factor \n");}
	|	factor			{printf("Aplica termino -> factor 	\n");}
	;
factor	:	'(' expr ')'		{printf("Aplica factor-> (expr) \n");}
	|	DIGITO			{printf("Aplica factor -> DIGITO \n");}
	;

%%

void yyerror (char const *s)
     {
       fprintf (stderr, "%s\n", s);
     }


int yylex() {
	int c;
	while ((c = getchar ()) == ' ' || c == '\t')
         ;
	
	if (isdigit(c)) {
		yylval=c-'0';
		return DIGITO;
	}
	
	return c;
}

int main (void) {
	
	return yyparse();
  
}
