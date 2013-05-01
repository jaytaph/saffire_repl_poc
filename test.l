%{
	#include "test.tab.h"
%}

%option yylineno
%option nounput noyy_top_state
%option debug

lnum            [0-9]+
identifier      (::[\+])|([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*)|([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*[\?\!]?)
whitespace      [ \t\n\r]+
string		[a-z]+

%%

{whitespace} { }

"class"		{ return T_CLASS; }
"="		{ return T_ASSIGNMENT; }

[;] { return yytext[0]; }

{string}	{
	yylval.sVal = strdup(yytext);
	return T_STRING;
}

{identifier}	{
	yylval.sVal =strdup(yytext);
	return T_IDENTIFIER;
}

{lnum}	{
	yylval.lVal = strtol(yytext, NULL, 10);
	return T_LNUM;
}

. {
	printf("Unknown token: %s\n", yytext);
	yyterminate();
}

%%

int yywrap(void) { return 1 ; }
