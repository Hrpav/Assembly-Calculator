; common definitions for x64 windows assembly

EXTERN ExitProcess: PROC
EXTERN GetModuleHandleA: PROC
EXTERN LoadIconA: PROC
EXTERN LoadCursorA: PROC
EXTERN RegisterClassExA: PROC
EXTERN CreateWindowExA: PROC
EXTERN ShowWindow: PROC
EXTERN UpdateWindow: PROC
EXTERN GetMessageA: PROC
EXTERN TranslateMessage: PROC
EXTERN DispatchMessageA: PROC
EXTERN PostQuitMessage: PROC
EXTERN DefWindowProcA: PROC
EXTERN SendMessageA: PROC
EXTERN SetWindowTextA: PROC
EXTERN GetWindowTextA: PROC
EXTERN MessageBoxA: PROC
EXTERN PlaySoundA: PROC
EXTERN AddFontResourceExA: PROC
EXTERN RemoveFontResourceExA: PROC
EXTERN CreateFontA: PROC
EXTERN SelectObject: PROC
EXTERN DeleteObject: PROC
EXTERN SetBkMode: PROC
EXTERN SetTextColor: PROC
EXTERN BeginPaint: PROC
EXTERN EndPaint: PROC
EXTERN TextOutA: PROC
EXTERN GetClientRect: PROC
EXTERN InvalidateRect: PROC

; constants
WM_CREATE           equ 1
WM_DESTROY          equ 2
WM_SETTEXT          equ 12
WM_PAINT            equ 15
WM_SETFONT          equ 48
WM_COMMAND          equ 273

CS_VREDRAW          equ 1
CS_HREDRAW          equ 2
CS_DBLCLKS          equ 8

IDI_APPLICATION     equ 32512
IDC_ARROW           equ 32512

COLOR_WINDOW        equ 5
COLOR_BTNFACE       equ 15

WS_OVERLAPPED       equ 00000000h
WS_CAPTION          equ 00C00000h
WS_SYSMENU          equ 00080000h
WS_THICKFRAME       equ 00040000h
WS_MINIMIZEBOX      equ 00020000h
WS_MAXIMIZEBOX      equ 00010000h
WS_ VERLAPPEDWINDOW equ WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX
WS_VISIBLE          equ 10000000h
WS_CHILD            equ 40000000h

SS_RIGHT            equ 2

BS_PUSHBUTTON       equ 0
BS_DEFPUSHBUTTON    equ 1

SW_SHOW             equ 5
SW_SHOWNORMAL       equ 1

SND_SYNC            equ 0
SND_ASYNC           equ 1
SND_FILENAME        equ 20000h

FR_PRIVATE          equ 10h

TRANSPARENT         equ 1

LF_FACESIZE         equ 32

; structures
MyWNDCLASSEX STRUCT
    cbSize          DWORD ?
    style           DWORD ?
    lpfnWndProc     QWORD ?
    cbClsExtra      DWORD ?
    cbWndExtra      DWORD ?
    hInstance       QWORD ?
    hIcon           QWORD ?
    hCursor         QWORD ?
    hbrBackground   QWORD ?
    lpszMenuName    QWORD ?
    lpszClassName   QWORD ?
    hIconSm         QWORD ?
MyWNDCLASSEX ENDS

MyPOINT STRUCT
    x   SDWORD ?
    y   SDWORD ?
MyPOINT ENDS

MyMSG STRUCT
    hwnd        QWORD ?
    message     DWORD ?
    padding1    DWORD ? ; Padding for alignment
    wParam      QWORD ?
    lParam      QWORD ?
    time        DWORD ?
    pt          MyPOINT <>
    padding2    DWORD ? ; Padding for alignment
MyMSG ENDS

MyRECT STRUCT
    left    SDWORD ?
    top     SDWORD ?
    right   SDWORD ?
    bottom  SDWORD ?
MyRECT ENDS

MyPAINTSTRUCT STRUCT
    hdc         QWORD ?
    fErase      DWORD ?
    rcPaint     MyRECT <>
    fRestore    DWORD ?
    fIncUpdate  DWORD ?
    rgbReserved BYTE 32 dup(?)
MyPAINTSTRUCT ENDS

; button IDs
ID_BTN_0    equ 100
ID_BTN_1    equ 101
ID_BTN_2    equ 102
ID_BTN_3    equ 103
ID_BTN_4    equ 104
ID_BTN_5    equ 105
ID_BTN_6    equ 106
ID_BTN_7    equ 107
ID_BTN_8    equ 108
ID_BTN_9    equ 109
ID_BTN_ADD  equ 110
ID_BTN_SUB  equ 111
ID_BTN_MUL  equ 112
ID_BTN_DIV  equ 113
ID_BTN_EQ   equ 114
ID_BTN_CLR  equ 115
ID_BTN_DOT  equ 116
ID_Display  equ 200

; global variables declared in main or logic
; EXTERN declarations removed to avoid redefinition errors.
; include them explicitly in files where needed.
