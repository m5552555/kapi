# Kapi – Project Map

## Purpose
Kapi (khallaf Api test) is a Windows desktop Flutter application for testing HTTP API endpoints.
It is a single-screen tool built with Provider state management and a strict layered architecture.

---

## Top-level structure

```
lib/
  main.dart               Entry point — WidgetsFlutterBinding + runApp
  app.dart                KapiApp — MaterialApp + MultiProvider (ApiTesterNotifier + PresetNotifier)
  core/                   Shared infrastructure (no business logic)
  features/
    api_tester/           The only feature (single-screen product)
docs/                     AI-friendly documentation
test/                     Widget smoke tests
windows/                  Flutter Windows platform runner
```

---

## core/

### core/theme/
| File | Role |
|------|------|
| `app_colors.dart` | Central color palette — all colors referenced here, nowhere else |
| `app_theme.dart` | ThemeData assembly — inputs/dividers/scrollbars/colors |

### core/constants/
| File | Role |
|------|------|
| `app_constants.dart` | Sizing constants, timeout values, product strings |

### core/utils/
| File | Role |
|------|------|
| `url_utils.dart` | URL composition, path-param substitution, URI building, validation |
| `json_utils.dart` | JSON formatting, validation, size/duration formatting |
| `copy_utils.dart` | Centralized clipboard copy with snackbar feedback |
| `request_trace_builder.dart` | Mirrors RequestExecutor logic to compute exact wire-level request for diagnostics |

---

## features/api_tester/

### domain/models/
Immutable data models. No Flutter imports. Pure Dart.

| File | Role |
|------|------|
| `kv_pair.dart` | Key-value-enabled triplet (headers, params, form fields) |
| `auth_config.dart` | Auth type enum + AuthConfig model + validation |
| `api_request.dart` | HttpMethod/BodyType enums + ApiRequest model |
| `api_response.dart` | Parsed HTTP response with timing, headers, body |
| `app_error.dart` | ErrorCategory enum + structured 4-field AppError |
| `request_state.dart` | Sealed class: Idle / Loading / Success / Failure / ValidationError |
| `request_draft.dart` | Serializable snapshot of request form state for cross-session persistence |
| `request_trace.dart` | Immutable snapshot of what was actually sent (URL, headers, body, cURL) |
| `endpoint_type.dart` | Enum classifying request purpose: normal / tokenEndpoint / protectedEndpoint |
| `captured_token.dart` | Immutable model for extracted auth token with metadata (type, source, expiry) |

### data/
Stateless logic classes. All are `abstract final` with static methods.

| File | Role |
|------|------|
| `error_interpreter.dart` | Maps exceptions and HTTP status codes → AppError |
| `response_parser.dart` | Converts http.Response → ApiResponse (JSON detection, formatting) |
| `request_executor.dart` | Builds and sends the HTTP request; re-throws as AppError on failure |
| `draft_storage.dart` | Reads and writes the last request draft as a JSON file on disk |
| `preset_storage.dart` | Reads and writes named presets as a JSON file on disk |
| `report_exporter.dart` | Generates styled HTML API test report; saves to Documents\Kapi Reports |
| `token_extractor.dart` | Parses common token field names from a JSON response (access_token, jwt, etc.) |

### state/
| File | Role |
|------|------|
| `api_tester_notifier.dart` | ChangeNotifier owning all form state, controllers, request lifecycle, token flow, trace, and draft persistence |
| `preset_notifier.dart` | ChangeNotifier managing the list of saved presets |

### presentation/
| File | Role |
|------|------|
| `api_tester_screen.dart` | Single screen: header + left request panel + right response panel |

### widgets/shared/
| File | Role |
|------|------|
| `kapi_text_field.dart` | Styled TextField with Kapi dark theme |
| `section_card.dart` | Collapsible section container with header |
| `copy_button.dart` | Reusable icon/label button that copies text with snackbar feedback |

