%{
#include <bits/stdc++.h>
using namespace std;

#include "SymbolTable.h"
#include "AsmCode.h"

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

const string ERROR_STR = "error";

int lineCount = 1;
int errorCount = 0;
int scopeCount = 1;

SymbolTable symbolTable(7);

vector<SymbolInfo*> var_list;
vector<FuncParam> par_list;

FILE* input;
ofstream asmOut;
ofstream logOut;
ofstream errorOut;

void yyerror(char*);

/***************** Things needed for Intermediate Code Generation **************************************/
AsmCode asmCode;


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

bool isNumber(string str) {
        for(char c: str) if(!('0' <= c and c <= '9')) return false;
        return true;
}

bool isInsideFuncDefinition() {
        return par_list.size() > 0;
}

string getStackPointer(string variableName) {
        string stackPointer = "#";
        for(int i = 0, j = (int)par_list.size()-1; j>=0; j--, i++) {
                if(par_list[j].name == variableName) {
                        stackPointer = "[BP+" + to_string(4 + 2*i) + "]";
                        break;
                }
        }
        return stackPointer;
}

void insertVarDeclaration(string variableType, bool isParameter) {
        if(variableType == "void") {
                printError("Variable type cannot be void");
                variableType = FLOAT_STR;                                 // treating void variables as FLOAT henceforth
        }
        for(int i = 0; i < var_list.size(); i++) {
                SymbolInfo* sinfo = var_list[i];
                sinfo->setReturnType(variableType);
                bool ok = symbolTable.insertIntoTable(sinfo);
                if(!ok) printError("Multiple declaration of " + sinfo->getSymbolName());
                
                string str;
                if(sinfo->getSymbolType() == ARRAY_STR) 
                        str = sinfo->getSymbolName() + "1 DW " + sinfo->intToStr(sinfo->getArraySize()) + " DUP(?)"; 
                else
                        str = sinfo->getSymbolName() + "1 DW ?";
                
                if(!isParameter)
                        asmCode.varList.push_back(str);
        }
        var_list.clear();
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
        SymbolInfo* sinfo = new SymbolInfo(fooName, "ID");              // setting name and TOKEN
        sinfo->setSymbolType(FUNCTION_DEFINITION_STR);                  // setting type as "function_definition"
        sinfo->setReturnType(fooType);                                  // setting return type as "int"|"void"|"float"
        sinfo->setArraySize(par_list.size());                           // setting no of parameters
        for(int i = 0; i < par_list.size(); i++) {                      // setting the return type and name of each parameter
                sinfo->insertFuncParameter(par_list[i].retType, par_list[i].name);
        }

        symbolTable.insertIntoTable(sinfo);                     // inserting function definition in symbolTable
}

void processFuncDef(string fooType, string fooName) {
        if(checkFuncValidity(fooType, fooName))
                insertFuncDef(fooType, fooName);
}

void voidChecking(SymbolInfo* sinfo) {
        if(sinfo->getReturnType() != VOID_STR) return;
                printError("Void function used in expression");
        // sinfo->setReturnType(FLOAT_STR);                                // treating void as FLOAT henceforth

        sinfo->setReturnType(ERROR_STR);
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
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("start : program", name);

                string asmStr = "";
                asmStr = ".MODEL SMALL\n";
                asmStr += ".STACK 100H\n\n";
                asmStr += ".DATA\n";
                asmStr += "CR EQU 0DH\n";
                asmStr += "LF EQU 0AH\n";
                asmStr += "NEWLN DB CR, LF, '$'\n";

                asmStr += asmCode.Comment("all the variables here ...");
                for(string str: asmCode.varList)  asmStr += str + "\n";
                asmCode.varList.clear();

                asmStr += asmCode.Comment("temporary variabls ...");
                for(string str: asmCode.tempList) asmStr += str + "\n";
                asmCode.tempList.clear();
                asmStr += "\n";

                asmStr += ".CODE\n\n";
                asmStr += "MAIN PROC\n";
                asmStr += "; initialize_DS\n";
                asmStr += "MOV AX, @DATA\n";
                asmStr += "MOV DS, AX\n\n";
        
                asmStr += asmCode.Comment("main code here ...\n");
                asmStr += asmCode.mainCode;

                asmStr += "\nDOS_EXIT:\n";
                asmStr += "MOV AH, 4CH\n";
                asmStr += "INT 21H\n";

                asmStr += "MAIN ENDP\n\n";

                asmStr += asmCode.Comment("extra procedues here\n");

                asmStr = asmCode.removeReturnStatements(asmStr, "DOS_EXIT");
                asmOut << asmStr << endl;
                asmStr.clear();

                // print procedure
                ifstream in;
                in.open("print_procedure.asm");
                while(getline(in, asmStr)) asmOut << asmStr << endl;
                in.close();

                asmOut << asmCode.CreateProcedures() << endl;

                asmOut << "END MAIN" << endl;

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
        
                /**
                        Code Generator

                        Nothing to do here. As list of required variables is maintained in the global vector asmCode.varList.
                        Using this global vector, the asm code is generated in the rule 'start : program'
                        Refer to the implementation of 'start : program' and locate where and how asmCode.varList has been
                        used
                */
        }
        | func_declaration {
                string name = $<symbolInfo>1->getSymbolName();                  // func_declaration
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unit : func_declaration", name);

                /**
                        Code Generator

                        Nothing to do here. In my version of code generation, no code is generated for function declarations
                        that has no definitions, since these functions can never be called in the main() procedure. 

                        If any such function that has only declaration andd no definition, is used in the main() procedure,
                        that would imply a semantic error, in which case, no code is generated to begin with.
                */
        }
        | func_definition {                                                     // func_definition
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unit : func_definition", name);

                /**
                        Code Generator
                        
                        Nothing to do here as well :)
                */
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
                        sinfo = new SymbolInfo($<symbolInfo>2->getSymbolName(), "ID");
                        sinfo->setSymbolType(FUNCTION_DECLARATION_STR);
                        sinfo->setReturnType($<symbolInfo>1->getSymbolName());

                        for(int i = 0; i < par_list.size(); i++)
                                sinfo->insertFuncParameter(par_list[i].retType);

                        symbolTable.insertIntoTable(sinfo);
                        par_list.clear();
                }
        }
        | type_specifier ID LPAREN RPAREN SEMICOLON {
                string name = $<symbolInfo>1->getSymbolName();                   // type_specifier
                name += " " + $<symbolInfo>2->getSymbolName();                   // ID
                name += "();";                                                   // ();
                $<symbolInfo>$ = new SymbolInfo(name, "ID");
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

                if($<symbolInfo>1->getSymbolName() != $<symbolInfo>7->getReturnType())
                        printError("Return type mismatch with function declaration in function " + $<symbolInfo>2->getSymbolName());


                /**
                        Code Generator
                */
                string funcName = $<symbolInfo>2->getSymbolName();
                string asmFuncCode = $<symbolInfo>7->getAsmCode();
                int paramSize = par_list.size();
                
                if(funcName == "main") {
                        asmCode.mainCode = $<symbolInfo>7->getAsmCode();        // setting the code so far generated as the main asm procedure code
                }
                else {
                        for(int i = 0; i < par_list.size(); i++)  {
                                asmFuncCode = asmCode.Comment(par_list[i].name + " => " + getStackPointer(par_list[i].name)) + asmFuncCode;
                        }
                        asmCode.insertFunction(funcName, asmFuncCode, paramSize);
                }

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

                if($<symbolInfo>1->getSymbolName() != $<symbolInfo>6->getReturnType())
                        printError("Return type mismatch with function definition in function " + $<symbolInfo>2->getSymbolName());
        

                /**
                        Code Generator
                */
                string funcName = $<symbolInfo>2->getSymbolName();
                string asmFuncCode = $<symbolInfo>7->getAsmCode();
                int paramSize = par_list.size();

                if($<symbolInfo>2->getSymbolName() == "main") {
                        asmCode.mainCode = $<symbolInfo>6->getAsmCode();        // setting the code so far generated as the main asm procedure code
                }
                else {
                        for(int i = 0; i < par_list.size(); i++)  {
                                asmFuncCode = asmCode.Comment(par_list[i].name + " => " + getStackPointer(par_list[i].name)) + asmFuncCode;
                        }
                        asmCode.insertFunction(funcName, asmFuncCode, paramSize);
                }
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

                insertVarDeclaration($<symbolInfo>1->getSymbolName(), false);
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
                $<symbolInfo>$ = new SymbolInfo(name, "ID");
                printLog("declaration_list : declaration_list COMMA ID", name);

                SymbolInfo* sinfo = $<symbolInfo>3;
                sinfo->setSymbolType(VARIABLE_STR);
                var_list.push_back(sinfo);
        }
        | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
                string name = ($<symbolInfo>1)->getSymbolName() + ",";                  // declaration_list,
                name += ($<symbolInfo>3)->getSymbolName();                              // ID
                name += "[" + ($<symbolInfo>5)->getSymbolName() + "]";                  // [CONST_INT]
                $<symbolInfo>$ = new SymbolInfo(name, "ID");
                printLog("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD", name);

                SymbolInfo* sinfo = $<symbolInfo>3;
                sinfo->setSymbolType(ARRAY_STR);
                sinfo->setArraySize( stoi( ($<symbolInfo>5)->getSymbolName() ) );
                var_list.push_back(sinfo);
        }
        | ID {
                string name = ($<symbolInfo>1)->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "ID");
                printLog("declaration_list : ID", name);

                SymbolInfo* sinfo = $<symbolInfo>1;
                sinfo->setSymbolType(VARIABLE_STR);
                var_list.push_back(sinfo);
        }
        | ID LTHIRD CONST_INT RTHIRD {
                string name = ($<symbolInfo>1)->getSymbolName() + "[" + ($<symbolInfo>3)->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "ID");
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
        
                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
        }
        | statements statement {
                string name = $<symbolInfo>1->getSymbolName() + "\n" + $<symbolInfo>2->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statements : statements statement", name);

                $<symbolInfo>$->setReturnType( $<symbolInfo>2->getReturnType() );
                if($<symbolInfo>$->getReturnType() == VOID_STR) 
                        $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());

                /**
                        Code Generator
                */
                string asmStr = $<symbolInfo>1->getAsmCode() + $<symbolInfo>2->getAsmCode();
                $<symbolInfo>$->setAsmCode(asmStr);
        }
       ;


