#ifndef __INT_H__
#define __INT_H__

typedef struct Interpreter {
    char* ps1; // prompt to start statement
    char* ps2; // prompt to continue statement
    char* echo; // result of last statement to display
    int eof; // set by the EOF action in the parser
    char* error; // set by the error action in the parser
    int completeLine; // managed by yyread
    int atStart; // true before scanner sees printable chars on line
} Interpreter;

#endif
