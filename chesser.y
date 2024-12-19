%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chesser.tab.h"

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line;

typedef struct {
    char nombre[100];
    char *movimientos[20];
    int num_movimientos;
} Apertura;

char *moves[50];
Apertura aperturas[120];
int num_aperturas = 0;
int num_movimientos = 0;

void cargar_aperturas(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "No se pudo abrir el archivo de aperturas %s\n", filename);
        exit(1);
    }

    char buffer[1024];
    while (fgets(buffer, sizeof(buffer), file)) {
        char *newline = strchr(buffer, '\n');
        if (newline) {
            *newline = '\0';
        }

        char *movimientos = strtok(buffer, "=");
        char *nombre = strtok(NULL, "=");

        if (nombre && movimientos) {
            while (*nombre == ' ') nombre++;
            char *end = nombre + strlen(nombre) - 1;
            while (end > nombre && *end == ' ') end--;
            *(end + 1) = '\0';

            strncpy(aperturas[num_aperturas].nombre, nombre, sizeof(aperturas[num_aperturas].nombre) - 1);
            aperturas[num_aperturas].nombre[sizeof(aperturas[num_aperturas].nombre) - 1] = '\0';
            aperturas[num_aperturas].num_movimientos = 0;

            char *token = strtok(movimientos, " ");
            while (token && aperturas[num_aperturas].num_movimientos < 14) {
                aperturas[num_aperturas].movimientos[aperturas[num_aperturas].num_movimientos] = strdup(token);
                aperturas[num_aperturas].num_movimientos++;
                token = strtok(NULL, " ");
            }
            num_aperturas++;
        }
    }
    fclose(file);
}

int validar_movimientos(char **movimientos, int num_movimientos) {
    int count_castle_short = 0;
    int count_castle_long = 0;

    for (int i = 0; i < num_movimientos; i++) {
        if (strcmp(movimientos[i], "O-O") == 0) {
            count_castle_short++;
        } else if (strcmp(movimientos[i], "O-O-O") == 0) {
            count_castle_long++;
        }

        if ((count_castle_short + count_castle_long) > 2) {
            return 0;
        }
    }

    return 1;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s en la línea %d\n", s, line);
}

%}

%union {
    char *str;
}

%token <str> PIECE COORD1 COORD2 CAPTURE CASTLE_SHORT CASTLE_LONG CHECK CHECKMATE ERROR
%type <str> movs mov
%start S
%%

S : input
;

input:
    | input movs {
        char *apertura_reconocida = NULL;
        int max_movimientos_coincidentes = 0;

        for (int i = 0; i < num_aperturas; i++) {
            int movimientos_a_comparar = aperturas[i].num_movimientos;

            if (num_movimientos >= movimientos_a_comparar) {
                int coincide = 1;
                for (int j = 0; j < movimientos_a_comparar; j++) {
                    if (strcmp(moves[j], aperturas[i].movimientos[j]) != 0) {
                        coincide = 0;
                        break;
                    }
                }

                if (coincide && movimientos_a_comparar > max_movimientos_coincidentes) {
                    max_movimientos_coincidentes = movimientos_a_comparar;
                    apertura_reconocida = aperturas[i].nombre;
                }
            }
        }

        if (apertura_reconocida) {
            printf("Apertura reconocida: %s.\n", apertura_reconocida);
        } else if(!validar_movimientos(moves, num_movimientos)) {
            printf("Apertura ilegal. Un jugador no puede enrocar varias veces por partida.\n");
        } else {
            printf("Apertura no reconocida.\n");
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
    COORD1 COORD2 {
        $$ = malloc(strlen($1) + strlen($2) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        free($1); 
        free($2); 
    }
    | COORD1 COORD2 CHECK {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        strcat($$, $3); 
        free($1); 
        free($2); 
        free($3);
    }
    | COORD1 COORD2 CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        strcat($$, $3); 
        free($1); 
        free($2); 
        free($3);
    }

    | PIECE COORD1 COORD2 {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); 
        strcpy($$, $1); 
        strcat($$, $2); 
        strcat($$, $3); 
        free($1); 
        free($2); 
        free($3);
    }
    | PIECE COORD1 COORD2 CHECK {
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
    | PIECE COORD1 COORD2 CHECKMATE {
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
    | COORD1 CAPTURE COORD1 COORD2 {
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
    | COORD1 CAPTURE COORD1 COORD2 CHECK {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + strlen($5) + 1); 
        strcpy($$, $1); 
        strcat($$, $2); 
        strcat($$, $3);
        strcat($$, $4);
        strcat($$, $5);
        free($1); 
        free($2); 
        free($3);
        free($4);
        free($5);
    }
    | COORD1 CAPTURE COORD1 COORD2 CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + strlen($5) + 1); 
        strcpy($$, $1); 
        strcat($$, $2); 
        strcat($$, $3);
        strcat($$, $4);
        strcat($$, $5);
        free($1); 
        free($2); 
        free($3);
        free($4);
        free($5);
    }
    | CASTLE_SHORT {
        $$ = strdup($1);
        free($1);
    }
    | CASTLE_SHORT CHECK {
        $$ = malloc(strlen($1) + strlen($2) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        free($1); 
        free($2);
    }
    | CASTLE_SHORT CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        free($1); 
        free($2);
    }
    | CASTLE_LONG {
        $$ = strdup($1); 
        free($1);
    }
    | CASTLE_LONG CHECK {
        $$ = malloc(strlen($1) + strlen($2) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        free($1); 
        free($2);
    }
    | CASTLE_LONG CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        free($1); 
        free($2);
    }
    | PIECE CAPTURE COORD1 COORD2 {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); 
        strcpy($$, $1); 
        strcat($$, $2); 
        strcat($$, $3); 
        strcat($$, $4);
        free($1); 
        free($2); 
        free($3); 
        free($4);
    }
    | PIECE CAPTURE COORD1 COORD2 CHECK {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); 
        strcpy($$, $1); 
        strcat($$, $2); 
        strcat($$, $3);
        strcat($$, $4); 
        free($1); 
        free($2); 
        free($3); 
        free($4);
    }
    | PIECE CAPTURE COORD1 COORD2 CHECKMATE {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); 
        strcpy($$, $1); 
        strcat($$, $2);
        strcat($$, $3); 
        strcat($$, $4); 
        free($1); 
        free($2); 
        free($3); 
        free($4);
    }
    | COORD1 CAPTURE COORD2 {
        $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1);
        strcpy($$, $1);
        strcat($$, $2); 
        strcat($$, $3); 
        free($1); 
        free($2); 
        free($3); 
    }
    | COORD1 CAPTURE COORD2 CHECK {
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
    | COORD1 CAPTURE COORD2 CHECKMATE {
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

    cargar_aperturas("aperturas.txt");

    yyparse();

    return 0;
}
