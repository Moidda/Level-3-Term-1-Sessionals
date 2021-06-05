%{
#include <bits/stdc++.h>
using namespace std;

#include "SymbolTable.h"

int yyparse(void);
int yylex(void);
extern FILE *yyin;


// SymbolInfo symbolType
const string VARIABLE_STR = "variable";
const string FUNCTION_DECLARATION_STR = "function_declaration";
const string FUNCTION_DEFINITION_STR = "function_definition";
const string ARRAY_STR = "array";

// SymbolInfo returnType
const string INT_STR = "int";
const string FLOAT_STR = "float";
const string VOID_STR = "void";

int lineCount = 1;
int errorCount = 0;
int scopeCount = 1;

// needed for function definition
bool globalBool;

SymbolTable symbolTable(7);

vector<SymbolInfo*> var_list;
vector<FuncParam> par_list;

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
        logOut << "Inserting Variables ... " << endl;
        for(int i = 0; i < var_list.size(); i++) {
                SymbolInfo* sinfo = var_list[i];
                sinfo->setReturnType(variableType);
                
                logOut << sinfo->getSymbolContent() << endl;

                bool ok = symbolTable.insertIntoTable(sinfo);
                if(!ok) printError("Multiple declaration of " + sinfo->getSymbolName());
        }
        var_list.clear();
        symbolTable.printCurrentScope(logOut);
}


/*
        Two possible scenarios:
                1) Function was declared
                2) Another ID has the same name
        Prints any relevant error message and returns a boolean
*/
bool checkFuncValidity(string fooType, string fooName) {
        
        SymbolInfo* sinfo = symbolTable.lookup(fooName);

        // no ID with the same name exists
        if(sinfo == NULL) return true;
        
        // Case 2
        if(sinfo->getSymbolType() != FUNCTION_DECLARATION_STR) {
                printError("Multiple declaration of " + fooName);
                return false;
        }

        bool ok = true;
        // this function was declared. Check consisteny of declaration parameter list with definition parameter list
        if(sinfo->getFuncParamList().size() != par_list.size()) {

                cout << endl;
                cout << "Function ->" << fooName << "<-" << endl;
                cout << "Declaration parameter size->" << sinfo->getFuncParamList().size() << "<-" << endl;
                cout << "Definition parameter size->" << par_list.size() << "<-" << endl << endl;

                printError("Total number of arguments mismatch with declaration in function " + fooName);
                ok = false;
        }

        // get the parameter list from declaration and matching return types of each parameter
        vector<FuncParam> temp = sinfo->getFuncParamList();
        for(int i = 0; i < temp.size(); i++) 
                if(temp[i].retType != par_list[i].retType) {
                        printError(sinfo->intToStr(i+1) + "th argument mismatch in function " + fooName);
                        ok = false;
                }


        // match func_definition return type with func_declaration
        if(fooType != sinfo->getReturnType()) {
                printError("Return type mismatch with function declaration in function " + fooName);
                ok = false;
        }

        if(ok) 
              sinfo->setSymbolType(FUNCTION_DEFINITION_STR);                  

        return ok;
}

void insertFuncDef(string fooType, string fooName) {
        SymbolInfo* sinfo = new SymbolInfo(fooName, "FOO");     // setting name and TOKEN
        sinfo->setSymbolType(FUNCTION_DEFINITION_STR);          // setting type as "function_definition"
        sinfo->setReturnType(fooType);                          // setting return type as "int"|"void"|"float"
        sinfo->setArraySize(par_list.size());                   // setting no of parameters
        for(int i = 0; i < par_list.size(); i++) {              // setting the return type and name of each parameter
                sinfo->insertFuncParameter(par_list[i].retType, par_list[i].name);        
        }

        symbolTable.insertIntoTable(sinfo);                     // inserting function definition in symbolTable

        logOut << "Inserting Function ..." << endl;
        logOut << sinfo->getSymbolContent() << endl;
        logOut << "Parameter List :" << endl;
        vector<FuncParam> temp = sinfo->getFuncParamList();
        for(int i = 0; i < temp.size(); i++)
                logOut << "\t" << temp[i].retType << " " << temp[i].name << endl;
}

