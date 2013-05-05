%{
	#include "int.h"
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <stdarg.h>

    #include "test.tab.h"

    typedef void * yyscan_t;

    extern int yywrap(yyscan_t scanner);
    extern int yylex(union YYSTYPE * yylval, struct YYLTYPE *yyloc, yyscan_t scanner);

//    void yyprint(FILE *, int , const union YYSTYPE * const);
//    #define YYPRINT(File, Type, Value) yyprint (File, /* &yylloc, */ Type, &Value)

    int yyerror(struct YYLTYPE *, yyscan_t scanner, Interpreter *, const char *);

%}

%locations

%define api.pure

%lex-param { yyscan_t scanner }
%parse-param { yyscan_t scanner }
%parse-param { Interpreter *interpreter }
%error-verbose

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
		class_def_list assignment_list { }
;

assignment_list :
		non_empty_assignment_list { }
;

non_empty_assignment_list :
		assignment { }
	| 	non_empty_assignment_list assignment { }
;

assignment :
		T_STRING T_ASSIGNMENT T_LNUM            ';' { fprintf(stdout, "\n\033[41;37;1m Assigning %s \033[0m\n", $1); }
    |	T_STRING T_ASSIGNMENT expr '+' expr ';' { fprintf(stdout, "\n\033[41;37;1m Assigning %s with %s and %s \033[0m\n", $1, $3, $5); }
;

expr :
        T_STRING { $$ = $1 }
    |   T_LNUM { char buf[100];  snprintf(buf, 99, "%d", $1); $$ = strdup(buf); }
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
		T_CLASS T_STRING ';' { fprintf(stdout, "\n\033[41;37;1m Class %s defined\033[0m\n", $2); }
;

%%

int yyerror(struct YYLTYPE *yyloc, yyscan_t scanner, Interpreter *inter, const char *message) {
    printf("yyparse() error at line %d: %s\n", yyloc->first_line, message);
    exit(1);
}

void yyprint(FILE *file, int type, const union YYSTYPE * const value) {
    fprintf (file, "(%d) %s", type, value);
}
