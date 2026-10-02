---
name: swift-concurrency
description: 'Diagnose data races, convert callback-based code to async/await, implement actor isolation patterns, resolve Sendable conformance issues, and guide Swift 6 migration. Use when developers mention: (1) Swift Concurrency, async/await, actors, or tasks, (2) "use Swift Concurrency" or "modern concurrency patterns", (3) migrating to Swift 6, (4) data races or thread safety issues, (5) refactoring closures to async/await, (6) @MainActor, Sendable, or actor isolation, (7) concurrent code architecture or performance optimization, (8) concurrency-related linter warnings (SwiftLint or similar; e.g. async_without_await, Sendable/actor isolation/MainActor lint).'
---
# Swift Concurrency

## Overview

This skill covers async/await, tasks, actors, `Sendable`, and Swift 6 migration. Use it to write and fix safe, performant concurrent code. Upstream “fast path / quick fix / diagnostics” flows are merged here with **Players platform** defaults (see below).

## Fast Path

Before proposing a fix:

1. Analyze `Package.swift` or `.pbxproj` to determine Swift language mode, strict concurrency level, default isolation, and upcoming features. Do this always, not only for migration work. **In this monorepo**, the `ios-app` app targets are defined with **Tuist** (`ios-app/players/Project.swift`, `SWIFT_VERSION` = 6.0) — default to **Swift 6**-appropriate advice unless a target explicitly differs.
2. Capture the exact diagnostic and offending symbol.
3. Determine the isolation boundary: `@MainActor`, custom actor, actor instance isolation, or `nonisolated`.
4. Confirm whether the code is UI-bound or intended to run off the main actor. For delayed retries, timers, and backoff tasks, separate the waiting from the UI mutation. The sleep often belongs off the main actor even when the final state update belongs on it.

Project settings that change concurrency behavior:

| Setting | SwiftPM (`Package.swift`) | Xcode (`.pbxproj`) / Tuist |
|---|---|---|
| Language mode | `swiftLanguageVersions` or `-swift-version` (`// swift-tools-version:` is not a reliable proxy) | Swift Language Version; Tuist: `SWIFT_VERSION` in `Project.swift` |
| Strict concurrency | `.enableExperimentalFeature("StrictConcurrency=targeted")` | `SWIFT_STRICT_CONCURRENCY` |
| Default isolation | `.defaultIsolation(MainActor.self)` | `SWIFT_DEFAULT_ACTOR_ISOLATION` |
| Upcoming features | `.enableUpcomingFeature("NonisolatedNonsendingByDefault")` | `SWIFT_UPCOMING_FEATURE_*` |

If any of these are unknown, ask the developer to confirm them before giving migration-sensitive guidance. Do not guess.

### How to discover settings (agent tooling)

- **SwiftPM:** `Read` on `Package.swift` (tools version, strict concurrency, upcoming features, default isolation).
- **Xcode / Tuist:** `Grep` in `**/*.pbxproj` and `ios-app/**/Project.swift` for `SWIFT_STRICT_CONCURRENCY`, `SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_VERSION`, and `SWIFT_UPCOMING_FEATURE_`.

### Guardrails

- Do not recommend `@MainActor` as a blanket fix. Justify why the code is truly UI-bound.
- Prefer structured concurrency over unstructured tasks. Use `Task.detached` only with a clear reason.
- Do not treat task groups as hard-timeout primitives when a losing child can ignore cancellation.
- If recommending `@preconcurrency`, `@unchecked Sendable`, or `nonisolated(unsafe)`, require a **documented safety invariant** and a **follow-up plan** to remove or replace it.
- Optimize for the smallest safe change. Do not refactor unrelated architecture during migration.
- Course references are for deeper learning only. Use them sparingly and only when they clearly help.

## Quick Fix Mode

Use Quick Fix Mode when all of these are true:

- The issue is localized to one file or one type.
- The isolation boundary is clear.
- The fix can be explained in 1-2 behavior-preserving steps.

Skip Quick Fix Mode when any of these are true:

- Build settings or default isolation are unknown.
- The issue crosses module boundaries or changes public API behavior.
- The likely fix depends on unsafe escape hatches.

