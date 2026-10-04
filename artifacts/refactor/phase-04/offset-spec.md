# Langfens Loop Engine V2 — Stable Span Offset Specification

## 1. Mục tiêu và Tiêu chuẩn

Mọi text span trong Langfens Loop Engine V2 sử dụng khoảng nửa mở `[startChar, endChar)` tính theo **Unicode code point** trên nội dung đã qua chuẩn hóa NFKC.

### Bất biến cốt lõi (Core Invariant)
```
normalized_text[startChar:endChar] == span.text
```
Bất biến này phải thỏa mãn 100% trên cả hai môi trường runtime: Python 3 và .NET 10.

---

## 2. Quy ước Cross-Language (Python ↔ .NET)

### 2.1. Bản chất String Indexing giữa hai ngôn ngữ

| Thuộc tính | Python 3 (`str`) | .NET 10 (`System.String`) | UTF-8 Byte Stream |
|---|---|---|---|
| **Đơn vị chỉ mục (Index Unit)** | **Unicode code point** (1..N) | **UTF-16 code unit** (16-bit `char`) | Byte (8-bit octet) |
| **Ký tự Basic Multilingual Plane (BMP)** (U+0000..U+FFFF) | 1 code point | 1 `char` | 1..3 bytes |
| **Ký tự ngoài BMP (Emojis, CJK mở rộng)** (U+10000..U+10FFFF) | **1 code point** | **2 `char`s (Surrogate Pair)** | 4 bytes |
| **Dấu thanh / Combining diacritics** (e.g. Vietnamese) | Chuẩn hóa NFKC thành precomposed char (1 cp) | Chuẩn hóa NFKC thành precomposed char (1 `char`) | 2..3 bytes |

### 2.2. Quy tắc chuyển đổi (Offset Conversion Rules)

1. **Canonical Storage:** Mọi offset lưu trong `SourceOffset` (`startChar`, `endChar`) được định nghĩa là **Unicode code point offset**.
2. **Khi chuyển đổi sang .NET:** Sử dụng helper `UnicodeOffsetHelper.CodePointToUtf16Offset(text, cpOffset)` để tính toán chỉ mục `char` trong C#.
3. **Khi chuyển đổi từ .NET về Python:** Sử dụng `UnicodeOffsetHelper.Utf16ToCodePointOffset(text, utf16Offset)`.
4. **Idempotency:** Chuẩn hóa hai lần liên tiếp `clean(clean(text))` phải trả về chuỗi giống hệt nhau (`clean(clean(text)) == clean(text)`).

---

## 3. Triển khai tham chiếu (Reference Implementations)

### Python Reference
```python
def codepoint_to_utf16_offset(text: str, cp_offset: int) -> int:
    sub = text[:cp_offset]
    return sum(2 if ord(ch) > 0xFFFF else 1 for ch in sub)

def utf16_to_codepoint_offset(text: str, u16_offset: int) -> int:
    current_u16 = 0
    for cp_idx, ch in enumerate(text):
        if current_u16 >= u16_offset:
            return cp_idx
        current_u16 += 2 if ord(ch) > 0xFFFF else 1
    return len(text)
```

### C# Reference (.NET)
```csharp
public static int CodePointToUtf16Offset(string text, int codePointOffset)
{
    if (string.IsNullOrEmpty(text) || codePointOffset <= 0) return 0;
    int currentCp = 0;
    int utf16Index = 0;
    while (utf16Index < text.Length && currentCp < codePointOffset)
    {
        utf16Index += char.IsSurrogatePair(text, utf16Index) ? 2 : 1;
        currentCp++;
    }
    return utf16Index;
}
```

---

## 4. Context Selection và Coverage Map

1. Khi chia nguồn thành các chunks (e.g. 350 từ/chunk, 50 từ overlap), mỗi chunk lưu `startChar`, `endChar` và danh sách `spanIds`.
2. `CoverageMap` ghi lại các khoảng ký tự `covered_ranges: list[tuple[int, int]]`.
3. Một claim chỉ được coi là hợp lệ nếu toàn bộ khoảng `[startChar, endChar)` nằm trọn trong `covered_ranges`.
4. Excerpt **không bao giờ** được coi là toàn nguồn (`is_excerpt == True` nếu có bất kỳ chunk nào không được chọn).
