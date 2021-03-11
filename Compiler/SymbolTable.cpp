#include <bits/stdc++.h>
using namespace std;

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


class ScopeTable {
private:
    string id;
    int totalBuckets;
    int childScopeCount;
    ScopeTable* parentScope;
    vector<SymbolInfo*> symbolsHashTable;

public:

    ScopeTable(int totalBuckets) {
        this->id = "";
        this->totalBuckets = totalBuckets;
        this->parentScope = NULL;
        this->symbolsHashTable.resize(totalBuckets);
        for(int i = 0; i < totalBuckets; i++) {
            this->symbolsHashTable[i] = NULL;
        }
        this->childScopeCount = 0;
        this->parentScope = NULL;
    }

    ~ScopeTable() {
        for(int i = 0; i < this->symbolsHashTable.size(); i++) {
            SymbolInfo *cur = this->symbolsHashTable[i];
            while(cur != NULL) {
                SymbolInfo *nxt = cur->getNextSymbol();
                delete cur;
                cur = nxt;
            }
        }
    }

    // returns which bucket a symbolInfo object should belong using the symbolName
    int scopeHash(string symbolName) {
        int sumAscii = 0;
        for(char ch: symbolName)
            sumAscii += ch;

        return (sumAscii % this->totalBuckets);
    }

    // insert a symbolInfo in this scope
    bool scopeInsert(SymbolInfo *sinfo) {
        if(this->scopeLookup(sinfo->getSymbolName()) != NULL) {
            cout << sinfo->symbolToString() + " already exists in current ScopeTable\n\n";
            return false;
        }

        int bucket = this->scopeHash(sinfo->getSymbolName());
        int pos = 0;
        if(this->symbolsHashTable[bucket] == NULL) {
            this->symbolsHashTable[bucket] = sinfo;
        }
        else {
            SymbolInfo *cur = this->symbolsHashTable[bucket];
            while(cur->getNextSymbol() != NULL) {
                cur = cur->getNextSymbol();
                pos++;
            }
            cur->setNextSymbol(sinfo);
            pos++;
        }

        cout << "Inserted in ScopeTable# " << this->id << " " << "at position " << bucket << ", " << pos << "\n\n";
        return true;
    }

    // searches for a specific symbolInfo in current scope
    SymbolInfo* scopeLookup(string symbolName) {
        int bucket = this->scopeHash(symbolName);
        int pos = 0;
        SymbolInfo *cur = this->symbolsHashTable[bucket];
        while(cur != NULL) {
            if(cur->getSymbolName() == symbolName) {
                cout << "Found in ScopeTable# " << this->getId() << " at position " << bucket << ", " << pos << "\n\n";
                return cur;
            }
            cur = cur->getNextSymbol();
        }
        return NULL;
    }

    bool scopeDelete(string symbolName) {
        int bucket = this->scopeHash(symbolName);
        int pos = 0;
        SymbolInfo *par = NULL;
        SymbolInfo *cur = this->symbolsHashTable[bucket];

        while(cur != NULL) {
            if(cur->getSymbolName() == symbolName) {
                cout << "Found in ScopeTable# " << this->getId() << " at position " << bucket << ", " << pos << "\n\n";

                if(par != NULL) par->setNextSymbol(cur->getNextSymbol());
                else this->symbolsHashTable[bucket] = cur->getNextSymbol();
                delete cur;

                cout << "Deleted Entry " << bucket << ", " << pos << " from current ScopeTable\n\n";
                return true;
            }
            par = cur;
            cur = cur->getNextSymbol();
            pos++;
        }

        cout << "Not found\n\n";
        return false;
    }

    void scopePrint() {
        cout << "ScopeTable # " << this->getId() << "\n";
        for(int i = 0; i < this->totalBuckets; i++) {
            cout << i << " --> ";
            SymbolInfo *cur = this->symbolsHashTable[i];
            while(cur != NULL) {
                cout << " " + cur->symbolToString() + " ";
                cur = cur->getNextSymbol();
            }
            cout << "\n";
        }
        cout << "\n\n";
    }

