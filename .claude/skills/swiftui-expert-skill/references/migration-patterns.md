# UIKit-to-SwiftUI Migration Patterns

Use this reference for UIKit-to-SwiftUI migration work, partial rewrites, interoperability reviews, and interview answers about production migrations.

## Migration Answer Shape

For interview prep, answer migration questions in this order:

1. Why migrate: velocity, state clarity, design-system reuse, previews, or platform direction.
2. Boundary: which screens, flows, or components move first.
3. Interop: how UIKit and SwiftUI coexist.
4. Risk control: feature flags, snapshots, analytics, accessibility, and rollback.
5. Tradeoff: what got harder, not just what improved.

## Interoperability

- Embed SwiftUI in UIKit with `UIHostingController`.
- Embed UIKit in SwiftUI with `UIViewRepresentable` / `UIViewControllerRepresentable`.
- Keep ownership clear: UIKit coordinators/controllers should not secretly own SwiftUI source-of-truth state unless that is the chosen boundary.
- Use representable coordinators for delegate callbacks, but keep heavy business logic outside the wrapper.
- Ensure callbacks that update UI-owned state run on the main actor.

## Navigation

- During partial migrations, navigation often remains UIKit-owned while SwiftUI owns screen content.
- For new SwiftUI-only flows, prefer `NavigationStack` and typed destinations.
- Avoid duplicating navigation state in both UIKit and SwiftUI.
- For deep links, define one route model and adapt it at the UIKit/SwiftUI boundary.

## Lifecycle

- UIKit lifecycle methods and SwiftUI `.task`, `.onAppear`, and `.onDisappear` do not map one-to-one.
- `.onAppear` can run more often than expected when identity changes.
- Prefer `.task(id:)` for view-scoped async work that should cancel and restart with a changing input.
- Store long-lived state in a view model or observable model, not in representable glue.

## Rollout Strategy

- Start with leaf screens or reusable components before replacing root navigation.
- Put migrated screens behind flags when behavior risk is high.
- Use snapshot tests for visual parity and focused unit tests for state transitions.
- Track crash rate, performance, conversion/dropoff, and support feedback after rollout.
- Keep UIKit fallbacks until the SwiftUI path is proven in production.

## Common Pitfalls

- Recreating observable objects on every render.
- Mixing UIKit callbacks and SwiftUI state without main-actor isolation.
- Losing state due to identity changes.
- Moving too much business logic into `View`.
- Rebuilding navigation and design system at the same time with no rollout seam.
- Assuming SwiftUI automatically fixes performance problems that are actually data, image, or main-thread issues.

## Staff-Level Tradeoffs

- SwiftUI can improve development speed and consistency, but debugging lifecycle and identity issues requires different instincts.
- UIKit interop is powerful but can create unclear ownership if boundaries are not explicit.
- Full rewrites are rarely justified; incremental migration usually gives better risk control.
- A design system migration should define component APIs and tokens before every team independently ports screens.