statement : var_declaration {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : var_declaration", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator 

                        No need to do anything for code generation in this section
                        as code has been generated in var_declaration already
                */
        }
        | expression_statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : expression_statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
        }
        | compound_statement {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : compound_statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
        }
        | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
                string name = "for(" + $<symbolInfo>3->getSymbolName();                         // for(expression_statement
                name += $<symbolInfo>4->getSymbolName();                                        // expression_statement
                name += $<symbolInfo>5->getSymbolName() + ")";                                  // expression)
                name += $<symbolInfo>7->getSymbolName();                                        // statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator

                        initiating code -> $3
                        condition code -> $4
                        increment code -> $5
                        loop body code -> $7
                
                        => ; FOR LOOP
                        => initiating code
                        => LOOP:
                        => condition code
                        => ; check if condition is false
                        => CMP $4->getValueRep(), 0
                        => JE LABEL                    ; break loop when condition becomes true
                        => loop body code
                        => increment code
                        => JMP LOOP
                        => LABEL: 
                */
                string asmStr = "";
                string endLoop = asmCode.newLabel();
                string beginLoop = asmCode.newLabel();

                asmStr += asmCode.Comment("--- FOR LOOP ---");

                asmStr += asmCode.Comment("INITIATING LOOP");
                asmStr += $<symbolInfo>3->getAsmCode();           
                
                asmStr += asmCode.Label(beginLoop);                             
                asmStr += asmCode.Comment("LOOP BREAK CONDITION");              
                asmStr += $<symbolInfo>4->getAsmCode();                         
                asmStr += asmCode.Cmp($<symbolInfo>4->getValueRep(), "0");      
                asmStr += asmCode.Jump("JE", endLoop, "BREAK WHEN BREAK-CONDITION IS TRUE");
        
                asmStr += $<symbolInfo>7->getAsmCode();                         
                asmStr += $<symbolInfo>5->getAsmCode();                         
                asmStr += asmCode.Jump("JMP", beginLoop, "JMP TO NEXT ITERATION");                            

                asmStr += asmCode.Label(endLoop);                              
                asmStr += asmCode.Comment("--- END FOR ---");

                $<symbolInfo>$->setAsmCode(asmStr);
        }
        | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
                string name = "if (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator          
                */
                string asmStr = "";
                string label = asmCode.newLabel();

                asmStr += asmCode.Comment("--- if(" + $<symbolInfo>3->getSymbolName() + ") ---");
                asmStr += $<symbolInfo>3->getAsmCode();                         // condition code
                asmStr += asmCode.Cmp($<symbolInfo>3->getValueRep(), "0");      // is condition false?
                asmStr += asmCode.Jump("JE", label);
                asmStr += asmCode.Comment("--- INSIDE IF ---");
                asmStr += $<symbolInfo>5->getAsmCode();                         // body code
                asmStr += asmCode.Label(label);
                asmStr += asmCode.Comment("--- END IF ---");
        
                $<symbolInfo>$->setAsmCode(asmStr);
        }
        | IF LPAREN expression RPAREN statement ELSE statement {
                string name = "if (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();        // if(expression) statement
                name += "\nelse\n" + $<symbolInfo>7->getSymbolName();                                                  // else statement
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : IF LPAREN expression RPAREN statement ELSE statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator
                */
                string endIf = asmCode.newLabel();
                string elseLabel = asmCode.newLabel();
                string asmStr = "";

                asmStr += asmCode.Comment("--- if(" + $<symbolInfo>3->getSymbolName() + ") ---");
                
                asmStr += $<symbolInfo>3->getAsmCode();
                asmStr += asmCode.Cmp($<symbolInfo>3->getValueRep(), "0");
                asmStr += asmCode.Jump("JE", elseLabel, "ELSE CONDITION");

                asmStr += asmCode.Comment("--- INSIDE IF ---");
                asmStr += $<symbolInfo>5->getAsmCode();
                asmStr += asmCode.Jump("JMP", endIf);

                asmStr += asmCode.Label(elseLabel);
                asmStr += asmCode.Comment("--- ELSE ---");
                asmStr += $<symbolInfo>7->getAsmCode();

                asmStr += asmCode.Label(endIf);
                asmStr += asmCode.Comment("--- END IF ---");
        
                $<symbolInfo>$->setAsmCode(asmStr);
        }
        | WHILE LPAREN expression RPAREN statement {
                string name = "while (" + $<symbolInfo>3->getSymbolName() + ")" + $<symbolInfo>5->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : WHILE LPAREN expression RPAREN statement", name);
                $<symbolInfo>$->setReturnType(VOID_STR);

                /**
                        Code Generator
                */
                string beginLoop = asmCode.newLabel();
                string endLoop = asmCode.newLabel();
                string asmStr = "";

                asmStr += asmCode.Comment("--- while(" + $<symbolInfo>3->getSymbolName() + ")---");
                asmStr += asmCode.Label(beginLoop);
                asmStr += $<symbolInfo>3->getAsmCode();
                asmStr += asmCode.Cmp($<symbolInfo>3->getValueRep(), "0", "LOOP BREAK CONDITION");
                asmStr += asmCode.Jump("JE", endLoop, "BREAK");
        
                asmStr += $<symbolInfo>5->getAsmCode();
                asmStr += asmCode.Jump("JMP", beginLoop);

                asmStr += asmCode.Label(endLoop);
                asmStr += asmCode.Comment("--- END WHILE ---");

                $<symbolInfo>$->setAsmCode(asmStr);
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

                /**
                        Code Generator

                        MOV AX, TO_PRINT
                        CALL PRINT_INT
                        LEA DX, MSGN
                        MOV AH, 9
                        INT 21H
                */
                string valueRep = asmCode.variableNaming($<symbolInfo>3->getSymbolName());
                string asmStr = asmCode.Mov("AX", valueRep);
                asmStr += asmCode.Line("CALL PRINT_INT");
                asmStr += asmCode.Line("LEA DX, NEWLN");
                asmStr += asmCode.Line("MOV AH, 9");
                asmStr += asmCode.Line("INT 21H");
                $<symbolInfo>$->setAsmCode(asmStr);
        }
        | RETURN expression SEMICOLON {
                string name = "return " + $<symbolInfo>2->getSymbolName() + ";";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("statement : RETURN expression SEMICOLON", name);

                $<symbolInfo>$->setReturnType($<symbolInfo>2->getReturnType());
        
                /**
                        Code Generator
                */
                string asmStr = $<symbolInfo>2->getAsmCode();
                asmStr += asmCode.Line("RETURN " + $<symbolInfo>2->getValueRep());
                $<symbolInfo>$->setAsmCode(asmStr);
        }
        ;