    string getUniqueId() {
        if(this->parentScope == NULL)
            return "1";

        int p = this->parentScope->childScopeCount + 1;
        string id = this->parentScope->id + "." + to_string(p);
        return id;
    }

    void setId(string id) {
        this->id = id;
    }

    string getId() {
        return this->id;
    }

    void setChildScopeCount(int childScopeCount) {
        this->childScopeCount = childScopeCount;
    }

    int getChildScopeCount() {
        return this->childScopeCount;
    }

    // this function has to be called at least once to set an id to this object
    // so even if there is no parent, setParentScope(NULL) has to be called
    // since id is dependent on the parentScope's id
    void setParentScope(ScopeTable* parentScope) {
        this->parentScope = parentScope;

        if(this->id.empty()) {
            this->setId(this->getUniqueId());
            if(parentScope != NULL)
                parentScope->setChildScopeCount(parentScope->getChildScopeCount() + 1);
        }
    }
    ScopeTable* getParentScope() {
        return this->parentScope;
    }
};


class SymbolTable {
private:
    int totalBuckets;
    ScopeTable *currentScope;

public:

    SymbolTable(int totalBuckets) {
        this->totalBuckets = totalBuckets;
        this->currentScope = new ScopeTable(totalBuckets);
        this->currentScope->setParentScope(NULL);
    }

    ~SymbolTable() {
        delete currentScope;
    }

    void enterScope() {
        ScopeTable *newScope = new ScopeTable(this->totalBuckets);
        newScope->setParentScope(this->currentScope);
        this->currentScope = newScope;
        cout << "New ScopeTable with id " << this->currentScope->getId() << " created" << "\n\n";
    }

    void exitScope() {
        ScopeTable *parentScope = this->currentScope->getParentScope();
        cout << "ScopeTable with id " << this->currentScope->getId() << " removed\n\n";
        delete this->currentScope;                  // is this ok??
        this->currentScope = parentScope;
    }

    bool insertIntoTable(SymbolInfo *symbol) {
        return this->currentScope->scopeInsert(symbol);
    }

    bool removeFromTable(string symbolName) {
        return this->currentScope->scopeDelete(symbolName);
    }

    SymbolInfo* lookup(string symbolName){
        ScopeTable *cur = this->currentScope;
        while(cur != NULL) {
            SymbolInfo *ret = cur->scopeLookup(symbolName);             // scopeLookup() prints a "Found" msg
            if(ret != NULL) return ret;
            cur = cur->getParentScope();
        }
        cout << "Not Found\n\n";
        return NULL;
    }

    void printCurrentScope() {
        this->currentScope->scopePrint();
    }

    void printAllScope() {
        ScopeTable *cur = this->currentScope;
        while(cur != NULL) {
            cur->scopePrint();
            cur = cur->getParentScope();
        }
    }
};


int main() {

    freopen("input.txt", "r", stdin);

    int totalBucket;
    string query;

    cin >> totalBucket;
    SymbolTable *symbolTable = new SymbolTable(totalBucket);

    while(cin >> query) {
        string symbolName, symbolType;
        if(query == "I") {
            cin >> symbolName >> symbolType;
            symbolTable->insertIntoTable(new SymbolInfo(symbolName, symbolType));
        }

        else if(query == "L") {
            cin >> symbolName;
            symbolTable->lookup(symbolName);
        }

        else if(query == "D") {
            cin >> symbolName;
            symbolTable->removeFromTable(symbolName);
        }

        else if(query == "P") {
            string typ;
            cin >> typ;
            if(typ == "A") symbolTable->printAllScope();
            if(typ == "C") symbolTable->printCurrentScope();
        }

        else if(query == "S") {
            symbolTable->enterScope();
        }

        else if(query == "E") {
            symbolTable->exitScope();
        }

        else if(query == "X") {
            break;
        }
    }

    return 0;
}