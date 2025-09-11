# Nestra Roadmap (Living Document)

This roadmap is an initial directional plan. Priorities may shift based on community feedback and technical findings.

## Phase 0 – Foundation (Current)
* Repository open‑sourcing (docs, license, governance).
* Basic Flutter desktop scaffold builds on Linux/macOS/Windows.
* Domain layer scaffolding for app entity & repository interfaces.

## Phase 1 – Core App Registry & UI
* Create / edit / delete app entries (in‑memory → JSON persistence).
* Basic hub screen listing registered apps.
* Launch single app window via CLI arg.
* Per‑app window title & icon (fallback favicon fetch).

## Phase 2 – Web Runtime & Isolation
* Embed WebView wrapper.
* Distinct cookie/cache containers per app.
* Manual reload button & menu.
* Clear cache action.

## Phase 3 – Desktop Integration
* System tray (switch apps, quit, reload current, toggle notifications).
* Auto‑start on login (Linux, Windows, macOS).
* Native notifications bridge (initial: simple forwarding).

## Phase 4 – UX & Reliability
* Error states (offline, load failed retries).
* Settings panel (global + per app preferences).
* Theme (light/dark/system) & icon theming.
* Export/import app definitions.

## Phase 5 – Advanced Enhancements
* Optional offline cache mode.
* Plugin API (exploratory).
* Update channel & in‑app changelog.
* Accessibility audits & improvements.

## Phase 6 – Hardening
* Threat modeling & security review.
* Sandboxing improvements / permission dialogs.
* Performance & memory profiling.

## Phase 7 – Pre‑Release
* Beta milestone; define stability guarantees.
* Website / landing page.
* Packaged builds for distros / winget / brew.

## Stretch Ideas
* Workspace/app grouping & search.
* Multi‑profile containers.
* Scripting hooks (launch events).

Contributions that align with or thoughtfully amend this roadmap are welcome—open a `proposal` issue to discuss changes.