compound_statement : LCURL cmpnd_action statements RCURL {
                string name = "{\n" + $<symbolInfo>3->getSymbolName() + "\n}";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("compound_statement : LCURL statements RCURL", name);

                symbolTable.printAllScope(logOut);
                symbolTable.exitScope();
                $<symbolInfo>$->setReturnType( $<symbolInfo>3->getReturnType() );

                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>3->getAsmCode());
        }
        | LCURL cmpnd_action RCURL {
                $<symbolInfo>$ = new SymbolInfo("{}", "NON_TERMINAL");
                printLog("compound_statement : LCURL RCURL", "{}");

                symbolTable.printAllScope(logOut);
                symbolTable.exitScope();
                $<symbolInfo>$->setReturnType(VOID_STR);
        }
        ;

cmpnd_action : {
                symbolTable.enterScope();

                // insert parameters in current scope
                for(int i = 0; i < par_list.size(); i++) {
                        SymbolInfo* sinfo = new SymbolInfo(par_list[i].name, "ID");
                        sinfo->setSymbolType(VARIABLE_STR);                             // parameter_list should contain only variables (arrays are not supported)
                        var_list.push_back(sinfo);
                        insertVarDeclaration(par_list[i].retType, true);
                }
        }


expression_statement : SEMICOLON {
                $<symbolInfo>$ = new SymbolInfo(";", "NON_TERMINAL");
                printLog("expression_statement : SEMICOLON", ";");
        
                /**
                        No code to generate over here
                */
        }
        | expression SEMICOLON {
                string name = $<symbolInfo>1->getSymbolName() + ";";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression_statement : expression SEMICOLON", name);
        
                /**
                        Code generation 
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        ;

variable : ID {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("variable : ID", name);

                SymbolInfo* sinfo = symbolTable.lookup(name);
                if(sinfo == NULL) {
                        printError("Undeclared variable " + name);
                        $<symbolInfo>$->setReturnType(ERROR_STR);
                }
                else {
                        // copy the contents of symbolInfo stored in symbol table into $$
                        $<symbolInfo>$->setSymbolType(sinfo->getSymbolType());
                        $<symbolInfo>$->setReturnType(sinfo->getReturnType());
                        $<symbolInfo>$->setArraySize(sinfo->getArraySize());
                }

                if(sinfo != NULL and sinfo->getSymbolType() != VARIABLE_STR) {
                        printError("Type mismatch, " + sinfo->getSymbolName() + " is a " + sinfo->getSymbolType());
                        $<symbolInfo>$->setReturnType(ERROR_STR);
                }

                /**
                        Code Generator
                        A single variable does not generate any code. 
                        Only propagate/assign the valueRep appropriately
                */
                string valueRep;
                if(isInsideFuncDefinition()) valueRep = getStackPointer($<symbolInfo>1->getSymbolName()); 
                else valueRep = asmCode.variableNaming($<symbolInfo>1->getSymbolName());
                
                if(valueRep == "#")
                        valueRep = asmCode.variableNaming($<symbolInfo>1->getSymbolName());

                $<symbolInfo>$->setValueRep(valueRep);
        }
        | ID LTHIRD expression RTHIRD {
                string name = $<symbolInfo>1->getSymbolName() + "[" + $<symbolInfo>3->getSymbolName() + "]";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("variable : ID LTHIRD expression RTHIRD", name);

                // find the symbolInfo with the name of ID
                SymbolInfo* sinfo = symbolTable.lookup($<symbolInfo>1->getSymbolName());
                if(sinfo == NULL) {
                        printError("Undeclared variable " + name);
                        $<symbolInfo>$->setReturnType(ERROR_STR);
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
                        $<symbolInfo>$->setReturnType(ERROR_STR);
                }
        
                /**
                        Code Generator
                        1) generate all the codes for $3 i.e. the expression.
                        2) get the valueRep for $3
                        3) access the index using valueRepof $3
                */
                string asmStr = $<symbolInfo>3->getAsmCode();                   // code for expression
                string index = $<symbolInfo>3->getValueRep();                   // valueRep of expression
                asmStr += asmCode.Mov("BX", index);                             // bx <- index
                asmStr += asmCode.Add("BX", "BX");                              // bx *= 2
                $<symbolInfo>$->setAsmCode(asmStr);
                
                string valueRep = $<symbolInfo>1->getSymbolName();
                valueRep = asmCode.variableNaming(valueRep);
                $<symbolInfo>$->setValueRep(valueRep);
        }
        ;

