%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line;

char *moves[50];
int num_movimientos = 0;

typedef struct {
    char nombre[100];
    char *movimientos[20];
    int num_movimientos;
} Apertura;

Apertura aperturas[200];
int num_aperturas = 0;

void cargar_aperturas(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "No se pudo abrir el archivo de aperturas %s\n", filename);
        exit(1);
    }

    char buffer[1024];
    while (fgets(buffer, sizeof(buffer), file)) {
        // Eliminar el carácter de nueva línea si existe
        char *newline = strchr(buffer, '\n');
        if (newline) {
            *newline = '\0';
        }

        // Dividir en movimientos y nombre
        char *movimientos = strtok(buffer, "=");
        char *nombre = strtok(NULL, "=");

        if (nombre && movimientos) {
            // Eliminar espacios iniciales/finales del nombre
            while (*nombre == ' ') nombre++; // Saltar espacios al inicio
            char *end = nombre + strlen(nombre) - 1;
            while (end > nombre && *end == ' ') end--; // Saltar espacios al final
            *(end + 1) = '\0'; // Terminar la cadena

            // Limpiar y almacenar el nombre de la apertura
            strncpy(aperturas[num_aperturas].nombre, nombre, sizeof(aperturas[num_aperturas].nombre) - 1);
            aperturas[num_aperturas].nombre[sizeof(aperturas[num_aperturas].nombre) - 1] = '\0';
            aperturas[num_aperturas].num_movimientos = 0;

            // Dividir y almacenar los movimientos
            char *token = strtok(movimientos, " ");
            while (token && aperturas[num_aperturas].num_movimientos < 10) {
                aperturas[num_aperturas].movimientos[aperturas[num_aperturas].num_movimientos] = strdup(token);
                aperturas[num_aperturas].num_movimientos++;
                token = strtok(NULL, " ");
            }

            num_aperturas++;
        }
    }

    fclose(file);
}


void yyerror(const char *s) {
    fprintf(stderr, "Error: %s en la línea %d\n", s, line);
}
%}

%error-verbose
%union {
    char *str;
}

%token <str> PIECE COORD CAPTURE CASTLE_SHORT CASTLE_LONG CHECK CHECKMATE
%type <str> movs mov

%%

input:
    | input movs {
        char *apertura_reconocida = NULL;
        int max_movimientos_coincidentes = 0;

        for (int i = 0; i < num_aperturas; i++) {
            int movimientos_a_comparar = aperturas[i].num_movimientos;

            // Verificar coincidencia de movimientos
            if (num_movimientos >= movimientos_a_comparar) {
                int coincide = 1;
                for (int j = 0; j < movimientos_a_comparar; j++) {
                    if (strcmp(moves[j], aperturas[i].movimientos[j]) != 0) {
                        coincide = 0;
                        break;
                    }
                }

                // Actualizar la apertura más larga reconocida
                if (coincide && movimientos_a_comparar > max_movimientos_coincidentes) {
                    max_movimientos_coincidentes = movimientos_a_comparar;
                    apertura_reconocida = aperturas[i].nombre;
                }
            }
        }

        if (apertura_reconocida) {
            printf("Apertura reconocida: %s\n", apertura_reconocida);
        } else {
            printf("Apertura desconocida\n");
        }
    }
    ;
movs:
    mov {
        moves[num_movimientos++] = $1; // Agrega el primer movimiento al array
    }
    | movs mov {
        moves[num_movimientos++] = $2; // Agrega más movimientos al array
    }
    ;

mov:
    PIECE COORD {
        $$ = malloc(strlen($1) + strlen($2) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        free($1);
        free($2);
    }
    | COORD {
        $$ = strdup($1);
        free($1);
    }
    | COORD CAPTURE COORD {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        strcat($$, $3);
        free($1);
        free($2);
        free($3);
    }
    | CASTLE_SHORT {
        $$ = strdup($1);
        free($1);
    }
    | CASTLE_LONG {
        $$ = strdup($1);
        free($1);
    }
    | COORD CHECK {
        $$ = malloc(strlen($1) + strlen($2) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        free($1);
        free($2);
    }
    | COORD CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        free($1);
        free($2);
    }
    | PIECE COORD CHECK {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        strcat($$, $3);
        free($1);
        free($2);
        free($3);
    }
    | PIECE COORD CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        strcat($$, $3);
        free($1);
        free($2);
        free($3);
    }
    | COORD CAPTURE COORD CHECK {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        strcat($$, $3);
        strcat($$, $4);
        free($1);
        free($2);
        free($3);
        free($4);
    }
    | COORD CAPTURE COORD CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + 1);
        strcpy($$, $1);
        strcat($$, $2);
        strcat($$, $3);
        strcat($$, $4);
        free($1);
        free($2);
        free($3);
        free($4);
    }
    ;

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "No se pudo abrir el archivo %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }

    // Cargar aperturas desde el archivo
    cargar_aperturas("aperturas.txt");

    // Parsear el archivo de entrada
    yyparse();

    return 0;
}
