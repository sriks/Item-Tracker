# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is this app about ?

ItemTracker is a SwiftUI app that helps users track item locations using natural language. Users store notes like "Kept toilet papers in 2nd row in storage area" and query them with questions like "Where are tissues?"

## Flows

Add content flow: User opens app and adds content which is stored in swift data.
Query content flow: User can type in a query and see the result in the same UI. This is the landing page.

Only 3 tabs - home / items / settings

## Build & Run

This is an Xcode project with no external dependencies. Open `ItemTracker.xcodeproj` in Xcode 16.0+ and build/run from there.

```bash
# Build from command line
xcodebuild -project ItemTracker.xcodeproj -scheme ItemTracker -sdk iphonesimulator build

# Run tests
xcodebuild -project ItemTracker.xcodeproj -scheme ItemTracker -sdk iphonesimulator test
```

**Requirements**: iOS 26.0+, Xcode 16.0+

## Architecture

- Under the hood it uses Apple's Foundation Models framework to run a prompt on user's saved content. The content is persisted using SwiftData.
- Uses MVVM architecture and clear speration of concern so we can write tests efficiently.
- Repository pattern as the gateway to data. Viewmodels interact with Repository as the single source of truth.
- Uses SwiftData to persist user content.
- Uses Observation frameworks for UI state changes only.
- Uses async-await pattern and swift async algorithms. (Try not to use combine framework!)
- Uses SwiftTesting for unit tests
- Uses xcode localisation for user visible strings.
- Uses SF Symbols for icons where applicable

## Repositories

- A repository acts as a gateway to data and a single source of truth.
- It interacts with the underlying persistence storage and handles any cache.
- The call sites such as viewmodel are not aware of these internal details.
- Since this is the gateway to data, it should adher to capability protocols so that the callsite will inject only the required protocol capability. As applicable we shouls apply interface segregation.

## Testing

- Use SwiftTesting to create legible tests

## Dependencies

- App level dependencies - which all modules need are created as dependencycontainer at App and injected.
- All dependencies should be injected as constructor dependencies.

### Key Components

- **ContentView.swift** - Main UI with "Ask" (query items) and "Tag Content" (process inputs) buttons
- **Reasoning/ReasoningBrain.swift** - Core AI integration using Apple's FoundationModels framework:
  - `ReasoningBrain` - Searches item locations via `LanguageModelSession`
  - `ContentTaggingBrain` - Tags content with structured metadata, handles guardrail violations with reframing
  - `ItemTag` (@Generable struct) - Structured output with @Guide decorators
- **Stubs** - Helperss and json to test the prompts quickly.

### Data Flow

```
inputs.json → JSONInputs (decode) → Helpers.prefilWithInputs() → ReasoningBrain
                                                                      ↓
User question via TextField → ReasoningBrain.findItem() → LanguageModelSession → Answer
```

### Frameworks Used

- SwiftUI (declarative UI)
- SwiftData (persistence - Item model)
- FoundationModels (on-device AI for natural language queries)

### Concurrency Model

- Uses Swift async/await with strict concurrency checking. Default actor isolation is MainActor. AI operations run in Task blocks with temperature 0.25 for deterministic responses.
- Use Swift Approachable concurrency.
- Refer to swift concurrency skill which is already installed.

## Design

See design/DESIGN.md for how to build the UI for features.
