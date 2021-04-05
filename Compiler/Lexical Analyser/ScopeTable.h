#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H
    #include "SymbolInfo.h"
#endif // SYMBOL_INFO_H

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
    bool scopeInsert(SymbolInfo *sinfo, ostream& stream) {
        int bucket, position;
        SymbolInfo* parent;
        SymbolInfo* s =  this->scopeLookupAdvanced(sinfo->getSymbolName(), bucket, position, parent);
        if(SymbolInfo::isEquivalent(s, sinfo)) {
            stream << sinfo->symbolToString() + " already exists in current ScopeTable\n\n";
            return false;
        }
        if(parent == NULL) this->symbolsHashTable[bucket] = sinfo;
        else  parent->setNextSymbol(sinfo);
        return true;
    }

    // searches for a specific symbolInfo in current scope
    SymbolInfo* scopeLookup(string symbolName) {
        int bucket, position;
        SymbolInfo *parent;
        SymbolInfo* s = this->scopeLookupAdvanced(symbolName, bucket, position, parent);
        if(SymbolInfo::isEquivalent(s, symbolName)) return s;
        return NULL;
    }

    bool scopeDelete(string symbolName) {
        int bucket, pos;
        SymbolInfo *parent;
        SymbolInfo* s = this->scopeLookupAdvanced(symbolName, bucket, pos, parent);
        if(SymbolInfo::isEquivalent(s, symbolName)) {
            if(parent != NULL) parent->setNextSymbol(s->getNextSymbol());
            else this->symbolsHashTable[bucket] = s->getNextSymbol();
            delete s;
            return true;
        }
        return false;
    }

    // searches for a symbol and
    // if symbol is found:
    //     returns
    //         -> reference to the symbol object
    //         -> the bucket and position of the symbol object
    //         -> reference to its parent symbol object
    // if symbol not found:
    //         -> returns null
    //         -> the bucket and position of where the symbol object would belong to
    //         -> reference to the last accessed symbol object
    SymbolInfo* scopeLookupAdvanced(string symbolName, int &b, int &p, SymbolInfo*& parent) {
        int bucket = this->scopeHash(symbolName);
        int pos = 0;
        SymbolInfo *par = NULL;
        SymbolInfo *cur = this->symbolsHashTable[bucket];

        while(cur != NULL) {
            if(cur->getSymbolName() == symbolName) {
                b = bucket;
                p = pos;
                parent = par;
                return cur;
            }
            par = cur;
            cur = cur->getNextSymbol();
            pos++;
        }

        b = bucket;
        p = pos;
        parent = par;
        return NULL;
    }

    void scopePrint(ostream& stream) {
        stream << "ScopeTable # " << this->getId() << "\n";
        for(int i = 0; i < this->totalBuckets; i++) {
            if(this->symbolsHashTable[i] == NULL) continue;
            stream << i << " --> ";
            SymbolInfo *cur = this->symbolsHashTable[i];
            while(cur != NULL) {
                stream << " " + cur->symbolToString() + " ";
                cur = cur->getNextSymbol();
            }
            stream << "\n";
        }
        stream << "\n\n";
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

