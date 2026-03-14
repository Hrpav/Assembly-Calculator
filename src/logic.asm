; the logic for the calculator
include common.inc

PUBLIC Logic_Init
PUBLIC Logic_ProcessDigit
PUBLIC Logic_ProcessOp
PUBLIC Logic_ProcessEqual
PUBLIC Logic_ProcessClear
PUBLIC Logic_GetDisplayString

EXTERN PlayErrorSound: PROC
EXTERN IntToString: PROC

.data
currentValue    dq 0
pendingValue    dq 0
pendingOp       dq 0 ; 0 = none, 1 = add, 2 = sub, 3 = mul, 4 = div
isNewEntry      db 1
displayBuffer   db 64 dup(0)
tempBuffer      db 64 dup(0)

OP_NONE equ 0
OP_ADD  equ 1
OP_SUB  equ 2
OP_MUL  equ 3
OP_DIV  equ 4

.code

; Logic_Init - initializes the calculator logic state
Logic_Init PROC
    mov currentValue, 0
    mov pendingValue, 0
    mov pendingOp, OP_NONE
    mov isNewEntry, 1
    lea rdx, displayBuffer
    mov byte ptr [:dx], '0'
    mov byte ptr [rdx+1], 0
    ret
Logic_Init ENDP

; Logic_ProcessDigit - handles digit button press (0-9)
; RCX = Digit value (0-9)
; updates currentValue and displayBuffer
Logic_ProcessDigit PROC
    push rbx
    push rsi
    push rdi

    mov rbx, rcx ; digit

    cmp isNewEntry, 1
    jne append_digit
    
    ; new entry, replace display
    mov currentValue, rbx
    mov isNewEntry, 0
    jmp update_display
    
append_digit:
    ; current = current * 10 + digit
    mov rax, currentValue
    mov rcx, 10
    imul rcx
    add rax, rbx
    mov currentValue, rax
    
update_display:
    ; convert current value to string
    mov rcx, currentValue
    lea rdx, displayBuffer
    call IntToString
    
    pop rdi
    pop rsi
    pop rbx
    ret
Logic_ProcessDigit ENDP

; Logic_ProcessOp - handles operator button press (+, -, *, /)
; RCX = operator ID (1=Add, 2=Sub, 3=Mul, 4=Div)
Logic_ProcessOp PROC
    push rbx
    mov rbx, rcx
    
    ; if there was a pending operation, execute it first
    cmp pendingOp, OP_NONE
    je set_pending
    
    ; if just pressed op after op, just update op
    cmp isNewEntry, 1
    je update_op_only
    
    ; execute pending op
    call Logic_ExecutePending
    
set_pending:
    mov rax, currentValue
    mov pendingValue, rax
    mov isNewEntry, 1
    
update_op_only:
    mov pendingOp, rbx
    
    pop rbx
    ret
Logic_ProcessOp ENDP

; Logic_ProcessEqual - handles equal button press
Logic_ProcessEqual PROC
    cmp pendingOp, OP_NONE
    je done_equal
    
    call Logic_ExecutePending
    mov pendingOp, OP_NONE
    mov isNewEntry, 1
    
done_equal:
    ret
Logic_ProcessEqual ENDP

; Logic_ProcessClear - handles clear button press
Logic_ProcessClear PROC
    call Logic_Init
    ret
Logic_ProcessClear ENDP

; Logic_ExecutePending - executes the pending operation
Logic_ExecutePending PROC
    push rbx
    
    mov rax, pendingValue
    mov rbx, currentValue
    
    cmp pendingOp, OP_ADD
    je do_add
    cmp pendingOp, OP_SUB
    je do_sub
    cmp pendingOp, OP_MUL
    je do_mul
    cmp pendingOp, OP_DIV
    je do_div
    jmp done_exec
; addition
do_add:
    add rax, rbx
    jmp save_result
; subscration (i spelled that wrong)
do_sub:
    sub rax, rbx
    jmp save_result
; multiplication
do_mul:
    imul rbx
    jmp save_result
 ; division   
do_div:
    cmp rbx, 0
    je div_zero
    xor rdx, rdx
    cqo ; sign extend RAX to RDX:RAX
    idiv rbx
    jmp save_result
; division by zero    
div_zero:
    call PlayErrorSound
    ; reset logic or keep previous value? 
    ; let's keep previous value but show error
    lea rdx, displayBuffer
    mov byte ptr [rdx], 'E'
    mov byte ptr [rdx+1], 'r'
    mov byte ptr [rdx+2], 'r'
    mov byte ptr [rdx+3], 0
    mov isNewEntry, 1
    pop rbx
    ret

save_result:
    mov currentValue, rax
    
    ; update display
    mov rcx, currentValue
    lea rdx, displayBuffer
    call IntToString
    
done_exec:
    pop rbx
    ret
Logic_ExecutePending ENDP

; Logic_GetDisplayString - returns pointer to display string
Logic_GetDisplayString PROC
    lea rax, displayBuffer
    ret
Logic_GetDisplayString ENDP

END
