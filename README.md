# Callisto

ASM-first, zero runtime, Linux kernel ready system programming language.

> "Closer to silicon than anything else."

## Status
- [ ] Stage-0 (NASM bootstrap compiler)
- [ ] Stage-1 (Callisto compiler written in Callisto)
- [ ] Self-hosting

## Build

```bash
# Stage-0 derle (sadece NASM gerekli)
cd stage0
nasm -f elf64 main.asm -o cal0.o
ld -o cal0 cal0.o

# Test
./cal0 tests/stage0/hello.cal -o hello
./hello
```

## Repository Structure

```
stage0/   — NASM ile yazılmış bootstrap derleyici
stage1/   — Callisto ile yazılmış tam derleyici
spec/     — Dil spesifikasyonu
tests/    — Test dosyaları
tools/    — Yardımcı araçlar
docs/     — Dökümanlar
```

## Contributors
- Rehman (@reshneww)
