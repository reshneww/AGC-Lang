; AGC Stage-0 — ELF Object File Generator
; mssn : uretilen x86-64 makine kodunu gecerli ELF .o dosyasina yaz
; ELF64 Header sabitleri
ELFMAG0     equ 0x7F
ELFMAG1     equ 0x45    ; 'E'
ELFMAG2     equ 0x4C    ; 'L'
ELFMAG3     equ 0x46    ; 'F'
ELFCLASS64  equ 2       ; 64-bit
ELFDATA2LSB equ 1       ; little-endian
ET_REL      equ 1       ; relocatable object file
EM_X86_64   equ 0x3E    ; x86-64 mimarisi

section .data

; ELF64 Header template (64 byte)
elf_header:
    db ELFMAG0, ELFMAG1, ELFMAG2, ELFMAG3  ; magic
    db ELFCLASS64       ; 64-bit
    db ELFDATA2LSB      ; little-endian
    db 1                ; ELF version 1
    db 0                ; OS/ABI: System V
    dq 0                ; padding
    dw ET_REL           ; type: relocatable
    dw EM_X86_64        ; machine: x86-64
    dd 1                ; ELF version
    dq 0                ; entry point (yok, relocatable)
    dq 0                ; program header offset (yok)
    dq 64               ; section header offset (sonra doldurulacak)
    dd 0                ; flags
    dw 64               ; ELF header boyutu
    dw 0                ; program header entry boyutu
    dw 0                ; program header sayisi
    dw 64               ; section header entry boyutu
    dw 0                ; section header sayisi (sonra doldurulacak)
    dw 0                ; section name string table index

section .text

; elf_write_header
; input:  RDI = output file descriptor
; output:  RAX = yazılan byte sayısı (negatifse hata)
elf_write_header:
    ; TODO: elf_header'ı dosyaya yaz (sys_write)
    ret

; elf_write_text_section
; input:  RDI = output fd
;         RSI = makine kodu buffer pointer
;         RDX = makine kodu boyutu
; output:  RAX = yazılan byte sayısı
elf_write_text_section:
    ; TODO: .text section içeriğini yaz
    ret

; elf_write_section_headers
; input:  RDI = output fd
elf_write_section_headers:
    ; TODO: null section header
    ; TODO: .text section header
    ; TODO: .symtab section header
    ; TODO: .strtab section header
    ret
