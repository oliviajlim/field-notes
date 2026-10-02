# SwiftUI Interview Prep

Use this reference when the user asks to practice senior/staff SwiftUI interviews, explain concepts aloud, whiteboard SwiftUI behavior, or turn implementation guidance into interview-ready answers.

## Answer Shape

Use this structure for conceptual answers:

1. Mental model: define the mechanism in plain language.
2. Tradeoff: name what the approach buys and what it costs.
3. Common bug: give a realistic failure mode.
4. Verification: say how you would test, profile, or observe it.

For staff-level answers, avoid trivia-only responses. Connect the mechanism to architecture, performance, migration risk, or team maintainability.

## Core Prompts

### Explain SwiftUI rendering

Good answer:

- SwiftUI views are value descriptions of UI, not long-lived view objects.
- State changes cause affected view bodies to be recomputed.
- SwiftUI diffs the resulting tree using structural identity (type + position) and explicit identity (`id`) where provided.
- `body` recomputation is not the same as a full visual redraw.
- Identity changes can reset local state, retrigger lifecycle work, and break animations.

Common bug:

- Swapping different view types in an `if/else` when the same view with conditional modifiers would preserve identity.
- Using unstable IDs in `ForEach`, especially indices for dynamic collections.

Verification:

- Use `Self._printChanges()` / `Self._logChanges()` for surprise updates.
- Profile with Instruments when the issue is visible as hangs, hitches, or main-thread work.

### Explain Observation and property wrappers

Modern model:

- `@Observable` creates fine-grained tracking for stored properties.
- A view invalidates when it reads a property that later changes.
- A view-created `@Observable` object is owned with `@State`.
- An injected `@Observable` object is usually a plain property.
- Use `@Bindable` only when the child needs bindings into an injected observable.

Legacy model:

- `ObservableObject` uses `objectWillChange`.
- `@Published` fires broad object-level invalidation.
- `@StateObject` owns a view-created object.
- `@ObservedObject` observes an object created elsewhere.

Interview distinction:

- The difference is not just syntax. Observation improves precision, reduces broad invalidation, and avoids common ownership bugs from using `@ObservedObject` for objects a view creates itself.

### Explain `@State`, `@Binding`, and environment

- `@State`: private state owned by this view.
- `@Binding`: a writable projection into parent-owned state.
- `@Environment`: ambient dependency or value from the view hierarchy.
- `@EnvironmentObject`: legacy broad injection for `ObservableObject`; convenient, but dependencies become implicit.

Staff-level framing:

- Prefer explicit inputs for reusable views.
- Use environment for true cross-cutting concerns like theme, dismiss, locale, auth/session, or app-level services.
- Do not use environment as a shortcut around clear dependency boundaries.

### Explain SwiftUI performance

Lead with measurement:

- First decide whether the issue is main-thread work, repeated invalidation, layout churn, image decoding, list identity, or expensive work in `body`.
- Use Instruments for hangs/hitches and SwiftUI debug hooks for invalidation.

Common fixes:

- Pass narrower data into subviews.
- Keep `body` cheap.
- Stabilize IDs.
- Move filtering/sorting out of hot `ForEach` paths.
- Avoid `AnyView` in hot rows.
- Downsample large images before display.

### Explain Combine vs. async/await in SwiftUI

- Use async/await for one-shot async work.
- Use `.task` / `.task(id:)` for view-scoped async work with automatic cancellation.
- Use `AsyncSequence` for streams that fit structured concurrency.
- Use Combine when operator-rich, multi-source streams are clearer or the codebase already depends on it.

Common example:

- Search can use `debounce` because the action should fire after typing pauses.
- Typing indicators usually need immediate show plus delayed hide, so `debounce` alone is the wrong mental model.

## Practice Questions

- How does SwiftUI decide whether a view keeps or loses state?
- What is the difference between `body` recomputation and a visual redraw?
- When would you use `@StateObject` instead of `@ObservedObject`?
- How does `@Observable` improve on `ObservableObject` + `@Published`?
- How would you debug a SwiftUI screen that hitches while scrolling?
- How would you design a reusable component for a design system?
- How would you test a SwiftUI feature without relying only on UI tests?
- How would you migrate a UIKit screen to SwiftUI without stopping feature work?

