%{
	#include "test.tab.h"
	#include <stdio.h>
	#include <stdlib.h>

	extern int yylineno;
	int yylex(void);
	void yyerror(const char *err) { printf("Error in line %lu: %s\n", (unsigned long)yylineno, err); exit(1); }

%}

%union {
    char                *sVal;
    long                lVal;
}

%token END 0 "end of file"
%token <lVal> T_LNUM
%token <sVal> T_IDENTIFIER T_STRING

%token T_CLASS T_ASSIGNMENT

%token_table
%error-verbose

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
		T_STRING T_ASSIGNMENT T_LNUM            ';' { }
	|	T_STRING T_ASSIGNMENT T_LNUM '+' T_LNUM ';' { }
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
		T_CLASS T_STRING ';' { }
;

