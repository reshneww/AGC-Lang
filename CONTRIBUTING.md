# Contributing to Callisto

## Kurallar

1. Kod yazmadan önce issue aç, ne yapacağını anlat
2. Her commit mesajı ne yaptığını açıklamalı
3. Yeni özellik eklemeden önce spec/ klasörüne yaz
4. Test yaz — çalışmayan kod merge edilmez
5. En önemlisi: yazacağınız her kodda yorum satırı olsun! 


## Görev Dağılımı

| Alan | Sorumlu |
|------|---------|
| Stage-0 ASM | - |
| Dil tasarımı / Spec | - |
| Stage-1 | - |
| Testler | İkisi |

## Commit Formatı

```
[stage0] lexer: token okuma eklendi
[stage1] typechecker: bond analizi başlandı
[spec]   drift semantiği güncellendi
[test]   stage0 lexer testleri eklendi
```

## Branch Yapısı

```
main        — stabil, çalışan kod
stage0-dev  — stage0 geliştirme
stage1-dev  — stage1 geliştirme
```
