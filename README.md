# Nestra

[![CI](https://github.com/dip-develop/nestra/actions/workflows/ci.yml/badge.svg)](https://github.com/dip-develop/nestra/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Changelog](https://img.shields.io/badge/Changelog-Keep%20a%20Changelog-blue)](CHANGELOG.md)
[![Code of Conduct](https://img.shields.io/badge/Code%20of%20Conduct-Contributor%20Covenant-lightgrey)](CODE_OF_CONDUCT.md)
[![Dependabot](https://img.shields.io/badge/Dependabot-enabled-brightgreen.svg)](.github/dependabot.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg)](CONTRIBUTING.md)

Nestra is an upcoming cross‑platform desktop application that lets you run web apps (PWA / regular web pages) as if they were native desktop applications. Think of having first‑class, isolated, launchable “apps” for services that don’t ship official Linux (or desktop) clients—such as WhatsApp or Microsoft Teams—while keeping a single lightweight core.

> Status: Early design / pre‑alpha. Core implementation is in progress. Community feedback, ideas, and early contributions are welcome.

## Vision

Provide a unified launcher and runtime that:
* Registers multiple web apps ("Nestra apps") with distinct names, icons, notification preferences, and window behaviors.
* Offers both a multi‑app hub (launch Nestra with no arguments) and single‑app direct launch (`nestra --app <id>`), behaving like a real native app window.
* Delivers native desktop affordances: tray icon, system notifications, auto‑launch, per‑app cache control, offline mode (future), basic theming, and controlled reload.
* Makes adding a new app as simple as providing a URL and optional metadata.

## High‑Level Features (Planned)

| Area | Planned Capabilities |
|------|----------------------|
| App Registry | Create, edit, remove web app entries with ID, name, URL, icon, category, tags. |
| Launch Modes | Hub UI listing all apps OR direct single‑app window via CLI flag. |
| Web Engine | Embedded WebView (Flutter webview / platform view abstraction). |
| Isolation | Per‑app cookies/cache (configurable); quick “Clear cache” action. |
| Reload | Manual reload + optional auto‑reload on network regain. |
| Tray Integration | Global tray with quick app switch, reload, mute notifications, quit. |
| Notifications | Native system notifications; future hook to intercept / enhance push (subject to platform limitations). |
| Auto‑Start | Optional enable at OS login (Linux systemd / autostart, Windows Registry/Startup, macOS LaunchAgent). |
| Theming | Light/dark mode + follow system. |
| Shortcuts | Generate desktop/menu launcher entries per app. |
| Security | Content sandboxing defaults, configurable permission prompts (camera / mic / notifications). |
| Updates | Auto‑update channel (future) + change log surfacing. |
| Extensibility | Plugin API (exploration phase). |

## Quick Start (Developer Preview)

Prerequisites (Linux example):
```bash
sudo apt-get update
sudo apt-get install -y libayatana-appindicator3-dev libnotify-dev
```

Clone and run (Flutter stable recommended):
```bash
git clone https://github.com/dip-develop/nestra.git
cd nestra
flutter pub get
flutter run -d linux   # or windows / macos when enabled
```

> Until feature implementation lands, the app will run as a minimal Flutter shell.

## Command Line (Design Draft)

```
nestra                      # Open hub (list of registered apps)
nestra --app <id>           # Launch a specific app in standalone window
nestra --register <url> \
			 --name "My Chat" \
			 --icon /path/icon.png
nestra --list               # Output registered app metadata (JSON)
nestra --clear-cache <id>   # Wipe cache/storage for one app
nestra --reset              # Factory reset (after confirmation)
```

## Configuration (Planned)
* Config file: `~/.config/nestra/config.json` (platform‑appropriate path abstraction) containing global settings.
* App definitions: `~/.config/nestra/apps/*.json` one file per app.
* Icons cached under: `~/.cache/nestra/icons/`.
* Environment overrides (example):
	* `NESTRA_DATA_DIR=/custom/path`
	* `NESTRA_LOG_LEVEL=debug`

## Architecture Overview (Work in Progress)
Clean Architecture + SOLID:
* Presentation: Flutter widgets + BLoC (state management) + localization (ARB, Flutter gen-l10n).
* Application / Use Cases: Stateless interactors encapsulating business actions (register app, list apps, etc.).
* Domain: Entities (AppDefinition), value objects, repository abstractions.
* Infrastructure: Repository implementations (currently in-memory), future JSON/SQLite persistence & platform services.
* Core: Dependency injection (get_it + injectable), configuration, logging.
* Platform Integration: WebView wrapper, tray, auto-start, notifications via thin, swappable adapters.

Dependency Injection: `GetIt` container initialized early (codegen with `injectable` planned; manual bootstrap pre‑alpha).

State Management: `flutter_bloc` for unidirectional data flow & testability.

Localization: ARB files in `lib/l10n/` (English default). Add new language by creating `app_<locale>.arb`.

## Roadmap
See `ROADMAP.md` for a living roadmap with milestones.

## Contributing
We welcome contributions of all kinds: code, design feedback, docs, issue triage, localization, and testing. Please read `CONTRIBUTING.md` for detailed guidelines (branch strategy, commit conventions, PR review process) and `CODE_OF_CONDUCT.md` for community standards.

Quick checklist:
1. Open (or find) an issue describing the change.
2. Fork → create a feature branch (`feat/short-name`).
3. Keep commits atomic; follow conventional commits style (`feat: add tray mute toggle`).
4. Add/update docs as needed.
5. Ensure formatting & static analysis pass (`flutter format`, `dart analyze`).
6. Open a PR; link the issue; fill out the PR template.

## Security
If you discover a vulnerability or privacy concern, DO NOT open a public issue. Instead, follow the instructions in `SECURITY.md` to report it responsibly.

## Governance
Project stewardship is led by DIP Dev. See `GOVERNANCE.md` for roles (Maintainers, Contributors) and decision process.

## Licensing
This project is released under the MIT License (see `LICENSE`). You are free to use it in commercial and open source projects, with attribution & license inclusion.

## Trademark & Third‑Party Notice
“WhatsApp”, “Microsoft Teams”, and all other third‑party product names, logos, and brands are property of their respective owners. Nestra is an independent project and is not affiliated with, endorsed by, or sponsored by those parties.

## Why Another Wrapper Tool?
Existing solutions often either (a) focus on a single app, (b) are electron‑heavy, or (c) don’t cleanly separate multiple web apps with lightweight isolation. Nestra aims for a clean architecture, low overhead, and a straightforward UX for managing many apps at once.

## FAQ (Early Draft)
**Q: Will it support mobile?** No—desktop focus only.
**Q: Will it intercept proprietary push notifications?** Only within platform & legal constraints; many web push flows rely on service workers which we’ll integrate via the underlying WebView where available.
**Q: Can I export/import my app list?** Planned via JSON bundle.
**Q: Offline mode?** Future: optional caching / manifest packaging per app.

## Development
Formatting & Lints:
```bash
dart format .
dart analyze
```

Run tests:
```bash
flutter test
```

Generate localization (usually automatic on build):
```bash
flutter gen-l10n
```

DI code generation (future when annotations introduced):
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Community & Feedback
* Issues: Feature requests, bugs, questions.
* Discussions (future): Architecture debates, plugin ideas, UX sketches.
* Roadmap proposals: Open an issue tagged `proposal`.

## Attribution
Copyright (c) 2025 DIP Dev.

## Citation
If you reference Nestra in academic or technical material, see `CITATION.cff`.

---
Made with care by DIP Dev and the community. Contributions welcome!