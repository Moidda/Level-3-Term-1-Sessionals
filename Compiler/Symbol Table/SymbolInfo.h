class SymbolInfo {
private:
    string symbolName;
    string symbolType;
    SymbolInfo* nextSymbol;

public:

    SymbolInfo() {
        this->symbolName = this->symbolType = "";
        this->nextSymbol = NULL;
    }

    SymbolInfo(string symbolName, string symbolType) {
        this->symbolName = symbolName;
        this->symbolType = symbolType;
        this->nextSymbol = NULL;
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
        string ret = "< " + this->symbolName + " : " + this->symbolType + " >";
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
    void setSymbolType(string symbolType) {
        this->symbolType = symbolType;
    }
    string getSymbolType() {
        return this->symbolType;
    }
};