### widgets/app_header.dart
Top bar with product title, badge, version, PresetMenuButton, and keyboard shortcut hint.

### widgets/presets/
| File | Role |
|------|------|
| `preset_menu.dart` | PresetMenuButton + dialog for saving, applying, and deleting presets |

### widgets/request_builder/
| File | Role |
|------|------|
| `method_selector.dart` | HTTP method popup with color-coded labels |
| `url_input_row.dart` | Method + Base URL + Endpoint + composed URL preview |
| `endpoint_type_bar.dart` | Endpoint type selector chips + token status indicator |
| `auth_section.dart` | Auth type chips + conditional auth fields |
| `kv_table.dart` | Reusable enabled/key/value/delete row table with multi-select bulk actions |
| `body_section.dart` | Body type chips + JSON editor + form fields editor |
| `action_buttons.dart` | Send + Reset fixed action bar |

### widgets/response_viewer/
| File | Role |
|------|------|
| `status_bar.dart` | Status code badge, message, timing, size, Copy URL, Copy All response |
| `error_panel.dart` | Full error display (ErrorPanel) + inline 4xx/5xx interpretation |
| `response_body_view.dart` | Formatted/raw body switcher with CopyButton |
| `response_panel.dart` | State-switching root: idle / loading / success / failure + ExportSection |
| `request_trace_panel.dart` | Collapsible panel showing sent headers, body, and Copy as cURL |
| `token_capture_panel.dart` | Shows token extraction result after Token Endpoint sends (success or failure) |
| `export_section.dart` | Notes input + Export button rendered below every result |

---

## Token flow subsystem

### Where it lives
```
domain/models/endpoint_type.dart         — enum: normal / tokenEndpoint / protectedEndpoint
domain/models/captured_token.dart        — immutable token model (value, type, source, expiry)
data/token_extractor.dart                — parses JSON response for common token field names
state/api_tester_notifier.dart           — owns _endpointType, _capturedToken; auto-injects
widgets/request_builder/endpoint_type_bar.dart — type selector chips + token status indicator
widgets/response_viewer/token_capture_panel.dart — shows capture result after token endpoint sends
widgets/request_builder/action_buttons.dart     — dynamic send label (Send / Get Token / Send Protected)
```

### How the guided flow works
1. User selects **Token Endpoint** in the `EndpointTypeBar` and fills in the login endpoint.
2. Send button shows **"Get Token"**. On success, `TokenExtractor.extract()` searches the JSON response body for `access_token`, `accessToken`, `token`, `jwt`, `id_token`, `idToken`, `auth_token`, `authToken`, `bearer_token`, `bearerToken` (top-level first, then one level of nesting).
3. If a token field is found, `CapturedToken` is stored in the notifier. `TokenCapturePanel` appears in the response area with masked value, copy action, and a one-click CTA to switch to Protected Endpoint mode.
4. User switches to **Protected Endpoint** (via the CTA or the type selector). The token status indicator turns green.
5. Send button shows **"Send Protected"**. `_buildAuthConfig()` in the notifier automatically injects `Authorization: Bearer <token>` without any user action.
6. The token injection is transparent in the `RequestTrace` — the sent `Authorization` header is visible in `RequestTracePanel`.

### Token injection logic
In `ApiTesterNotifier._buildAuthConfig()`:
- Condition: `endpointType == protectedEndpoint && capturedToken != null && authType == none`
- Returns `AuthConfig(type: bearerToken, token: capturedToken.value)`
- If the user has configured manual auth (`authType != none`), manual auth takes precedence.

### Validation
- Sending a Protected Endpoint request when `capturedToken == null && authType == none` is blocked with:
  `"No token available yet. Run a Token Endpoint request first to get your login token, then come back here."`

---

## Request fidelity subsystem

