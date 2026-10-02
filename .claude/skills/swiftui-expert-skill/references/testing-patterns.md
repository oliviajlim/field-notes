# SwiftUI Testing Patterns

Use this reference for SwiftUI testing strategy, testability reviews, interview prep, and code changes that need verification guidance.

## Test Pyramid

- Unit tests: fast, deterministic checks for view models, reducers, formatters, validators, and state transitions.
- Snapshot tests: visual regression checks for important component states and screen variants.
- UI tests: thin coverage for critical end-to-end flows only; they are slower and more brittle.
- Previews: development feedback and fixture coverage, not a substitute for automated tests.
- Instruments: performance verification for hangs, hitches, memory, startup, and scrolling.

## Make SwiftUI Testable

- Keep business logic out of `View`.
- Inject services behind protocols or concrete test doubles.
- Use deterministic schedulers/clocks when testing time-based behavior.
- Isolate formatting and mapping logic into pure functions where practical.
- Prefer model-driven sheets/navigation so state transitions can be tested directly.
- Avoid hidden dependencies through global singletons unless the app has an established dependency system.

## What To Unit Test

- View model state transitions.
- Loading, empty, success, and error states.
- Retry and cancellation behavior.
- Validation and formatting.
- Sorting/filtering/pagination logic outside `body`.
- Analytics or experiment event emission when user-visible behavior depends on it.

## What To Snapshot Test

- Reusable design-system components.
- Empty/error/loading states.
- Dynamic Type sizes.
- Light/dark mode.
- Localization-sensitive layouts.
- Important animation endpoints, not every frame.

## What To UI Test

- Login/onboarding or other business-critical flows.
- Purchase/subscription or high-risk conversion flows.
- Navigation paths that commonly regress.
- Accessibility smoke checks when supported by the project.

## Async and Concurrency

- Test async view models with `async` tests.
- Assert cancellation behavior when `.task(id:)` or user actions restart work.
- Mark UI-facing models `@MainActor` when they mutate state read by SwiftUI.
- Use fake services to avoid network, BLE, persistence, or clock nondeterminism.

## Interview Answer Shape

Good answer:

1. "I would not test SwiftUI mostly through UI tests."
2. "I would put logic in a testable model and unit-test state transitions."
3. "I would snapshot important UI states and keep a small set of critical UI tests."
4. "For performance, I would measure with Instruments rather than assume."

Common follow-up:

- If asked how to test a view itself, describe previews/snapshots for rendering states and unit tests for the model that drives those states.

