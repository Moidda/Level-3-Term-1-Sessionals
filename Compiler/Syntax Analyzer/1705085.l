%option noyywrap

%{
#include<bits/stdc++.h>
using namespace std;

#include "SymbolTable.h"
#include "y.tab.h"

extern YYSTYPE yylval;
extern SymbolTable symbolTable;

extern int lineCount;
extern int errorCount;
extern ofstream logOut;

void yyerror(char*);
%}
 
 
WHITESPACE [ \t\f\r\v]+
NEWLINE [\n]
LETTER [a-zA-Z]
DIGIT [0-9]
ALPHANUMERIC [a-zA-Z0-9]
INTEGER ([1-9]{DIGIT}*)|[0]

POWER_OF_TEN [Ee][-]?{INTEGER}
FRACTION {INTEGER}?[.]{DIGIT}+

FLOAT {FRACTION}|{FRACTION}{POWER_OF_TEN}|{INTEGER}{POWER_OF_TEN}
FLOAT_ERROR {FRACTION}[.]({FLOAT}|{INTEGER})*

ILL {INTEGER}[Ee][-]?{FLOAT}({FLOAT}|{FLOAT_ERROR}|{INTEGER})*
ILL_NUMBER {ILL}[Ee]({ILL}|{FLOAT_ERROR}|{FLOAT}|{POWER_OF_TEN}|{INTEGER})*

IDENTIFIER ({LETTER}|[_])({ALPHANUMERIC}|[_])*
PREFIX_ERROR ({INTEGER}|{FLOAT}|{FLOAT_ERROR})+{IDENTIFIER}({FLOAT}|{FLOAT_ERROR})*
SUFFIX_ERROR ({INTEGER}|{FLOAT}|{FLOAT_ERROR})*{IDENTIFIER}({FLOAT}|{FLOAT_ERROR})+
ID_ERROR {PREFIX_ERROR}|{SUFFIX_ERROR}
        

SINGLE_QUOTE [\\]["]
STRING_BODY ([^\n"]|{SINGLE_QUOTE})*
NORMAL_STRING {STRING_BODY}["]
MULTI_STRING_BODY {STRING_BODY}[\\][\n] 
MULTI_STRING {MULTI_STRING_BODY}*{NORMAL_STRING}
UNTERMINATED_STRING {MULTI_STRING_BODY}*([\n]|[^\n"]*[^\\"][\n])

%%
{WHITESPACE}    {}
{NEWLINE}       {lineCount++;       }

"if"            {return IF;         }
"else"          {return ELSE;       }
"for"           {return FOR;        }
"while"         {return WHILE;      }
"do"            {return DO;         }
"break"         {return BREAK;      }
"int"           {return INT;        }
"char"          {return CHAR;       }
"float"         {return FLOAT;      }
"double"        {return DOUBLE;     }
"void"          {return VOID;       }
"return"        {return RETURN;     }
"switch"        {return SWITCH;     }
"case"          {return CASE;       }
"default"       {return DEFAULT;    }
"continue"      {return CONTINUE;   }
"println"       {return PRINTLN;    }

"+"|"-"         {
                    yylval.symbolInfo = new SymbolInfo(yytext, "ADDOP"); 
                    return ADDOP;      
                }
"*"|"/"|"%"     {
                    yylval.symbolInfo = new SymbolInfo(yytext, "MULOP");
                    return MULOP;      
                }
"++"            {return INCOP;      }
"--"            {return DECOP;      }

"<"|"<="|">"|">="|"=="|"!=" {
                    return RELOP;      
                }
"="             {return ASSIGNOP;   }
"&&"|"||"       {
                    return LOGICOP;    
                }
"!"             {return NOT;        }

"("             {return LPAREN;     }
")"             {return RPAREN;     }
"{"             {return LCURL;      }
"}"             {return RCURL;      }
"["             {return LTHIRD;     }
"]"             {return RTHIRD;     }
","             {return COMMA;      }
";"             {return SEMICOLON;  }


{INTEGER}       {
                    yylval.symbolInfo = new SymbolInfo(yytext, "CONST_INT");
                    return CONST_INT;
                }

{FLOAT}         {
                    SymbolInfo* symbolInfo = new SymbolInfo(yytext, "CONST_FLOAT");
                    yylval.symbolInfo = symbolInfo;
                    return CONST_FLOAT;
                }

{FLOAT_ERROR}   {}

{ILL_NUMBER}    {}


{ID_ERROR}      {}

{IDENTIFIER}    {
                    SymbolInfo* symbolInfo = new SymbolInfo(yytext, "ID");
                    yylval.symbolInfo = symbolInfo;
                    return ID;                           
                }

%%

