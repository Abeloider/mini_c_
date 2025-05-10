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
        free($2); // libera el ID del nombre del programa        
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





statement_list : statement_list statement {
                    $$ = $1;
                    concatenaLC($$,$2);
                    liberaLC($2);
}
    |   /* LAMBDA */                {   
        
        // ?????????????????????????????????????????????????????

    } 
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
            {  $$=$1;  }

    |print_list COMMA print_item 
            {
            $$=$1;
            concatenaLC($$,$3);
            liberaLC($3);
            }
    ;







print_item : expression
            {

                $$ = $1;
                Operacion op;
                op.op = "li";
                op.res = "$v0";
                op.arg1 = "1";
                op.arg2 = NULL;
                insertaLC($$,finalLC($$),op);
                op.op = "move";
                op.res = "$a0";
                op.arg1 = recuperaResLC($1);
                op.arg2 = NULL;
                liberarReg(op.arg1);
                insertaLC($$,finalLC($$),op);
                op.op = "syscall";
                op.res = NULL;
                op.arg1 = NULL;
                op.arg2 = NULL;
                insertaLC($$,finalLC($$),op);







            }




    | STRING {  añadeEntrada($1,CADENA); 
                contCadena++;
                free($1);

                $$ = creaLC();
                Operacion op;
                op.op = "la";
                op.res = "$a0";
                char* str;
                asprintf(&str,"$str%d",numStr-1);
                op.arg1 = str;
                op.arg2 = NULL;
                insertaLC($$,finalLC($$),op);
                op.op = "li";
                op.res = "$v0";
                op.arg1 = "4";
                op.arg2 = NULL;
                insertaLC($$,finalLC($$),op);
                op.op = "syscall";
                op.res = NULL;
                op.arg1 = NULL;
                op.arg2 = NULL;
                insertaLC($$,finalLC($$),op);

    }

    ;







read_list : ID 
                {if (!(perteneceTablaS($1))) {
                    printf("Error semantico en linea %d: %s no declarada\n", yylineno, $1); 
                    semantic_errors_count++;
                    }  
                else if (esConstante($1)) {
                    printf("Error semantico en linea %d: %s es constante\n", yylineno, $1);
                    semantic_errors_count++;                    
                    }
                free($1);
                

                $$=creaLC();
                Operacion op;
                op.op="li";
                op.res = "$v0";
                op.arg1="5";
                op.arg2=NULL;
                insertaLC($$,finalLC($$),op);
                op.op="syscall";
                op.res = NULL;
                op.arg1 = NULL;
                op.arg2 = NULL;
                insertaLC($$,finalLC($$),op);
                op.op="sw";
                op.res="$v0";
                op.arg1=concatena("_",$1);
                op.arg2=NULL;
                insertaLC($$,finalLC($$),op);
                liberarReg(op.res);
                }


            
    | read_list COMMA ID 
                {if (!(perteneceTablaS($3))) {
                    printf("Error semantico en linea %d: %s no declarada\n", yylineno, $3);
                    semantic_errors_count++;        
                }
                else if ((esConstante($3))) {
                    printf("Error semantico en linea %d: %s es constante\n", yylineno, $3);
                    semantic_errors_count++;
                    }
                free($3);

                 $$=$1;
                  Operacion op;
                  op.op="li";
                  op.res = "$v0";
                  op.arg1="5";
                  op.arg2=NULL;
                  insertaLC($$,finalLC($$),op);
                  op.op="syscall";
                  op.res = NULL;
                  op.arg1 = NULL;
                  op.arg2 = NULL;
                  insertaLC($$,finalLC($$),op);
                  op.op="sw";
                  op.res="$v0";
                  op.arg1=concatena("_",$3);
                  op.arg2=NULL;
                  insertaLC($$,finalLC($$),op);
                  liberarReg(op.res);


                }
    ;





