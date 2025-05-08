%{
#include <string.h>
#include <stdio.h>
#include  "listaCodigo.h" 
#include  "listaSimbolos.h"
#include <stdlib.h>


void yyerror();
extern char *yytext;
extern int yylex();
extern int yylineno;
Lista tablaSimb;
int contCadena=0;

// Contadores de errores
int semantic_errors_count = 0;
int syntactic_errors_count = 0;
int lexical_errors_count = 0; 

int perteneceTablaS(char *nombre);
void añadeEntrada(char *nombre, Tipo tipo) ;
int esConstante(char *nombre);
void imprimirTablaS();

%}


%expect 1


%union{ 
char *c;
}


%token READ VAR CONST INT IF ELSE WHILE PRINT LPAREN RPAREN SEMICOLON COMMA ASSIGNOP LCORCH RCORCH INTERR DOSPUNT
%token <c> NUM 
%token <c> ID
%token <c> STRING


%left PLUSOP MINUSOP
%left DIV POR
%left UMINUS 

%%

//hay que añadir la inicializacion entonces añadimos tablaSimb=creaLS() justo donde pone; 
// cremos un contador para los erroes del semantico sintactico y lexico imprimimos alfinal
program:  { 
            tablaSimb=creaLS(); 
            semantic_errors_count = 0; // Inicializar contadores
            syntactic_errors_count = 0;
            lexical_errors_count = 0;   // Inicializar

        } 
        ID LPAREN RPAREN LCORCH declarations  statement_list RCORCH 
{
         // Imprimir resumen de errores
        printf("Errores lexicos: %d\n", lexical_errors_count);
        printf("Errores sintacticos: %d\n", syntactic_errors_count);
        printf("Errores semanticos: %d\n", semantic_errors_count);

        imprimirTablaS();
        free($2); // liberam el ID del nombre del programa 

        
}
    ;

// asignamnos tipo = variable
declarations : declarations VAR tipo var_list SEMICOLON
    | declarations CONST tipo  const_list    SEMICOLON
    |   /* LAMBDA */                {}    
    ;  

tipo :     INT                      {}
    ;



var_list :   ID  { if (!(perteneceTablaS($1))) añadeEntrada($1,VARIABLE);
                        else {
                        printf("Error semantico en linea %d: %s ya declarada\n", yylineno, $1);
                        semantic_errors_count++;
                        }
                        free($1);
                }
    | var_list COMMA ID {if (!(perteneceTablaS($3))) añadeEntrada($3,VARIABLE);
                        else {
                        printf("Error  semantico en linea %d: %s ya declarada\n", yylineno, $3);
                        semantic_errors_count++;
                        }
                        free($3);
                        }
    ;
                       
    
const_list : ID ASSIGNOP expression {
                if (!(perteneceTablaS($1))) 
                    añadeEntrada($1, CONSTANTE);
                else {
                    printf("Error  semantico en linea %d: %s ya declarada\n", yylineno, $1);
                    semantic_errors_count++;
                }  
                    free($1);
            }
    | const_list COMMA ID ASSIGNOP expression {
                if (!(perteneceTablaS($3))) 
                    añadeEntrada($3, CONSTANTE);
                else {
                    printf("Error semantico en linea %d: %s ya declarada\n", yylineno, $3);
                    semantic_errors_count++;
                }
                free($3);
            }
    ;

statement_list : statement_list statement
    |   /* LAMBDA */                {} 
    ;

statement : ID ASSIGNOP expression SEMICOLON{  
    if (!(perteneceTablaS($1))) {
        printf("Error semantico en linea %d: %s no declarada\n", yylineno, $1);
        semantic_errors_count++;
    }
    else if ((esConstante($1))) {
            printf("Error semantico en linea %d: %s es constante\n", yylineno, $1);
            semantic_errors_count++;      
        }
        free($1);
    }

    |   LCORCH statement_list RCORCH
    |   IF LPAREN expression RPAREN statement ELSE statement
    |   IF LPAREN expression RPAREN statement
    |   WHILE LPAREN expression RPAREN statement
    |   PRINT LPAREN print_list RPAREN SEMICOLON
    |   READ LPAREN read_list RPAREN SEMICOLON
    ;

