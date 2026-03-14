include common.inc

PUBLIC PlayDingSound
PUBLIC PlayErrorSound
PUBLIC IntToString

; sounds that we will be using (sounds\ dir)
.data
szErrSound db "sounds\err.wav", 0
szDingSound db "sounds\ding.wav", 0

.code

; PlayDingSound - plays the ding sound
PlayDingSound PROC
    sub rsp, 40                 ; shadow space + alignment
    lea rcx, szDingSound        ; sound file
    xor rdx, rdx                ; NULL (module handle, ignored for filename)
    mov r8, SND_ASYNC or SND_FILENAME
    call PlaySoundA
    add rsp, 40
    ret
PlayDingSound ENDP

; PlayErrorSound - plays the error sound
PlayErrorSound PROC
    sub rsp, 40
    lea rcx, szErrSound
    xor rdx, rdx
    mov r8, SND_ASYNC or SND_FILENAME
    call PlaySoundA
    add rsp, 40
    ret
PlayErrorSound ENDP

; IntToString - converts signed 64-bit integer to string
; RCX = integer value
; RDX = pointer to buffer
IntToString PROC
    push rbx
    push rsi
    push rdi
    
    mov rax, rcx
    mov rdi, rdx
    
    test rax, rax
    jns positive
    neg rax
    mov byte ptr [rdi], '-'
    inc rdi
    
positive:
    mov rsi, rdi        ; start of number string
    mov rbx, 10
    
convert_loop:
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi], dl
    inc rdi
    test rax, rax
    jnz convert_loop
    
    mov byte ptr [rdi], 0 ; null terminator
    dec rdi
    
    ; reverse the string
reverse_loop:
    cmp rsi, rdi
    jge done
    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al
    inc rsi
    dec rdi
    jmp reverse_loop
    
done:
    pop rdi
    pop rsi
    pop rbx
    ret
IntToString ENDP

END