void processFuncDef(string fooType, string fooName) {
        if(checkFuncValidity(fooType, fooName))
                insertFuncDef(fooType, fooName);
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
        

                SymbolInfo* sinfo = symbolTable.lookup($<symbolInfo>2->getSymbolName());
                if(sinfo != NULL) {
                        printError("Multiple declaration of " + sinfo->getSymbolName());
                }
                else {
                        sinfo = new SymbolInfo($<symbolInfo>2->getSymbolName(), "NON_TERMINAL");
                        sinfo->setSymbolType(FUNCTION_DECLARATION_STR);
                        sinfo->setReturnType($<symbolInfo>1->getSymbolName());
                        
                        for(int i = 0; i < par_list.size(); i++) 
                                sinfo->insertFuncParameter(par_list[i].retType);
                
                        cout << "Inserting function declaration of " << sinfo->getSymbolName() << endl;
                        cout << sinfo->getSymbolContent() << endl;
                        cout << "Parameters: ";
                        vector<FuncParam> temp = sinfo->getFuncParamList();
                        for(int i = 0; i < temp.size(); i++) 
                                cout << temp[i].retType << ",";
                        cout << endl << endl;

                        symbolTable.insertIntoTable(sinfo);
                        par_list.clear();
                }
        }
        | type_specifier ID LPAREN RPAREN SEMICOLON {
                string name = $<symbolInfo>1->getSymbolName();                   // type_specifier
                name += " " + $<symbolInfo>2->getSymbolName();                   // ID
                name += "();";                                                   // ();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON", name);
        

                SymbolInfo* sinfo = symbolTable.lookup($<symbolInfo>2->getSymbolName());
                if(sinfo != NULL) {
                        printError("Multiple declaration of " + sinfo->getSymbolName());
                }
                else {
                        // set up the function declaration to be inserted in the scopetable
                        sinfo = new SymbolInfo($<symbolInfo>2->getSymbolName(), "NON_TERMINAL");
                        sinfo->setSymbolType(FUNCTION_DECLARATION_STR);
                        sinfo->setReturnType($<symbolInfo>1->getSymbolName());
                        symbolTable.insertIntoTable(sinfo);
                }
        }
        ;
                 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {
                processFuncDef($<symbolInfo>1->getSymbolName(), $<symbolInfo>2->getSymbolName());
        } compound_statement {
                string name = $<symbolInfo>1->getSymbolName();                  // type_specifier 
                name += " " + $<symbolInfo>2->getSymbolName();                  // ID
                name += "(" + $<symbolInfo>4->getSymbolName() + ")";            // (parameter_list)
                name += $<symbolInfo>7->getSymbolName();                       // compound_statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement", name);
                

                cout << "in func_definition of " << $<symbolInfo>2->getSymbolName() << endl;
                cout << "par_list:" << endl;
                for(int i = 0; i < par_list.size(); i++) {
                        cout << par_list[i].retType << "," << par_list[i].name << endl; 
                }
                cout << "end of par_list" << endl << endl;

                if($<symbolInfo>1->getSymbolName() != $<symbolInfo>7->getReturnType())
                        printError("Return type mismatch with function declaration in function " + $<symbolInfo>2->getSymbolName());
        
                par_list.clear();
        }
        | type_specifier ID LPAREN RPAREN {
                processFuncDef($<symbolInfo>1->getSymbolName(), $<symbolInfo>2->getSymbolName());
        }
         compound_statement {
                string name = $<symbolInfo>1->getSymbolName();                  // type_specifier
                name += " " + $<symbolInfo>2->getSymbolName();                  // ID
                name += "()";                                                   // ()
                name += $<symbolInfo>6->getSymbolName();                        // compound_statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("func_definition : type_specifier ID LPAREN RPAREN compound_statement", name);


                cout << "in func_definition of " << $<symbolInfo>2->getSymbolName() << endl;
                cout << "par_list:" << endl;
                for(int i = 0; i < par_list.size(); i++) {
                        cout << par_list[i].retType << "," << par_list[i].name << endl; 
                }
                cout << "end of par_list" << endl << endl;

                if($<symbolInfo>1->getSymbolName() != $<symbolInfo>6->getReturnType()) 
                        printError("Return type mismatch with function definition in function " + $<symbolInfo>2->getSymbolName());
        }
        ;                               