expression : logic_expression {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression : logic_expression", name);

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generation
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        | variable ASSIGNOP logic_expression {
                string name = $<symbolInfo>1->getSymbolName() + "=" + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("expression : variable ASSIGNOP logic_expression", name);

                voidChecking($<symbolInfo>3);

                if($<symbolInfo>1->getReturnType() != ERROR_STR and $<symbolInfo>3->getReturnType() != ERROR_STR){
                        if($<symbolInfo>1->getReturnType() != $<symbolInfo>3->getReturnType()) {
                                // float = int,  int to float typecasting is ok
                                bool ok = ($<symbolInfo>1->getReturnType() == FLOAT_STR and $<symbolInfo>3->getReturnType() == INT_STR);
                                if(!ok)
                                        printError("Type Mismatch");
                        }
                }
                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generation for ASSIGNOP
                        => code for $3
                        => code for $1 (for arrays there will be code, and temp register will have to be used)
                */
                string asmStr = $<symbolInfo>3->getAsmCode();
                asmStr += $<symbolInfo>1->getAsmCode();
                asmStr += asmCode.Comment(name);
                asmStr += asmCode.Mov("AX", $<symbolInfo>3->getValueRep());
                if($<symbolInfo>1->getSymbolType() == ARRAY_STR) {
                        string temp = asmCode.newTemp();
                        asmStr += asmCode.Comment(temp + " <- " + $<symbolInfo>1->getSymbolName());
                        asmStr += asmCode.Mov($<symbolInfo>1->getValueRep() + "[BX]", "AX");
                        asmStr += asmCode.Mov(temp, "AX");
                        $<symbolInfo>$->setValueRep(temp);
                }
                else {
                        asmStr += asmCode.Mov($<symbolInfo>1->getValueRep(), "AX");
                        $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
                }
                $<symbolInfo>$->setAsmCode(asmStr);
        }
        ;

logic_expression : rel_expression {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("logic_expression : rel_expression", name);

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generation
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        | rel_expression LOGICOP rel_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("logic_expression : rel_expression LOGICOP rel_expression", name);

                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);
                $<symbolInfo>$->setReturnType(INT_STR);                 // type casting, LOGICOP should return int
        
                /**
                        Code Generation for LOGICOP (&&, ||)
                        
                        => code for $1
                        => code for $3
                        => code for logicop
                */
                string temp = asmCode.newTemp();
                string asmStr = $<symbolInfo>1->getAsmCode();
                asmStr += $<symbolInfo>3->getAsmCode();
        
                if($<symbolInfo>2->getSymbolName() == "||") asmStr += asmCode.LogicOr(temp, $<symbolInfo>1->getValueRep(), $<symbolInfo>3->getValueRep());
                if($<symbolInfo>2->getSymbolName() == "&&") asmStr += asmCode.LogicAnd(temp, $<symbolInfo>1->getValueRep(), $<symbolInfo>3->getValueRep());
        
                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep(temp);
        }
        ;

