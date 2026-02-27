; AGC-Lang Stage-0 — Lexer
; mission : Kaynak kodu okuyup tokenlara ayir
global _start:
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

; Token struct layout (24 byte):
;   +0  u8   kind
;   +8  ptr  start
;   +16 u64  len

struc Token
    .kind:  resb 1
            resb 7  ; padding
    .start: resq 1
    .len:   resq 1
endstruc

section .text

; cal_next_token
; giris:  RSI = kaynak buffer pointer not :mevcut pozisyon
;         RDI = Token struct pointer not : sonuc buraya yazilcak
; cikis:  RAX = token tipi
;         RSI = yeni pozisyon not:token sonrasi bu
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
        inc [rsi]
        jmp .skip_whites ; kodun tekrar etmesi icin bir ileri gidip yine kontrol etme mekanigi
      
    .done:
        ;blank
    .eof_control:
        movzx eax, byte [rsi] ; ayni yukarida bahsettim
        cmp al, 0
        jne .classify

        ;EOF
        movzx byte [rdi], 0
        mov rax, 0
        jmp .classify

    .classify:
        ; mantik basic bakicaz tokenmi harfmi
        movzx eax, byte [rsi]
        ; not tutcam bi dk. jl- lower jg-buyuk
        ; bu arada 0x61-a 0x7A-z
        cmp al, 0x61
        jl .degil

        cmp al, 0x7A
        jg .degil

        jmp .identifier

    .check_digit:
        ; not rakamlar 0x30 0x39

        movzx eax, byte [rsi]

        cmp al, 0x30
        jl .degil 

        cmp al 0x39
        jg .degil

        jmp .number 

    .check_upper:
        movzx eax, byte [rsi]

        cmp al, 0x41
        jl .degil

        cmp al, 0x5A
        jg .degil

        jmp .identifier

    .check_symbol:
        ; !"()*+,-/:;{}
        movzx eax, byte [rsi]

        cmp al, 0x21
        jl .degil

        cmp al, 0x2F
        jg .degil

        cmp al, 0x3A
        jl .degil

        cmp al, 0x3E
        jg .degil

        cmp al, 0x7B
        jl .degil

        cmp al, 0x7D
        jg .degil

        jmp .symbol

    .identifier:
        ; yazilcak
    .number:
        ;yazilcak
    .symbol:
        ;yazilcak
        
    ret