## Common Diagnostics

| Diagnostic | First check | Smallest safe fix | Escalate to |
|---|---|---|---|
| `Main actor-isolated ... cannot be used from a nonisolated context` | Is this truly UI-bound? | Isolate the caller to `@MainActor` or use `await MainActor.run { ... }` only when main-actor ownership is correct. | `references/actors.md`, `references/threading.md` |
| `Actor-isolated type does not conform to protocol` | Must the requirement run on the actor? | Prefer isolated conformance (e.g., `extension Foo: @MainActor SomeProtocol`); use `nonisolated` only for truly nonisolated requirements. | `references/actors.md` |
| `Sending value of non-Sendable type ... risks causing data races` | What isolation boundary is being crossed? | Keep access inside one actor, or convert the transferred value to an immutable/value type. | `references/sendable.md`, `references/threading.md` |
| `SwiftLint async_without_await` | Is `async` actually required by protocol, override, or `@concurrent`? | Remove `async`, or use a narrow suppression with rationale. Never add fake awaits. | `references/linting.md` |
| `wait(...) is unavailable from asynchronous contexts` | Is this legacy XCTest async waiting? | Replace with `await fulfillment(of:)` or Swift Testing equivalents. | `references/testing.md` |
| Core Data concurrency warnings | Are `NSManagedObject` instances crossing contexts or actors? | Pass `NSManagedObjectID` or map to a Sendable value type. | `references/core-data.md` |
| `Thread.current` / `class property 'current' is unavailable` | Debugging by thread instead of isolation? | Reason in terms of isolation; use `references/threading.md` and Instruments. | `references/threading.md` |
| SwiftLint concurrency-related warnings | Which specific lint rule triggered? | `references/linting.md`; avoid dummy awaits. | `references/linting.md` |

## When Quick Fixes Fail

1. Gather project settings if not already confirmed.
2. Re-evaluate which isolation boundaries the type crosses.
3. Route to the matching reference file for a deeper fix.
4. If the fix may change behavior, document the invariant and add verification steps.

## Triage-First Playbook (narrative)

