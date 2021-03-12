#include <bits/stdc++.h>
using namespace std;

#include "SymbolTable.h"

int main() {

    freopen("alu.txt", "r", stdin);
    freopen("vorta.txt", "w", stdout);

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