rel_expression : simple_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("rel_expression : simple_expression", $<symbolInfo>1->getSymbolName());

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generation
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        | simple_expression RELOP simple_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("rel_expression : simple_expression RELOP simple_expression", name);

                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);
                $<symbolInfo>$->setReturnType(INT_STR);                 // type casting, RELOP should return int
        
                /**
                        Code Generation for RELOP (<, <=, >, >=, ==, !=)
                
                        => code for $1
                        => code for $3
                
                                let X = $1->getValueRep(), Y = $3->getValueRep()
                
                        => ; TEMP <- matched rule
                        => MOV TEMP, 1          ; considering matched_rule to be true by default
                        => MOV AX, X
                        => CMP AX, Y            ; X ? Y
                        => TRUE_CHECKING LABEL
                        => MOV TEMP, 0
                        => LABEL:
                        =>      ...
                */
                string temp = asmCode.newTemp();

                string asmStr = $<symbolInfo>1->getAsmCode();
                asmStr += $<symbolInfo>3->getAsmCode();
                asmStr += asmCode.Comment(temp + " <- " + name);
                asmStr += asmCode.Line("MOV " + temp + ", 1", "CONSIDERING " + name + " TO BE TRUE BY DEFAULT");
                asmStr += asmCode.Mov("AX", $<symbolInfo>1->getValueRep());
                asmStr += asmCode.Cmp("AX", $<symbolInfo>3->getValueRep(), name);

                string jumpType;
                if($<symbolInfo>2->getSymbolName() == "<")      jumpType = "JL";
                if($<symbolInfo>2->getSymbolName() == "<=")     jumpType = "JLE";
                if($<symbolInfo>2->getSymbolName() == ">")      jumpType = "JG";
                if($<symbolInfo>2->getSymbolName() == ">=")     jumpType = "JGE";
                if($<symbolInfo>2->getSymbolName() == "==")     jumpType = "JE";
                if($<symbolInfo>2->getSymbolName() == "!=")     jumpType = "JNE";
                string labelName = asmCode.newLabel();
                string comment = "SKIP THE FOLLOWING LINE FOR TRUE CONDITION"; 
                asmStr += asmCode.Jump(jumpType, labelName, comment);
                asmStr += asmCode.Mov(temp, "0");
                asmStr += asmCode.Label(labelName);

                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep(temp);
        }
        ;