Use when a diagnostic string does not map cleanly to the table above, or for extra context (same references as the table and [Topic decision tree](#topic-decision-tree)):

- **non-Sendable at boundary** → isolate, convert to value type, or `sendable.md` + `threading.md` (Swift 6.2 rules).
- **Main-actor / nonisolated mismatch** → `actors.md`, `threading.md`.
- **Core Data cross-context** → `core-data.md` (IDs and DAOs).
- **Thread APIs from async** → avoid thread-centric mental model; `threading.md`.

## Smallest Safe Fixes

Prefer changes that preserve behavior while satisfying data-race safety:

- **UI-bound state**: isolate the type or member to `@MainActor`.
- **Shared mutable state**: move it behind an `actor`, or use `@MainActor` only if the state is UI-owned.
- **Background work**: when work must hop off caller isolation, use an `async` API marked `@concurrent`; when work can safely inherit caller isolation, use `nonisolated` without `@concurrent`. If a task mostly waits or retries before one UI-bound mutation, keep the delay off `@MainActor` and hop back only for the final update.
- **Sendability issues**: prefer immutable values and explicit boundaries over `@unchecked Sendable`.

## Concurrency Tool Selection

| Need | Tool | Key Guidance |
|---|---|---|
| Single async operation | `async/await` | Default choice for sequential async work |
| Fixed parallel operations | `async let` | Known count at compile time; auto-cancelled on throw |
| Dynamic parallel operations | `withTaskGroup` | Unknown count; structured — cancels children on scope exit, but the scope still waits for child cancellation to finish |
| Sync → async bridge | `Task { }` | Inherits actor context; use `Task.detached` only with documented reason |
| Shared mutable state | `actor` | Prefer over locks/queues; keep isolated sections small |
| UI-bound state | `@MainActor` | Only for truly UI-related code; justify isolation |

### Code patterns (short)

**async/await** — single async operation  
**async let** — fixed parallelism at compile time  
**Task { }** — unstructured bridge (inherits context)  
**withTaskGroup** — dynamic parallelism  
**actor** — shared mutable state  
**@MainActor** — UI- or main-actor–bound types

### Common scenarios

**Network request with UI update**
```swift
Task { @concurrent in
    let data = try await fetchData()
    await MainActor.run { self.updateUI(with: data) }
}
```

**Multiple parallel requests**
```swift
async let users = fetchUsers()
async let posts = fetchPosts()
let (u, p) = try await (users, posts)
```

**Processing array items in parallel**
```swift
await withTaskGroup(of: ProcessedItem.self) { group in
    for item in items {
        group.addTask { await process(item) }
    }
    for await result in group {
        results.append(result)
    }
}
```

### Timeout and race patterns

Use task groups for structured dynamic child work, not as a hard-timeout primitive when the slow child might ignore cancellation. A `withTaskGroup` scope cancels losing children, but it still waits for them to finish cancellation before returning.

For callback bridges, request adapters, token refresh, and "first result wins" code:

1. Use a call-once completion gate so the timeout path can release the callback independently of the slow operation.
2. Protect racing completions with a lock, Mutex, or actor.
3. Add a hostile cancellation test where the slow operation catches/ignores cancellation or never resumes, and assert the timeout still completes.

## Topic Decision Tree

1. **New async code?** → `async-await-basics.md`; parallel ops → `tasks.md`.
2. **Shared mutable state?** → `actors.md` / `@MainActor`; value crossing boundaries → `sendable.md`.
3. **Streams?** → `async-sequences.md`, `async-algorithms.md`.
4. **Core Data or legacy stack?** → `core-data.md`, `migration.md`.
5. **Perf / tests / memory?** → `performance.md`, `testing.md`, `memory-management.md`.
6. **Threading model?** → `threading.md`.

## Swift 6 Migration Quick Guide

Key changes in Swift 6:
- **Strict concurrency checking** enabled by default
- **Complete data-race safety** at compile time
- **Sendable requirements** enforced on boundaries
- **Isolation checking** for all async boundaries

### Migration validation loop

1. **Build** — surface diagnostics.
2. **Fix** — one category at a time (e.g. Sendable first).
3. **Rebuild** — confirm clean compile for that step.
4. **Test** — `swift test` or Xcode test.
5. **Do not** batch unrelated refactors; keep changes reviewable.

If a fix introduces new warnings, resolve them before continuing.

For detailed steps, see `references/migration.md`.

## Reference Router

Open the smallest reference that matches the question (see also `references/_index.md` if present):

- **Foundations** — `async-await-basics.md`, `tasks.md`, `actors.md`, `sendable.md`, `threading.md`
- **Streams** — `async-sequences.md`, `async-algorithms.md`
- **Applied** — `testing.md`, `performance.md`, `memory-management.md`, `core-data.md`
- **Migration and tooling** — `migration.md`, `linting.md`
- **Glossary** — `glossary.md`

## Best practices (summary)

1. Prefer structured concurrency; avoid unnecessary `Task.detached`.
2. Keep actor-isolated and `@MainActor` work small.
3. Use `@MainActor` only for real UI or main-actor ownership.
4. Prefer `Sendable` / value types at boundaries; document any escape hatches.
5. Check `Task.isCancelled` in long work; avoid semaphores blocking async code.
6. Test async and cancellation paths deliberately.

## Verification Checklist

- Re-check build settings (default isolation, strict concurrency, upcoming features) before interpreting diagnostics.
- After refactors: run tests (actor, lifetime, cancellation); use Instruments for perf claims; verify deinit/cancellation for long-lived tasks.
- Never use ad hoc locks in async code when an `actor` or `Mutex` expresses ownership more safely.

## Glossary

See `references/glossary.md` for quick definitions of core concurrency terms.

---

**Note**: This skill is based on the comprehensive [Swift Concurrency Course](https://www.swiftconcurrencycourse.com?utm_source=github&utm_medium=agent-skill&utm_campaign=skill-footer) by Antoine van der Lee. Upstream: [AvdLee/Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill); this file merges that content with **Players** repository defaults and tooling notes.
