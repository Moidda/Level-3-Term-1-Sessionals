%{
#include <bits/stdc++.h>
using namespace std;

#include "SymbolTable.h"

int yyparse(void);
int yylex(void);
extern FILE *yyin;


// SymbolInfo symbolType
const string VARIABLE_STR = "variable";
const string FUNCTION_STR = "function";
const string ARRAY_STR = "array";

// SymbolInfo returnType
const string INT_STR = "int";
const string FLOAT_STR = "float";
const string VOID_STR = "void";

int lineCount = 1;
int errorCount = 0;
int scopeCount = 1;

SymbolTable symbolTable(7);

vector<SymbolInfo*> var_list;

FILE* input;
ofstream logOut;
ofstream errorOut;

void yyerror(char*);

/********************** Helper Functions **********************/

void printLog(string matchedRule, string matchedText) {
    logOut << "Line " << lineCount << ": " << matchedRule << endl << endl;
    logOut << matchedText << endl << endl;
}

void printError(string errorMsg) {
        errorOut << "Error at line " << lineCount << ": " << errorMsg << endl << endl;
        logOut << "Error at line " << lineCount << ": " << errorMsg << endl << endl;
        errorCount++;
}

void insertVarDeclaration(string variableType) {
        if(variableType == "void") {
                printError("Variable type cannot be void");
                variableType = FLOAT_STR;                                 // treating void variables as FLOAT henceforth
        }
        for(int i = 0; i < var_list.size(); i++) {
                SymbolInfo* sinfo = var_list[i];
                sinfo->setReturnType(variableType);
                logOut << sinfo->getSymbolContent() << endl;
                bool ok = symbolTable.insertIntoTable(sinfo);
                if(!ok) {
                        printError("Multiple declaration of " + sinfo->getSymbolName());
                }
        }
        var_list.clear();    
}

void voidChecking(SymbolInfo* sinfo) {
        if(sinfo->getReturnType() != VOID_STR) return;
        printError("Void function used in expression");
        sinfo->setReturnType(FLOAT_STR);                                // treating void as FLOAT henceforth
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
start : program {
                // string name = $<symbolInfo>1->getSymbolName();
                // $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("start : program", "");
        }
        ;

program : program unit {
                string name = $<symbolInfo>1->getSymbolName();                  // program
                name += "\n" + $<symbolInfo>2->getSymbolName();                  // unit
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("program : program unit", name);
        }
        | unit {
                string name = $<symbolInfo>1->getSymbolName();                  //unit
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("program : unit", name);       
        }
        ;
        
unit : var_declaration {
                string name = $<symbolInfo>1->getSymbolName();                  // var_declaration
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unit : var_declaration", name);
        }
        | func_declaration {
                string name = $<symbolInfo>1->getSymbolName();                  // func_declaration
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unit : func_declaration", name);
        }
        | func_definition {                                                     // func_definition
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unit : func_definition", name);       
        }
        ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
                string name = $<symbolInfo>1->getSymbolName();                   // type_specifier
                name += " " + $<symbolInfo>2->getSymbolName();                   // ID
                name += "(" + $<symbolInfo>4->getSymbolName() + ");";           // (parameter_list);
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", name);
        }
        | type_specifier ID LPAREN RPAREN SEMICOLON {
                string name = $<symbolInfo>1->getSymbolName();                   // type_specifier
                name += " " + $<symbolInfo>2->getSymbolName();                   // ID
                name += "();";                                                   // ();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON", name);
        }
        ;
                 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
                string name = $<symbolInfo>1->getSymbolName();                  // type_specifier 
                name += " " + $<symbolInfo>2->getSymbolName();                  // ID
                name += "(" + $<symbolInfo>4->getSymbolName() + ")";            // (parameter_list)
                name += $<symbolInfo>6->getSymbolName();                       // compound_statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement", name);
        }
        | type_specifier ID LPAREN RPAREN compound_statement {
                string name = $<symbolInfo>1->getSymbolName();                  // type_specifier
                name += " " + $<symbolInfo>2->getSymbolName();                  // ID
                name += "()";                                                   // ()
                name += $<symbolInfo>5->getSymbolName();                        // compound_statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_definition : type_specifier ID LPAREN RPAREN compound_statement", name);
        }
        ;                               


