#include <stdio.h>
#include <string.h>
#include "test.tab.h"
#include "int.h"

typedef void * yyscan_t;

extern int yyparse();
extern FILE *yyin;
extern int yydebug;

int main(int argc, char **argv) {
    Interpreter inter;
    yyscan_t scanner;

    yydebug = 0;

    int interactive = argc;

    FILE *f = fopen("test.a", "r");
    inter.f = f;

    inter.atStart = 1;
    inter.completeLine = 0;
    inter.echo = NULL;
    inter.error = NULL;
    inter.ps1 = strdup(">");
    inter.ps2 = strdup("...");
    inter.eof = 0;

    yylex_init_extra(&inter, &scanner);
    yyset_in(f, scanner);

    while (! inter.eof) {
        inter.atStart = 1;
        int status = yyparse(scanner, &inter);
        if (status) {
            if (inter.error) {
                fprintf(stderr, "Interpreter Error");
            }
        } else {
            printf("Executing: \n");
            if (interactive)  {
                inter.echo = strdup("foobar!");
            }
        }
    }

    yylex_destroy(scanner);
    fclose(f);

    return 0;
}
