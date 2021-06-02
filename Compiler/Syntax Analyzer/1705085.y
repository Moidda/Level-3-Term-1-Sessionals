%{
#include <bits/stdc++.h>
using namespace std;

#include "SymbolTable.h"

int yyparse(void);
int yylex(void);
extern FILE *yyin;


int lineCount = 1;
int errorCount = 0;
int scopeCount = 1;

SymbolTable symbolTable(7);
SymbolInfo* symbolInfo;

FILE* input;
ofstream logOut;
ofstream errorOut;

void yyerror(char*);

/********************** Helper Functions **********************/

void printLog(string matchedRule, string matchedText) {
    logOut << "At line no: " << lineCount << " " << matchedRule << endl << endl;
    logOut << matchedText << endl << endl;
}

/**************************************************************/

%}


%union {
    SymbolInfo* symbolInfo;
}

%token IF ELSE FOR WHILE DO BREAK CONTINUE INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT PRINTLN
%token ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token CONST_INT CONST_FLOAT
%token ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%
var_declaration : type_specifier declaration_list SEMICOLON {
                string name = ($<symbolInfo>1)->getSymbolName() + " " + ($<symbolInfo>2)->getSymbolName() + ";" ;
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("var_declaration : type_specifier declaration_list SEMICOLON", name);
        }
         ;

type_specifier  : INT {
                $<symbolInfo>$ = new SymbolInfo("int", "NON_TERMINAL");
                printLog("type_specifier: INT", "int");
        }
        | FLOAT {
                $<symbolInfo>$ = new SymbolInfo("float", "NON_TERMINAL");
                printLog("type_specifier: FLOAT", "float");
        }
        | VOID {
                $<symbolInfo>$ = new SymbolInfo("void", "NON_TERMINAL");
                printLog("type_specifier: VOID", "void");
        }
        ;

declaration_list : declaration_list COMMA ID {
                string name = ($<symbolInfo>1)->getSymbolName() + "," + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : declaration_list COMMA ID", name);
            }
            | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
                string name = ($<symbolInfo>1)->getSymbolName() + "," + ($<symbolInfo>3)->getSymbolName() + "[" + ($<symbolInfo>5)->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : declaration_list COMMA ID", name);
            }
            | ID {
                string name = ($<symbolInfo>1)->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list: ID", name);
            }
            | ID LTHIRD CONST_INT RTHIRD {
                string name = ($<symbolInfo>1)->getSymbolName() + "[" + ($<symbolInfo>3)->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : ID LTHIRD CONST_INT RTHIRD", name);
            }
          ;


statements : statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statements : statement", name);
        }
        | statements statement {
                string name = $<symbolInfo>1->getSymbolName() + " " + $<symbolInfo>2->getSymbolName(); 
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statements : statements statement", name);
        }
       ;

       
statement : var_declaration {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : var_declaration", name);
        }
        | expression_statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : expression_statement", name);   
        }
        | compound_statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : compound_statement", name);
        }
        | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
                string name = "for(" + $<symbolInfo>3->getSymbolName() + $<symbolInfo>4->getSymbolName() + $<symbolInfo>5->getSymbolName() + ") " + $<symbolInfo>7->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement", name);
        }
        | IF LPAREN expression RPAREN statement {
                string name = "if(" + $<symbolInfo>3->getSymbolName() + ") " + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement", name);      
        }
        | IF LPAREN expression RPAREN statement ELSE statement {
                string name = "if(" + $<symbolInfo>3->getSymbolName() + ") " + $<symbolInfo>5->getSymbolName() + " else " + $<symbolInfo>7->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement ELSE statement", name);
        }
        | WHILE LPAREN expression RPAREN statement {
                string name = "while(" + $<symbolInfo>3->getSymbolName() + ") " + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : WHILE LPAREN expression RPAREN statement", name);
        }
        | PRINTLN LPAREN ID RPAREN SEMICOLON {
                string name = "println(" + $<symbolInfo>3->getSymbolName() + ");";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : PRINTLN LPAREN ID RPAREN SEMICOLON", name);
        }
        | RETURN expression SEMICOLON {
                string name = "return " + $<symbolInfo>2->getSymbolName() + ";";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : RETURN expression SEMICOLON", name);
        }
        ;
      

compound_statement : LCURL statements RCURL {
                string name = "{ " + $<symbolInfo>2->getSymbolName() + " }";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("compound_statement : LCURL statements RCURL", name);
        }
        | LCURL RCURL {
                $<symbolInfo>$ = new SymbolInfo("{}", "NON_TERMINAL");
                printLog("compound_statement : LCURL RCURL", "{}");       
        }
        ;

expression_statement : SEMICOLON {
                $<symbolInfo>$ = new SymbolInfo(";", "NON_TERMINAL");
                printLog("expression_statement : SEMICOLON", ";");
            }
        | expression SEMICOLON {
                string name = $<symbolInfo>1->getSymbolName() + " ;";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression_statement : expression SEMICOLON", name);
        }
        ;
      
variable : ID {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("variable : ID", name);        
        }
        | ID LTHIRD expression RTHIRD {
                string name = $<symbolInfo>1->getSymbolName() + "[" + $<symbolInfo>3->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("variable : ID LTHIRD expression RTHIRD", name);
        }
        ;
     
expression : logic_expression {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression : logic_expression", name);
        }
        | variable ASSIGNOP logic_expression {
                string name = $<symbolInfo>1->getSymbolName() + " = " + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression : variable ASSIGNOP logic_expression", name);   
        }
        ;
            
logic_expression : rel_expression {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("logic_expression : rel_expression", name);       
        }
        | rel_expression LOGICOP rel_expression {
                string name = $<symbolInfo>1->getSymbolName() + 
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("logic_expression : rel_expression", name);   
        }
        ;
            
rel_expression  : simple_expression 
        | simple_expression RELOP simple_expression 
        ;
                
simple_expression : term 
          | simple_expression ADDOP term 
          ;
                    
term :  unary_expression
     |  term MULOP unary_expression
     ;

unary_expression : ADDOP unary_expression  
         | NOT unary_expression 
         | factor 
         ;
    
factor  : variable 
    | LPAREN expression RPAREN
    | CONST_INT 
    | CONST_FLOAT
    | variable INCOP 
    | variable DECOP
    ;
%%


int main(int argc,char *argv[])
{

    if((input = fopen(argv[1], "r")) == NULL) {
        printf("Cannot Open Input File.\n");
        exit(1);
    }

    logOut.open("Parser_log.txt");
    errorOut.open("Parser_error.txt");
    
    yyin = input;
    yyparse(); // processing starts

    symbolTable.printAllScope(logOut);
    symbolTable.exitScope();

    fclose(yyin);
    logOut.close();
    errorOut.close();
    
    return 0;
}


void yyerror(char* s) {
    logOut << "Error At line no: " << lineCount << " " << s << endl;

    lineCount++;
    errorCount++;
    
    return ;
}