simple_expression : term {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("simple_expression : term", $<symbolInfo>1->getSymbolName());

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generation
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        | simple_expression ADDOP term {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("simple_expression : simple_expression ADDOP term", name);

                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);

                if($<symbolInfo>1->getReturnType() == ERROR_STR or $<symbolInfo>3->getReturnType() == ERROR_STR) {
                        $<symbolInfo>$->setReturnType(ERROR_STR);
                }
                else {
                        if($<symbolInfo>1->getReturnType() == FLOAT_STR or $<symbolInfo>3->getReturnType() == FLOAT_STR)
                                $<symbolInfo>$->setReturnType(FLOAT_STR);
                        else
                                $<symbolInfo>$->setReturnType(INT_STR);
                }

                /**
                        Code Generation for ADDOP (+, -)
                
                        => code for simple_expression
                        => code for term
                        => ; $1 + $3
                        => MOV AX, $1->getValueRep()
                        => ADD/SUB AX, $2->getValueRep()
                        => MOV NEWTEMP, AX
                */
                string temp = asmCode.newTemp();
                
                string asmStr = $<symbolInfo>1->getAsmCode() + "\n";
                asmStr += $<symbolInfo>3->getAsmCode() + "\n";
                asmStr += asmCode.Comment(temp + " <- " + name);
                asmStr += asmCode.Mov("AX", $<symbolInfo>1->getValueRep());
                if($<symbolInfo>2->getSymbolName() == "+")      asmStr += asmCode.Add("AX", $<symbolInfo>3->getValueRep());
                else                                            asmStr += asmCode.Sub("AX", $<symbolInfo>3->getValueRep());
                asmStr += asmCode.Mov(temp, "AX");

                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep(temp);
        }
        ;

term : unary_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("term : unary_expression", $<symbolInfo>1->getSymbolName());

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());

                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        | term MULOP unary_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName() + $<symbolInfo>3->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("term : term MULOP unary_expression", name);

                voidChecking($<symbolInfo>1);
                voidChecking($<symbolInfo>3);

                if($<symbolInfo>1->getReturnType() == ERROR_STR or $<symbolInfo>3->getReturnType() == ERROR_STR) {
                        $<symbolInfo>$->setReturnType(ERROR_STR);
                }
                else {
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

                /**
                        Code Generator
                        
                        => code for $1
                        => code for $3
                        => ...
                */
                
                string temp = asmCode.newTemp();

                string asmStr = $<symbolInfo>1->getAsmCode();
                asmStr += $<symbolInfo>3->getAsmCode();
                asmStr += asmCode.Comment(temp + " <- " + name);

                string operand1 = $<symbolInfo>1->getValueRep();
                string operand2 = $<symbolInfo>3->getValueRep();
                if(isNumber($<symbolInfo>3->getValueRep())) {
                        asmStr += asmCode.Mov("CX", $<symbolInfo>3->getValueRep());
                        operand2 = "CX";
                }

                if($<symbolInfo>2->getSymbolName() == "*")  asmStr += asmCode.Imul(temp, operand1, operand2);
                else  asmStr += asmCode.Idiv(temp, operand1, operand2, $<symbolInfo>2->getSymbolName() == "/");
                
                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep(temp);
                
        }
        ;

