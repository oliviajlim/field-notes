---
name: swiftui-expert-skill
description: Write, review, improve, or explain SwiftUI code and concepts following best practices for state management, view composition, rendering identity, performance, Swift concurrency, modern and deprecated API migration, testing, UIKit-to-SwiftUI migration, macOS-specific APIs, and iOS 26+ Liquid Glass adoption. Use when building new SwiftUI features, refactoring existing views, reviewing code quality, adopting modern SwiftUI patterns, preparing for senior/staff SwiftUI interviews, or explaining SwiftUI tradeoffs out loud. Also triggers when an Xcode Instruments `.trace` file is referenced (to analyse it) or the user asks to **record** a new trace (attach, launch, or stop-file session via `record_trace.py`). A target SwiftUI source file is optional; a trace alone is enough to diagnose hangs, hitches, CPU hotspots, and high-severity SwiftUI updates.
---

# SwiftUI Expert Skill

## Overview
Use this skill to build, review, or improve SwiftUI features with correct state management, modern API usage, Swift concurrency, optimal view composition, and iOS 26+ Liquid Glass styling. Prioritize native APIs, Apple design guidance, and performance-conscious patterns. The skill is **grounded in facts and best practices** without mandating a specific app architecture. Use **`references/latest-apis.md`**: Part 1 is the deprecation matrix (iOS 15+ through 26+); Part 2 is narrative examples and rationale. Route topics through the Topic router below.

## Operating rules
- **Deprecation scan:** consult `references/latest-apis.md` at the start of substantive SwiftUI work — Part 1 for the matrix, Part 2 for narrative how-tos and code samples.
- Prefer native SwiftUI APIs over UIKit/AppKit bridging unless bridging is necessary.
- Focus on correctness and performance; do not enforce specific architectures (for example MVVM, VIPER).
- Encourage separating business logic from views for testability without mandating how.
- Follow Apple’s Human Interface Guidelines and API design patterns.
- **Liquid Glass:** only when the user explicitly asks; see `references/liquid-glass.md`.
- Present performance optimizations as **suggestions**, not requirements.
- Use `#available` gating with sensible fallbacks for version-specific APIs.
- **Instruments / trace scripts** under `scripts/` expect `SKILL_DIR` to point at this skill’s root (the folder that contains `SKILL.md`); if unset, substitute the absolute path to `.cursor/skills/swiftui-expert-skill` in this repository.

## Task workflow (summary)

