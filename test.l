%{
	#include "test.tab.h"
	#include "int.h"
	#include <string.h>
	#include <stdio.h>

	size_t repl_read(FILE *f, char *buf, size_t max, Interpreter *interpreter);

    #undef YY_INPUT
    #define YY_INPUT(buf, result, max_size) result = repl_read(yyin, buf, max_size, yyget_extra(yyscanner))

    #define YY_EXTRA_TYPE Interpreter *

//	#define YY_USER_ACTION  if (!isspace(*yytext)) { yyextra->atStart = 0; }
//    #define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;


    extern int yylex(union YYSTYPE * yylval, struct YYLTYPE *yyloc, yyscan_t scanner);

	int yyerror(struct YYLTYPE *, Interpreter *, const char *);

%}

%option noyywrap
%option reentrant
%option bison-bridge
%option bison-locations

%option yylineno
%option extra-type="Interpreter *"
%option debug


lnum            [0-9]+
identifier      (::[\+])|([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*)|([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*[\?\!]?)
whitespace      [ \t\n\r]+
string          [a-z]+

%%

{whitespace} { }

"class"		{ return T_CLASS; }
"="		{ return T_ASSIGNMENT; }

[;\+] { return yytext[0]; }

{string}	{
    yylval->sVal = strdup(yytext);
	return T_STRING;
}

{identifier}	{
	yylval->sVal =strdup(yytext);
	return T_IDENTIFIER;
}

{lnum}	{
	yylval->lVal = strtol(yytext, NULL, 10);
	return T_LNUM;
}

. {
	printf("Unknown token: %s\n", yytext);
	yyterminate();
}

%%

size_t repl_read(FILE *f, char *buf, size_t max, Interpreter *interpreter) {
    fprintf(stdout, "\n\nCUSTOM YYREAD!\n\n");

	if (f == NULL) {
		if (interpreter->completeLine) {
			if (interpreter->atStart && interpreter->echo != NULL) {
				fputs(interpreter->echo, stdout);
				fputs("\n", stdout);
				free(interpreter->echo);
				interpreter->echo = NULL;
			}
			fputs(interpreter->atStart ? interpreter->ps1 : interpreter->ps2, stdout);
			fflush(stdout);
		}

		char ibuf[max+1];
		size_t len = 0;
		if (fgets(ibuf, max+1, stdin)) {
			len = strlen(ibuf);
			memcpy(buf, ibuf, len);
			interpreter->completeLine = (ibuf[len-1] == '\n');
		} else if (ferror(stdin)) {
			printf("Error!");
		}
		return len;
	} else {

        if (feof(f)) {
            interpreter->eof = 1;
            return 0;
        }
		size_t len = fread(buf, 1, max, f);
        printf("fread(): %d (%d)\n", len, feof(f));

		if (len == 0 && ferror(f)) {
			printf("Error!");
		}
		return len;
	}
}
