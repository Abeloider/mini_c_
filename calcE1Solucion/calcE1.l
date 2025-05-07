%{
#include "calcE1.tab.h"
void error();
%}
digito [0-9]

%%
[ \t]+				;
{digito}{digito}*	{yylval=atoi(yytext);return NUM;}
"+"				    return MAS;
"-"				    return MENOS;
"*"				    return POR;
"/"				    return DIV;
"("				    return PARI;
")"				    return PARD;
[\n]				return '\n';
.				    {error();}
%%

void error()
{
printf("Error en el car�cter %s\n",yytext);
}


