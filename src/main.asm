; windows xp type of calculator made in assembly x64-86
; to compile just run:
;   build.bat
; made using vim

include common.inc

EXTERN UI_InitFont: PROC
EXTERN UI_CreateControls: PROC
EXTERN UI_UpdateDisplay: PROC
EXTERN Logic_Init: PROC
EXTERN Logic_ProcessDigit: PROC
EXTERN Logic_ProcessOp: PROC
EXTERN Logic_ProcessEqual: PROC
EXTERN Logic_ProcessClear: PROC
EXTERN PlayDingSound: PROC
EXTERN MessageBoxA: PROC
EXTERN GetLastError: PROC
EXTERN IntToString: PROC

PUBLIC hInst
PUBLIC hWndMain

.data
szClassName     db "CalculatorClass", 0
szTitle         db "Assembly Calculator", 0
szErrorReg      db "Error registering class: ", 0
szErrorCreate   db "Error creating window: ", 0
szDebugStart    db "Starting Calculator...", 0
szErrorTitle    db "Error", 0
szDebugTitle    db "Debug", 0
szErrorBuffer   db 64 dup(0)
hInst           dq 0
hWndMain        dq 0

.code

main PROC
    sub rsp, 40 ; shadow space + alignment
    
    ; get instance handle
    xor rcx, rcx
    call GetModuleHandleA
    mov hInst, rax
    
    ; register window class
    call RegisterMyClass
    test ax, ax
    jnz register_ok
    
    ; error: register class
    call GetLastError
    mov rcx, rax
    lea rdx, szErrorBuffer
    call IntToString
    
    mov rcx, 0
    lea rdx, szErrorBuffer
    lea r8, szErrorReg
    mov r9, 0
    call MessageBoxA
    
    mov rcx, 1
    call ExitProcess
    
register_ok:
    
    ; create window
    call CreateMyAppWindow
    test rax, rax
    jnz create_ok
    
    ; error: Create Window
    call GetLastError
    mov rcx, rax
    lea rdx, szErrorBuffer
    call IntToString
    
    mov rcx, 0
    lea rdx, szErrorBuffer
    lea r8, szErrorCreate
    mov r9, 0
    call MessageBoxA
    
    mov rcx, 1
    call ExitProcess

create_ok:
    mov hWndMain, rax
    
    ; show window
    mov rcx, hWndMain
    mov rdx, SW_SHOW
    call ShowWindow ; this shit types rr, ok nice it works
    ; ignore my comments, im going to change my .vimrc cuz it doesnt work properly AAAAAA   
    mov rcx, hWndMain
    call UpdateWindow
    
    ; initialize logic
    call Logic_Init
    
; message loop
msg_loop:
    lea rcx, msg
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    
    cmp eax, 0
    jle exit_loop
    
    lea rcx, msg
    call TranslateMessage
    
    lea rcx, msg
    call DispatchMessageA
    jmp msg_loop
    
exit_loop:
    xor rcx, rcx
    call ExitProcess
    
exit_error:
    mov rcx, 1
    call ExitProcess

main ENDP

RegisterMyClass PROC
    sub rsp, 88 ; sizeof(MyWNDCLASSEX) + shadow space + alignment
    
    lea rbx, wc
    
    mov dword ptr [rbx], 80             ; cbSize
    mov dword ptr [rbx+4], CS_VREDRAW or CS_HREDRAW ; style
    lea rax, WndProc
    mov qword ptr [rbx+8], rax          ; lpfnWndProc
    mov dword ptr [rbx+16], 0           ; cbClsExtra
    mov dword ptr [rbx+20], 0           ; cbWndExtra
    mov rax, hInst
    mov qword ptr [rbx+24], rax         ; hInstance
    
    mov rcx, IDI_APPLICATION
    xor rdx, rdx
    ; call LoadIconA ; skip icon for now
    mov qword ptr [rbx+32], 0           ; hIcon
    
    mov rcx, 0
    mov rdx, IDC_ARROW
    call LoadCursorA
    mov qword ptr [rbx+40], rax         ; hCursor
    
    mov qword ptr [rbx+48], COLOR_BTNFACE + 1 ; hbrBackground
    
    mov qword ptr [rbx+56], 0           ; lpszMenuName
    lea rax, szClassName
    mov qword ptr [rbx+64], rax         ; lpszClassName
    mov qword ptr [rbx+72], 0           ; hIconSm
    
    mov rcx, rbx
    call RegisterClassExA
    
    add rsp, 88
    ret
RegisterMyClass ENDP

CreateMyAppWindow PROC
    sub rsp, 136 ; 12 args + alignment
    ; some strange stuff happening!

    ; CreateWindowExA(0, szClassName, szTitle, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 296, 450, NULL, NULL, hInst, NULL)
    ; width = 10 + 60*4 + 10*3 + 10 = 290. Client area.
    ; window width = 290 + borders (approx 16) = 306? let's say 320 is fine.
    ; height = 10 + 40 + 10 + 60*5 + 10*5 = 60 + 300 + 50 = 410.
    ; window height = 410 + caption + borders = 450?
    
    mov rcx, 0                  ; dwExStyle
    lea rdx, szClassName        ; lpClassName
    lea r8, szTitle             ; lpWindowName
    mov r9, WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX or WS_VISIBLE ; dwStyle
    
    mov qword ptr [rsp+32], 80000000h ; CW_USEDEFAULT (x)
    mov qword ptr [rsp+40], 80000000h ; CW_USEDEFAULT (y)
    mov qword ptr [rsp+48], 306        ; nWidth (Client 290 + 16)
    mov qword ptr [rsp+56], 450        ; nHeight (Client 410 + 40)
    mov qword ptr [rsp+64], 0          ; hWndParent
    mov qword ptr [rsp+72], 0          ; hMenu
    mov rax, hInst
    mov [rsp+80], rax           ; hInstance
    mov qword ptr [rsp+88], 0          ; lpParam
    
    call CreateWindowExA
    
    add rsp, 136
    ret