unary_expression : ADDOP unary_expression {
                string name = $<symbolInfo>1->getSymbolName() + $<symbolInfo>2->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unary_expression : ADDOP unary_expression", name);

                voidChecking($<symbolInfo>2);

                $<symbolInfo>$->setReturnType($<symbolInfo>2->getReturnType());

                /**
                        Code Generator
                */
                string asmStr = $<symbolInfo>2->getAsmCode();
                if($<symbolInfo>1->getSymbolName() == "-") 
                        asmStr += asmCode.Neg($<symbolInfo>2->getValueRep());  
                
                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep($<symbolInfo>2->getValueRep());

        }
        | NOT unary_expression {
                string name = "!" + $<symbolInfo>2->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unary_expression : NOT unary_expression", name);

                voidChecking($<symbolInfo>1);
                $<symbolInfo>$->setReturnType(INT_STR);                         // type casting, NOT should return INT
        
                /**
                        Code Generator
                        
                        => CMP $2->getValueRep(), 0
                        => JE L_1
                        => MOV newTemp, 1
                        => JMP L_2
                        => L_1:
                        =>      MOV newTemp, 0
                        => L_2:
                        =>      ...
                */
                string l1 = asmCode.newLabel();
                string l2 = asmCode.newLabel();
                string temp = asmCode.newTemp();
                
                string asmStr = $<symbolInfo>2->getAsmCode();
                asmStr += asmCode.Comment(temp + " <- " + name);
                asmStr += asmCode.Cmp($<symbolInfo>2->getValueRep(), "0", "if " + $<symbolInfo>2->getSymbolName() + " == 0");
                asmStr += asmCode.Jump("JE", l1);
                asmStr += asmCode.Mov(temp, "1");
                asmStr += asmCode.Jump("JMP", l2);
                asmStr += asmCode.Label(l1, $<symbolInfo>2->getSymbolName() + " == 0");
                asmStr += asmCode.Mov(temp, "0");
                asmStr += "\n";
                asmStr += asmCode.Label(l2);

                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep(temp);

        }
        | factor {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("unary_expression : factor", name);

                $<symbolInfo>$->setReturnType( $<symbolInfo>1->getReturnType() );

                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
        }
        ;

