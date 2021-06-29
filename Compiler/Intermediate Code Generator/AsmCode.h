class AsmCode {
public:

    struct FunctionBody {
        string name, code;
        int paramSize;

        FunctionBody() {}

        FunctionBody(string name, string code, int paramSize) {
            this->name = name;
            this->code = code;
            this->paramSize = paramSize;
        }
    };

    int tempCount = 0;
    int labelCount = 0;
    string mainCode;
    vector<FunctionBody> funcList;
    vector<string> varList;
    vector<string> tempList;
    vector<string> argList;

    string newLabel() {
        string labelName = "L_" + to_string(labelCount);
        labelCount++;
        return labelName;
    }

    string newTemp() {
        string tempName = "T" + to_string(tempCount);
        tempList.push_back(tempName + " DW ?");
        tempCount++;
        return tempName;
    }

    string variableNaming(string var) {
        return var + "1";
    }

    string Comment(string str) {
        return "; " + str + "\n";
    }

    string Line(string str, string comment = "") {
        if(comment.size()) str += "\t\t\t; " + comment;
        str += "\n";
        return str;
    }

    // PUSH VAR    ; STACK <- VAR
    string Push(string var) {
        return "PUSH " + var + "\t\t\t; STACK <- " + var + "\n";
    }

    // POP VAR      ; STACK -> VAR
    string Pop(string var) {
        return "POP " + var + "\t\t\t; STACK -> " + var + "\n";
    }

    // INC VAR      ; VAR++
    string Inc(string var) {
        return "INC " + var + "\t\t\t\t; " + var + "++\n";
    }

    // DEC VAR      ; VAR--
    string Dec(string var) {
        return "DEC " + var + "\t\t\t\t; " + var + "--\n";
    }

    // MOV DEST, SRC    ; DEST = SRC
    string Mov(string dest, string src) {
        return "MOV " + dest + ", " + src + "\t\t\t; " + dest + " = " + src + "\n";
    }

    // ADD DEST, SRC    ; DEST = DEST +_ SRC
    string Add(string dst, string src) {
        return "ADD " + dst + ", " + src + "\t\t\t; " + dst + " = " + dst + " + " + src + "\n";
    }

    // SUB DEST, SRC    ; DEST = DEST -_ SRC
    string Sub(string dst, string src) {
        return "Sub " + dst + ", " + src + "\t\t\t; " + dst + " = " + dst + " - " + src + "\n";
    }

    /**
     * XOR DX, DX       ; CLEAR OUT DX
     * MOV AX, X        ; DX:AX = 00:X
     * IMUL Y           ; (DX:AX) <- AX*Y = X*Y
     * MOV Z, AX        ; PRODUCT IN Z -> Z = X*Y
     * */
    string Imul(string z, string x, string y) {
        string ret = "XOR DX, DX\t\t\t; CLEAR OUT DX\n";
        ret += "MOV AX, " + x + "\t\t\t; DX:AX = 00:" + x + "\n";
        ret += "IMUL " + y + "\t\t\t; (DX:AX) <- AX*" + y + " = " + x + "*" + y + "\n";
        ret += "MOV " + z + ", AX\t\t\t; PRODUCT IN " + z + " -> " + z + " = " + x + "*" + y + "\n"; 
        return ret;
    }

    /**
     * XOR DX, DX       ; CLEAR OUT DX
     * MOV AX, X        ; DX:AX = 00:X
     * IDIV Y           ; (DX:AX) / Y -> QUOTIENT IN AX, REMAINDER IN DX
     * MOV Z, AX        ; QUOTIENT IN Z  -> Z = X/Y           
     * MOV Z, DX        ; REMAINDER IN Z -> Z = X%Y
     * */
    string Idiv(string z, string x, string y, bool isDiv) {
        string ret = "XOR DX, DX\t\t\t; CLEAR OUT DX\n";
        ret += "MOV AX, " + x + "\t\t\t; DX:AX = 00:" + x + "\n";
        ret += "IDIV " + y + "\t\t\t; (DX:AX) / " + y + " -> QUOTIENT IN AX, REMAINDER IN DX\n";
        if(isDiv) ret += "MOV " + z + ", AX\t\t\t; QUOTIENT IN " + z + " -> " + z + " = " + x + "/" + y + "\n";
        else ret += "MOV " + z + ", DX\t\t\t; REMAINDER IN " + z + " -> " + z + " = " + x + "%" + y + "\n";
        return ret;
    }

    // NEG SRC          ; SRC = -1*SRC
    string Neg(string src) {
        return "NEG " + src + "\t\t\t; " + src + " = -1*" + src + "\n";
    }

    // labelName:       ; comment
    string Label(string labelName, string comment = "") {
        return labelName + ":\t\t\t\t" + Comment(comment);
    }

    // CMP SRC1, SRC2   ; comment
    string Cmp(string src1, string src2, string comment = "") {
        string ret = "CMP " + src1 + ", " + src2; 
        ret += "\t\t\t" + Comment(comment);
        return ret;
    }

    // jumpType labelName     ; comment
    string Jump(string jumpType, string labelName, string comment = "") {
        return jumpType + " " + labelName + "\t\t\t\t" + Comment(comment);
    }

    /**
     * ; SRC1 || SRC2
     * MOV DEST, 1          ; ASSUMING SRC1 || SRC2 TO BE TRUE
     * CMP SRC1, 0          ; CHECK IF SRC1 IS FALSE
     * JNE L1               
     * CMP SRC2, 0          ; CHECK IF SRC2 IS ALSO FALSE
     * JNE L1
     * MOV DEST, 0          ; SRC1 || SRC2 IS FALSE
     * L1:
     * */
    string LogicOr(string dest, string src1, string src2) {
        string expression = src1 + " || " + src2;
        string ret = Comment(dest + " <- " + expression);
        string label = newLabel();
        ret += Line("MOV " + dest + ", 1", "ASSUMING " + expression + " TO BE TRUE");
        ret += Cmp(src1, "0", "CHECK IF " + src1 + " IS FALSE");
        ret += Jump("JNE", label);
        ret += Cmp(src2, "0", "CHECK IF " + src1 + " IS ALSO FALSE");
        ret += Jump("JNE", label);
        ret += Line("MOV " + dest + ", 0", expression + " IS FALSE");
        ret += Label(label) + "\n";
        return ret;
    }

    /**
     * ; SRC1 && SRC2
     * MOV DEST, 0          ; ASSUMING SRC1 && SRC2 TO BE FALSE
     * CMP SRC1, 0          ; CHECK IF SRC1 IS TRUE
     * JE L1               
     * CMP SRC2, 0          ; CHECK IF SRC2 IS ALSO TRUE
     * JE L1
     * MOV DEST, 1          ; SRC1 && SRC2 IS TRUE
     * L1:
     * */
    string LogicAnd(string dest, string src1, string src2) {
        string ret;
        string label = newLabel();
        string expression = src1 + " && " + src2;
        ret += Comment(dest + " <- " + expression);
        ret += Line("MOV " + dest + ", 0", "ASSUMING " + expression + " TO BE FALSE");
        ret += Cmp(src1, "0", "CHECK IF " + src1 + " IS TRUE");
        ret += Jump("JE", label);
        ret += Cmp(src2, "0", "CHECK IF " + src1 + " IS ALSO TRUE");
        ret += Jump("JE", label);
        ret += Line("MOV " + dest + ", 1", expression + " IS TRUE");
        ret += Label(label) + "\n";
        return ret;
    }

    void insertFunction(string name, string code, int paramSize) {
        funcList.push_back(FunctionBody(name, code, paramSize));
    }

    /**
     * replacing all the return statements with a MOV AX, RETURN_VALUE
     * and a JUMP RETURN_LABEL statement
     * */
    string removeReturnStatements(string str, string returnLabel) {
        int st = 0, en = -1;
        while(true) {
            st = str.find("RETURN", 0);
            if(st == string::npos) break;
            en = str.find("\n", st);
            
            string returnValue;
            stringstream ss(str.substr(st, en-st+1));
            ss >> returnValue;
            ss >> returnValue;
            int pos = str.erase(str.begin()+st, str.begin()+en+1) - str.begin();
            string toInsert = Mov("AX", returnValue);
            toInsert += Jump("JMP", returnLabel, "return");
            str.insert(pos, toInsert);
        }
        return str;
    }

    /**
     * FUNC_NAME PROC
     *      ...
     * ENDP FUNC_NAME
     * */
    string asmProcedure(FunctionBody f) {
        string returnLabel = newLabel();
        string asmStr = Line(";----------------------------------------------------------------------------------;");
        asmStr += Line(f.name + " PROC");
        asmStr += Line("PUSH BP");
        asmStr += Line("MOV BP, SP");
        asmStr += removeReturnStatements(f.code, returnLabel);
        asmStr += Label(returnLabel);
        asmStr += Line("POP BP");
        asmStr += Line("RET " + to_string(f.paramSize*2));
        asmStr += Line("ENDP " + f.name);
        asmStr += Line(";----------------------------------------------------------------------------------;");
        
        return asmStr;
    }

    /**
     * Creates all the procedures from the list of functions
     * */
    string CreateProcedures() {
        string ret = "";
        for(int i = 0; i < funcList.size(); i++) 
            ret += asmProcedure(funcList[i]);
        
        return ret;
    }

    vector<string> string_split(string str, string regex) {
        vector<string> ret;
        string cur = "";
        for(char ch: str) {
            bool found = false;
            for(char ch2: regex) found |=( ch==ch2);
            if(!found) {
                cur.push_back(ch);
            }
            else {
                if(!cur.empty()) ret.push_back(cur);
                cur.clear();
            }
        }
        if(!cur.empty()) ret.push_back(cur);
        return ret;
    }

    void createOptimizedCode(string inputFile, string outputFile) {
        ifstream in;
        ofstream out;
        in.open(inputFile);
        out.open(outputFile);
        map<string, string> mp;
        string str;

        while(getline(in, str)) {
            vector<string> v = string_split(str, " ,\t");
            if(v.empty() or v[0] != "MOV") {
                out << str << endl;
                continue;
            }

            string str1 = str;
            string dst1 = v[1];
            string src1 = v[2];

            getline(in, str);
            v = string_split(str, " ,\t");
            if(v.empty() or v[0] != "MOV") {
                out << str1 << endl;
                out << str << endl;
                continue;
            }

            string str2 = str;
            string dst2 = v[1];
            string src2 = v[2];

            /**
             * MOV X, Y
             * MOV Y, X
             * */

            out << str1 << endl;
            if(dst1 == src2 and src1 == dst2) {
                // dont print str2
            }
            else {
                out << str2 << endl;
            }
        }
    }
};