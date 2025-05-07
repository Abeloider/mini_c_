%{
 #include <stdio.h>
 extern char *yytext;
 extern int yylineno;
 void main();
 void yyerror();
 extern int yylex();
 
%}

%token NUM MAS POR FIN APAR CPAR DIV MENOS
%%
entrada : entrada linea             {}
    |   /* LAMBDA */                {}    
    ;
linea : E FIN                       {printf("Resultado=%d\n",$1);}
    ;
E : E MAS T                         {$$=$1+$3;}
    |E MENOS T                      {$$=$1-$3;}
    | T                             {$$=$1;}
    ;
T : T POR F                         {$$=$1*$3;}
    |T DIV F                        {$$=$1/$3;}
    | F                             {$$=$1;}
    ;
F : APAR E CPAR                     {$$=$2;}
    | NUM                           {$$=$1;}
    | MENOS  FIN                       {$$=-$2;}
    ;
%%
void main() {
    yyparse();
    }
void yyerror(){
    printf("Error sintactico en token %s y linea %d\n",yytext,yylineno);
}
