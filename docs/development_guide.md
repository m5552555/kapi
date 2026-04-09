# Kapi – Development Guide

## Coding conventions

- Every Dart file starts with two comment lines: filename + purpose.
- `abstract final` classes for stateless utility/logic (no instantiation).
- Sealed classes for state types (exhaustive pattern matching).
- Enums carry display labels via `.label` getters.
- No direct `Colors.*` usage — always use `AppColors.*`.
- No magic numbers — always use `AppConstants.*`.
- `const` constructors wherever possible.
- `List.unmodifiable()` when exposing internal lists from the notifier.

---

## How to add a new auth type

1. Add a value to `AuthType` enum in `auth_config.dart`.
2. Add a `.label` case to the `label` getter switch.
3. Add validation logic to `AuthConfig.validate()`.
4. Add an `_apply*` case in `request_executor.dart → _applyAuth()`.
5. Mirror the same case in `request_trace_builder.dart → _applyAuth()`.
6. Add a new `_*Fields` widget in `auth_section.dart`.
7. Add a case to the `AnimatedSwitcher` switch in `AuthSection.build()`.
8. Update `api_tester_notifier.dart` if new TextEditingControllers are needed.
9. If new controllers are added, include them in `_allControllers` in the notifier.
10. Add the corresponding fields to `RequestDraft` and update `toJson`/`fromJson`.

---

## How to add a new body type

1. Add a value to `BodyType` enum in `api_request.dart`.
2. Add `.label` and `.contentType` cases.
3. Add a `_applyBody` case in `request_executor.dart`.
4. Mirror the same encoding in `request_trace_builder.dart → _applyBodyContentType()` and `_computeBodyText()`.
5. Add a `_*Editor` widget in `body_section.dart`.
6. Add a case to the `AnimatedSwitcher` switch in `BodySection.build()`.

---

## How to add a new request section

1. Create a new widget file in `widgets/request_builder/`.
2. Wrap it in a `SectionCard` in `api_tester_screen.dart → _RequestPanel`.
3. If it requires persistent state, add the state to `ApiTesterNotifier`.
4. Pass `resetKey` as part of the widget key for reset support.
5. If it requires validation, add a check in `ApiTesterNotifier._validate()`.
6. Include the new state in `_buildDraft()` and `_applyDraft()` in the notifier.
7. Add the corresponding field to `RequestDraft.toJson()` and `RequestDraft.fromJson()`.

---

## How to extend the saved draft safely

The draft schema is versioned (`RequestDraft._schemaVersion`).

**Adding a new field (backwards-compatible):**
1. Add the field to `RequestDraft` constructor, `toJson`, and `fromJson`.
2. In `fromJson`, always use `?? defaultValue` so old saved files without the field still work.
3. No schema version bump needed — the fallback handles it.

**Adding a field that is not backwards-compatible:**
1. Bump `_schemaVersion` in `request_draft.dart`.
2. Update `fromJson` to return null (or migrate) for `version < newVersion`.
3. Users with old drafts will start fresh on next launch — which is correct.

**Adding a new TextEditingController to the notifier:**
1. Create it as a `final` field in `ApiTesterNotifier`.
2. Add it to `_allControllers` — this automatically attaches the save listener and ensures disposal.
3. Add `_applyDraft` restoration and `_buildDraft` capture for it.
4. Add the field to `RequestDraft`.

---

## How to extend the error interpreter

In `error_interpreter.dart`:
- **New exception type**: Add an `if (error is XException)` branch in `fromException()`.
- **New HTTP status**: Add a case to the `switch` in `fromStatusCode()`.
  Use the catch-all `_` clause only as a final fallback.

Error messages must follow the 4-field pattern:
- `technical`: exact code / exception name
- `meaning`: what happened from the user's perspective
- `likelyCause`: most probable reason
- `nextStep`: concrete action the developer should take

---

## How to extend the report

`ReportExporter._buildHtml()` in `data/report_exporter.dart` builds the full HTML string.

