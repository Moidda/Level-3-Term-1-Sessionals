struct FuncParam {
    string retType;
    string name;
};

class SymbolInfo {
private:
    string symbolName;
    string symbolToken;
    SymbolInfo* nextSymbol;

    /*
        Modified for parser implementation:

        ID symbols are special

        x, ID
        arr, ID
        foo, ID

        An ID can be
            - array, variable or function?
        ID can have different return type?
            - float, int, void
    
        A total of 9 combinations
            (return type)   symbol type
            float/int/void  variable/array/function
                            x/arr[]/foo()
    
        void variable/array not allowed
    */
    string symbolType;      // "array", "variable", "function_declaration", "function_definition"
    string returnType;      // "float", "void", "int"
    int arraySize;          // array size for symbolType="array"
                            // no of parameters for symbolType="function"

    vector<FuncParam> funcParamList;

    /**
     * Modified for intermediate code generation
     * */
    string asmCode;         // holds the code to be propagated
    /**
     * In the input c code, there will be expressions that has to be evaluated.
     * An expression might contain variables, and also CONST_INT values.
     * For each of these expressions, a temporary variable has to be introduced 
     * in the asm code as a representative of that expression. This temporary
     * representative holds the value the respective expression evaluates to
     * 
     * Example Input:
     *      var = 2 + 3;
     * 
     * Here, the expression 2+3 should evaluate to 5, and this value should be 
     * assigned to var.
     * 
     * Instead of doing this addition inside the parser/code generator, we want
     * the generated asm code to handle this calculation. But then, there has to be
     * a mechanism so that the asm code can 'remember' the resultant value 5.
     * Here we introduce a temporary variable, which represents the value of this
     * expression and thus 'remembers' it.  
     * 
     * Steps in which the output asm code is generated:
     * (1) Evaluating the expression 2 + 3 :
     * -----------------------------------------------------------------------------------------
     *      => Matches with the rule 'simple_expression : simple_expression ADDOP term '
     * 
     *      => create a new temporary variable for the expression '2+3' (for representing $$),
     *         let's name this temporary varaible, which will be the representative value for
     *         this expression, to be 'T0'
     * 
     *      => retrieve the valueRep of $1, $1->getValueRep() should return '2'
     *      => retrieve the valueRep of $3, $3->getValueRep() should return '3'
     * 
     *      => generate asm code to perform ADDOP on valueRep of $1 and valueRep of $3
     *                  MOV AX, $1->getValueRep()
     *                  ADD AX, $3->getValueRep()
     * 
     *      => store the result in 'T0'
     *                  MOV T0, AX
     * 
     *      => assign 'T0' to be the representative for our expression '2+3' so that we can
     *         retrieve this while doing step 2
     *                  $$->setValueRep('T0');
     * 
     * (2) Assigning the value of '2+3' to 'var':
     * -----------------------------------------------------------------------------------------
     *      => Matches with the rule 'expression : variable ASSIGNOP logic_expression '
     *      => retrieve the value representative for '2+3', $3->getValueRep() should return 'T0'
     *                  MOV AX, $3->getValueRep()
     *      => assign the value to 'VAR', $$->getValueRep() should return 'VAR'
     *                  MOV $$->getValueRep(), AX
     * 
     * 
     * TLDR ....
     * The main takeaway is , each symbolInfo should have a representative for it's value, 
     * which is the valueRep attribute
     * 
     * ----Input----            ----Output---- 
     * var = 2 + 3              MOV AX, 2
     *                          ADD AX, 3
     *                          MOV T0, AX      ; T0 now holds 2+3
     *                          MOV AX, T0
     *                          MOV VAR, AX     ; VAR now holds T0
     * */
    string valueRep;

public:

    SymbolInfo() {
        this->symbolName = this->symbolToken = "";
        this->nextSymbol = NULL;
    
        this->symbolType = this->returnType = "";
        this->arraySize = -1;
    }

    SymbolInfo(string symbolName, string symbolToken) {
        this->symbolName = symbolName;
        this->symbolToken = symbolToken;
        this->nextSymbol = NULL;
    
        this->symbolType = this->returnType = "";
        this->arraySize = -1;
    }

    ~SymbolInfo() {

    }

    static bool isEquivalent(SymbolInfo *symbol, string symbolName) {
        if(symbol == NULL) return false;
        return (symbol->getSymbolName() == symbolName);
    }

    static bool isEquivalent(SymbolInfo *s1, SymbolInfo *s2) {
        if(s1 == NULL or s2 == NULL) return false;
        return (s1->getSymbolName() == s2->getSymbolName());
    }

    string symbolToString() {
        string ret = "< " + this->symbolName + " : " + this->symbolToken + " >";
        return ret;
    }



    void setValueRep(string valueRep) {
        this->valueRep = valueRep;
    }
    string getValueRep() {
        return this->valueRep;
    }

    void setAsmCode(string asmCode) {
        this->asmCode = asmCode;
    }
    string getAsmCode() {
        return this->asmCode;
    }

    void setNextSymbol(SymbolInfo *nextSymbol) {
        this->nextSymbol = nextSymbol;
    }

    SymbolInfo* getNextSymbol() {
        return this->nextSymbol;
    }

    void setSymbolName(string symbolName) {
        this->symbolName = symbolName;
    }
    string getSymbolName() {
        return this->symbolName;
    }
    void setSymbolToken(string symbolToken) {
        this->symbolToken = symbolToken;
    }
    string getSymbolToken() {
        return this->symbolToken;
    }

    void setReturnType(string returnType) {
        this->returnType = returnType;
    }
    string getReturnType() {
        return this->returnType;
    }

    void setSymbolType(string symbolType) {
        this->symbolType = symbolType;
    }
    string getSymbolType() {
        return this->symbolType;
    }

    void setArraySize(int arraySize) {
        this->arraySize = arraySize;
    }
    int getArraySize() {
        return this->arraySize;
    }

    string intToStr(int x) {
        string ret = "";
        while(x) {
            ret += (char)(x%10 + '0');
            x /= 10;
        }
        reverse(ret.begin(), ret.end());
        return ret;
    }
    string getSymbolContent() {
        string ret = "";
        ret += "symbolName = " + this->symbolName + "\n";
        ret += "symbolToken = " + this->symbolToken + "\n";
        ret += "symbolType = " + this->symbolType + "\n";
        ret += "returnType = " + this->returnType + "\n";
        if(this->symbolType == "array") ret += "arraySize = " + intToStr(this->arraySize) + "\n";
        return ret;
    }

    void insertFuncParameter(string retType, string name = "") {
        FuncParam p;
        p.retType = retType;
        p.name = name;
        funcParamList.push_back(p);
    }

    vector<FuncParam> getFuncParamList() {
        return this->funcParamList;
    }
};
