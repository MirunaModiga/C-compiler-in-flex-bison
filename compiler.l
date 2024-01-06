%option noyywrap
%{
	#include "compiler.tab.h"

	int lineNo = 1;
	int colNo = 1;
%}

%%
\/\/.*              ;
\/\*(.*\n)*.*\*\/   ;
"{"             { colNo++; return TOK_BRACE_LEFT; }
"}"             { colNo++; return TOK_BRACE_RIGHT; }
"+"				{ colNo++; return TOK_PLUS; }
"-"				{ colNo++; return TOK_MINUS; }
"*"				{ colNo++; return TOK_MULTIPLY; }
"/"				{ colNo++; return TOK_DIVIDE; }
"("				{ colNo++; return TOK_LEFT; }
")"				{ colNo++; return TOK_RIGHT; }
";"				{ colNo++; return ';'; }
"="				{ colNo++; return '='; }
">"             { colNo++; return TOK_GT; }
"<"             { colNo++; return TOK_LT; }
"=="            { colNo+=2; return TOK_EQ; }
"!="            { colNo+=2; return TOK_NEQ; }
"if"            {colNo+=2; return TOK_IF;}
"else"          {colNo+=4; return TOK_ELSE;}
"while"         {colNo+=5; return TOK_WHILE;}
[0-9]+"."[0-9]+([eE][-+]?[0-9]+)?	{
                                        yylloc.first_line = lineNo; 
                                        yylloc.first_column = colNo; 
                                        colNo += strlen(yytext); 
                                        yylval.val = atof(yytext); 
                                        return TOK_NUMBER; 
                                    }
0|[1-9][0-9]*	{ 	yylloc.first_line = lineNo; 
					yylloc.first_column = colNo; 
					colNo+=strlen(yytext); 
					yylval.val = atoi(yytext); 
					return TOK_NUMBER; }
[0-9]+"."[0-9]*[1-9]+"f"	{ 	yylloc.first_line = lineNo; 
					            yylloc.first_column = colNo; 
					            colNo+=strlen(yytext); 
                                if(yytext[strlen(yytext) - 1] == 'f')
                                    { yytext[strlen(yytext) - 1] = '\0';}
					            yylval.val = atof(yytext); 
					            return TOK_NUMBER; }
"int"           { yylloc.first_line = lineNo; 
                yylloc.first_column = colNo; 
                colNo += strlen(yytext);
                yylval.sir = new char[strlen(yytext)+1];
                strncpy(yylval.sir, yytext, strlen(yytext));
                yylval.sir[strlen(yytext)+1] = '\0';
                return TOK_DECLARE; }
"double"           { yylloc.first_line = lineNo; 
                yylloc.first_column = colNo; 
                colNo += strlen(yytext);
                yylval.sir = new char[strlen(yytext)+1];
                strncpy(yylval.sir, yytext, strlen(yytext));
                yylval.sir[strlen(yytext)+1] = '\0';
                return TOK_DECLARE; }
"float"           { yylloc.first_line = lineNo; 
                yylloc.first_column = colNo; 
                colNo += strlen(yytext);
                yylval.sir = new char[strlen(yytext)+1];
                strncpy(yylval.sir, yytext, strlen(yytext));
                yylval.sir[strlen(yytext)+1] = '\0';
                return TOK_DECLARE; }
"void"           { yylloc.first_line = lineNo; 
                yylloc.first_column = colNo; 
                colNo += strlen(yytext);
                yylval.sir = new char[strlen(yytext)+1];
                strncpy(yylval.sir, yytext, strlen(yytext));
                yylval.sir[strlen(yytext)+1] = '\0';
                return TOK_DECLARE; }
"printf("			    { colNo+=7; return TOK_PRINTF; }
"scanf(\"%d\", &"       { colNo += strlen(yytext); return TOK_SCANF; }
"scanf(\"%f\", &"       { colNo += strlen(yytext); return TOK_SCANF; }
\"([^"])*\" {
                yylloc.first_line = lineNo; 
                yylloc.first_column = colNo; 
                colNo += strlen(yytext);
                yylval.sir = new char[strlen(yytext)-1];
                strncpy(yylval.sir, yytext+1, strlen(yytext)-2);
                yylval.sir[strlen(yytext)-2] = '\0';
                return TOK_STRING_LITERAL;
            }
\"([^"])*\",   {
                yylloc.first_line = lineNo; 
                yylloc.first_column = colNo; 
                colNo += strlen(yytext);
                yylval.sir = new char[strlen(yytext)-1];
                strncpy(yylval.sir, yytext+1, strlen(yytext)-2);
                yylval.sir[strlen(yytext)-5] = '\0';
                return TOK_STRING_LITERAL;
            }

[a-zA-Z][a-zA-Z0-9]* { 	yylloc.first_line = lineNo; 
						yylloc.first_column = colNo; 
						colNo+=strlen(yytext); 
						yylval.sir = new char[strlen(yytext)+1];
						strcpy(yylval.sir,yytext); 
						return TOK_VARIABLE;}
[ ]				{ colNo++; }
\r\n			{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ colNo++; return TOK_ERROR; }
%%
