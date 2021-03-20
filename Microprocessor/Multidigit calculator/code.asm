.MODEL SMALL

.STACK 100H

.DATA
    CR EQU 0DH
    LF EQU 0AH

    INPUT_PROMPT1    DB CR, LF, 'OPERAND1: $'
    INPUT_PROMPT2    DB CR, LF, 'OPERATOR: $'
    INPUT_PROMPT3    DB CR, LF, 'OPERAND2: $'
    OUTPUT_PROMPT   DB CR, LF, 'OUTPUT =  $'
    WRONG_OPERATOR  DB CR, LF, 'WRONG OPERATOR$'
    X DW ?
    Y DW ?
    Z DW ?
    CHAR DB ?

.CODE

MAIN PROC

; initialize DS
    MOV AX, @DATA
    MOV DS, AX
    
    INPUT1:
        LEA DX, INPUT_PROMPT1               ; PROMPT MSG
        MOV AH, 9
        INT 21H
        CALL SCAN_INT                       ; TAKING INPUT
        MOV X, AX                           ; STORING IT IN X

    INPUT2:
        LEA DX, INPUT_PROMPT2               ; PROMPT MSG
        MOV AH, 9
        INT 21H
        MOV AH, 1                           ; TAKING CHAR INPUT
        INT 21H
        MOV CHAR, AL                        ; STORING IN CHAR

        CMP CHAR, '+'
        JE INPUT3
        CMP CHAR, '-'
        JE INPUT3
        CMP CHAR, '*'
        JE INPUT3
        CMP CHAR, '/'
        JE INPUT3
        CMP CHAR, 'q'
        JE DOS_EXIT

        LEA DX, WRONG_OPERATOR
        MOV AH, 9
        INT 21H
        JMP DOS_EXIT
        

    INPUT3:
        LEA DX, INPUT_PROMPT3               ; PROMPT MSG
        MOV AH, 9
        INT 21H
        CALL SCAN_INT                       ; TAKIKNG INPUT
        MOV Y, AX                           ; STORING IN Y

    CMP CHAR, '+'
    JE ADDITION
    CMP CHAR, '-'
    JE SUBSTRACTION
    CMP CHAR, '*'
    JE MULTIPLICATION
    CMP CHAR, '/'
    JE DIVISION


    ADDITION:
        MOV DX, X
        ADD DX, Y
        MOV Z, DX
        JMP PRINTZ

    SUBSTRACTION:
        MOV DX, X
        SUB DX, Y
        MOV Z, DX
        JMP PRINTZ

    MULTIPLICATION:
        MOV AX, X
        IMUL Y                   ; DX:AX = AX*Y = X*Y
        MOV Z, AX
        JMP PRINTZ

    DIVISION:
        XOR DX, DX              ; CLEAR OUT DX
        MOV AX, X               ; DX:AX = 00:X
        IDIV Y                  ; (DX:AX) / DIVISOR -> QUOTIENT IN AX, REMAINDER IN DX
        MOV Z, AX               ; => QUOTIENT IN Z
        JMP PRINTZ

    PRINTZ:
        LEA DX, OUTPUT_PROMPT
        MOV AH, 9
        INT 21H
        MOV AX, Z
        CALL PRINT_INT    

DOS_EXIT:
    MOV AH, 4CH
    INT 21H

MAIN ENDP


;----------------------------------------------------------------------------------
; OUTPUTS A SIGNED 16-BIT-INT STORED IN AX
PRINT_INT PROC

    MOV CX, 0H
    MOV DX, 0H

    ; CHECK IF AX IS -VE
    CMP AX, 0H
    JGE PROCESS
    NEG AX
    MOV BX, AX              ; TEMPORARILY STORE AX, IN BX

    MOV DL, '-'
    MOV AH, 2
    INT 21H

    MOV AX, BX              ; RETRIEVE BACK AX
    MOV CX, 0H
    MOV DX, 0H

    PROCESS:
        ; GO TO PRINT IF AX DIMINISHED
        CMP AX, 0H
        JE PRINT

        MOV BX, 10D
        DIV BX              ; AX/BX -> AX/10 => QUOTIENT AX, REMAINDER DX

        PUSH DX             ; PUSH LAST DIGIT IN STACK
        INC CX              ; INC COUNT i,e INC STACK SIZE
        XOR DX, DX          ; RESET DX
        JMP PROCESS
    PRINT:
        CMP CX, 0H          ; CHECK IF STACK EMPTY i.e IF COUNT IS 0
        JE PRINT_INT_RET

        POP DX              ; POP FROM STACK
        ADD DX, '0'
        MOV AH, 2           ; PRINT TOP OF STACK CHARACTER
        INT 21H

        DEC CX
        JMP PRINT

    PRINT_INT_RET:

RET
PRINT_INT ENDP
;----------------------------------------------------------------------------------
;----------------------------------------------------------------------------------
; SCANS FROM CONSOLE AND STORES A SIGNED-16-BIT INTEGER IN AX
SCAN_INT PROC
    ; COUNTER TO MAINTAIN NUMBER OF DIGITS
    ; INITIALIZE COUNTER WITH 0
    MOV CX, 0H
    ; BL = 0 -> INPUT IS +VE
    ; BL = 1 -> INPUT IS -VE
    MOV BL, 0H
    ; STACK CONTAINS CURRENT INPUT IN INTEGER
    PUSH 0H

    SINGLE_KEY_INPUT:
        MOV AH, 1
        INT 21H

    ; TERMINATE IF ENTER IS PRESSED
    CMP AL, 0DH
    JE SCAN_INT_RET

    IS_NEG_INPUT:
        CMP CX, 0H
        JG IS_DIGIT_INPUT               ; RETURN IF DIGIT_COUNT > 0
        CMP AL, '-'
        JNE IS_DIGIT_INPUT
        MOV BL, 1H
        JMP SINGLE_KEY_INPUT

    IS_DIGIT_INPUT:
        CMP AL, 30H
        JL SINGLE_KEY_INPUT
        CMP AL, 39H
        JG SINGLE_KEY_INPUT
        SUB AL, 30H
        MOV BH, AL                      ; BH = INPUT DIGIT

        POP DX                          ; DX = FORMED INT
        MOV AX, 10D
        MUL DX                          ; DX:AX  = AX*DX = 10*DX
        ; AX = FORMED INT * 10

        XOR DX, DX                      ; CLEAR OUT DX
        MOV DL, BH                      ; DX = INPUT DIGIT
        ADD AX, DX
        PUSH AX
        INC CX
        JMP SINGLE_KEY_INPUT

    SCAN_INT_RET:
        XOR AX, AX
        POP AX
        CMP BL, 1H
        JNE RETURN_INPUT
        NEG AX

    RETURN_INPUT:
RET
SCAN_INT ENDP
;----------------------------------------------------------------------------------

END MAIN