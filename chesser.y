%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern int line;
extern char moves[1024];

typedef struct {
    char nombre[50];
    char movimientos[1024];
} Apertura;

Apertura aperturas[100];
int num_aperturas = 0;

void cargar_aperturas(const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        fprintf(stderr, "No se pudo abrir el archivo de aperturas %s\n", filename);
        exit(1);
    }

    char buffer[1024];
    while (fgets(buffer, sizeof(buffer), file)) {
        char *movimientos = strtok(buffer, "= ");
        char *nombre = strtok(NULL, "\n");
        if (nombre && movimientos) {
            strcpy(aperturas[num_aperturas].nombre, nombre);
            strcpy(aperturas[num_aperturas].movimientos, movimientos);
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

%token <str> PIECE COORD CAPTURE CASTLE_SHORT CASTLE_LONG CHECK CHECKMATE ERROR
%type <str> line movs mov

%%

input:
    | input line
    ;

line:
    movs '\n' { free($1); }
    ;

movs:
    mov { strcat(moves, $1); strcat(moves, " "); $$ = $1; }
    | movs mov { strcat(moves, $2); strcat(moves, " "); $$ = $2; }
    ;

mov:
    PIECE COORD { $$ = malloc(strlen($1) + strlen($2) + 1); strcpy($$, $1); strcat($$, $2); free($1); free($2); }
    | COORD { $$ = strdup($1); free($1); }
    | COORD CAPTURE COORD { $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); strcpy($$, $1); strcat($$, $2); strcat($$, $3); free($1); free($2); free($3); }
    | CASTLE_SHORT { $$ = strdup($1); free($1); }
    | CASTLE_LONG { $$ = strdup($1); free($1); }
    | COORD CHECK { $$ = malloc(strlen($1) + strlen($2) + 1); strcpy($$, $1); strcat($$, $2); free($1); free($2); }
    | COORD CHECKMATE { $$ = malloc(strlen($1) + strlen($2) + 1); strcpy($$, $1); strcat($$, $2); free($1); free($2); }
    | PIECE COORD CHECK { $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); strcpy($$, $1); strcat($$, $2); strcat($$, $3); free($1); free($2); free($3); }
    | PIECE COORD CHECKMATE { $$ = malloc(strlen($1) + strlen($2) + strlen($3) + 1); strcpy($$, $1); strcat($$, $2); strcat($$, $3); free($1); free($2); free($3); }
    | COORD CAPTURE COORD CHECK { $$ = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + 1); strcpy($$, $1); strcat($$, $2); strcat($$, $3); strcat($$, $4); free($1); free($2); free($3); free($4); }
    | COORD CAPTURE COORD CHECKMATE { $$ = malloc(strlen($1) + strlen($2) + strlen($3) + strlen($4) + 1); strcpy($$, $1); strcat($$, $2); strcat($$, $3); strcat($$, $4); free($1); free($2); free($3); free($4); }
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

    for (int i = 0; i < num_aperturas; i++) {
        if (strcmp(moves, aperturas[i].movimientos) == 0) {
            printf("%s %s\n", moves, aperturas[i].nombre);
            return 0;
        }
    }

    printf("%sApertura desconocida\n", moves);
    return 0;
}