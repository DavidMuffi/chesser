%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chesser.tab.h"
int line = 1;
%}

NEW_LINE      [\n\r]
PIECE         [KQRBNP]
COORD1        [a-h]
COORD2        [1-8]
CAPTURE       x
CASTLE_SHORT  O-O
CASTLE_LONG   O-O-O
CHECK         [+]
CHECKMATE     [#]

%%

{PIECE} { 
    yylval.str = strdup(yytext); 
    return PIECE; 
}
{COORD1} { 
    yylval.str = strdup(yytext); 
    return COORD1; 
}
{COORD2} { 
    yylval.str = strdup(yytext); 
    return COORD2; 
}
{CAPTURE} { 
    yylval.str = strdup(yytext); 
    return CAPTURE; 
}
{CASTLE_SHORT} { 
    yylval.str = strdup(yytext); 
    return CASTLE_SHORT; 
}
{CASTLE_LONG} { 
    yylval.str = strdup(yytext); 
    return CASTLE_LONG; 
}
{CHECK} { 
    yylval.str = strdup(yytext); 
    return CHECK; 
}
{CHECKMATE} { 
    yylval.str = strdup(yytext); 
    return CHECKMATE; 
}
{NEW_LINE} { ++line; }
[ \t]+ {}
. { 
    fprintf(stderr, "Notación incorrecta: '%s' en la línea %d\n", yytext, line);
}

%%

int yywrap() {
    return 1;
}
