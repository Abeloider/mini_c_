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
ListaC c; //char *c; asume que listaC es el tipo de tus estrucutra de codigo
}


%token READ VAR CONST INT IF ELSE WHILE PRINT LPAREN RPAREN SEMICOLON COMMA ASSIGNOP LCORCH RCORCH INTERR DOSPUNT
%token <c> NUM 
%token <c> ID
%token <c> STRING

%type <c> program declarations tipo var_list const_list statement_list statement expression print_list print_item read_list

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
        ID LPAREN RPAREN LCORCH declarations statement_list RCORCH 
        {
        // Imprimir resumen de errores
        printf("Errores lexicos: %d\n", lexical_errors_count);
        printf("Errores sintacticos: %d\n", syntactic_errors_count);
        printf("Errores semanticos: %d\n", semantic_errors_count);

        imprimirTablaS();
        free($2); // libera el ID del nombre del programa

                imprimeLS();            // imprime tabla simbolos
                concatenaLC($6,$7);     // une el codig de declar y sentencias
                imprimirLC($6);
                liberaLC($6);
                liberaLC($7);
                liberaLS(ls);
}
    ;

// asignamnos tipo = variable
declarations : declarations VAR tipo var_list SEMICOLON 
            {
                $$=$1;              // asignamos el valor izquierdo semantico al valor derecho $1
                concatenaLC($$,$4); // cocatenamos     
                liberaLC($4);    
            }
            | declarations CONST tipo  const_list   SEMICOLON 
            {
                $$=$1;             // asignamos el valor izquierdo semantico al valor derecho $1
                concatenaLC($$,$4);     
                liberaLC($4);    
            }
            |   /* LAMBDA */  { $$=creaLC(); }     
            ; 



tipo :     INT  {$$ = VARIABLE;}                 // Asignar el valor semántico al lado izquierdo de la regla
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

                    /* 1. Verificación semántica de $1
                       2. $$ = código de asignación
                       3. Liberar registro de $3  */

                $$ = $3;  // Código de la expresión
                Operacion op;
                op.op = "sw";
                op.res = recuperaResLC($3);  // Registro con el resultado
                op.arg1 = concatena("_", $1);  // Dirección de memoria de la constante
                op.arg2 = NULL;
                insertaLC($$, finalLC($$), op);  // Añade operación SW al código
                liberarReg(op.res);  // Liberar registro usado

    }
            
    | const_list COMMA ID ASSIGNOP expression {
                if (!(perteneceTablaS($3))) 
                    añadeEntrada($3, CONSTANTE);
                else {
                    printf("Error semantico en linea %d: %s ya declarada\n", yylineno, $3);
                    semantic_errors_count++;
                }
                free($3);

                /* 1. Verificación semántica de $3
                   2. $$ = código de asignación
                   3. Liberar registro de $5 */

                // Generar código para la expresión
                ListaC expr_code = $5;
                Operacion op;
                op.op = "sw";
                op.res = recuperaResLC(expr_code);
                op.arg1 = concatena("_", $3);
                op.arg2 = NULL;
                insertaLC(expr_code, finalLC(expr_code), op);  // Añade SW al código de la expresión
                liberarReg(op.res);

                // Concatenar al código existente
                concatenaLC($1, expr_code);
                $$ = $1;  // El código combinado
                liberaLC(expr_code);  // Liberar la lista temporal
             
        }
    ;



statement_list : statement_list statement {
                    $$ = $1;
                    concatenaLC($$,$2);
                    liberaLC($2);
}
    |   /* LAMBDA */  { $$=creaLC(); } // cuando no hay ninguna declaracion entonces inicializa una nueva linea de codigo
    ;