parameter_list : parameter_list COMMA type_specifier ID {
                string name = $<symbolInfo>1->getSymbolName();                  // parameter_list
                name += "," + $<symbolInfo>3->getSymbolName();                  // ,type_specifier
                name += " " + $<symbolInfo>4->getSymbolName();                  // ID
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : parameter_list COMMA type_specifier ID", name);

                /*
                        All the IDs from parameter_list are pushed in the vector par_list
                        for further processing when this parameter_list is matched with the
                        rule of func_definition or func_declaration.
                        
                        par_list is cleared in the code section of the specific rule section
                        parameter_list is matched with  
                */
        
                FuncParam temp;
                temp.retType = $<symbolInfo>3->getSymbolName();
                temp.name = $<symbolInfo>4->getSymbolName();
                par_list.push_back(temp);
        }
        | parameter_list COMMA type_specifier {
                string name = $<symbolInfo>1->getSymbolName();                  // parameter_list
                name += "," + $<symbolInfo>3->getSymbolName();                  // ,type_specifier
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : parameter_list COMMA type_specifier", name);
        
                FuncParam temp;
                temp.retType = $<symbolInfo>3->getSymbolName();
                temp.name = "";
                par_list.push_back(temp);
        }
        | type_specifier ID {   
                string name = $<symbolInfo>1->getSymbolName() + " " + $<symbolInfo>2->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : type_specifier ID", name);
        
                FuncParam temp;
                temp.retType = $<symbolInfo>1->getSymbolName();
                temp.name = $<symbolInfo>2->getSymbolName();
                par_list.push_back(temp);
        }
        | type_specifier {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("parameter_list : type_specifier", name);
        
                FuncParam temp;
                temp.retType = $<symbolInfo>1->getSymbolName();
                temp.name = "";
                par_list.push_back(temp);
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
                printLog("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", name);
            
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

                $<symbolInfo>$->setReturnType( $<symbolInfo>1->getReturnType() );
        }
        | statements statement {
                string name = $<symbolInfo>1->getSymbolName() + "\n" + $<symbolInfo>2->getSymbolName(); 
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statements : statements statement", name);
        
                $<symbolInfo>$->setReturnType( $<symbolInfo>2->getReturnType() );
        }
       ;

       
statement : var_declaration {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : var_declaration", name);
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | expression_statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : expression_statement", name);   
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | compound_statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : compound_statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
                string name = "for(" + $<symbolInfo>3->getSymbolName();                         // for(expression_statement
                name += $<symbolInfo>4->getSymbolName();                                        // expression_statement
                name += $<symbolInfo>5->getSymbolName() + ")";                                  // expression)            
                name += $<symbolInfo>7->getSymbolName();                                        // statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
                string name = "if (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement", name);      
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | IF LPAREN expression RPAREN statement ELSE statement {
                string name = "if (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();        // if(expression) statement
                name += "\nelse\n" + $<symbolInfo>7->getSymbolName();                                                    // else statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement ELSE statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | WHILE LPAREN expression RPAREN statement {
                string name = "while (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : WHILE LPAREN expression RPAREN statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        | PRINTLN LPAREN ID RPAREN SEMICOLON {
                string name = "printf(" + $<symbolInfo>3->getSymbolName() + ");";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : PRINTLN LPAREN ID RPAREN SEMICOLON", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                SymbolInfo* sinfo = symbolTable.lookup($<symbolInfo>3->getSymbolName());
                if(sinfo == NULL) {
                        printError("Undeclared variable " + $<symbolInfo>3->getSymbolName());
                }
        }
        | RETURN expression SEMICOLON {
                string name = "return " + $<symbolInfo>2->getSymbolName() + ";";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : RETURN expression SEMICOLON", name);

                $<symbolInfo>$->setReturnType($<symbolInfo>2->getReturnType());       
        }
        ;
      

