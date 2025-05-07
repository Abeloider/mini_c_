#include <stdio.h>
#include <stdlib.h>
#include "p1.h"

extern char *yytext;
extern int  yyleng;
extern FILE *yyin;
extern int yylex();
FILE *fich;
int main()
{
    int i;
    char nombre[80];
    printf("INTRODUCE NOMBRE DE FICHERO FUENTE:");
    scanf("%s",nombre);
	printf("\n");
    if ((fich=fopen(nombre,"r"))==NULL) {
        printf("***ERROR, no puedo abrir el fichero\n");
        exit(1);		}
    yyin=fich;
    while (i=yylex()) {

        printf("TOKEN %d ",i); 
      if (i == ID) {
            printf("LEXEMA %s  LONGITUD %d\n", yytext, yyleng);
        } else if (i == INTLITERAL) {
            long num = atol(yytext); // Convertir el lexema a número
            if (num >= -2147483648 && num <= 2147483647) {
                printf("LEXEMA %s  LONGITUD %d (NÚMERO VÁLIDO)\n", yytext, yyleng);
            } else {
                printf("LEXEMA %s  LONGITUD %d (ERROR: NÚMERO FUERA DE RANGO)\n", yytext, yyleng);
            }
        } else {
            printf("\n");
        }
    }

    fclose(fich);
    return 0;
}
