# AGENTS.md

Guidance for coding agents working in this repository.

## Project overview

- App: **Vesprium** (iOS game app)
- Main target structure:
  - `Items/` — app source (Scenes, Services, Models, DesignSystem, Resources)
  - `Modules/Models/` — shared model module
  - `ItemsUnitTests/` — unit tests
  - `ItemsSnapshotTests/` — snapshot/UI snapshot tests
  - `ItemsDebugger/` — debug helper target

## Build, lint, and test

Use these commands from repo root:

- Build app:
  - `xcodebuild -scheme Items -configuration Debug build`
- Lint:
  - `swiftlint --fix --strict`

If local environment/simulator availability differs, keep command intent the same and adjust destinations as needed.

## Workspace-specific implementation rules

### 1) Text-only dialogs

For explanatory/help text dialogs, use coordinator + `MainPath.dialog(String)` (card overlay), not SwiftUI `.alert` or `.sheet`.

Pattern:

```swift
coordinator?.custom(overlay: .card, MainPath.dialog(text))
```

If the view does not hold coordinator access, route through the screen ViewModel.

### 2) Item art generation

When asked to add/update item images:

- Create icon-style, cartoony 2D item art with clean dark outline and high readability.
- Output must be square **384x384 PNG** with **real alpha transparency**.
- Post-process generated images to remove checkerboard/solid backgrounds and verify alpha.
- Place output in the correct `.imageset` under:
  - `Items/Resource/Assets.xcassets`
- Run `swiftgen` after asset updates.

## Coding guidelines

- Keep changes minimal and scoped to the request.
- Follow existing naming and scene/view model patterns.
- Avoid broad refactors unless explicitly requested.
- Add concise comments only when logic is non-obvious.
- Prefer deterministic, testable logic in view models/services.

## Safety checks before finishing

- Ensure changed files compile conceptually with existing architecture.
- Run relevant lint/tests for the touched area when possible.
- Keep generated files updated when assets/resources change.