expression : 
                expression PLUSOP expression {
                    $$ = $1;
                    concatenaLC($$,$3);
                    Operacion oper; 
                    oper.op = “add”;
                    oper.res = recuperaResLC($1);
                    oper.arg1 = recuperaResLC($1);
                    oper.arg2 = recuperaResLC($3);
                    insertaLC($$,finalLC($$),oper);
                    liberaLC($3);
                    liberarReg(oper.arg2); 
                }
            |   expression MINUSOP expression {
                    $$ = $1;
                    concatenaLC($$,$3);
                    Operacion oper; 
                    oper.op = “sub”;
                    oper.res = recuperaResLC($1);
                    oper.arg1 = recuperaResLC($1);
                    oper.arg2 = recuperaResLC($3);
                    insertaLC($$,finalLC($$),oper);
                    liberaLC($3);
                    liberarReg(oper.arg2); 
                }
            |   expression POR expression {
                    $$ = $1;
                    concatenaLC($$,$3);
                    Operacion oper; 
                    oper.op = “mul”;
                    oper.res = recuperaResLC($1);
                    oper.arg1 = recuperaResLC($1);
                    oper.arg2 = recuperaResLC($3);
                    insertaLC($$,finalLC($$),oper);
                    liberaLC($3);
                    liberarReg(oper.arg2); 
            }
            |   expression DIV expression {   
                    $$ = $1;
                    concatenaLC($$,$3);
                    Operacion oper; 
                    oper.op = “div”;
                    oper.res = recuperaResLC($1);
                    oper.arg1 = recuperaResLC($1);
                    oper.arg2 = recuperaResLC($3);
                    insertaLC($$,finalLC($$),oper);
                    liberaLC($3);
                    liberarReg(oper.arg2); 
                    }







    
    |   LPAREN expression INTERR expression DOSPUNT expression RPAREN{
            $$ = creaLC();
            concatenaLC($$, $2);  // Añadimos código de la condición

            char* etiq1 = nuevaEtiqueta();  // Etiqueta para el caso verdadero
            char* etiq2 = nuevaEtiqueta();  // Etiqueta para el final

            Operacion op;
            // Salto condicional: si es falso, salta a etiq1
            op.op = "beqz";
            op.arg1 = recuperaResLC($2);
            op.arg2 = etiq1;
            op.res = NULL;
            insertaLC($$, finalLC($$), op);

            // Código para el caso verdadero
            concatenaLC($$, $4);
            op.op = "b";
            op.arg1 = etiq2;
            op.arg2 = NULL;
            insertaLC($$, finalLC($$), op);

            // Etiqueta para el caso falso
            op.op = "etiq";
            op.arg1 = etiq1;
            op.arg2 = NULL;
            insertaLC($$, finalLC($$), op);

            // Código para el caso falso
            concatenaLC($$, $6);

            // Etiqueta final
            op.op = "etiq";
            op.arg1 = etiq2;
            op.arg2 = NULL;
            insertaLC($$, finalLC($$), op);

            // Liberamos las listas y registros que ya no necesitamos
            liberaLC($2);
            liberaLC($4);
            liberaLC($6);
            liberarReg(recuperaResLC($2));

            // El resultado final estará en el registro de $4 o $6
            guardaResLC($$, recuperaResLC($4));  // O podría ser $6, depende de qué camino se tome
        

        
    }





    
    |   MINUSOP expression %prec UMINUS {

            $$=$2;
            Operacion op;
            op.op="neg";
            op.res=recuperaResLC($2);
            op.arg1=recuperaResLC($2);
            op.arg2=NULL;
            insertaLC($$,finalLC($$),op);
        }




    |   LPAREN expression RPAREN {
        { $$ = $2; }
    }
    



    |   ID  {if (!(perteneceTablaS($1))) {
                printf("Error semantico en linea %d: %s no declarada\n", yylineno, $1);
                semantic_errors_count++;
            }  
            free($1);
            $$=creaLC();
            Operacion op;
            op.op="lw";
            op.res = obtenerReg();
            op.arg1=concatena("_",$1);
            op.arg2=NULL;
            insertaLC($$,finalLC($$),op);
            guardaResLC($$,op.res);
            }



            
    |   NUM {free($1);

            $$=creaLC();
            Operacion op;
            op.op="li";
            op.res = obtenerReg();
            op.arg1=$1;
            op.arg2=NULL;
            insertaLC($$,finalLC($$),op); //donde la inserto,en que posicion, el que guardo
            guardaResLC($$,op.res);

    
        }
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



char* nuevaEtiqueta(){
    char* etiq;
    asprintf(&etiq,"etiq%d",contador_etiq);
    contador_etiq++;
    return etiq;
}

