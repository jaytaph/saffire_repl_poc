#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "test.tab.h"
#include "int.h"

typedef void * yyscan_t;

extern int yyparse();
extern FILE *yyin;
extern int yydebug;

int main(int argc, char **argv) {
    Interpreter inter;
    yyscan_t scanner;

    // Define to 1 to lots of flex/bison debug output
    yydebug = 0;

    // Initialize interpreter structure
    inter.atStart = 1;              // Defines if we are the start of a expression
    inter.completeLine = 0;
    inter.echo = NULL;              //
    inter.error = NULL;
    inter.ps1 = strdup(">");           // Prompt displayer
    inter.ps2 = strdup("...>");
    inter.context = strdup("global");
    inter.eof = 0;

    // Initialize scanner structure and hook the interpreter structure as extra info
    yylex_init_extra(&inter, &scanner);

    // Number of arguments decides if we need to read a file or do REPL
    if (argc == 2) {
        inter.mode = MODE_FILE;
        inter.filehandle = fopen(argv[1], "r");
        if (! inter.filehandle) {
            printf("file not found.\n");
            exit(1);
        }
        yyset_in(inter.filehandle, scanner);
    } else {
        inter.mode = MODE_REPL;
        inter.filehandle = NULL;
    }

    // Here be generic initialization

    // Main loop
    while (! inter.eof) {
        // New 'parse' loop
        inter.atStart = 1;
        int status = yyparse(scanner, &inter);

        // Did something went wrong?
        if (status) {
            if (inter.error) {
                fprintf(stdout, "Error: %s\n", inter.error);
                free(inter.error);
            }
            continue;
        }

        // Do something with our data

        if (inter.mode == MODE_REPL && inter.echo != NULL)  {
            printf("repl output: '%s'\n", inter.echo);
            free(inter.echo);
            inter.echo = NULL;
        }
    }

    // Here be generic finalization

    // Destroy scanner structure
    yylex_destroy(scanner);

    // Close file, if any
    if (inter.filehandle) {
        fclose(inter.filehandle);
    }

    return 0;
}