### Where it lives
```
core/utils/request_trace_builder.dart     — mirrors executor logic; builds RequestTrace
domain/models/request_trace.dart          — immutable wire-level snapshot
data/request_executor.dart                — sends request; fixes Content-Type ordering
state/api_tester_notifier.dart            — builds and stores lastTrace before each send
widgets/response_viewer/request_trace_panel.dart — displays trace; Copy as cURL
```

### How request fidelity is guaranteed
1. `_applyBody` encodes form fields manually (`request.body = encoded`) instead of using
   `request.bodyFields`, eliminating the `StateError` thrown when Content-Type is pre-set.
2. Header application order: auth → body Content-Type → custom headers (Content-Type filtered).
3. Custom headers with key `content-type` are silently dropped when body type is not None.
4. All custom header keys and values are `.trim()`-ed before sending.
5. `RequestTraceBuilder.build(request)` mirrors the executor logic exactly, producing a
   `RequestTrace` with the final URL, resolved headers, encoded body, and cURL command.
6. The trace is built in `sendRequest()` before the executor runs, so it is always available
   even on connection failures.

### Content-Type conflict resolution
Priority (highest to lowest):
1. Body type's Content-Type (set by `_applyBody`)
2. Custom user headers (everything except Content-Type when body is active)
3. Auth headers (Authorization / custom key header)

---

## Report export subsystem

### Where it lives
```
data/report_exporter.dart                 — HTML generation + file I/O
widgets/response_viewer/export_section.dart — Notes TextField + Export button
```

### How export works
1. `ExportSection` widget reads `lastTrace` and `requestState` from `ApiTesterNotifier` via Provider.
2. On Export tap, calls `ReportExporter.export(trace, state, notes, endpoint, baseUrl)`.
3. `ReportExporter` generates a self-contained dark-themed HTML file.
4. File is saved to `%USERPROFILE%\Documents\Kapi Reports\kapi_report_{endpoint}_{timestamp}.html`.
5. A snackbar shows the saved path (or failure message) after write completes.
6. The HTML file is self-contained — no external assets — and opens in any browser.

### Report sections
A. Report title  
B. API identity (URL, method, timestamp)  
C. Request headers sent  
D. Request body (type + payload)  
E. Response (status, headers, body) or error detail  
F. Test details (duration, outcome, body encoding)  
G. Tester notes  
H. Footer: `Kapi - Made by Mohamed Khallaf 2026`

---

## Draft persistence subsystem

### Where it lives
```
domain/models/request_draft.dart   — serializable model (pure Dart)
data/draft_storage.dart            — file I/O using dart:io + dart:convert
state/api_tester_notifier.dart     — orchestrates load/save/restore lifecycle
```

### How it works
1. The notifier constructor calls `_attachSaveListeners()` and then `_loadAndRestoreDraft()` (async, fire-and-forget).
2. `_loadAndRestoreDraft` reads `%APPDATA%\Kapi\draft.json` via `DraftStorage.load()`.
3. If a valid draft exists, `_applyDraft()` restores all controllers and enum values under `_isRestoring = true`, then bumps `_resetKey` to force KVTable widget recreation.
4. After restoration, `notifyListeners()` triggers a full UI rebuild with the restored state.
5. Every subsequent user change calls `_scheduleSave()`, which debounces a `DraftStorage.save()` call by 500 ms.
6. On reset, any pending save is cancelled and `DraftStorage.clear()` removes the file.

### Draft file location
`%APPDATA%\Kapi\draft.json` — e.g. `C:\Users\username\AppData\Roaming\Kapi\draft.json`

---

## Architectural boundaries

- **domain/models** — pure Dart, no Flutter, no http package
- **data** — pure logic, depends only on dart:io/http/domain
- **state** — depends on data + domain; notifies UI
- **widgets** — depend only on state + domain models; never call data directly
- Colors live exclusively in `app_colors.dart`
- No hardcoded colors or sizes in widget files
- No persistence logic in any widget file