parameter_list : parameter_list COMMA type_specifier ID {
                string name = $<symbolInfo>1->getSymbolName();                  // parameter_list
                name += "," + $<symbolInfo>3->getSymbolName();                  // ,type_specifier
                name += " " + $<symbolInfo>4->getSymbolName();                  // ID
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : parameter_list COMMA type_specifier ID", name);
        }
        | parameter_list COMMA type_specifier {
                string name = $<symbolInfo>1->getSymbolName();                  // parameter_list
                name += "," + $<symbolInfo>3->getSymbolName();                  // ,type_specifier
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : parameter_list COMMA type_specifier", name);
        }
        | type_specifier ID {   
                string name = $<symbolInfo>1->getSymbolName() + " " + $<symbolInfo>2->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : type_specifier ID", name);
        }
        | type_specifier {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : type_specifier", name);
        }
        ;

var_declaration : type_specifier declaration_list SEMICOLON {                   
                string name = ($<symbolInfo>1)->getSymbolName();                // type_specifier
                name += " " + ($<symbolInfo>2)->getSymbolName() + ";";          // declaration_list;
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("var_declaration : type_specifier declaration_list SEMICOLON", name);

                insertVarDeclaration($<symbolInfo>1->getSymbolName());
        }
        ;

type_specifier : INT {
                $<symbolInfo>$ = new SymbolInfo("int", "NON_TERMINAL");
                printLog("type_specifier : INT", "int");
        }
        | FLOAT {
                $<symbolInfo>$ = new SymbolInfo("float", "NON_TERMINAL");
                printLog("type_specifier : FLOAT", "float");
        }
        | VOID {
                $<symbolInfo>$ = new SymbolInfo("void", "NON_TERMINAL");
                printLog("type_specifier : VOID", "void");
        }
        ;

declaration_list : declaration_list COMMA ID {
                string name = ($<symbolInfo>1)->getSymbolName() + "," + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : declaration_list COMMA ID", name);

                SymbolInfo* sinfo = $<symbolInfo>3;
                sinfo->setSymbolType(VARIABLE_STR);
                var_list.push_back(sinfo);
        }
        | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
                string name = ($<symbolInfo>1)->getSymbolName() + ",";                  // declaration_list, 
                name += ($<symbolInfo>3)->getSymbolName();                              // ID
                name += "[" + ($<symbolInfo>5)->getSymbolName() + "]";                  // [CONST_INT]
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : declaration_list COMMA ID", name);
            
                SymbolInfo* sinfo = $<symbolInfo>3;
                sinfo->setSymbolType(ARRAY_STR);
                sinfo->setArraySize( stoi( ($<symbolInfo>5)->getSymbolName() ) );
                var_list.push_back(sinfo);
        }
        | ID {
                string name = ($<symbolInfo>1)->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : ID", name);
            
                SymbolInfo* sinfo = $<symbolInfo>1;
                sinfo->setSymbolType(VARIABLE_STR);
                var_list.push_back(sinfo);
        }
        | ID LTHIRD CONST_INT RTHIRD {
                string name = ($<symbolInfo>1)->getSymbolName() + "[" + ($<symbolInfo>3)->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("declaration_list : ID LTHIRD CONST_INT RTHIRD", name);
            
                SymbolInfo* sinfo = $<symbolInfo>1;
                sinfo->setSymbolType(ARRAY_STR);
                sinfo->setArraySize( stoi( ($<symbolInfo>3)->getSymbolName() ) );
                var_list.push_back(sinfo);
        }
        ;