factor : variable {
                string name = $<symbolInfo>1->getSymbolName();
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : variable", name);

                $<symbolInfo>$->setReturnType( $<symbolInfo>1->getReturnType() );

                /**
                        Code Generator
                */
                if($<symbolInfo>1->getSymbolType() == ARRAY_STR) {
                        string temp = asmCode.newTemp();
                        string asmStr = $<symbolInfo>1->getAsmCode();
                        asmStr += asmCode.Mov("AX", $<symbolInfo>1->getValueRep() + "[BX]");
                        asmStr += asmCode.Mov(temp, "AX");
                        asmStr = asmCode.Comment(temp + " = " + name) + asmStr;
                
                        $<symbolInfo>$->setAsmCode(asmStr);
                        $<symbolInfo>$->setValueRep(temp);
                }
                else {
                        $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                        $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
                }
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
                

                        /**
                                Code Generator for calling functions
                                
                        */
                        string temp = asmCode.newTemp();                                                // new temp register to assign the valueRep
                        string asmStr = "";
                        asmStr += asmCode.Comment(temp + " <- " + name);
                        for(string str: asmCode.argList) asmStr += asmCode.Push(str);
                        asmStr += asmCode.Line("CALL " + $<symbolInfo>1->getSymbolName());
                        asmStr += asmCode.Mov(temp, "AX");                                              // all procedures store the return value in AX 

                        $<symbolInfo>$->setAsmCode(asmStr);
                        $<symbolInfo>$->setValueRep(temp);

                        asmCode.argList.clear();
                }
        }       
        | LPAREN expression RPAREN {
                string name = "(" + $<symbolInfo>2->getSymbolName() + ")";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : LPAREN expression RPAREN", name);

                voidChecking($<symbolInfo>2);
                $<symbolInfo>$->setReturnType( $<symbolInfo>2->getReturnType() );
        
                /**
                        Code Generator
                */
                string asmStr = $<symbolInfo>2->getAsmCode();
                string temp = asmCode.newTemp();
                asmStr += asmCode.Mov("AX", $<symbolInfo>2->getValueRep());
                asmStr += asmCode.Mov(temp, "AX");
                asmStr = asmCode.Comment(temp + " = " + name) + asmStr;

                $<symbolInfo>$->setAsmCode(asmStr);
                $<symbolInfo>$->setValueRep(temp);
        }
        | CONST_INT {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("factor : CONST_INT", $<symbolInfo>1->getSymbolName());

                $<symbolInfo>$->setReturnType(INT_STR);

                /**
                        Coge Generation 
                */
                $<symbolInfo>$->setValueRep($<symbolInfo>1->getSymbolName());
        }
        | CONST_FLOAT {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("factor : CONST_FLOAT", $<symbolInfo>1->getSymbolName());

                $<symbolInfo>$->setReturnType(FLOAT_STR);
        
                /**
                        Coge Generation 
                        8086 assembly lanugage cannot handle floating point numbers 'normally' hence this is skipped
                        i.e. code is not generated for floating point numbers
                */
        }
        | variable INCOP {
                string name = $<symbolInfo>1->getSymbolName() + "++";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : variable INCOP", name);

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generator
                */
                if($<symbolInfo>1->getSymbolType() == ARRAY_STR) {
                        string asmStr, temp;
                        temp = asmCode.newTemp();
                        asmStr = $<symbolInfo>1->getAsmCode();
                        asmStr += asmCode.Mov("AX", $<symbolInfo>1->getValueRep() + "[BX]");
                        asmStr += asmCode.Inc("AX");
                        asmStr += asmCode.Mov($<symbolInfo>1->getValueRep() + "[BX]", "AX");
                        asmStr += asmCode.Mov(temp, "AX");
                        asmStr = asmCode.Comment(temp + " = " + name) + asmStr;
                        $<symbolInfo>$->setAsmCode(asmStr);
                        $<symbolInfo>$->setValueRep(temp);
                }       
                else {
                        $<symbolInfo>$->setAsmCode(asmCode.Inc($<symbolInfo>1->getValueRep()));
                        $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
                }
        }
        | variable DECOP {
                string name = $<symbolInfo>1->getSymbolName() + "--";
                $<symbolInfo>$ = new SymbolInfo(name, "NON_TERMINAL");
                printLog("factor : variable DECOP", name);

                $<symbolInfo>$->setReturnType($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generator
                */
                if($<symbolInfo>1->getSymbolType() == ARRAY_STR) {
                        string asmStr, temp;
                        temp = asmCode.newTemp();
                        asmStr = $<symbolInfo>1->getAsmCode();
                        asmStr += asmCode.Mov("AX", $<symbolInfo>1->getValueRep() + "[BX]");
                        asmStr += asmCode.Dec("AX");
                        asmStr += asmCode.Mov($<symbolInfo>1->getValueRep() + "[BX]", "AX");
                        asmStr += asmCode.Mov(temp, "AX");
                        asmStr = asmCode.Comment(temp + " = " + name) + asmStr;
                        $<symbolInfo>$->setAsmCode(asmStr);
                        $<symbolInfo>$->setValueRep(temp);
                }       
                else {
                        $<symbolInfo>$->setAsmCode(asmCode.Dec($<symbolInfo>1->getValueRep()));
                        $<symbolInfo>$->setValueRep($<symbolInfo>1->getValueRep());
                }
        }
        ;

argument_list : arguments {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("argument_list : arguments", $<symbolInfo>1->getSymbolName());

                vector<FuncParam> temp = $<symbolInfo>1->getFuncParamList();
                for(int i = 0; i < temp.size(); i++) {
                        $<symbolInfo>$->insertFuncParameter(temp[i].retType);
                }


                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
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

                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode() + $<symbolInfo>3->getAsmCode());
                asmCode.argList.push_back($<symbolInfo>3->getValueRep());
        }
        | logic_expression {
                $<symbolInfo>$ = new SymbolInfo($<symbolInfo>1->getSymbolName(), "NON_TERMINAL");
                printLog("arguments : logic_expression", $<symbolInfo>1->getSymbolName());

                voidChecking($<symbolInfo>1);

                $<symbolInfo>$->insertFuncParameter($<symbolInfo>1->getReturnType());
        
                /**
                        Code Generator
                */
                $<symbolInfo>$->setAsmCode($<symbolInfo>1->getAsmCode());
                asmCode.argList.push_back($<symbolInfo>1->getValueRep());
        }
        ;
%%


int main(int argc,char *argv[])
{

    if((input = fopen(argv[1], "r")) == NULL) {
        printf("Cannot Open Input File.\n");
        exit(1);
    }


    asmOut.open("assembly_code.asm");
    logOut.open("Parser_log.txt");
    errorOut.open("Parser_error.txt");

    yyin = input;
    yyparse(); // processing starts

    symbolTable.printAllScope(logOut);
    symbolTable.exitScope();

    logOut << "Total lines: " << lineCount-1 << endl;
    logOut << "Total errors: " << errorCount << endl << endl;

    fclose(yyin);
    logOut.close();
    errorOut.close();
    asmOut.close();

    if(errorCount) {
        remove("assembly_code.asm");
        asmOut.open("assembly_code.asm");
        asmOut << "Errors in code" << endl;
    }

    return 0;
}


void yyerror(char* s) {
    logOut << "Error At line " <<  lineCount << ": " << s << endl;
    errorOut << "Error At line " << lineCount << ": " << s << endl;
    errorCount++;
    return;
}
