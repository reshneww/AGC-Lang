; AGC-Lang Stage-0 Bootstrap Compiler
; Hedef: x86-64 Linux ELF
; Derleme kodu : nasm -f elf64 main.asm -o cal0.o && ld -o cal0 cal0.o

section .data
    ; hata mesajlari buraya gelecek
section .bss
    ; bufferlar buraya gelecek

section .text
    global _start

_start:
    ; TODO: komut satiri argümanlarını oku (argv[1] = kaynak dosya)
    ; TODO: dosyayi bellege yukle
    ; TODO: lexeri baslat
    ; TODO: parseri baslat
    ; TODO: code generatori baslat
    ; TODO: ELF object file yaz
    ; TODO: temizle ve cik

    mov rax, 60     ; sys_exit
    xor rdi, rdi    ; exit code 0
    syscall

;todolar yukarida var onlardan devam