statements : statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statements : statement", name);
        }
        | statements statement {
                string name = $<symbolInfo>1->getSymbolName() + "\n" + $<symbolInfo>2->getSymbolName(); 
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
                string name = "for(" + $<symbolInfo>3->getSymbolName();                         // for(expression_statement
                name += $<symbolInfo>4->getSymbolName();                                        // expression_statement
                name += $<symbolInfo>5->getSymbolName() + ")";                                  // expression)            
                name += $<symbolInfo>7->getSymbolName();                                        // statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement", name);
        }
        | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
                string name = "if (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement", name);      
        }
        | IF LPAREN expression RPAREN statement ELSE statement {
                string name = "if (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();        // if(expression) statement
                name += "\nelse\n" + $<symbolInfo>7->getSymbolName();                                                    // else statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement ELSE statement", name);
        }
        | WHILE LPAREN expression RPAREN statement {
                string name = "while (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : WHILE LPAREN expression RPAREN statement", name);
        }
        | PRINTLN LPAREN ID RPAREN SEMICOLON {
                string name = "printf(" + $<symbolInfo>3->getSymbolName() + ");";
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
                string name = "{\n" + $<symbolInfo>2->getSymbolName() + "\n}";
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
                string name = $<symbolInfo>1->getSymbolName() + ";";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression_statement : expression SEMICOLON", name);
        }
        ;
      
variable : ID {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("variable : ID", name);    

                SymbolInfo* sinfo = symbolTable.lookup(name);
                if(sinfo == NULL) {
                        printError("Undeclared variable " + name);
                }
                else {
                        // copy the contents of symbolInfo stored in symbol table into $$
                        $<symbolInfo>$->setSymbolType(sinfo->getSymbolType());
                        $<symbolInfo>$->setReturnType(sinfo->getReturnType());
                        $<symbolInfo>$->setArraySize(sinfo->getArraySize());
                }
        }
        | ID LTHIRD expression RTHIRD {
                string name = $<symbolInfo>1->getSymbolName() + "[" + $<symbolInfo>3->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("variable : ID LTHIRD expression RTHIRD", name);
        
                // find the symbolInfo with the name of ID
                SymbolInfo* sinfo = symbolTable.lookup($<symbolInfo>1->getSymbolName());
                if(sinfo == NULL) {
                        printError("Undeclared variable " + name);
                }
                else {
                        // copy the contents of symbolInfo from symbolTable into $$
                        $<symbolInfo>$->setSymbolType(sinfo->getSymbolType());
                        $<symbolInfo>$->setReturnType(sinfo->getReturnType());
                        $<symbolInfo>$->setArraySize(sinfo->getArraySize());

                        // check if expression has returnType of int or not
                        if($<symbolInfo>3->getReturnType() != INT_STR) {
                                printError("Expression inside third brackets not an integer");
                        }
                }
        }
        ;
     
expression : logic_expression {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression : logic_expression", name);

                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        | variable ASSIGNOP logic_expression {
                string name = $<symbolInfo>1->getSymbolName() + "=" + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression : variable ASSIGNOP logic_expression", name);                

                voidChecking($<symbolInfo>3);
                if($<symbolInfo>1->getReturnType() != $<symbolInfo>3->getReturnType()) printError("Type Mismatch");
                $<symbolInfo>$->setReturnType($<symbolInfo>3->getReturnType());
        }
        ;
            
logic_expression : rel_expression {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("logic_expression : rel_expression", name);       
        
                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        | rel_expression LOGICOP rel_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("logic_expression : rel_expression LOGICOP rel_expression", name);   
        
                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);
                $<symbolInfo>$->setReturnType(INT_STR);                 // type casting, LOGICOP should return int
        }
        ;
            
rel_expression  : simple_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("rel_expression : simple_expression", $<symbolInfo>1->getSymbolName());
        
                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        | simple_expression RELOP simple_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("rel_expression : simple_expression RELOP simple_expression", name);
        
                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);
                $<symbolInfo>$->setReturnType(INT_STR);                 // type casting, RELOP should return int
        }       
        ;
                
simple_expression : term {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("simple_expression : term", $<symbolInfo>1->getSymbolName());
        
                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        | simple_expression ADDOP term {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("simple_expression : term", name);
        
                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);
                
                if($<symbolInfo>1->getReturnType() == FLOAT_STR or $<symbolInfo>3->getReturnType() == FLOAT_STR)
                        $<symbolInfo>$->setReturnType(FLOAT_STR); 
                else
                        $<symbolInfo>$->setReturnType(INT_STR);
        }
        ;
                    