### Review existing SwiftUI code
- Read the code and identify which topics apply.
- Compare against `references/latest-apis.md` and route topics through the [Topic router](#topic-router) (and the [detailed workflow](#detailed-workflow-code) below for systematic review).
- Validate `#available` and fallbacks for iOS 26+ features.

### Improve existing SwiftUI code
- Audit against the Topic router and the detailed workflow below.
- Replace deprecated APIs per `latest-apis.md` (Parts 1 and 2 as needed).
- Refactor hot paths, extract complex view bodies, and (optionally) suggest image downsampling when `UIImage(data:)` appears (`references/image-optimization.md`).

### Implement new SwiftUI feature
- Design data flow: owned vs injected state (`references/state-management.md`).
- Structure for diffing; apply animation patterns; prefer `Button` for tappables; add accessibility as appropriate.
- Gate version-specific APIs with `#available` and provide fallbacks.

### Interview prep / explanation mode
Trigger when the user asks to practice, study, explain, whiteboard, prepare for an interview, or answer SwiftUI questions out loud. Read `references/interview-prep.md` first; also read `references/migration-patterns.md` for UIKit-to-SwiftUI migration stories and `references/testing-patterns.md` for test strategy questions. Prefer mental models, tradeoffs, common bugs, and crisp spoken answers over code-only output.

### Record a new Instruments trace
Trigger when the user asks to "record a trace", "profile the app", "capture a session", etc. Full reference: `references/trace-recording.md`.

1. **Confirm target** — attach, launch, or all processes? If unclear, ask. List devices when useful:
   ```bash
   python3 "${SKILL_DIR}/scripts/record_trace.py" --list-devices
   ```
2. **Template** — `SwiftUI` template populates the SwiftUI lane on **real devices** and the **host Mac**; on **iOS Simulator** the lane is often empty — use `--template "Time Profiler"` there. See the decision table in `references/trace-recording.md`.
3. **Start recording** — for agent-driven "tell me when I’m done" sessions, use a stop-file:
   ```bash
   python3 "${SKILL_DIR}/scripts/record_trace.py" \
       --device "<name|udid>" --attach "<AppName>" \
       --stop-file /tmp/stop-trace --output ~/Desktop/session.trace
   ```
4. **Stop** — `touch /tmp/stop-trace` when the user is done; the script finalizes the trace.
5. **Analyse** using the trace-driven workflow below.

### Trace-driven improvement (`.trace` present)
Trigger when the request references a `.trace` file. A Swift source file is **optional** (`references/trace-analysis.md` has the full flow). Summary:
1. Scope whole trace vs time window; use `--list-logs` / `--list-signposts` to build `--window START_MS:END_MS` if needed.
2. Run:
   ```bash
   python3 "${SKILL_DIR}/scripts/analyze_trace.py" --trace <path> \
       --json-only --top 10 [--window START_MS:END_MS]
   ```
3. Interpret `main_running_coverage_pct` and SwiftUI cause lanes per `trace-analysis.md`.
4. Only edit code if the user asked for edits.

## Detailed workflow (code)

### 1) Review existing SwiftUI code
- Check property wrappers against `references/state-management.md` (selection guide).
- Verify modern API usage via `latest-apis.md`.
- Check composition and performance (`view-structure.md`, `performance-patterns.md`).
- Verify list identity (`list-patterns.md`), animations (`animation-*.md`), and Liquid Glass if applicable (`liquid-glass.md`).
- Validate iOS 26+ availability and fallbacks.

### 2) Improve existing SwiftUI code
- Prefer `@Observable` over `ObservableObject` for new code; align `@State` / `@Bindable` usage with `state-management.md`.
- Replace deprecated APIs using `latest-apis.md`.
- Extract complex views; reduce redundant updates on hot paths.
- Stabilize `ForEach` identity; improve animations; optionally suggest image downsampling for `UIImage(data:)`.
- Adopt Liquid Glass only when the user requests it.

### 3) Implement a new SwiftUI feature
- Design data flow; use modern APIs; keep views small and testable.
- Use `@Observable` and `@MainActor` as in `state-management.md` when applicable.
- Apply glass effects after layout/appearance (`liquid-glass.md`).

### 4) Explain SwiftUI for interviews
- Start with the mental model, then name the tradeoff, then give a concrete bug or production example.
- Cover rendering identity, property wrapper ownership, observation granularity, Swift concurrency boundaries, and performance measurement when relevant.
- For migration questions, discuss interoperability and rollout strategy before syntax.
- For testing questions, separate unit tests, snapshot tests, UI tests, previews, and instrumentation.

## Topic router

| Topic | Reference |
|-------|-----------|
| State management | `references/state-management.md` |
| Interview prep / SwiftUI explanations | `references/interview-prep.md` |
| UIKit-to-SwiftUI migration | `references/migration-patterns.md` |
| SwiftUI testing strategy | `references/testing-patterns.md` |
| View composition | `references/view-structure.md` |
| Performance | `references/performance-patterns.md` |
| Lists and `ForEach` | `references/list-patterns.md` |
| Layout | `references/layout-best-practices.md` |
| Sheets and navigation | `references/sheet-navigation-patterns.md` |
| `ScrollView` | `references/scroll-patterns.md` |
| Focus | `references/focus-patterns.md` |
| Animations (basics / transitions / advanced) | `animation-basics.md`, `animation-transitions.md`, `animation-advanced.md` |
| Accessibility | `references/accessibility-patterns.md` |
| Swift Charts | `references/charts.md`, `charts-accessibility.md` |
| Image optimization | `references/image-optimization.md` |
| Liquid Glass (iOS 26+) | `references/liquid-glass.md` |
| macOS scenes / windows / views | `macos-scenes.md`, `macos-window-styling.md`, `macos-views.md` |
| Text (localization, numbers, dates, search) | `references/text-patterns.md` |
| Deprecations + narrative API examples | `references/latest-apis.md` |
| Trace analysis / recording | `trace-analysis.md`, `trace-recording.md` |

## Core guidelines

### State management
- **Prefer `@Observable` over `ObservableObject`** for new code.
- **Mark `@Observable` types with `@MainActor`** when not relying on default main-actor isolation project-wide.
- **Always mark `@State` and `@StateObject` as `private`**.
- **Never declare passed values as `@State` or `@StateObject`** (they only take initial values).
- Use `@State` with `@Observable` classes (not `@StateObject`).
- `@Binding` only when a child must **modify** parent state; `@Bindable` for injected `@Observable` that need bindings.
- Use `let` for read-only values; `var` plus `.onChange` for reactive reads.
- Legacy: `@StateObject` for owned `ObservableObject`; `@ObservedObject` for injected.
- Nested `ObservableObject` does not compose well—pass objects explicitly; `@Observable` nests more naturally.

### Interview explanations
- Prefer "mental model → tradeoff → bug/example → test/measurement" when answering conceptual SwiftUI questions.
- For rendering questions, distinguish `body` recomputation from actual rendered updates; name structural identity (type + position) and explicit identity (`id`) as the state-preservation mechanism.
- For Observation questions, explain why `@Observable` is not just less syntax: it gives finer-grained dependency tracking than `ObservableObject` + `@Published`.
- For senior/staff answers, include what you would measure or how you would verify the claim.

### Modern APIs
- `foregroundStyle()` not `foregroundColor()`; `clipShape(.rect(cornerRadius:))` not bare `cornerRadius()`.
- `Tab` not `tabItem()`; `Button` not `onTapGesture()` unless you need location/count; `NavigationStack` not `NavigationView`.
- `navigationDestination(for:)`; two-parameter or no-parameter `onChange`; `ImageRenderer` for rendering; `.sheet(item:)` for model-driven sheets; sheets own actions and call `dismiss()`.
- `ScrollViewReader` for programmatic scroll with stable IDs; avoid `UIScreen` for sizing; avoid `GeometryReader` when `containerRelativeFrame()` or other APIs suffice.

### Swift best practices
- Modern `Text` formatting (`.format`, not `String(format:)` for display); `localizedStandardContains()` for user-input search.
- Static member style (`.blue`); `.task` / `.task(id:)` for async work with cancellation.

### View composition
- Prefer **modifiers** over **conditional views** for state-driven appearance when identity should stay stable.
- Extract subviews; keep `body` simple; use `@ViewBuilder let content: Content` for containers where it fits.
- Action handlers should call methods, not embed large inline logic; relative layout over magic constants.

### Performance
- Pass only what each view needs; avoid wide invalidation; guard assignments in hot paths.
- `LazyVStack` / `LazyHStack` for large lists; stable `ForEach` identity; avoid `AnyView` in hot rows; consider POD parents for heavy subtrees.
- Use `Self._printChanges()` / `Self._logChanges()` to debug surprise updates.
- Suggest image downsampling when raw `UIImage(data:)` is a bottleneck (optional; see `image-optimization.md`).

### Animations
- `.animation(_:value:)` with a `value` where possible; `withAnimation` for events; know transition vs animation ordering; iOS 17+ phase/keyframe tools; transaction/completion patterns from `animation-advanced.md`.

### Liquid Glass (iOS 26+)
**Only when the user explicitly asks.** Use native `glassEffect`, `GlassEffectContainer`, glass button styles; group glass in a container; apply glass after layout; `glassEffectID` + `@Namespace` for morphing.

## Quick reference

### Property wrappers (modern)
| Wrapper | Use when |
|---------|----------|
| `@State` | Internal state (`private`) or an owned `@Observable` instance |
| `@Binding` | Child writes parent state |
| `@Bindable` | Injected `@Observable` needs bindings |
| `let` | Read-only from parent |
| `var` | Read-only value observed via `.onChange` |

**Legacy:** `@StateObject` / `@ObservedObject` for `ObservableObject` as in `state-management.md`.

### Common API replacements
| Deprecated / avoid | Prefer |
|--------------------|--------|
| `foregroundColor()` | `foregroundStyle()` |
| `cornerRadius()` | `clipShape(.rect(cornerRadius:))` |
| `tabItem()` | `Tab` API |
| `onTapGesture()` | `Button` (unless location/count) |
| `NavigationView` | `NavigationStack` |
| Old `onChange` | `onChange` with `old,new` or zero-arg closure |
| `fontWeight(.bold)` | `bold()` where appropriate |
| `GeometryReader` (when possible) | `containerRelativeFrame()` / `visualEffect()` |
| `String(format:)` in `Text` | `Text(value, format: …)` |
| `contains` for user search | `localizedStandardContains` |

### Liquid Glass patterns
```swift
if #available(iOS 26, *) {
    content
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    content
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}

GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        // glass subviews
    }
}

Button("Confirm") { }
    .buttonStyle(.glassProminent)
```

## Correctness checklist (hard rules)
- [ ] `@State` properties are `private`
- [ ] `@Binding` only where a child modifies parent state
- [ ] Passed values never declared as `@State` or `@StateObject`
- [ ] iOS 17+: prefer `@State` + `@Observable`; `@Bindable` for injected observables needing bindings; legacy rules for `ObservableObject` as in `state-management.md`
- [ ] `ForEach` uses stable identity (not `.indices` for dynamic content)
- [ ] Constant number of views per `ForEach` element
- [ ] `.animation(_:value:)` includes the `value` parameter when using that form
- [ ] `@FocusState` is `private`; no redundant focus writes on `.focusable()` tap handlers (see `focus-patterns.md`)
- [ ] iOS 26+ APIs are gated with fallbacks
- [ ] `import Charts` in files that use chart types

## Review checklist (broader)

### State
- [ ] New code uses `@Observable` where possible; `MainActor` as needed
- [ ] No mistaken `@State` / `@StateObject` for parent-provided values
- [ ] Bindings and `@Bindable` used appropriately

### Interview readiness
- [ ] Can explain SwiftUI rendering, identity, and redraw behavior without notes
- [ ] Can compare `@State`, `@Binding`, `@Observable`, `@Published`, `@StateObject`, `@ObservedObject`, and `@Environment`
- [ ] Can explain UIKit-to-SwiftUI migration tradeoffs and partial rollout strategy
- [ ] Can describe a practical SwiftUI testing strategy

### APIs (`latest-apis.md`)
- [ ] Styling, navigation, sheets, and alerts use current APIs
- [ ] No unnecessary `GeometryReader` / `UIScreen`
- [ ] Button labels / accessibility for icon-only controls (project a11y rules)

### Sheets and navigation
- [ ] `sheet(item:)` where it fits; dismiss ownership clear
- [ ] `navigationDestination(for:)` for typed stacks

### Scroll and text
- [ ] `ScrollViewReader` with stable IDs; scroll indicators style API
- [ ] `Text` localization and formatting as in `text-patterns.md`

### View structure and performance
- [ ] Subviews extracted; `body` cheap; no accidental heavy work in `body`
- [ ] Lists: identity, no `AnyView` in hot rows, filter outside `ForEach` where it matters

### Layout and behavior
- [ ] Relative layout; context-agnostic where possible; actions factored to methods

### Animation
- [ ] Value-driven animation; transitions consistent with `animation-basics/transition/adv`

### Liquid Glass
- [ ] Gated, consistent materials/shapes, container grouping

## References
- `references/latest-apis.md` — **Deprecations (Part 1) and narrative examples (Part 2)**; read early on substantive tasks
- `references/interview-prep.md` — Senior/staff SwiftUI explanation prompts, spoken answer shapes, and common conceptual traps
- `references/migration-patterns.md` — UIKit-to-SwiftUI migration, interoperability, rollout, lifecycle, and navigation tradeoffs
- `references/testing-patterns.md` — SwiftUI unit, snapshot, UI, preview, dependency-injection, and instrumentation test strategy
- `references/state-management.md` — Property wrappers, `@Observable`, data flow
- `references/view-structure.md` — Composition and containers
- `references/performance-patterns.md` — Hot paths, updates, debug hooks
- `references/list-patterns.md` — `ForEach`, lists, `Table`
- `references/layout-best-practices.md` — Layout, `GeometryReader` alternatives
- `references/animation-basics.md`, `animation-transitions.md`, `animation-advanced.md` — Motion and transitions
- `references/sheet-navigation-patterns.md` — Sheets, split views, inspector
- `references/scroll-patterns.md` — Scrolling and readers
- `references/text-patterns.md` — Verbatim vs localized `Text`, number/date formatting, search strings
- `references/image-optimization.md` — Images and downsampling
- `references/liquid-glass.md` — iOS 26+ glass
- `references/accessibility-patterns.md` — VoiceOver, Dynamic Type, traits
- `references/charts.md`, `references/charts-accessibility.md` — Swift Charts
- `references/focus-patterns.md` — Focus and keyboard
- `references/macos-scenes.md`, `macos-window-styling.md`, `macos-views.md` — macOS
- `references/trace-analysis.md`, `trace-recording.md` — Instruments and `scripts/`

## Philosophy
This skill encodes **facts and practices**, not a single architecture:
- It does not impose MVVM, VIPER, or other patterns; it does encourage testable logic outside views.
- It favors modern APIs, clear concurrency, and measured performance.
- It follows Apple’s HIG and API direction; **Liquid Glass** and heavy tooling are opt-in to user intent and task context.
