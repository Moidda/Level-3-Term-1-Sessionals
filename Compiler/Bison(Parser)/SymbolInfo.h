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

