; AGC Stage-0 — Lexer
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
    ; TODO: whitespace atla
    ; TODO: EOF kontrol et
    ; TODO: karakteri classify et
    ;       - harf ise: identifier veya keyword
    ;       - rakam ise: number
    ;       - sembol ise: operator
    ret
