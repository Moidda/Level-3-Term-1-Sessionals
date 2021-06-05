#ifndef SCOPE_TABLE_H
#define SCOPE_TABLE_H
    #include "ScopeTable.h"
#endif // SCOPE_TABLE_H

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
        ScopeTable *cur = this->currentScope;
        while(cur != NULL) {
            ScopeTable *prv = this->currentScope->getParentScope();
            delete cur;
            cur = prv;
        }
    }

    void enterScope() {
        ScopeTable *newScope = new ScopeTable(this->totalBuckets);
        newScope->setParentScope(this->currentScope);
        this->currentScope = newScope;
    }

    void exitScope() {
        ScopeTable *parentScope = this->currentScope->getParentScope();
        delete this->currentScope;                  
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
            SymbolInfo *ret = cur->scopeLookup(symbolName);
            if(ret != NULL) return ret;
            cur = cur->getParentScope();
        }
        return NULL;
    }

    void printCurrentScope(ostream& stream) {
        this->currentScope->scopePrint(stream);
    }

    void printAllScope(ostream& stream) {
        ScopeTable *cur = this->currentScope;
        while(cur != NULL) {
            cur->scopePrint(stream);
            cur = cur->getParentScope();
        }
    }
};
