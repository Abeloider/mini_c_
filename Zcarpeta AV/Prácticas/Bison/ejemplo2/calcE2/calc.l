%{
#include "calc.tab.h"
void error();
%}
digito [0-9]
caracter  [a-zA-Z_]
%%
[ \t\n]+				  ;
{digito}+				{yylval=atoi(yytext);return NUM;}
{caracter}({caracter}|{digito})* 	{return ID;}
"+"					return MAS;
"-"					return MENOS;
"*"					return POR;
"/"					return DIV;
"("					return PARI;
")"					return PARD;
"="					return ASIG;
";"					return FIN;
"%"					return MOD;
.					{error();}
%%

void error()
{
printf("Error en el carácter %s\n",yytext);
}



