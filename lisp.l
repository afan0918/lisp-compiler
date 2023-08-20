%option noyywrap

%{
#include "y.tab.h"
#include <stdio.h>

// 參考專案 : https://github.com/Zane2453/Mini-LISP-interpreter_Lex-Yacc
// 還有 https://github.com/q23175401/complier-final-miniLisp
// 大家好像都會參考一下這兩個，粗事了
%}

digit	[0-9]
letter	[a-z]
number	0|[1-9]{digit}*|-[1-9]{digit}*
id	{letter}({letter}|{digit}|-)*

%%

"print-num"		{return PRINTNUM;}
"print-bool"	{return PRINTBOOL;}
"+"			{return '+';}
"-"			{return '-';}
"*"			{return '*';}
"/"			{return '/';}
"mod"		{return '%';}
">"			{return '>';}
"<"			{return '<';}
"="			{return '=';}
"and"		{return '&';}
"or"		{return '|';}
"not"		{return '!';}
"define"	{return 'd';}
"lambda"	{return 'l';}
"fun"		{return 'l';}	// 講義寫fun，測資給lambda，所以我決定兩個都收
"if"		{return 'i';}
{number}	{
	yylval.intval = atoi(yytext); 
	return NUMBER;
}
"#t"			{
	yylval.boolval=1;
	return BOOL;
}
"#f"			{
	yylval.boolval=0;
	return BOOL;
}
{id}		{
	yylval.strval = strdup(yytext); 
	return ID;
}
"("|")"		{return yytext[0];}
.|\n		{;}

%%
