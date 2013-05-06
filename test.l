%{
	#include "test.tab.h"
	#include "int.h"
	#include <string.h>
	#include <stdio.h>

    // Forward defines
	size_t yyread(FILE *f, char *buf, size_t max, Interpreter *interpreter, int lineno);
	int yyerror(YYLTYPE *, Interpreter *, const char *);

    // yylex() takes an additional argument
    #define YY_EXTRA_TYPE Interpreter *

    // Redefine the YY_INPUT macro so we decide on how to read characters
    #undef YY_INPUT
    #define YY_INPUT(buf, result, max_size) result = yyread(yyin, buf, max_size, yyextra, yylineno)

//
//    #define YY_USER_ACTION  if (!isspace(*yytext)) { yyextra->atStart = 0; }


    // These two defines take care of line/column maintenance
    #define step                                                \
        do {                                                    \
            yylloc->first_column = yylloc->last_column + 1;   \
            yylloc->last_column += strlen(yytext);              \
        } while(0)

    #define step_nl                                             \
        do {                                                    \
            yylloc->first_line = yylloc->last_line = yylineno;  \
            yylloc->first_column = 1;                           \
            yylloc->last_column = 0;                            \
        } while (0)

%}

%option reentrant
%option bison-bridge
%option bison-locations
%option extra-type="Interpreter *"

%option yylineno
%option noyywrap
%option debug


lnum            [0-9]+
identifier      (::[\+])|([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*)|([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*[\?\!]?)
whitespace      [ \t\r]+
newline         [\n]
string          [a-z]+

%%

{whitespace}    { }
{newline}       { step_nl; }

"class"         { step; return T_CLASS; }
"="             { step; return T_ASSIGNMENT; }

[;\+\{\}]       { step; return yytext[0]; }

{string}	{
    step;
    yylval->sVal = strdup(yytext);
	return T_STRING;
}

{identifier}	{
    step;
	yylval->sVal =strdup(yytext);
	return T_IDENTIFIER;
}

{lnum}	{
    step;
	yylval->lVal = strtol(yytext, NULL, 10);
	return T_LNUM;
}

. {
    step;
	printf("Unknown token: %s\n", yytext);
	yyterminate();
}

%%

void flush_buffer(yyscan_t *yyscanner) {
    struct yyguts_t *yyg = (struct yyguts_t *)yyscanner;
    YY_FLUSH_BUFFER;
}



/**
 * This is the main character read function (as defined through YY_INPUT). Depending on interpreter mode it will read
 * from file, or display prompts and fetches data.
 */
size_t yyread(FILE *f, char *buf, size_t max, Interpreter *interpreter, int lineno) {

	if (interpreter->mode == MODE_REPL) {
	    // The REPL mode

		if (interpreter->completeLine) {
			if (interpreter->atStart && interpreter->echo != NULL) {
				fprintf(stdout, "%s\n", interpreter->echo);
				free(interpreter->echo);
				interpreter->echo = NULL;
			}
		}

        // print prompt
		fprintf(stdout, "(%d) [\033[33m%s\033[0m]%s", lineno, interpreter->context, interpreter->atStart ? interpreter->ps1 : interpreter->ps2, stdout);

		char ibuf[max+1];
		size_t len = 0;
		if (fgets(ibuf, max+1, stdin)) {
			len = strlen(ibuf);
			memcpy(buf, ibuf, len);
			interpreter->completeLine = (ibuf[len-1] == '\n');
		} else if (ferror(stdin)) {
			interpreter->error = strdup("Error while reading stdin");
			return YY_NULL;
		}
		return len;

	} else {
	    // Interpreter in file mode

        if (feof(f)) {
            // Signal the mainloop that we reached end of file
            interpreter->eof = 1;
            return YY_NULL;
        }

        // Read (part of) file
		size_t len = fread(buf, 1, max, f);
		if (len == 0 && ferror(f)) {
		    interpreter->error = strdup("Error while reading file");
		}
		return len;
	}
}
