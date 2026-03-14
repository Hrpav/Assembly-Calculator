include common.inc

PUBLIC UI_InitFont
PUBLIC UI_CreateControls
PUBLIC UI_UpdateDisplay

EXTERN Logic_GetDisplayString: PROC
EXTERN hInst: QWORD
EXTERN hWndMain: QWORD

.data
szFontFile      db "fonts\VGAOEM.FON", 0 ; font we are going to use (termios)
szFontName      db "Terminal", 0         ; strange
hFont           dq 0
hDisplay        dq 0

szBtn0          db "0", 0
szBtn1          db "1", 0
szBtn2          db "2", 0
szBtn3          db "3", 0
szBtn4          db "4", 0
szBtn5          db "5", 0
szBtn6          db "6", 0
szBtn7          db "7", 0
szBtn8          db "8", 0
szBtn9          db "9", 0
szBtnAdd        db "+", 0
szBtnSub        db "-", 0
szBtnMul        db "*", 0
szBtnDiv        db "/", 0
szBtnEq         db "=", 0
szBtnClr        db "C", 0
szBtnDot        db ".", 0
szButtonClass   db "BUTTON", 0
szStaticClass   db "STATIC", 0

.code

; UI_InitFont - loads the custom font and creates a font object
; returns: hFont (in RAX and stored in global)
UI_InitFont PROC
    sub rsp, 120            ; 120 bytes for stack args + alignment (14 args needed)
                            ; 14 args: 4 in regs, 10 on stack.
                            ; max offset used: [rsp + 104] (8 bytes) -> 112 bytes needed.
                            ; 120 satisfies alignment (120 + 8 = 128 which is 16*8)
    
    ; add font resource
    lea rcx, szFontFile
    mov rdx, FR_PRIVATE
    xor r8, r8
    call AddFontResourceExA
    
    ; create font
    ; CreateFontA(Height, Width, Escapement, Orientation, Weight, Italic, Underline, StrikeOut, CharSet, OutputPrecision, ClipPrecision, Quality, PitchAndFamily, FaceName)
    
    mov rcx, 24             ; height
    xor rdx, rdx            ; width
    xor r8, r8              ; escapement
    xor r9, r9              ; orientation
    
    ; stack args
    mov qword ptr [rsp + 32], 400   ; weight (FW_NORMAL)
    mov qword ptr [rsp + 40], 0     ; italic
    mov qword ptr [rsp + 48], 0     ; underline
    mov qword ptr [rsp + 56], 0     ; strikeOut
    mov qword ptr [rsp + 64], 255   ; charSet (OEM_CHARSET)
    mov qword ptr [rsp + 72], 0     ; outputPrecision
    mov qword ptr [rsp + 80], 0     ; clipPrecision
    mov qword ptr [rsp + 88], 0     ; quality
    mov qword ptr [rsp + 96], 49    ; pitchAndFamily (FIXED_PITCH | FF_MODERN)
    lea rax, szFontName
    mov [rsp + 104], rax    ; faceName
    
    call CreateFontA
    mov hFont, rax
    
    add rsp, 120
    ret
UI_InitFont ENDP

; helper macro to create button
CreateButton MACRO text, id, x, y, w, h
    mov rcx, 0              ; dwExStyle
    lea rdx, szButtonClass  ; lpClassName
    lea r8, text            ; lpWindowName
    mov r9, WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON ; dwStyle
    
    ; stack args
    mov qword ptr [rsp + 32], x
    mov qword ptr [rsp + 40], y
    mov qword ptr [rsp + 48], w
    mov qword ptr [rsp + 56], h
    mov rax, rdi            ; sse RDI (hWndParent)
    mov [rsp + 64], rax     ; hWndParent
    mov qword ptr [rsp + 72], id ; hMenu (ID)
    mov rax, hInst
    mov [rsp + 80], rax     ; hInstance
    mov qword ptr [rsp + 88], 0 ; lpParam
    
    call CreateWindowExA
    
    ; set font
    mov rcx, rax
    mov rdx, WM_SETFONT
    mov r8, hFont
    mov r9, 1
    call SendMessageA
ENDM