print_list : print_item
    |print_list COMMA print_item
    ;

print_item : expression
    | STRING {añadeEntrada($1,CADENA); contCadena++;
    free($1);
    }
    ;

read_list : ID {if (!(perteneceTablaS($1))) {
                    printf("Error semantico en linea %d: %s no declarada\n", yylineno, $1); 
                    semantic_errors_count++;
                    }  
                else if (esConstante($1)) {
                    printf("Error semantico en linea %d: %s es constante\n", yylineno, $1);
                    semantic_errors_count++;                    
                    }
                    free($1);
                }
    | read_list COMMA ID {if (!(perteneceTablaS($3))) {
                            printf("Error semantico en linea %d: %s no declarada\n", yylineno, $3);
                            semantic_errors_count++;        
                        }
                        else if ((esConstante($3))) {
                            printf("Error semantico en linea %d: %s es constante\n", yylineno, $3);
                            semantic_errors_count++;
                            }
                            free($3);
                         }
    ;


expression : expression PLUSOP expression
    |   expression MINUSOP expression
    |   expression POR expression
    |   expression DIV expression
    |   LPAREN expression INTERR expression DOSPUNT expression RPAREN
    |   MINUSOP expression %prec UMINUS
    |   LPAREN expression RPAREN
    |   ID  {if (!(perteneceTablaS($1))) {
                printf("Error semantico en linea %d: %s no declarada\n", yylineno, $1);
                semantic_errors_count++;
            }  
                free($1);
            }
    |   NUM {free($1);}
    ;

%%

void yyerror() {
    printf("Error sintactico en la linea %d. Token problematico: '%s'\n", yylineno, yytext);
    syntactic_errors_count++;
        printf("Errores lexicos: %d\n", lexical_errors_count);
        printf("Errores sintacticos: %d\n", syntactic_errors_count);
        printf("Errores semanticos: %d\n", semantic_errors_count);
}


// FUNCION PARA VER SI PERTENECE A LA TABLA
int perteneceTablaS(char *nombre) {
    PosicionLista pos = buscaLS(tablaSimb, nombre);
    return (pos != finalLS(tablaSimb));
}



// FUNCION PARA AÑADIR LA ENTRADA 
void añadeEntrada(char *nombre, Tipo tipo) {
    Simbolo nuevoSimbolo;
    nuevoSimbolo.nombre = strdup(nombre);  // Use strdup to allocate memory for the string
    nuevoSimbolo.tipo = tipo;
    nuevoSimbolo.valor = 0;  // inicializamos valor to 0

    insertaLS(tablaSimb, finalLS(tablaSimb), nuevoSimbolo);
}


//FUNCION PARA COMPROBAR SI ES CONSTANTE O NO 
int esConstante(char *nombre) {
    PosicionLista pos = buscaLS(tablaSimb, nombre);
    if (pos != finalLS(tablaSimb)) {
        Simbolo s = recuperaLS(tablaSimb, pos);
        return (s.tipo == CONSTANTE);
    } 
    return 0;
}

void imprimirTablaS() {
    PosicionLista pos;
    Simbolo s;
    int contador = 0;
    
    printf("\n----- TABLA DE SIMBOLOS -----\n");
    printf("Nombre\t\tTipo\n");
    printf("------------------------\n");
    
    // Iterate through all symbols in the table
    pos = inicioLS(tablaSimb);
    while (pos != finalLS(tablaSimb)) {
        s = recuperaLS(tablaSimb, pos);
        
        printf("%s\t\t", s.nombre);
        
        // Print the type information
        switch(s.tipo) {
            case VARIABLE:
                printf("VARIABLE");
                break;
            case CONSTANTE:
                printf("CONSTANTE");
                break;
            case CADENA:
                printf("CADENA");
                break;
            default:
                printf("DESCONOCIDO");
        }
        printf("\n");
        
        contador++;
        pos = siguienteLS(tablaSimb, pos);
    }
    printf("------------------------\n");
    printf("Total de simbolos: %d\n", contador);
}

// ensamblador 

// siempre que hacermos una cancatena liberamos la lista 

// crea un nuevo regisro 

// liberar el registor para que pueda ser utlizada 

