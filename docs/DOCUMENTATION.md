# AGC Language Documentation

> Low-level programming language bootstrapped from raw x86-64 assembly.  
> No runtime. No compromise.

---

## Table of Contents

1. [What is AGC](#1-what-is-agc)
2. [Design Philosophy](#2-design-philosophy)
3. [Getting Started](#3-getting-started)
4. [Syntax](#4-syntax)
5. [Type System](#5-type-system)
6. [Memory Model](#6-memory-model)
7. [Hardware Control](#7-hardware-control)
8. [Multi-core Programming](#8-multi-core-programming)
9. [Error Handling](#9-error-handling)
10. [ABI & Foreign Functions](#10-abi--foreign-functions)
11. [Math & SIMD](#11-math--simd)
12. [Compiler Architecture](#12-compiler-architecture)
13. [Bootstrap Process](#13-bootstrap-process)
14. [Roadmap](#14-roadmap)

---

## 1. What is AGC

AGC is a systems programming language designed for one purpose: **direct hardware control with zero overhead**.

It is not trying to replace Python. It is not trying to replace JavaScript. It exists in the space where C lives — kernels, drivers, firmware, embedded systems, real-time applications — and tries to do that job better.

**What makes AGC different:**

- Bootstrapped from pure x86-64 assembly — no C dependency anywhere
- Zero runtime: no garbage collector, no scheduler, no hidden allocations
- Every keyword maps directly to a hardware concept
- Compile-time memory safety without a borrow checker
- SIMD types are first-class citizens
- ABI is always explicit — no silent calling convention mismatches
- Built from day one to target Linux kernel development

---

## 2. Design Philosophy

Every design decision in Callisto is tested against one question:

> **Does this feature improve the quality of the generated machine code?**

If the answer is no, the feature does not enter the language.

**Three core principles:**

**What you see is what you get.**  
Every Callisto construct has a documented machine code equivalent. There are no surprises. `pulse {}` is a stack frame. `bond` is a pointer with compile-time alias analysis. `anchor` is a memory pin directive to the linker. Nothing is hidden.

**Zero hidden cost.**  
No garbage collector pauses. No runtime scheduler. No implicit heap allocation. No hidden vtable lookup. If something costs clock cycles, you wrote it yourself and you know it's there.

**Assembly first.**  
The compiler itself starts from raw x86-64 assembly. This is not a philosophical statement — it is a technical guarantee that the entire toolchain can be audited down to the last byte with no external dependencies.

---

## 3. Getting Started

### Requirements

- Linux x86-64
- NASM (for Stage-0 bootstrap)
- GNU ld (linker)

### Install NASM

```bash
sudo apt install nasm
```

### Build Stage-0

```bash
cd stage0
nasm -f elf64 main.asm -o cal0.o
ld -o cal0 cal0.o
```

### Compile Your First Program

```bash
./cal0 tests/stage0/hello.cal -o hello
./hello
```

### Hello World

```
extern sysv64 {
    fn write(fd: u64, buf: ptr u8, len: u64) -> i64;
    fn exit(code: u64) -> void;
}

fn main() -> void {
    write(1, "Hello from Callisto\n", 20);
    exit(0);
}
```

---

## 4. Syntax

### 4.1 Functions

```
fn function_name(param1: type, param2: type) -> return_type {
    // body
}
```

Example:

```
fn add(a: u64, b: u64) -> u64 {
    return a + b;
}
```

With drift declarations:

```
fn divide(a: u64, b: u64) -> u64 drifts(DivisionByZero) {
    if b == 0 { drift DivisionByZero; }
    return a / b;
}
```

### 4.2 Variables

```
let type name = value;       // immutable
let mut type name = value;   // mutable
ptr type name = address;     // pointer (unsafe block required)
```

Examples:

```
let u64 x = 42;
let mut u64 counter = 0;
let f64 pi = 3.14159;
```

### 4.3 Control Flow

**If:**
```
if condition {
    // ...
}

if condition {
    // ...
} else {
    // ...
}
```

**While:**
```
while condition {
    // ...
}
```

**Loop (infinite):**
```
loop {
    // ...
    if done { break; }
}
```

### 4.4 Structs

```
pack StructName {
    field1: type;
    field2: type;
}
```

Example:

```
pack Point {
    x: f64;
    y: f64;
}

fn distance(p: ptr Point) -> f64 {
    return sqrt(p.x * p.x + p.y * p.y);
}
```

### 4.5 Inline Assembly

```
fn get_rsp() -> u64 {
    let u64 result;
    core {
        asm {
            "mov %[out], rsp"
            : [out] "=r"(result)
            :
            :
        }
    }
    return result;
}
```

---

## 5. Type System

### 5.1 Integer Types

| Type | Size | Range |
|------|------|-------|
| `u8` | 1 byte | 0 to 255 |
| `u16` | 2 bytes | 0 to 65535 |
| `u32` | 4 bytes | 0 to 4294967295 |
| `u64` | 8 bytes | 0 to 2^64-1 |
| `i8` | 1 byte | -128 to 127 |
| `i16` | 2 bytes | -32768 to 32767 |
| `i32` | 4 bytes | -2147483648 to 2147483647 |
| `i64` | 8 bytes | -2^63 to 2^63-1 |
| `i128` / `u128` | 16 bytes | Two 64-bit registers |
| `usize` | platform | Pointer-sized unsigned |
| `isize` | platform | Pointer-sized signed |

### 5.2 Float Types

| Type | Size | Precision |
|------|------|-----------|
| `f32` | 4 bytes | IEEE 754 single |
| `f64` | 8 bytes | IEEE 754 double |

Both compile to XMM register operations. No x87 FPU stack.

### 5.3 Other Primitive Types

| Type | Description |
|------|-------------|
| `bool` | 8-bit storage, compiles to ZF flag in branches |
| `ptr T` | Raw pointer — unsafe block required |
| `void` | No value — return type only |

### 5.4 Composite Types

**Arrays (stack-allocated):**
```
let array[u8; 256] buffer;        // 256 bytes on stack
let array[f64; 4] vec = {1.0, 2.0, 3.0, 4.0};
```

**Slices (fat pointer):**
```
let slice u8 data = buffer[0..128];  // ptr + len pair
```

**Structs:**
```
pack Header {
    magic:   u32;
    version: u16;
    flags:   u16;
    size:    u64;
}
```

**Unions:**
```
// unsafe block required for access
union Register {
    qword: u64;
    dword: u32;
    word:  u16;
    byte:  u8;
}
```

### 5.5 Explicit Casting

All type conversions must be explicit. Silent coercion does not exist.

```
let u64 x = 42;
let u32 y = x as u32;       // explicit narrowing
let f64 z = x as f64;       // explicit int-to-float
let u8  b = (x & 0xFF) as u8;
```

---

## 6. Memory Model

### 6.1 PULSE — Lexical Memory Blocks

`pulse` defines a lexical scope. When the block closes, all variables declared inside are deterministically destroyed. This is a compiler guarantee, not a runtime operation. It compiles to nothing — the stack unwinds at the end of the block.

```
fn process() {
    pulse {
        let array[u8; 4096] temp_buf;
        // ... use temp_buf ...
    }
    // temp_buf is gone here — compile-time enforced
    // Accessing it here is a compile error
}
```

Nested pulse blocks:

```
pulse {
    let u64 outer = 1;
    pulse {
        let u64 inner = 2;
        // both outer and inner accessible here
    }
    // inner is gone, outer still accessible
}
```

### 6.2 BOND — Safe References

`bond` is a reference with compile-time alias analysis. The rule is simple:

> Infinite immutable bonds **OR** exactly one mutable bond. Never both at the same time.

This is enforced by static control flow graph analysis at compile time — not at runtime.

```
let u64 x = 42;

// OK: two immutable bonds
bond const u64 a = &x;
bond const u64 b = &x;

// OK: one mutable bond (after a and b go out of scope)
bond mut u64 c = &x;
[c] = 99;

// COMPILE ERROR: cannot open mutable bond while immutable bond exists
bond const u64 d = &x;
bond mut   u64 e = &x;  // error: AliasViolation
```

### 6.3 ANCHOR — Physical Memory Pinning

`anchor` prevents the optimizer and OS from moving a variable in physical memory. Required for DMA buffers, MMIO registers, and anything the hardware addresses directly.

```
// DMA buffer must stay at its physical address
anchor array[u8; 4096] dma_buffer align(4096);

// MMIO register at fixed physical address
anchor ptr u32 uart_data = 0x09000000;
```

Without `anchor`, the compiler or OS may relocate the variable, breaking hardware access.

### 6.4 ZONE — Address Space Regions

`zone` integrates physical or virtual address ranges into the type system. Out-of-bounds access is a compile error.

```
zone apic : 0xFEE00000..0xFEE01000 {
    anchor ptr u32 eoi    = 0xFEE000B0;
    anchor ptr u32 icr_lo = 0xFEE00300;
    anchor ptr u32 icr_hi = 0xFEE00310;
}

zone dma_zone : 0x00000000..0x01000000 {
    anchor array[u8; 65536] bounce_buf align(4096);
}

// Usage:
fn send_eoi() {
    core { [apic.eoi] = 0; }
}
```

### 6.5 SEAL — Read-Only Constants

`seal` defines compile-time constant memory. Equivalent to the kernel's `.rodata` segment.

```
seal array[u8; 16] KERNEL_MAGIC = "CALLISTO_KERNEL\0";
seal u32 PAGE_SIZE = 4096;
seal u64 KERNEL_BASE = 0xFFFFFFFF80000000;
```

---

## 7. Hardware Control

### 7.1 CORE Block

The `core` block is Callisto's direct hardware access layer. Inside it, register binding and inline assembly are permitted.

```
fn rdtsc() -> u64 {
    let u64 result;
    core {
        asm {
            "rdtsc"
            "shl rdx, 32"
            "or  rax, rdx"
            : "=a"(result)
            :
            : "rdx"
        }
    }
    return result;
}
```

### 7.2 Register Binding

Bind a variable to a specific CPU register. The compiler cannot use that register for other purposes.

```
core {
    reg rax u64 syscall_nr = 1;    // sys_write
    reg rdi u64 fd         = 1;    // stdout
    reg rsi ptr u8 buf     = data;
    reg rdx u64 len        = data.len;
    asm { "syscall" : : : "rcx", "r11", "memory" }
}
```

### 7.3 NAKED Functions

Naked functions have no prologue or epilogue. Used for interrupt handlers, exception entry points, and anything where you need full manual control of the stack.

```
naked fn irq_timer() {
    core {
        asm {
            "push rax"
            "push rbx"
            "push rcx"
            "push rdx"
        }
    }

    // handler logic here
    atomic_fetch_add(&tick_count, 1);

    core {
        // send EOI to APIC
        [apic.eoi] = 0;

        asm {
            "pop rdx"
            "pop rcx"
            "pop rbx"
            "pop rax"
            "iretq"
        }
    }
}
```

### 7.4 Direct Linux Syscalls

Bypass libc and call the kernel directly:

```
inline fn sys_write(fd: u64, buf: ptr u8, len: u64) -> i64 {
    let i64 result;
    core {
        reg rax u64 nr  = 1;
        reg rdi u64 _fd = fd;
        reg rsi ptr u8 _buf = buf;
        reg rdx u64 _len = len;
        asm {
            "syscall"
            : "=a"(result)
            :
            : "rcx", "r11", "memory"
        }
    }
    return result;
}
```

---

## 8. Multi-core Programming

Callisto has no implicit thread safety. Everything is explicit. This is intentional — in kernel and embedded development you need to know exactly what is atomic and what is not.

### 8.1 Atomic Variables

```
atomic u64 global_counter = 0;
atomic u32 spinlock_state  = 0;

fn increment() {
    atomic_fetch_add(&global_counter, 1);
}

fn compare_and_swap_example() {
    let u64 expected = atomic_load(&global_counter);
    let bool ok = atomic_cas(&global_counter, expected, expected + 1);
}
```

### 8.2 Memory Fences

```
// Producer
fn publish_data() {
    shared_buffer[0] = 0xFF;
    fence release;              // writes above complete before this line
    atomic_store(&data_ready, true);
}

// Consumer
fn consume_data() {
    while !atomic_load(&data_ready) { }
    fence acquire;              // reads below start after this line
    let u8 val = shared_buffer[0];  // guaranteed to be 0xFF
}
```

Fence types:

| Fence | Meaning |
|-------|---------|
| `fence acquire` | Reads after this point cannot move before it |
| `fence release` | Writes before this point cannot move after it |
| `fence seq_cst` | Full sequential consistency barrier |

### 8.3 Spinlock Example

```
pack Spinlock { state: atomic u32; }

fn lock(s: ptr Spinlock) {
    loop {
        let u32 old = atomic_cas(&s.state, 0, 1);
        if old == 0 {
            fence acquire;
            return;
        }
        core { asm { "pause" : : : } }  // CPU spin hint
    }
}

fn unlock(s: ptr Spinlock) {
    fence release;
    atomic_store(&s.state, 0);
}
```

---

## 9. Error Handling

AGC error handling is based on `drift` and `align`. There are no exceptions, no exception tables, no runtime overhead. A `drift` compiles to a conditional branch. On the non-error path the cost is zero.

All drifts declared in a function signature must be caught by the caller. Uncaught drifts are a compile error.

### 9.1 Declaring Drifts

```
drift OutOfMemory;
drift HardwareFailure;
drift InvalidArgument;
drift Timeout;
```

### 9.2 Functions That Drift

```
fn allocate(size: usize) -> ptr u8 drifts(OutOfMemory) {
    if size == 0 { drift InvalidArgument; }

    core {
        let ptr u8 result = internal_alloc(size);
        if result == null { drift OutOfMemory; }
        return result;
    }
}
```

### 9.3 Catching Drifts

```
fn init() {
    let ptr u8 buf = allocate(4096);

    align OutOfMemory {
        log("not enough memory");
        return;
    }

    align InvalidArgument {
        log("bug: zero size allocation");
        core { asm { "ud2" } }  // intentional crash
    }

    // buf is guaranteed valid here
    use_buffer(buf);
}
```

---

## 10. ABI & Foreign Functions

Every external function call must declare its ABI. There is no implicit calling convention.

### 10.1 Supported ABIs

| ABI | Description |
|-----|-------------|
| `sysv64` | Linux / macOS x86-64 System V |
| `win64` | Windows x64 |
| `cdecl` | 32-bit C standard |
| `fastcall` | 32-bit register-passing |
| `bare` | No ABI — interrupt handlers |
| `callisto` | Native Callisto ABI (v1.0) |

### 10.2 Calling C Functions

```
extern sysv64 {
    fn malloc(size: usize) -> ptr void;
    fn free(ptr: ptr void) -> void;
    fn memcpy(dst: ptr void, src: ptr void, n: usize) -> ptr void;
    fn printf(fmt: ptr u8, ...) -> i32;
}
```

### 10.3 Calling Linux Kernel Functions (from module)

```
extern sysv64 {
    fn printk(fmt: ptr u8, ...) -> i32;
    fn kmalloc(size: usize, flags: u32) -> ptr void;
    fn kfree(ptr: ptr void) -> void;
}
```

### 10.4 Exporting Functions to C

```
extern "C" fn callisto_module_init() -> i32 {
    printk("callisto: module loaded\n");
    return 0;
}
```

---

## 11. Math & SIMD

### 11.1 SIMD Vector Types

| Type | Registers | Elements |
|------|-----------|----------|
| `v128f32` | XMM | 4x f32 |
| `v256f32` | YMM | 8x f32 |
| `v512f32` | ZMM | 16x f32 |
| `v128f64` | XMM | 2x f64 |
| `v256f64` | YMM | 4x f64 |
| `v256i32` | YMM | 8x i32 |

### 11.2 SIMD Operations

```
fn dot_product(a: ptr array[f32;8], b: ptr array[f32;8]) -> f32 {
    core {
        reg ymm0 v256f32 va = simd_load256(a);
        reg ymm1 v256f32 vb = simd_load256(b);
        reg ymm2 v256f32 product = simd_mul(va, vb);
        return simd_hadd_f32(product);  // horizontal add
    }
}
```

### 11.3 Built-in Math Operations

| Function | Instruction | Description |
|----------|-------------|-------------|
| `simd_add(a, b)` | VADDPS/PD | Vector add |
| `simd_mul(a, b)` | VMULPS/PD | Vector multiply |
| `simd_fma(a,b,c)` | VFMADD | Fused multiply-add: (a*b)+c |
| `simd_sqrt(a)` | VSQRTPS | Vector square root |
| `simd_min(a, b)` | VMINPS | Element-wise minimum |
| `simd_max(a, b)` | VMAXPS | Element-wise maximum |
| `bit_clz(x)` | LZCNT | Count leading zeros |
| `bit_popcount(x)` | POPCNT | Count set bits |
| `bit_bswap(x)` | BSWAP | Byte swap |

### 11.4 Fixed-Point Math

For embedded targets without FPU:

```
// Q16.16 fixed-point multiply
fn q16_mul(a: i32, b: i32) -> i32 {
    let i64 result;
    core {
        asm {
            "imul rax, %[a], %[b]"
            "sar  rax, 16"
            : "=a"(result) : [a]"r"(a), [b]"r"(b) :
        }
    }
    return result as i32;
}
```

---

## 12. Compiler Architecture

### 12.1 Pipeline

```
Source (.cal)
    |
    v  [Lexer]
    |  Tokenizes source into token stream
    |
    v  [Parser]
    |  Builds Abstract Syntax Tree (AST)
    |
    v  [Type Checker]
    |  Resolves types, checks explicit casts
    |
    v  [BOND Analyzer]
    |  Static alias analysis — compile-time memory safety
    |
    v  [Drift Checker]
    |  Exhaustiveness: all drifts must be caught
    |
    v  [Zone Validator]
    |  Address range bounds checking at compile time
    |
    v  [CIR Generator]
    |  SSA-form intermediate representation
    |  Register hints preserved from source
    |
    v  [Register Allocator]
    |  Linear scan + register hint priority
    |
    v  [Instruction Selector]
    |  SIMD vectorization, peephole optimizer
    |
    v  [ELF Object Generator]
    |  .text .data .rodata .bss sections
    |
    v  ELF Object File (.o)
    |
    v  [GENESIS Linker]
    |
    v  ELF Executable / Bare Metal Binary
```

### 12.2 TRACE Mode

Every AGC statement can emit annotated assembly output. No external debugger needed for low-level analysis.

```bash
cal build --trace program.cal
```

Output:

```
[SRC]  let u64 result = a * b + c;
[CIR]  %0 = mul u64 %a, %b
[CIR]  %1 = add u64 %0, %c
[REG]  %0 -> rax,  %1 -> rbx
[ASM]  imul rax, rdi
[ASM]  add  rax, rdx
[MEM]  result: stack -8, immutable
```

### 12.3 Build Flags

```bash
cal build main.cal -o output          # basic build
cal build main.cal -o output --trace  # with annotated assembly
cal build main.cal -o output --no-std # no standard library
cal build main.cal -o kernel.elf \
    --target x86_64-bare \            # bare metal target
    --no-std \
    --link-args "-T linker.ld"
```

---

## 13. Bootstrap Process

AGC builds itself from scratch with no external language dependency.

### Stage-0 — Pure Assembly

Written in approximately 3000 lines of x86-64 NASM assembly. Understands only the minimal AGC subset needed to compile Stage-1. Produces ELF object files.

```bash
# Build Stage-0 (only NASM required)
cd stage0
nasm -f elf64 main.asm -o cal0.o
ld -o cal0 cal0.o
```

Stage-0 supports:
- `fn` definitions
- `let` / `ptr` variables
- `+ - * /` arithmetic
- `if` / `while` control flow
- `return`
- `asm {}` inline assembly
- `extern` bindings
- `pack {}` structs

### Stage-1 — Callisto Compiler in Callisto

Written in Callisto, compiled by Stage-0. Adds the full type system, BOND analysis, SIMD types, drift exhaustiveness checking, zone validation, and CIR generation.

```bash
# Build Stage-1 using Stage-0
./cal0 stage1/compiler.cal -o cal1
```

### Stage-2 — Self-Hosting

Stage-1 compiles itself. After this point there is zero dependency on any other language or tool except a linker.

```bash
# Self-hosting verification
./cal1 stage1/compiler.cal -o cal1_check
diff cal1 cal1_check && echo "Bootstrap OK"
```

---

## 14. Roadmap

| Version | Goal |
|---------|------|
| v0.1 — Now | Language specification complete. This document. |
| v0.2 | Stage-0: NASM lexer, parser, ELF generator. First programs compile. |
| v0.3 | Stage-1: Full type system, BOND analysis, CIR, register allocator. |
| v0.4 | x86-64 ELF backend. First bare metal program boots. SIMD support. |
| v0.5 | Self-hosting: Stage-1 compiles itself. Zero C dependency. |
| v0.6 | Linux kernel module support. `no_std` mode. GENESIS linker v1. |
| v0.7 | ARM64 backend. TRACE mode. Per-CPU variables. Atomic test suite. |
| v1.0 | Stable specification. Full toolchain. Linux kernel PR ready. |

---

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for how to contribute.

The most valuable contributions right now:

- Stage-0 lexer implementation (`stage0/lexer/lexer.asm`)
- Stage-0 ELF writer implementation (`stage0/elf/elf_writer.asm`)
- Test cases (`tests/stage0/`)
- Documentation improvements (`docs/`)

---

## License

GNU General Public License v2.0

See [LICENSE](../LICENSE) for full terms.

---

*AGC — ASM'den filizlenir, kernele uzanır.*
