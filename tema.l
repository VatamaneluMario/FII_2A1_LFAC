%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%
"/*"(.|\n)+"*/" ;
"int"|"float"|"char"|"string"|"bool" {yylval.strval=strdup(yytext);return TIP;}
"if" {return CTRL;}
"for" {return LOOPF;}
"while" {return LOOPW;}
">"|"<"|"="|"!!"|">="|"<=" {return OPR;}
"return" {return RET;}
"BEGIN" {return BGIN;}
"END" {return END;}
"CLASS" {return CLASS;}
"decl" {return DECL;}
"func" {return FUNC;}
"STARTSTR" {return STARTSTR;}
"ENDSTR" {return ENDSTR;}
"STARTCLASS" {return STARTCLASS;}
"ENDCLASS" {return ENDCLASS;}
"STARTFCT" {return STARTFCT;}
"ENDFCT" {return ENDFCT;}
"array" {yylval.strval=strdup(yytext);return ARRAYTYPE;}
"Eval" {return EV;}
"TypeOf" {return TO;}

[A-Za-z][A-Za-z0-9]* {yylval.strval=strdup(yytext); return ID;}
":=" {yylval.strval=strdup(yytext);return ASSIGN;}
-?[1-9][0-9]*|0 {yylval.intval=atoi(yytext); return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 