compound_statement : LCURL cmpnd_action statements RCURL {
                string name = "{\n" + $<symbolInfo>3->getSymbolName() + "\n}";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("compound_statement : LCURL statements RCURL", name);

                symbolTable.exitScope();
                $<symbolInfo>$->setReturnType( $<symbolInfo>3->getReturnType() );
        }
        | LCURL cmpnd_action RCURL {
                $<symbolInfo>$ = new SymbolInfo("{}", "NON_TERMINAL");
                printLog("compound_statement : LCURL RCURL", "{}");       
        
                symbolTable.exitScope();
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        ;

cmpnd_action : {
                symbolTable.enterScope();
                
                // insert parameters in current scope
                for(int i = 0; i < par_list.size(); i++) {
                        SymbolInfo* sinfo = new SymbolInfo(par_list[i].name, "NON_TERMINAL");
                        sinfo->setSymbolType(VARIABLE_STR);                             // parameter_list should contain only variables (arrays are not supported)
                        var_list.push_back(sinfo);
                        insertVarDeclaration(par_list[i].retType); 
                }
        }


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

                if(sinfo != NULL and sinfo->getSymbolType() != VARIABLE_STR) {
                        printError("Type mismatch, " + sinfo->getSymbolName() + " is a " + sinfo->getSymbolType());
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
        
                if(sinfo != NULL and sinfo->getSymbolType() != ARRAY_STR) {
                        printError("Type mismatch, " + sinfo->getSymbolName() + " is not an array");
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
                
                // returnType mismatch for two sides of '=' operator
                if($<symbolInfo>1->getReturnType() != $<symbolInfo>3->getReturnType()) {
                        
                        // float = int typecasting is ok
                        bool ok = ($<symbolInfo>1->getReturnType() == FLOAT_STR and $<symbolInfo>3->getReturnType() == INT_STR);
                        if(!ok)
                                printError("Type Mismatch");
                }
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
                printLog("simple_expression : simple_expression ADDOP term", name);
        
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
                
                        $<symbolInfo>$->setReturnType(INT_STR);
                }
                else {

                        if($<symbolInfo>2->getSymbolName() == "/" and $<symbolInfo>3->getSymbolName() == "0")
                                printError("Divide by zero");
                                
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
        
                SymbolInfo* sinfo = symbolTable.lookup($<symbolInfo>1->getSymbolName());
                if(sinfo == NULL) {
                        printError("Undeclared function " + $<symbolInfo>1->getSymbolName());
                        $<symbolInfo>$->setReturnType(VOID_STR);
                }
                else if(sinfo->getSymbolType() == ARRAY_STR or sinfo->getSymbolType() == VARIABLE_STR) {
                        printError("Type mismatch, " + sinfo->getSymbolName() + " is " + sinfo->getSymbolType());
                }
                else if(sinfo->getSymbolType() == FUNCTION_DECLARATION_STR) {
                        printError("Function " + sinfo->getSymbolName() + " declared but not defined");
                }
                else {
                        vector<FuncParam> foundList = $<symbolInfo>3->getFuncParamList();
                        vector<FuncParam> actualList = sinfo->getFuncParamList();
                        if(foundList.size() != actualList.size()) {
                                printError("Total number of arguments mismatch in function correct_foo");
                        }
                        else {
                                for(int i = 0; i < foundList.size(); i++) {
                                        if(foundList[i].retType != actualList[i].retType) {
                                                printError(sinfo->intToStr(i+1) + "th argument mismatch in function " + sinfo->getSymbolName());
                                        }
                        }
                        }
                        $<symbolInfo>$->setReturnType( sinfo->getReturnType() );
                }
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
        
                vector<FuncParam> temp = $<symbolInfo>1->getFuncParamList();
                for(int i = 0; i < temp.size(); i++) {
                        $<symbolInfo>$->insertFuncParameter(temp[i].retType);
                }
        }
        | {
                // thik ase ????????????????????????????????????????????????????????????????????????????
                $<symbolInfo>$ = new SymbolInfo("", "NON_TERMINAL");
                printLog("argument_list : ", "");
        }
        ;
        
arguments : arguments COMMA logic_expression {
                string name = $<symbolInfo>1->getSymbolName() + "," + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("arguments : arguments COMMA logic_expression", name);
        
                voidChecking($<symbolInfo>3);
                
                vector<FuncParam> temp = $<symbolInfo>1->getFuncParamList();
                for(int i = 0; i < temp.size(); i++) {
                        $<symbolInfo>$->insertFuncParameter(temp[i].retType);
                }
                $<symbolInfo>$->insertFuncParameter($<symbolInfo>3->getReturnType());
        }
        | logic_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("arguments : logic_expression", $<symbolInfo>1->getSymbolName());

                voidChecking($<symbolInfo>1); 
        
                $<symbolInfo>$->insertFuncParameter($<symbolInfo>1->getReturnType());
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