CreateMyAppWindow ENDP

WndProc PROC
    ; RCX = hWnd, RDX = uMsg, R8 = wParam, R9 = lParam
    
    ; save registers if needed? Windows x64 calling convention says RCX, RDX, R8, R9 are volatile.
    ; but we need them for comparison.
    ; better to save them to shadow space or stack if we call other functions.
    ; WndProc is a callback, so we should preserve non-volatile registers RBX, RBP, RDI, RSI, R12-R15.
    
    mov [rsp+8], rcx  ; save hWnd to shadow space (home)
    mov [rsp+16], rdx ; save uMsg
    mov [rsp+24], r8  ; save wParam
    mov [rsp+32], r9  ; save lParam
    
    sub rsp, 40 ; allocate stack frame
    
    cmp edx, WM_DESTROY
    je on_wm_destroy
    
    cmp edx, WM_CREATE
    je on_wm_create
    
    cmp edx, WM_COMMAND
    je on_wm_command
    
    ; default handling
    ; restore args from shadow space for DefWindowProcA
    mov rcx, [rsp+48]
    mov rdx, [rsp+56]
    mov r8,  [rsp+64]
    mov r9,  [rsp+72]
    call DefWindowProcA
    add rsp, 40
    ret

on_wm_create:
    mov rcx, [rsp+48] ; [rsp + 40 + 8]
    
    ; pass to UI_CreateControls(hWnd)
    ; but first UI_InitFont() which takes no args but clobbers registers.
    
    push rcx ; save hWnd again on stack just to be safe/easy
    sub rsp, 40 ; alignment/shadow for call (RSP was 8 mod 16, now 8 mod 16. WAIT)
                ; before push: RSP = 0 mod 16 (in func body).
                ; push rcx: RSP = 8 mod 16.
                ; sub 40: RSP = 48 (0 mod 16). correct.
    call UI_InitFont
    add rsp, 40
    pop rcx ; restore hWnd
    
    call UI_CreateControls
    
    xor rax, rax
    add rsp, 40
    ret

on_wm_destroy:
    xor rcx, rcx
    call PostQuitMessage
    xor rax, rax
    add rsp, 40
    ret

on_wm_command:
    ; wParam: high word = notification code, low word = Control ID
    ; lParam: control handle
    
    mov rax, r8
    and rax, 0FFFFh ; Get Low word (ID)
    
    ; check IDs
    cmp rax, ID_BTN_0
    je btn_digit
    cmp rax, ID_BTN_1
    je btn_digit
    cmp rax, ID_BTN_2
    je btn_digit
    cmp rax, ID_BTN_3
    je btn_digit
    cmp rax, ID_BTN_4
    je btn_digit
    cmp rax, ID_BTN_5
    je btn_digit
    cmp rax, ID_BTN_6
    je btn_digit
    cmp rax, ID_BTN_7
    je btn_digit
    cmp rax, ID_BTN_8
    je btn_digit
    cmp rax, ID_BTN_9
    je btn_digit
    
    cmp rax, ID_BTN_ADD
    je btn_op
    cmp rax, ID_BTN_SUB
    je btn_op
    cmp rax, ID_BTN_MUL
    je btn_op
    cmp rax, ID_BTN_DIV
    je btn_op
    
    cmp rax, ID_BTN_EQ
    je btn_eq
    
    cmp rax, ID_BTN_CLR
    je btn_clr
    
    jmp default_cmd
    
btn_digit:
    call PlayDingSound
    mov rcx, [rsp+64] ; reload wParam (saved R8) from stack
    and rcx, 0FFFFh
    sub rcx, ID_BTN_0 ; convert ID to digit 0-9
    call Logic_ProcessDigit
    call UI_UpdateDisplay
    xor rax, rax
    add rsp, 40
    ret
    
btn_op:
    call PlayDingSound
    mov rcx, [rsp+64] ; reload wParam (saved R8) from stack
    and rcx, 0FFFFh
    sub rcx, ID_BTN_ADD ; convert ID to op (0-3)
    inc rcx             ; logic expects 1-4 (Add=1, Sub=2, Mul=3, Div=4)
    call Logic_ProcessOp
    call UI_UpdateDisplay
    xor rax, rax
    add rsp, 40
    ret
    
btn_eq:
    call PlayDingSound
    call Logic_ProcessEqual
    call UI_UpdateDisplay
    xor rax, rax
    add rsp, 40
    ret
    
btn_clr:
    call PlayDingSound
    call Logic_ProcessClear
    call UI_UpdateDisplay
    xor rax, rax
    add rsp, 40
    ret
    
default_cmd:
    mov rcx, [rsp+48]
    mov rdx, [rsp+56]
    mov r8,  [rsp+64]
    mov r9,  [rsp+72]
    call DefWindowProcA
    add rsp, 40
    ret
WndProc ENDP

.data
wc MyWNDCLASSEX <>
msg MyMSG <>

END