statement : ID ASSIGNOP expression SEMICOLON {  
    if (!(perteneceTablaS($1))) {
        printf("Error semantico en linea %d: %s no declarada\n", yylineno, $1);
        semantic_errors_count++;
    }       
    else if ((esConstante($1))) {
            printf("Error semantico en linea %d: %s es constante\n", yylineno, $1);
            semantic_errors_count++;      
        }
        free($1);
                $$ = $3;                        
                Operacion op; 
                op.op = op; 
                op.res = recuperaLC($3);        // obtiene el resultado 
                op.arg1 = concatena("_",$1);    // concatena _ 
                op.arg2 = NULL ;
                isnertar($$,finalLC($$),op);    // añadimos la operacion alfinal lista
                liberaReg(op.res);              // liberamos el registro 
    }


    |   LCORCH statement_list RCORCH {$$ = $2;} 


    |   IF LPAREN expression RPAREN statement ELSE statement {
        
            $$ = $3;                                  
            Operacion op;                             
            char* etiqEndIf = nuevaEtiqueta();        // creamos la etiqueta if    
            char* etiqElse = nuevaEtiqueta();         // creamos la etiqueta else

            op.op = "beqz";                           // beqz brach if equal to zero
            op.res = recuperaResLC($3);               // registro con el resutlado de la condicion 
            op.arg1 = etiqEndIf;                      // saltamos al Endif
            op.arg2 = NULL;                           // el segundo registro no lo usamos 
            insertaLC($$,finalLC($$),op);             // beqz $t, etiqEndIf

// BLOQUE IF            
            concatenaLC($$,$5);                       // añadimos el codigo del bloque if
            op.op = "b";                              // salto condicional
            op.res = etiqElse;                        // saltamos a la etiqueta else 
            op.arg1 = NULL;                           // null oper1
            op.arg2 = NULL;                           // null oper2
            insertaLC($$,finalLC($$),op);             // b etiqElse

            op.op = concatena(etiqEndIf,":");         // creamos la etiqueta endif con la q concatenamos la etiqueta endif con : 
            op.res = NULL;                            // null resultado
            op.arg1 = NULL;                           // null oper1
            op.arg2 = NULL;                           // null oper2
            insertaLC($$,finalLC($$),op);             // etiqEndIf :
            
// BLOQUE ELSE            
            concatenaLC($$,$7);                       // añadimos el codigo del bloque else
            op.op = concatena(etiqElse,":");          // crea etiqueta para el else concatenando con : 
            op.res = NULL;                            // null resultado
            op.arg1 = NULL;                           // null oper1      
            op.arg2 = NULL;                           // null oper2
            insertaLC($$,finalLC($$),op);             // etiquetaElse :

// LIBERAMOS     
            liberarReg(recuperaResLC($3));            // liberamos la expresion
            liberaLC($5);                             // liberamos   $5
            liberaLC($7);                             // liberamos   $7
 }



    |   IF LPAREN expression RPAREN statement {  // LO MISMO QUE ANTES PERO SIN EL ELSE
            $$ = $3;                                  
            Operacion op;                             
            char* etiqEndIf = nuevaEtiqueta();        // creamos la etiqueta if

            op.op = "beqz";                           // brach if equal to zero
            op.res = recuperaResLC($3);               // registro con el resutlado de la condicion 
            op.arg1 = etiqEndIf;                      // saltamos al Endif
            op.arg2 = NULL;                           // el segundo registro no lo usamos 
            insertaLC($$,finalLC($$),op);             // beqz $t2, etiqEndIf :

        //  AÑADIMOS EL CODIGO DEL BLOQUE IF
            concatenaLC($$,$5);                       // se genera el codigo del bloque if  

            op.op = concatena(etiqEndIf,":");         // añadimos la etiqueta endif con :  
            op.res = NULL;                            
            op.arg1 = NULL;                           
            op.arg2 = NULL;                           
            insertaLC($$,finalLC($$),op);             // etiqEndif:

            liberarReg(recuperaResLC($3));            // Liberamos registro de la condición
            liberaLC($5);                             // Liberamos código del bloque if
    }

    
    |   WHILE LPAREN expression RPAREN statement {
            $$ = creaLC();                            // inicializamos lista codigo vacia
            Operacion op;                             // inicializamos op 
            char* etiqWhile = nuevaEtiqueta();        // creamos la etiqueta while
            char* etiqEndWhile = nuevaEtiqueta();     // creamos la etiqueta end while

        // ETIQUETA INICIO WHILE 
            op.op = concatena(etiqWhile,":");         //  
            op.res = NULL;                            // null resultado
            op.arg1 = NULL;                           // null oper1
            op.arg2 = NULL;                           // null oper2
            insertaLC($$,finalLC($$),op);             // etiqWhile :
            
            concatenaLC($$,$3);                       // generamos el codigo de la condicion
            
            op.op = "beqz";                           // hacemos un salto condicional
            op.res = recuperaResLC($3);             
            op.arg1 = etiqEndWhile;
            op.arg2 = NULL;
            insertaLC($$,finalLC($$),op);             // beqz $X, etiqWhile

            concatenaLC($$,$5);                      // generamos el cuerpo del while
            
            op.op = "b";                             // salto al inicio
            op.res = etiqWhile;                     
            op.arg1 = NULL; 
            op.arg2 = NULL;
            insertaLC($$,finalLC($$),op);             // b etiqWhile


        // ETIEQUETA FINAL WHILE
            op.op = concatena(etiqEndWhile,":");
            op.res = NULL;
            op.arg1 = NULL;
            op.arg2 = NULL;
            insertaLC($$,finalLC($$),op);           // etiqEndWhile :

            liberarReg(recuperaResLC($3));           // liberamos resultado de $3
            liberaLC($3);                            // liberamos $3
            liberaLC($5);                            // liberamos $5
    }


    |   PRINT LPAREN print_list RPAREN SEMICOLON    { $$ = $3; }

    |   READ LPAREN read_list RPAREN SEMICOLON   { $$=$3; }
    ;




print_list : print_item  {  $$=$1;  }

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

