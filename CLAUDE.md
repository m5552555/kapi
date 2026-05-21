<!--
File: CLAUDE.md
Purpose: Mandatory context file Claude reads at the start of every session.
Project: Kapi
Created: 2026-05-02
Keywords: flutter, project-rules, workflow, code-style
-->

# CLAUDE.md — Kapi

> **Read this file completely before responding to any prompt.**

---

## 1. Project Identity

- **Name:** Kapi
- **Type:** Flutter project (TODO: specify mobile / web / desktop)
- **Path:** `C:\Users\gra_a\AndroidStudioProjects\Kapi`
- **Purpose:** TODO — اكتب وصف موجز للمشروع

---

## 2. Tech Stack

- **Framework:** Flutter / Dart
- **State Management:** TODO (Riverpod / setState / BLoC / etc.)
- **HTTP:** TODO (Dio / http / etc.)
- **Routing:** TODO (GoRouter / onGenerateRoute / etc.)
- **Storage:** TODO

---

## 3. Mandatory Workflow Rules

### 3.1 Before Any Code Change
1. اطلب الكود الحالي كاملاً قبل أي تعديل
2. خطوة واحدة في كل رد ثم انتظر تأكيدي
3. تحقق من وجود الملف قبل إنشاء جديد

### 3.2 During the Edit
- حل واحد فقط، بدون خيارات متعددة
- لا تكسر السلوك القائم
- لا refactor لكود غير مطلوب

### 3.3 After the Edit
- أعد الملف كاملاً، ليس تعديلاً جزئياً
- انتظر تأكيدي قبل الخطوة التالية

---

## 4. File Structure & Limits

- **Max 200 lines per file** — قسّم الملفات الأكبر
- **File header** (3 lines) في بداية كل ملف:
  ```dart
  // File: <path>
  // Purpose: <description>
  // Keywords: <comma, separated, terms>
  ```

---

## 5. Communication Rules

- **رد بالعربية** دائماً
- سؤال واحد في كل مرة عند الحاجة للتوضيح
- ملف كامل بعد كل تعديل
- لا multiple solutions

---

## 6. Code Style

- Explicit types (no `dynamic` unless necessary)
- Comments in **English only**
- No `print()` — use `debugPrint`
- No TODO comments — implement or remove
- Use `withValues(alpha:)` instead of deprecated `withOpacity()`

---

## 7. TODO — أكمل هذا الملف

هذا قالب مبدئي. أضف الأقسام التالية حسب طبيعة المشروع:
- [ ] Routes Table
- [ ] API Endpoints
- [ ] Theme Tokens
- [ ] Auth & Permissions
- [ ] Known Pitfalls
- [ ] Reference Files

---

**End of CLAUDE.md**