term : unary_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("term : unary_expression", $<symbolInfo>1->getSymbolName());       
        
                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        | term MULOP unary_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("term : term MULOP unary_expression", name);
        
                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);

                if($<symbolInfo>2->getSymbolName() == "%") {
                        if($<symbolInfo>1->getReturnType() != INT_STR) printError("Non-Integer operand on modulus operator");
                        if($<symbolInfo>3->getReturnType() != INT_STR) printError("Non-Integer operand on modulus operator");
                        if($<symbolInfo>3->getSymbolName() == "0") printError("Modulus by Zero");
                }
                else {
                        if($<symbolInfo>1->getReturnType() == FLOAT_STR or $<symbolInfo>3->getReturnType() == FLOAT_STR)
                                $<symbolInfo>$->setReturnType(FLOAT_STR);
                        else
                                $<symbolInfo>$->setReturnType(INT_STR);
                }
        }
        ;

unary_expression : ADDOP unary_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unary_expression : ADDOP unary_expression", name);

                voidChecking($<symbolInfo>2);
                $<symbolInfo>$->setReturnType($<symbolInfo>2->getReturnType());

        }
        | NOT unary_expression {
                string name = "!" + $<symbolInfo>2->getSymbolName();       
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unary_expression : NOT unary_expression", name);
        
                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType(INT_STR);                         // type casting, NOT should return INT
        }
        | factor {
                string name = $<symbolInfo>1->getSymbolName();       
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unary_expression : factor", name);
        
                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType( $<symbolInfo>1->getReturnType() );
                
                if($<symbolInfo>1->getSymbolName() == "38") {
                        cout << $<symbolInfo>$->getReturnType() << endl;
                }
        }
        ;
    
factor : variable {
                string name = $<symbolInfo>1->getSymbolName();       
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : variable", name);       
        
                $<symbolInfo>$->setReturnType( $<symbolInfo>1->getReturnType() );
        }
        | ID LPAREN argument_list RPAREN {
                string name = $<symbolInfo>1->getSymbolName() + "(" + $<symbolInfo>3->getSymbolName() + ")";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : ID LPAREN argument_list RPAREN", name);
        
                // foo(x, y, z);
                // function has to be declared
                // i.e foo has to exist as a function in scopetable
                // foo has to be defined
                
        }
        | LPAREN expression RPAREN {
                string name = "(" + $<symbolInfo>2->getSymbolName() + ")";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : LPAREN expression RPAREN", name);

                voidChecking($<symbolInfo>2);
                $<symbolInfo>$->setReturnType( $<symbolInfo>2->getReturnType() );  
        }
        | CONST_INT {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("factor : CONST_INT", $<symbolInfo>1->getSymbolName());
                
                $<symbolInfo>$->setReturnType(INT_STR);
        }
        | CONST_FLOAT {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("factor : CONST_FLOAT", $<symbolInfo>1->getSymbolName());
        
                $<symbolInfo>$->setReturnType(FLOAT_STR);
        }
        | variable INCOP {
                string name = $<symbolInfo>1->getSymbolName() + "++";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : variable INCOP", name);
        
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        | variable DECOP {
                string name = $<symbolInfo>1->getSymbolName() + "--";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : variable DECOP", name);
        
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        }
        ;

argument_list : arguments {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("argument_list : arguments", $<symbolInfo>1->getSymbolName());
        }
        | {
                // thik ase ????????????????????????????????????????????????????????????????????????????
                $<symbolInfo>$ = new SymbolInfo("", "NON_TERMINAL");
                printLog("argument_list : <epsilon-production>", "");
        }
        ;
        
arguments : arguments COMMA logic_expression {
                string name = $<symbolInfo>1->getSymbolName() + "," + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("arguments : arguments COMMA logic_expression", name);
        
                voidChecking($<symbolInfo>3);
        }
        | logic_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("arguments : logic_expression", $<symbolInfo>1->getSymbolName());

                voidChecking($<symbolInfo>1); 
        }
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
    logOut << "Error At line " <<  lineCount << ": " << s << endl;
    errorOut << "Error At line " << lineCount << ": " << s << endl;
    errorCount++;
    return;
}
