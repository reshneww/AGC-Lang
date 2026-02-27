# Callisto Language Specification
# Version 3.0 — Stage-0 Subset

## Stage-0'ın Anladığı Sözdizimi

### Fonksiyon Tanımı
```
fn isim(parametre: tip, ...) -> donus_tip {
    ...
}
```

### Değişken
```
let tip isim = deger;
ptr tip isim = adres;
```

### Aritmetik
```
a + b
a - b
a * b
a / b
```

### Akış Kontrolü
```
if kosul { ... }
while kosul { ... }
return deger;
```

### Inline Assembly
```
asm {
    "instruction"
    : cikti
    : girdi
    : clobber
}
```

### Dış Fonksiyon
```
extern sysv64 {
    fn isim(parametre: tip) -> tip;
}
```

### Struct
```
pack Isim {
    alan: tip;
    ...
}
```

## Tipler (Stage-0)

```
u8 u16 u32 u64    — işaretsiz tam sayı
i8 i16 i32 i64    — işaretli tam sayı
ptr T             — pointer
void              — değer yok
```