To add a new section to the exported report:
1. Add a new `buf.write(...)` block in `_buildHtml()` following the existing pattern.
2. Use `_kv(label, value)` helper for key-value rows.
3. Use `_e(text)` for HTML-escaping any user-supplied content.
4. The report currently saves to `%USERPROFILE%\Documents\Kapi Reports\`.
   To change the directory: update `_reportsDir()` in `ReportExporter`.

---

## How request fidelity works

### The Content-Type conflict bug (now fixed)

The `http.Request.bodyFields` setter in the Dart http package throws a `StateError` if
`Content-Type` is already set to anything other than `application/x-www-form-urlencoded`.

**Before the fix**, custom headers were applied before the body, so if a user had
`Content-Type: application/json` in their headers list and selected Form URL Encoded body,
`bodyFields = fields` would throw — silently turning a valid request into a failure.

**After the fix**, the body is applied using `request.body = encoded` (direct byte assignment)
instead of the `bodyFields` setter, which is unconditional and never throws.

### Header application order (executor and trace builder)

```
1. _applyAuth       → sets Authorization (or custom API key header)
2. _applyBody       → sets Content-Type for the body type; encodes body directly
3. _applyCustomHeaders → applies user headers, BUT skips Content-Type when body is active
```

This order ensures the wire-format Content-Type always matches the selected body type,
regardless of what the user has in their custom headers section.

### Key/value trimming

All custom header keys and values are `.trim()`-ed before being written to `http.Request.headers`.
This prevents invalid headers such as `Accept ` (trailing space) from reaching the server.

### RequestTraceBuilder

`core/utils/request_trace_builder.dart` mirrors the executor's logic without performing I/O.
It is called in `ApiTesterNotifier.sendRequest()` before the executor runs:

```dart
_lastTrace = RequestTraceBuilder.build(request);
```

The trace is always set after validation passes, regardless of whether the subsequent
network call succeeds. This means the trace panel and export always show accurate data
even for failed connections.

### Copy as cURL

`RequestTraceBuilder._buildCurl()` generates a `curl.exe` command string from the resolved
URL, headers, and encoded body. The cURL command appears in `RequestTracePanel` (collapse the
panel to see it) and can be copied via the "Copy as cURL" button in the panel header.

---

## State management pattern

- `ApiTesterNotifier` is the single source of truth for all form state.
- TextEditingControllers are owned by the notifier (not by widgets).
- `_allControllers` is the single list of all controllers — used for listener attachment, removal, and disposal.
- KVTable widgets receive `initial` and `onChanged` — they manage their own row controllers internally.
- `resetKey` is bumped on `reset()` and on draft restoration to force KVTable widgets to reinitialize.
- Pattern matching on `RequestState` in `ResponsePanel` drives what is displayed.
- `lastTrace` is exposed as a getter; widgets read it via `context.watch<ApiTesterNotifier>().lastTrace`.

---

## How preset save/restore works

### Saving a preset
`PresetNotifier.saveFromNotifier(name, notifier)` reads every public field and controller
from the notifier and builds a `Preset` with schema version 2.
All request sections are captured: method, baseUrl, endpoint, endpointType, auth (all fields),
headers, queryParams, pathParams, formFields, bodyType, rawJsonBody.

### Loading a preset (reset-before-load)
`ApiTesterNotifier.loadFromPreset(preset)` is the authoritative restore entry point.

```
loadFromPreset(preset)
  ├─ _saveDebounce?.cancel()           — discard pending save
  ├─ _isRestoring = true               — suppress save listener callbacks
  ├─ (set all text controllers)        — baseUrl, endpoint, auth fields, rawJson
  ├─ (set all enum values)             — method, authType, apiKeyPlacement, bodyType, endpointType
  ├─ (replace all KV lists)            — headers, queryParams, pathParams, formFields
  ├─ (clear lifecycle state)           — IdleState, null trace, null errors
  ├─ _resetKey++                       — forces KVTable widget recreation
  ├─ _isRestoring = false
  ├─ _scheduleSave()                   — persist loaded state as new active draft
  └─ notifyListeners()                 — full UI rebuild from new state
```

`_capturedToken` is NOT cleared on preset load — it is session-level runtime state.

### Backward compatibility
Old v1 presets (no `version` field) are deserialized with safe defaults for all v2 fields.
No crash, no data loss. The preset loads cleanly and picks sensible defaults for any
missing fields.

---

## Draft save/restore lifecycle

```
App open
  └─ ApiTesterNotifier constructor
      ├─ _attachSaveListeners()     — hooks _scheduleSave to all text controllers
      └─ _loadAndRestoreDraft()     — async, reads %APPDATA%\Kapi\draft.json
          └─ _applyDraft(draft)     — sets controllers + enums + lists under _isRestoring=true
              └─ _resetKey++        — forces KVTable recreation via ValueKey
              └─ notifyListeners()  — UI rebuilds with restored state

User edits any field
  └─ _scheduleSave()               — debounced 500 ms
      └─ DraftStorage.save(draft)  — writes JSON to disk

User clicks Reset
  └─ _saveDebounce?.cancel()       — discard pending save
  └─ (clear all form state)
  └─ _lastTrace = null             — clear last trace
  └─ DraftStorage.clear()          — delete draft file
  └─ notifyListeners()
```

---

## Running on Windows

```bash
flutter pub get
flutter run -d windows
```

Or from Android Studio: select the Windows device target and click Run.

Minimum supported: Windows 10 x64.
