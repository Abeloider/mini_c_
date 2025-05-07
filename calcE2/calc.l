%{
#include "calc.tab.h"
void error();
%}
digito [0-9]
caracter  [a-zA-Z_]
%%
[ \t\n]+				  ;
{digito}+				{yylval.e=atoi(yytext);return NUM;}
{caracter}({caracter}|{digito})* 	{yylval.c=strdup(yytext);return ID;} //strdup! le reservamos un espacio de memoria ya q es un puntero*
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
printf("Error en el car�cter %s\n",yytext);
}