; UI_CreateControls
; RCX = hWnd (parent window)
UI_CreateControls PROC
    push rbx
    push rsi
    push rdi
    
    mov rdi, rcx ; save parent HWND in RDI
    
    sub rsp, 144 ; space for args + alignment (16*9 = 144)
    ; entry: 8 mod 16. pushes: 3*8=24. RSP -> 8-24 = -16 (0 mod 16).
    ; we need to keep it 0 mod 16.
    ; 144 is 16*9. so RSP - 144 -> 0 mod 16. correct.
    
    ; display (static)
    ; CreateWindowExA(0, "STATIC", NULL, WS_CHILD|WS_VISIBLE|SS_RIGHT, 10, 10, 280, 40, hWndParent, ID_Display, hInst, NULL)
    mov rcx, 0
    lea rdx, szStaticClass
    xor r8, r8
    mov r9, WS_CHILD or WS_VISIBLE or SS_RIGHT
    
    mov qword ptr [rsp + 32], 10    ; x
    mov qword ptr [rsp + 40], 10    ; y
    mov qword ptr [rsp + 48], 280   ; w
    mov qword ptr [rsp + 56], 40    ; h
    mov rax, rdi            ; parent (RDI)
    mov [rsp + 64], rax     ; parent
    mov qword ptr [rsp + 72], ID_Display
    mov rax, hInst
    mov [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    
    call CreateWindowExA
    mov hDisplay, rax
    
    ; set font for display
    mov rcx, hDisplay
    mov rdx, WM_SETFONT
    mov r8, hFont
    mov r9, 1
    call SendMessageA
    
    ; buttons layout:
    ; row 1: C, /, *, -
    CreateButton szBtnClr, ID_BTN_CLR, 10, 60, 60, 60
    CreateButton szBtnDiv, ID_BTN_DIV, 80, 60, 60, 60
    CreateButton szBtnMul, ID_BTN_MUL, 150, 60, 60, 60
    CreateButton szBtnSub, ID_BTN_SUB, 220, 60, 60, 60
    
    ; row 2: 7, 8, 9, + (tall)
    CreateButton szBtn7, ID_BTN_7, 10, 130, 60, 60
    CreateButton szBtn8, ID_BTN_8, 80, 130, 60, 60
    CreateButton szBtn9, ID_BTN_9, 150, 130, 60, 60
    CreateButton szBtnAdd, ID_BTN_ADD, 220, 130, 60, 130 ; height 130
    
    ; row 3: 4, 5, 6
    CreateButton szBtn4, ID_BTN_4, 10, 200, 60, 60
    CreateButton szBtn5, ID_BTN_5, 80, 200, 60, 60
    CreateButton szBtn6, ID_BTN_6, 150, 200, 60, 60
    
    ; row 4: 1, 2, 3, = (Tall)
    CreateButton szBtn1, ID_BTN_1, 10, 270, 60, 60
    CreateButton szBtn2, ID_BTN_2, 80, 270, 60, 60
    CreateButton szBtn3, ID_BTN_3, 150, 270, 60, 60
    CreateButton szBtnEq, ID_BTN_EQ, 220, 270, 60, 130 ; height 130
    
    ; row 5: 0 (Wide), .
    CreateButton szBtn0, ID_BTN_0, 10, 340, 130, 60 ; width 130
    CreateButton szBtnDot, ID_BTN_DOT, 150, 340, 60, 60
    
    add rsp, 144
    pop rdi
    pop rsi
    pop rbx
    ret
UI_CreateControls ENDP

UI_UpdateDisplay PROC
    sub rsp, 40
    
    ; get string from logic
    call Logic_GetDisplayString
    mov rdx, rax ; string ptr in RDX (lParam)
    
    mov rcx, hDisplay
    mov r8, rdx ; lParam (actually R8 is wParam, R9 is lParam for SendMessage?)
    ; SendMessage(hWnd, Msg, wParam, lParam)
    ; RCX, RDX, R8, R9
    
    ; wait, SendMessageA signature:
    ; LRESULT SendMessageA(HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam);
    
    ; so:
    ; RCX = hWnd
    ; RDX = Msg
    ; R8 = wParam
    ; R9 = lParam
    
    mov rcx, hDisplay
    mov rdx, WM_SETTEXT
    xor r8, r8 ; wParam = 0
    mov r9, rax ; lParam = string ptr (from Logic_GetDisplayString)
    
    call SendMessageA
    
    add rsp, 40
    ret
UI_UpdateDisplay ENDP

END

; end of file
