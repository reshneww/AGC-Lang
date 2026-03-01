section .data
    filename    db "output.elf", 0
    O_WRONLY    equ 1
    O_CREAT     equ 64        
    O_TRUNC     equ 512       
    MODE        equ 0755o     

section .bss
    fd          resd 1        

section .text
global write_elf

write_elf:
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov  r12, rsi           
    mov  r13, rdx           


    mov  rax, 2             
    lea  rdi, [rel filename]
    mov  rsi, O_WRONLY | O_CREAT | O_TRUNC
    mov  rdx, MODE
    syscall
    test rax, rax
    js   .error
    mov  [rel fd], eax
    mov  r14d, eax          


    sub  rsp, 64
    mov  rdi, rsp
    call .build_elf_header 


    mov  rax, 1             
    mov  rdi, r14
    mov  rsi, rsp
    mov  rdx, 64
    syscall
    add  rsp, 64
    cmp  rax, 64
    jne  .error

    
    sub  rsp, 56
    mov  rdi, rsp
    call .build_prog_header 

    mov  rax, 1
    mov  rdi, r14
    mov  rsi, rsp
    mov  rdx, 56
    syscall
    add  rsp, 56
    cmp  rax, 56
    jne  .error

    mov  rax, 1
    mov  rdi, r14
    mov  rsi, r12
    mov  rdx, r13
    syscall


.close:
    mov  rax, 3
    mov  rdi, r14
    syscall

.done:
    xor  rax, rax
    pop  r15
    pop  r14
    pop  r13
    pop  r12
    pop  rbx
    pop  rbp
    ret

.error:
    movsx rax, eax
    jmp  .close

.build_elf_header:
    push rdi
    ; Tamponu sifirla
    xor  eax, eax
    mov  ecx, 8
    rep  stosq
    pop  rdi

    mov  dword [rdi],      0x464c457f
    mov  byte  [rdi+4],    2

    mov  byte  [rdi+5],    1

    mov  byte  [rdi+6],    1



    mov  word  [rdi+16],   2

    mov  word  [rdi+18],   62

    mov  dword [rdi+20],   1
 
    mov  qword [rdi+24],   0x400078
 
    mov  qword [rdi+32],   64

    mov  qword [rdi+40],   0
 
    mov  dword [rdi+48],   0

    mov  word  [rdi+52],   64

    mov  word  [rdi+54],   56

    mov  word  [rdi+56],   1

    mov  word  [rdi+58],   64

    mov  word  [rdi+60],   0

    mov  word  [rdi+62],   0

    ret

.build_prog_header:
    push rdi
    xor  eax, eax
    mov  ecx, 7
    rep  stosq
    pop  rdi

    
    mov  dword [rdi+0],    1
    
    mov  dword [rdi+4],    5
    
    mov  qword [rdi+8],    0
    
    mov  qword [rdi+16],   0x400000
   
    mov  qword [rdi+24],   0x400000
   
    mov  rax, r13
    add  rax, 120
    mov  qword [rdi+32],   rax
    
    mov  qword [rdi+40],   rax
    
    mov  qword [rdi+48],   0x200000

    ret