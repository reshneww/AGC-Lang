; AGC-Lang Lexer
global cal_next_token
; tokenen tipleri
TOK_EOF     equ 0   ; dosya sonu
TOK_IDENT   equ 1   ; identifier: fn, let, add, x vesair
TOK_NUMBER  equ 2   ; sayı: 42, 100, 0xFF
TOK_PLUS    equ 3   ; +
TOK_MINUS   equ 4   ; -
TOK_STAR    equ 5   ; *
TOK_SLASH   equ 6   ; /
TOK_LPAREN  equ 7   ; (
TOK_RPAREN  equ 8   ; )
TOK_LBRACE  equ 9   ; {
TOK_RBRACE  equ 10  ; }
TOK_COLON   equ 11  ; :
TOK_SEMI    equ 12  ; ;
TOK_ARROW   equ 13  ; ->
TOK_EQ      equ 14  ; =
TOK_KW_FN   equ 15  ; fn
TOK_KW_LET  equ 16  ; let
TOK_KW_RET  equ 17  ; return
TOK_KW_IF   equ 18  ; if
TOK_KW_WHILE equ 19 ; while
TOK_KW_ASM  equ 20  ; asm
TOK_KW_EXT  equ 21  ; extern
TOK_KW_PACK equ 22  ; pack


struc Token
    .kind:  resb 1
            resb 7  ; padding
    .start: resq 1
    .len:   resq 1
endstruc

section .text

cal_next_token:
    .skip_whites:
        movzx eax, byte [rsi] ; giris al.  eax kullandim cunki rax bir alti 32 byte

        cmp al, 0x0A ; yeni satir olup
        je .advance

        cmp al, 0x09 ; tab olup olmadigini kontrol et 
        je .advance

        cmp al, 0x20 ; space olup olmadigini kontrol et 
        je .advance

        jmp .done


    .advance:
        inc rsi
        jmp .skip_whites ; kodun tekrar etmesi icin bir ileri gidip yine kontrol etme mekanigi
      
    .done:
        ;blank
    .eof_control:
        movzx eax, byte [rsi] ; ayni yukarida bahsettim
        cmp al, 0
        jne .classify

        ;EOF
        mov byte [rdi], 0
        mov rax, 0
        jmp .classify

    .classify:
        movzx eax, byte [rsi]
        cmp al, 0x61
        jl  .not_lower
        cmp al, 0x7A
        jle .identifier
    .not_lower:
        cmp al, 0x41
        jl  .not_upper
        cmp al, 0x5A
        jle .identifier
    .not_upper:
        cmp al, 0x5F
        je  .identifier

        cmp al, 0x30
        jl  .not_digit
        cmp al, 0x39
        jle .number
    .not_digit:
        jmp .symbol
    .identifier:
        movzx eax, byte [rsi]
        
        cmp al, 0x41
        jl .not_upper
        .not_upper:
            cmp al, 0x5F
            je  .identifier

            cmp al, 0x30
            jl  .not_digit
            cmp al, 0x39
            jle .number
        .not_digit:
            jmp .symbol
        cmp al, 0x5A
        jle .identifier_contuine
        cmp al, 0x5F
        je .identifier_contuine ;harf
        cmp al, 0x61
        jl .bitti
        cmp al, 0x7A
        jle .identifier_contuine
        cmp al, 0x30
        jl .bitti
        cmp al, 0x39
        jg .bitti

        jmp .identifier_contuine ;harf
    .identifier_contuine:
        inc rsi
        inc rcx

        jmp .identifier


