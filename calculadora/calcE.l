%{
#include "calcE.tab.h"
%}
%option yylineno

%%
[0-9]+      {yylval=atol(yytext);                return NUM;}
"+"         return MAS;
"*"         return POR;
"/"         return DIV;
"-"         return MENOS;
"("         return APAR;
")"         return CPAR;
";"         return FIN;
[ \t\n\r]+  ;
.           printf("Error lexico con caracter %s en linea %d\n",yytext,yylineno);
%%
