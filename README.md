# ItemTracker

A SwiftUI app that helps users track item locations using natural language. Store notes like *"Kept toilet papers in 2nd row in storage area"* and query them with questions like *"Where are tissues?"*

## Requirements

- Xcode 16.0+
- iOS 26.0+
- Swift 5.0+

## Getting Started

```bash
git clone <repo-url>
cd ItemTracker
git config core.hooksPath githooks
```

Open `ItemTracker.xcodeproj` in Xcode and run.

## Git Hooks

Pre-push hooks for SwiftLint and SwiftFormat are committed in `githooks/`. Activate them once after cloning:

```bash
git config core.hooksPath githooks
```

On every `git push` the hook will:
1. Run SwiftFormat in lint mode — fails if formatting issues are found
2. Run SwiftLint — fails on errors

To fix formatting before pushing:
```bash
swiftformat .
```

Both tools must be installed via Homebrew:
```bash
brew install swiftlint swiftformat
```

## Building & Testing

```bash
# Build
xcodebuild -project ItemTracker.xcodeproj -scheme ItemTracker -sdk iphonesimulator build

# Test
xcodebuild -project ItemTracker.xcodeproj -scheme ItemTracker -sdk iphonesimulator test
```

## CI/CD

Xcode Cloud is configured to trigger on pushes to `main`:

1. **Build** — verifies compilation
2. **Test** — runs unit and UI tests
3. **Archive** — creates a release build
4. **TestFlight** — distributes to internal testers automatically

TestFlight release notes are generated automatically from the last 20 git commit messages via `ci_scripts/ci_pre_xcodebuild.sh`.

## Architecture

MVVM with a repository pattern. ViewModels interact with repositories as the single source of truth.

- **SwiftUI** — declarative UI
- **SwiftData** — persistence
- **FoundationModels** — on-device AI for natural language queries (Apple Intelligence)
- **Swift Async/Await** — concurrency with `@MainActor` isolation
- **SwiftTesting** — unit tests

### Key Components

| File | Role |
|---|---|
| `ContentView.swift` | Main UI — query and tag content |
| `Reasoning/ReasoningBrain.swift` | AI integration via `LanguageModelSession` |
| `ItemTag.swift` | `@Generable` structured output with `@Guide` decorators |
