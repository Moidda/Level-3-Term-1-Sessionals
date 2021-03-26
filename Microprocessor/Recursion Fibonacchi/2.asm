.MODEL SMALL

.STACK 100H

.DATA
    CR EQU 0DH
    LF EQU 0AH

    MSGN DB CR, LF, 'ENTER N(TWO DIGIT): $'
    NEWLN DB CR, LF, '$'
    N DW ?
    ITR DW ?

.CODE

MAIN PROC

; initialize DS
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSGN
    MOV AH, 9
    INT 21H

    CALL SCAN_INT
    MOV N, AX
    LEA DX, NEWLN
    MOV AH, 9
    INT 21H

        MOV ITR, 1
    
    LOOP_BODY:
        MOV AX, ITR
        CMP AX, N                       ; IF ITR > N
        JG DOS_EXIT                     ; QUIT

        PUSH ITR
        CALL FIB                        ; FIB(ITR)
        CALL PRINT_INT

        MOV DL, ' '                     ; PRINT WHITESPACE
        MOV AH, 2
        INT 21H

        INC ITR
        JMP LOOP_BODY


DOS_EXIT:
    MOV AH, 4CH
    INT 21H

MAIN ENDP


; --------------------------------------------------------------------------------------------- ;
; RETURNS FIB(N)
; STORES RETURN VALUE IN AX
FIB  PROC   NEAR
    PUSH BP
    MOV BP, SP
    
    MOV AX, [BP+4]                  ; AX = N
    CMP AX, 1                       ; IF N = 1
    JE FIB_BASE_CASE_1              
    CMP AX, 2                       ; IF N = 2
    JE FIB_BASE_CASE_2               
    JMP FIB_RECURSE

    FIB_BASE_CASE_1:                ; N = 1
        MOV AX, 0                   ; RETURN 0
        JMP FIB_RETURN

    FIB_BASE_CASE_2:                ; N = 2
        MOV AX, 1                   ; RETURN 1
        JMP FIB_RETURN

    FIB_RECURSE:
        ; FIB(N) = FIB(N-1) + FIB(N-2)
        PUSH AX                     ; STORE N

        DEC AX                      ; AX = N-1
        PUSH AX
        CALL FIB                    ; AX = FIB(N-1)

        POP BX                      ; RETRIEVE N, BX = N
        PUSH AX                     ; STORE FIB(N-1)
        
        MOV AX, BX                  ; AX = N
        DEC AX
        DEC AX                      ; AX = N-2
        PUSH AX
        CALL FIB                    ; AX = FIB(N-2)

        POP BX                      ; RETRIEVE FIB(N-1), BX = FIB(N-1)
        ADD AX, BX                  ; AX = AX + BX = FIB(N-2) + FIB(N-1)


    FIB_RETURN:
        POP BP
        RET 2
ENDP FIB
; --------------------------------------------------------------------------------------------- ;
;----------------------------------------------------------------------------------;
; OUTPUTS A SIGNED 16-BIT-INT STORED IN AX
PRINT_INT PROC

    CMP AX, 0H              ; IF AX IS 0, PRINT A 0 AND EXIT
    JNE PRINT_INT_NEXT
    MOV DL, '0'
    MOV AH, 2
    INT 21H
    JMP PRINT_INT_RET

    PRINT_INT_NEXT:
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


END MAIN