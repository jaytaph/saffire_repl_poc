%{
	#include "int.h"
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <stdarg.h>

    #include "test.tab.h"

    typedef void *yyscan_t;

    extern int yywrap(yyscan_t scanner);
    extern int yylex(union YYSTYPE * yylval, YYLTYPE *yylloc, yyscan_t scanner);

    int yyerror(YYLTYPE *, yyscan_t scanner, Interpreter *, const char *);

    #define ERROR_RECOV | error { yyerrok; yyclearin; fprintf(stdout, "Recovering on error"); }

%}


%define api.pure

%lex-param { yyscan_t scanner }
%parse-param { yyscan_t scanner }
%parse-param { Interpreter *interpreter }
%error-verbose

%locations

%union {
    char                *sVal;
    long                lVal;
}

%token END 0 "end of file"
%token <lVal> T_LNUM
%token <sVal> T_IDENTIFIER T_STRING
%token T_CLASS T_ASSIGNMENT

%type <sVal> expr

%token_table

%start saffire

%%

saffire :
		class_def_list { }
;

class_def_list :
		non_empty_class_def_list { }
	|	/* empty */ { }
;

non_empty_class_def_list:
		class_def { }
	|	non_empty_class_def_list class_def { }
;

class_def :
		T_CLASS T_STRING '{' {
		    char buf[256];

		    snprintf(buf, 255, "global/class(%s)", $2);
		    if (interpreter->context) free(interpreter->context);
		    interpreter->context = strdup(buf);
		}
		assignment_list '}' {
		    char buf[256];

		    snprintf(buf, 255, "\033[41;37;1mClass %s defined\033[0m", $2);
		    interpreter->echo = strdup(buf);

		    if (interpreter->context) free(interpreter->context);
		    interpreter->context = strdup("global");

		    YYACCEPT;
        }
;

assignment_list :
		non_empty_assignment_list { }
	|   /* empty */ { }
;

non_empty_assignment_list :
		assignment { }
	| 	non_empty_assignment_list assignment { }
;

assignment :
        T_STRING T_ASSIGNMENT expr          ';' { fprintf(stdout, "\n\033[41;37;1m Assigning %s \033[0m\n", $1); }
    |   T_STRING T_ASSIGNMENT expr '+' expr ';' { fprintf(stdout, "\n\033[41;37;1m Assigning %s with %s and %s \033[0m\n", $1, $3, $5); }
    |   error { yyerrok; yyclearin; }
;

expr :
        T_STRING    { $$ = $1 }
    |   T_LNUM      { char buf[100];  snprintf(buf, 99, "%d", $1); $$ = strdup(buf); }
    ;

%%

extern flush_buffer(yyscan_t scanner);

/**
 * Displays error based on location, scanner and interpreter structure. Will continue or fail depending on interpreter mode
 */
int yyerror(YYLTYPE *yylloc, yyscan_t scanner, Interpreter *inter, const char *message) {
    printf("yyparse() error at line %d: %s\n", yylloc->first_line, message);

    // Just return when we are inside REPL mode
    if (inter->mode == MODE_REPL) {
        flush_buffer(scanner);
        return;
    }

    // Otherwise, exit.
    exit(1);
}

void yyprint(FILE *file, int type, const union YYSTYPE * const value) {
    fprintf (file, "(%d) %s", type, value);
}
