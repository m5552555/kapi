<!--
File: .claude/commands/update-claude-md.md
Purpose: Slash command to audit and update CLAUDE.md against recent project changes.
Keywords: claude-code, slash-command, documentation, sync, audit
-->

# Update CLAUDE.md — Audit & Sync

## Role

أنت **Documentation Auditor** للمشروع. مهمتك مراجعة ملف `CLAUDE.md` الموجود في جذر المشروع،
ومقارنته بالحالة الفعلية للكود الحالي، ثم اقتراح تحديثات بدقة جراحية — لا أكثر ولا أقل.

---

## سير العمل (إلزامي)

### الخطوة 1 — قراءة المراجع
اقرأ بالترتيب:
1. `CLAUDE.md` (الجذر) — كاملاً
2. ملفات tree/structure إن وُجدت في `Docs/`
3. `Docs/project_map.md` إن وُجد

### الخطوة 2 — المسح الذكي
افحص فقط هذه المناطق:

| المنطقة | الملفات المرجعية |
|---|---|
| **Routes** | `lib/app/app_router.dart` أو `lib/core/routing/` |
| **API Endpoints** | `lib/core/config/api_config.dart` أو `lib/core/api/` |
| **Permissions** | `lib/core/auth/` أو `lib/core/permissions/` |
| **Theme tokens** | `lib/core/theme/app_theme.dart` |
| **Feature folders** | `lib/features/*/` |
| **Forbidden patterns** | `withOpacity`, `print(`, `setState` بعد `dispose` |

### الخطوة 3 — تقرير الفجوات (Drift Report)

اعرض تقرير بهذا الشكل بالضبط:

```markdown
# CLAUDE.md Drift Report

## مناطق متطابقة (لا تحتاج تحديث)
- [قائمة موجزة]

## مناطق تحتاج تحديث
### 1. [اسم القسم]
**في CLAUDE.md:** [نص مختصر]
**في الكود:** [ما وجدته]
**التحديث المقترح:** [نص محدد]
**الأهمية:** عالية / متوسطة / منخفضة

## مناطق جديدة لم تُوثّق
- [feature أو endpoint جديد]

## مناطق قديمة يجب حذفها
- [feature محذوف لكنه لا يزال في CLAUDE.md]

## الإحصائيات
- إجمالي الأقسام: X
- محدّثة بشكل صحيح: Y
- تحتاج تعديل: Z
- نسبة الدقة: (Y/X) × 100%
```

### الخطوة 4 — انتظار التأكيد

اطرح السؤال حرفياً:
> هل تريد أن أطبّق التحديثات؟
> - **نعم الكل** — طبّق كل التحديثات
> - **نعم محدّد** — حدد بالأرقام (مثل: 1, 3, 5)
> - **لا** — احتفظ بـ CLAUDE.md كما هو

### الخطوة 5 — التطبيق
بعد التأكيد فقط:
1. أعد كتابة `CLAUDE.md` كاملاً
2. حافظ على بنية الأقسام وترقيمها
3. حافظ على نبرة الملف
4. أضف في النهاية:
   > **Last audited:** [التاريخ] — [ملخص في سطر]

---

## قواعد صارمة

1. لا تخترع features غير موجودة
2. لا تحذف قواعد العمل (workflow, communication, code style)
3. لا تغيّر أسلوب الكتابة
4. لا تطبّق قبل التأكيد الصريح
5. لا تعدّل ملفات غير `CLAUDE.md`

---

## معايير الجودة

✅ **يستحق التوثيق:** route جديد، endpoint جديد، feature folder جديد، bug خطير، dependency مهمة
❌ **لا يستحق:** تعديل widget واحد، تغيير لون، helper method صغير، نص في ARB

---

**End of /update-claude-md command**
