# Kapi – Session Context

AI-friendly summary for fast project onboarding in future sessions.

---

## Product identity

- **Visible title**: khallaf Api test
- **Internal name**: Kapi
- **Version**: 1.0.0
- **Platform**: Windows desktop Flutter only

## Purpose

A focused, single-screen API testing desktop tool for developers. It tests HTTP endpoints
with support for all common auth types, headers, query/path params, body types, and provides
structured error interpretation rather than raw exception messages.

## Theme

- Background: near-pure black (#080808)
- Primary accent: green (#4CAF50, bright #69F0AE)
- Error: red (#EF5350), Warning: amber (#FF8F00), Info: blue (#42A5F5)
- All colors are in `lib/core/theme/app_colors.dart`
- ThemeData is in `lib/core/theme/app_theme.dart`

## Architecture

- State: Provider + ChangeNotifier (`ApiTesterNotifier`, `PresetNotifier`)
- Data flow: UI → Notifier → RequestTraceBuilder (trace) → RequestExecutor → ErrorInterpreter / ResponseParser → Notifier → UI
- Sealed class for request lifecycle: IdleState / LoadingState / SuccessState / FailureState / ValidationErrorState
- No external state management packages beyond `provider`

## Key packages

- `http: ^1.2.2` — HTTP requests
- `provider: ^6.1.2` — State management
- No additional packages — persistence and export use `dart:io` + `dart:convert` (stdlib)

## Error system

Every error shown to the user has 4 structured fields:
1. `technical` — exception name or HTTP status code
2. `meaning` — plain English what happened
3. `likelyCause` — most probable root cause
4. `nextStep` — concrete developer action

Mapping happens in `lib/features/api_tester/data/error_interpreter.dart`.

## Request fidelity

Kapi guarantees wire-level correctness by:

1. **Body encoding**: Form fields are encoded via `Uri.encodeQueryComponent` and set directly
   via `request.body`, never via `request.bodyFields`. This avoids a `StateError` thrown
   by the http package when Content-Type is pre-set to a non-form value.

2. **Header order**: Auth → Body Content-Type → Custom headers.
   Custom `Content-Type` headers are dropped when body type is not None, so the
   wire-format Content-Type always matches the selected body type.

3. **Trimming**: All custom header keys and values are `.trim()`-ed before sending.

4. **RequestTrace**: Built before each send by `RequestTraceBuilder.build(request)`.
   Captures final URL, sent headers, encoded body, and a cURL command. Stored in
   `ApiTesterNotifier.lastTrace` and shown in `RequestTracePanel`.

5. **Copy as cURL**: Every result panel has a "Copy as cURL" button that produces a
   `curl.exe` command reproducing the exact request.

## Report export

After any successful or failed request, the user can:
1. Enter optional notes in the Notes field at the bottom of the response panel.
2. Click **Export** to generate a self-contained HTML report.
3. The report is saved to `%USERPROFILE%\Documents\Kapi Reports\`.
4. A snackbar confirms the save path.

Report format: **HTML** — no dependencies, opens in any browser, suitable for sharing
with QA or backend teams. The footer reads: `Kapi - Made by Mohamed Khallaf 2026`.

## Draft persistence

The last request configuration is automatically saved to disk and restored on the next launch.

- **Draft model**: `lib/features/api_tester/domain/models/request_draft.dart`
- **Storage**: `lib/features/api_tester/data/draft_storage.dart`
- **File location**: `%APPDATA%\Kapi\draft.json`
- **Save trigger**: debounced 500 ms after any form change
- **Restore trigger**: async at notifier construction, before first frame
- **Reset behavior**: cancels pending save, clears lastTrace, and deletes the draft file

### What is persisted
- HTTP method, base URL, endpoint
- Auth type and all auth field values (username, password, token, API key name/value, placement)
- All header rows (key, value, enabled state)
- All query parameter rows
- All path parameter rows
- Body type and raw JSON body content
- All form field rows (for form-urlencoded and form-data body types)

### What is intentionally NOT persisted
- Response data (status, body, headers, timing)
- Error panel state
- Loading state
- JSON validation errors
- In-flight request state
- RequestTrace (rebuilt on each send)
- Export notes (per-test, transient)

## Screen layout

```
[ AppHeader (title + badge + PresetMenuButton + version + shortcut hint) ]
[ RequestPanel (460px fixed) | VerticalDivider | ResponsePanel (expanded) ]
  └─ UrlInputRow (method + base URL + endpoint)
  └─ SectionCard: AUTHENTICATION (auth type chips + conditional fields)
  └─ SectionCard: HEADERS (KVTable with multi-select)
  └─ SectionCard: QUERY PARAMETERS (KVTable with multi-select)
  └─ SectionCard: PATH PARAMETERS (KVTable with multi-select)
  └─ SectionCard: BODY (body type chips + JSON editor / form fields)
  └─ ActionButtons (Send + Reset)

Response panel states:
  - Idle: placeholder
  - Loading: spinner
  - ValidationError: warning box
  - Success: StatusBar + RequestTracePanel (collapsed) + InlineStatusError? + Tabs (BODY/HEADERS) + ExportSection
  - Failure: ErrorPanel + RequestTracePanel + ExportSection
```

## Completed features

- Full request builder: method, base URL, endpoint, auth (none/basic/bearer/apiKey), headers, query params, path params, body (none/JSON/form-urlencoded/form-data)
- Full error interpretation layer: 30+ specific cases for exceptions and HTTP status codes
- Response viewer: status bar with timing/size/copy-URL/copy-all, tabbed body/headers view, JSON formatting, copy actions
- Keyboard shortcut: Ctrl+Enter to send
- Auto-detection of path parameter placeholders from endpoint string
- JSON validation and format-on-demand
- Reset clears all form state, reinitializes KVTable widgets via resetKey, and deletes the draft
- **Last-draft persistence**: automatically saves and restores the full request form state across sessions
- **Custom presets**: save/apply/delete named request configurations (baseUrl + auth + headers)
- **Multi-select KVTable**: per-row select, bulk enable/disable/duplicate/delete
- **Copy actions**: CopyButton widget throughout response viewer; Copy as cURL in RequestTracePanel
- **Request fidelity**: fixed form-body encoding and Content-Type conflict so requests match PowerShell/cURL exactly
- **RequestTracePanel**: shows exact headers, body, URL sent; collapses to save space
- **API test report export**: Notes field + Export button; generates HTML report to Documents\Kapi Reports
- **Guided token flow**: Endpoint type selector (Normal / Token Endpoint / Protected Endpoint), automatic token extraction from responses, auto-injection into protected requests, token status indicator, dynamic send button label

## Token flow

Endpoint classification bar sits between URL row and Authentication section. Three modes:
- **Normal**: standard request, no token handling
- **Token Endpoint**: Kapi extracts and stores the auth token from the response automatically
- **Protected Endpoint**: Kapi injects the stored token as `Authorization: Bearer` automatically

Token extraction searches: `access_token`, `token`, `jwt`, `id_token`, `auth_token`, `bearer_token` (and camelCase variants). Top-level first, then one nesting level deep.

Token status indicator in `EndpointTypeBar` shows: no token / token ready (masked) / token expired.
`TokenCapturePanel` appears in response area after Token Endpoint sends with a one-click CTA to switch to Protected Endpoint mode.
