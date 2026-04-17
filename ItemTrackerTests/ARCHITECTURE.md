# Test Architecture

Two layers, each testing a distinct concern with a different isolation strategy.

---

## Layer 1 — `ItemsRepositoryTests`: integration through real SwiftData

Tests the concrete `ItemsRepository` against an actual (in-memory) SwiftData store. No mocking — the point is to verify that persistence, unique constraints, stream emissions, and typed errors all work end-to-end through the real stack.

### Sandboxing via `TestHelpers.withRepository`

Every test receives a fresh `ItemsRepository` backed by a new `ModelContainer(isStoredInMemoryOnly: true)`. The container and repository are owned by the closure and released when it returns. This prevents state leakage where `ModelContext.mainContext` retains residual state across tests when the container outlives the test.

### Stream-iterator protocol

Because `ItemsRepository` communicates through an `AsyncStream`, tests drive it by subscribing before mutating and consuming emissions as checkpoints:

```
subscribe → skip initial empty → mutate → await next emission → assert
```

`try await iterator.next()` naturally blocks until the mutation triggers `refreshAndEmit()`, so there's no polling or arbitrary sleeping.

### Typed error assertions via `do/catch`

Rather than `#expect(throws: value)` — which has unreliable behaviour with typed throws through async closures — errors are asserted with explicit `do/catch` + `Issue.record`:

```swift
do {
    try await sut.delete(id: unknownId)
    Issue.record("Expected itemNotFound to be thrown")
} catch ItemsRepositoryError.itemNotFound(let id) {
    #expect(id == unknownId)
}
```

This also makes the associated value (the id) directly assertable.

---

## Layer 2 — `ItemsViewModelTests`: unit with a hand-rolled mock

Tests `ItemsViewModel` in complete isolation from SwiftData. The mock (`MockItemsRepository`) replaces the repository with an `AsyncStream` the test controls directly via `mock.emit([...])`. The ViewModel has no idea it's talking to a mock.

### What this layer tests

Only the ViewModel's responsibilities: mapping `Item` → `ItemDisplayModel`, applying correct date formatting, reacting to stream updates, and clearing state on empty emission. Storage and errors are not the concern here.

### `waitUntil` instead of a single yield

The ViewModel's observation runs in an internal `Task`. After `mock.emit(...)`, the test can't assert immediately because the Task needs at least one scheduling cycle to process the emission. A single `Task.yield()` isn't reliable enough (the scheduler isn't guaranteed to run the observation task), so `waitUntil` polls up to 20 cycles:

```swift
private func waitUntil(_ condition: @autoclosure () -> Bool) async {
    for _ in 0..<20 {
        if condition() { return }
        await Task.yield()
    }
}
```

---

## Structural decisions

| Decision | Reason |
|---|---|
| `@Suite(.serialized)` on both suites | Both suites share `@MainActor` state; serialisation prevents interleaving |
| `@MainActor` on both suites | Matches the production code — repository and ViewModel are both `@MainActor` |
| Mock conforms to `ItemsRepositoryType` | Forces the mock to stay in sync with the protocol contract, including typed throws |
| Integration tests use real SwiftData | The unique constraint and stream emissions are SwiftData behaviour — a mock can't verify them |
| Unit tests never touch SwiftData | Keeps ViewModel tests fast and decoupled from storage concerns |
