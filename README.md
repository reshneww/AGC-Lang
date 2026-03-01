# AGC Lang

ASM-first, zero runtime, Linux kernel ready system programming language.

> "Closer to silicon than anything else."

## Status
- [ ] Stage-0 (NASM bootstrap compiler)
- [ ] Stage-1 (AGC compiler written in AGC)
- [ ] Self-hosting

## Build

```bash
# Stage-0 derle (sadece NASM gerekli)
cd stage0
nasm -f elf64 main.asm -o agc0.o
ld -o agc0 agc0.o

# Test
./agc0 tests/stage0/hello.agc -o hello
./hello
```

## Repository Structure

```
stage0/   — NASM ile yazılmış bootstrap derleyici
stage1/   — AGC ile yazılmış tam derleyici
spec/     — Dil spesifikasyonu
tests/    — Test dosyaları
tools/    — Yardımcı araçlar
docs/     — Dökümanlar
```

## Contributors
- Rehman (@reshneww)
