%{
#include "lexico.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    
//extern YYSTYPE yylval; no hace falta pornerlo 
void error();
%}
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+
string              \"([^"\n\\]|\\.)*\"
panico              [^a-zA-Z0-9(){},;\;=+\-*/?\n\t\r] 

%option yylineno
%X COMENT
%%


{string}                                   { yylval.c = strdup(yytext); return STRING; }
read                                        return READ;
var                                         return VAR;
const                                       return CONST;
int                                         return INT;
if                                          return IF; 
else                                        return ELSE; 
while                                       return WHILE;      
print                                       return PRINT; 
({letra}|_|$)({letra}|{digito}|_|$)*       { yylval.c = strdup(yytext); return ID;     }
{entero}                                    { yylval.c = strdup(yytext); return NUM;    }
"("                                         return LPAREN;		
")"                                         return RPAREN;
";"                                         return SEMICOLON;
","                                         return COMMA;
"="                                         return ASSIGNOP;
"+"                                         return PLUSOP;
"-"                                         return MINUSOP;
"/"                                         return DIV;
"*"                                         return POR; 
"{"                                         return LCORCH;
"}"                                         return RCORCH;
"?"                                         return INTERR;
":"                                         return DOSPUNT;
"/*"                                        BEGIN COMENT;
<COMENT>[*]+[/]                             BEGIN 0;
<COMENT>[^*]*                               ;
<COMENT>[*]+[^/*]*                          ;
[ \n\t\r]+                                  ;
"//"(.*)[\n]                                ;

{panico}                                    printf("\nERROR, simbolo no reconocido %s en la linea %d\n",yytext,yylineno);
                                      
%%
