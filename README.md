# Kapi

A clean Windows desktop API testing tool built with Flutter.
Test HTTP endpoints with auth flows, save reusable presets, and export test reports.

## Features

- HTTP request builder (GET/POST/PUT/PATCH/DELETE) with headers, query params, path params, and body
- Multiple auth types: Basic, Bearer Token, API Key (header or query)
- Guided token flow: capture a token from a Token Endpoint and auto-inject it into Protected Endpoints
- Named presets — save, load, edit, and delete full request snapshots
- Auto-saved draft — never lose your work between sessions
- Wire-level request trace with Copy as cURL
- Styled HTML report export to `%USERPROFILE%\Documents\Kapi Reports\`

## Tech Stack

- Flutter (Windows Desktop)
- Provider for state management
- `http` package
- Local storage via JSON files in `%APPDATA%\Kapi\`

## Run

```bash
flutter pub get
flutter run -d windows
```

Minimum: Windows 10 x64.

## License

MIT
