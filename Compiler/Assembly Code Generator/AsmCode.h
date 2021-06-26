class AsmCode {
public:

    int tempCount = 0;
    int labelCount = 0;
    string mainCode;
    vector<string> funcList;
    vector<string> varList;
    vector<string> tempList;

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
        return str + "\t\t\t; " + comment + "\n";
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
};