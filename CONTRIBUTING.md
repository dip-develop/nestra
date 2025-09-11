# Contributing to Nestra

Thanks for your interest in contributing! Nestra is in an early stage—thoughtful design discussion and well‑scoped PRs are especially valuable now.

## Ways to Contribute
* Report bugs (clear reproduction steps, expected vs actual behavior).
* Propose features (describe problem first; don’t jump straight to solution).
* Improve documentation (clarity, examples, architecture notes).
* Implement issues labeled `help wanted` or `good first issue`.
* Performance, accessibility, or UX polish.

## Development Setup
1. Install Flutter (stable channel) & platform toolchains.
2. Install required desktop deps (Linux example):
   ```bash
   sudo apt-get install -y libayatana-appindicator3-dev libnotify-dev
   ```
3. Clone & bootstrap:
   ```bash
   git clone https://github.com/dip-develop/nestra.git
   cd nestra
   flutter pub get
   flutter run -d linux
   ```

## Branching Strategy
* `main`: Always releasable (may be pre‑alpha but should build).
* Feature branches: `feat/<slug>`.
* Fix branches: `fix/<slug>`.
* Docs only: `docs/<topic>`.

## Commit Convention (Conventional Commits)
```
<type>(optional scope): <short summary>

types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
```
Examples:
* `feat: add per-app cache clearing`
* `fix(webview): handle load failure event`

## Pull Requests
Checklist before opening a PR:
* Linked issue (if applicable) in the description.
* Clear title using conventional commits.
* Tests added/updated (when logic introduced).
* `dart analyze` passes.
* No unrelated formatting churn.
* Updated README / docs if behavior is user‑visible.

## Code Style
* Follow Dart & Flutter default formatting (`dart format .`).
* Prefer small, composable widgets & pure domain logic.
* Keep platform integrations modular.

## Testing (Planned)
We will introduce layers of testing:
* Unit: domain/use cases.
* Widget: UI states.
* Integration: launching apps, persistence.

## Architecture Guidelines
* Clean separation: presentation / domain / data.
* Entities are immutable.
* Use dependency inversion for platform services.
* Keep WebView wrapper behind an interface for testability.

## Issue Labels (Draft)
| Label | Meaning |
|-------|---------|
| `good first issue` | Low complexity task to onboard new contributors. |
| `help wanted` | Core team requests community assistance. |
| `discussion` | Needs design / tradeoff conversation. |
| `blocked` | Waiting on dependency or decision. |
| `security` | Security related (handled privately if sensitive). |
| `platform:<name>` | Platform‑specific work. |
| `type:feature` | Adds a new capability. |
| `type:bug` | Bug fix. |
| `type:docs` | Documentation only. |

## Design Proposals
For larger features create an issue with label `proposal` including:
* Problem statement
* Goals / non‑goals
* Architecture sketch
* Data model impacts
* Migration / rollout plan

## Release Process (Future)
1. Merge features to `main`.
2. Update CHANGELOG (automated planned).
3. Tag `vX.Y.Z`.
4. Build & publish desktop artifacts.

## Communication
* GitHub Issues: bugs, tasks, proposals.
* (Future) Discussions: open Q&A, design threads.

## License
By contributing you agree your work is licensed under the MIT License of the repository.

Happy hacking!
