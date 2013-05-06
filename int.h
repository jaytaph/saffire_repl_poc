#ifndef __INT_H__
#define __INT_H__

    #include <stdio.h>

    #define MODE_FILE       0       // Standard fileread mode
    #define MODE_REPL       1       // REPL mode


    typedef struct Interpreter {
        int     mode;           // MODE_* constants
        FILE    *filehandle;    // FILE to read from (or NULL)
        char    *ps1;           // prompt to start statement
        char    *ps2;           // prompt to continue statement
        char    *context;       // prompt for context
        char    *echo;          // result of last statement to display
        int     eof;            // set by the EOF action in the parser
        char    *error;         // set by the error action in the parser
        int     completeLine;   // managed by yyread
        int     atStart;        // true before scanner sees printable chars on line
    } Interpreter;

#endif
