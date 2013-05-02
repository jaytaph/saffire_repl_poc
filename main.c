#include <stdio.h>
#include <string.h>
#include "test.tab.h"
#include "int.h"

extern int yyparse();

int main(int argc, char **argv) {
    Interpreter inter;

    int interactive = argc;

    inter.ps1 = strdup(">");
    inter.ps2 = strdup("...");
    inter.eof = 0;

//    yylex_init_extra(inter, &scanner);

    while (! inter.eof) {
        inter.atStart = 1;
        int status = yyparse(&inter);
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

    return 0;
}
