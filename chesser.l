%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chesser.tab.h"

int line = 1;
char moves[1024] = "";
%}

NEW_LINE      [\n\r]
PIECE         [KQRBNP]
COORD         [a-h][1-8]
CAPTURE       x
CASTLE_SHORT  O-O
CASTLE_LONG   O-O-O
CHECK         [+]
CHECKMATE     [#]

%%

{PIECE} { 
    printf("Token PIECE: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return PIECE; 
}

{COORD} { 
    printf("Token COORD: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return COORD; 
}

{CAPTURE} { 
    printf("Token CAPTURE: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return CAPTURE; 
}

{CASTLE_SHORT} { 
    printf("Token CASTLE_SHORT: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return CASTLE_SHORT; 
}

{CASTLE_LONG} { 
    printf("Token CASTLE_LONG: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return CASTLE_LONG; 
}

{CHECK} { 
    printf("Token CHECK: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return CHECK; 
}

{CHECKMATE} { 
    printf("Token CHECKMATE: %s\n", yytext); 
    yylval.str = strdup(yytext); 
    return CHECKMATE; 
}

{NEW_LINE} { 
    printf("Nueva línea detectada: línea %d\n", ++line); 
}

[ \t]+ { 
    printf("Espacio o tabulación ignorada\n"); 
}

. { 
    fprintf(stderr, "Notación incorrecta: '%s' en la línea %d\n", yytext, line); 
    return ERROR; 
}

%%

int yywrap() {
    return 1;
}
