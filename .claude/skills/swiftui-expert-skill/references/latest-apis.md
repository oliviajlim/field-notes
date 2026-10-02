# SwiftUI API reference: deprecations and patterns

> **Part 1** is a matrix from Apple's documentation (Sosumi MCP). **Part 2** is narrative guidance (merged from the former `modern-apis.md` reference).

> Based on a comparison of Apple's documentation using the Sosumi MCP, we found the latest recommended APIs to use.

## Table of Contents
- [Always Use (iOS 15+)](#always-use-ios-15)
- [When Targeting iOS 16+](#when-targeting-ios-16)
- [When Targeting iOS 17+](#when-targeting-ios-17)
- [When Targeting iOS 18+](#when-targeting-ios-18)
- [When Targeting iOS 26+](#when-targeting-ios-26)
- [Narrative: Modern API patterns (extended)](#narrative-modern-api-patterns-extended)

---

## Always Use (iOS 15+)

These APIs have been deprecated long enough that there is no reason to use the old variants.

### Compact Replacements

These replacements have minimal API shape changes. Most are near-direct swaps; a few require an additional parameter or structural adjustment:

- **`navigationTitle(_:)`** instead of `navigationBarTitle(_:)`
- **`toolbar { ToolbarItem(...) }`** instead of `navigationBarItems(...)` (structural change)
- **`toolbarVisibility(.hidden, for: .navigationBar)`** instead of `navigationBarHidden(_:)`
- **`statusBarHidden(_:)`** instead of `statusBar(hidden:)`
- **`ignoresSafeArea(_:edges:)`** instead of `edgesIgnoringSafeArea(_:)`
- **`preferredColorScheme(_:)`** instead of `colorScheme(_:)`
- **`foregroundStyle(_:)`** instead of `foregroundColor(_:)` (e.g., `.foregroundStyle(.primary)`)
- **`clipShape(.rect(cornerRadius:))`** instead of `cornerRadius()`
- **`textInputAutocapitalization(_:)`** instead of `autocapitalization(_:)` (note: `.never` replaces `.none`)
- **`animation(_:value:)`** instead of `animation(_:)` (adds required `value:` parameter; back-deploys to iOS 13+)

### Presentation

- **Always use `.confirmationDialog(_:isPresented:actions:message:)`** instead of `actionSheet(...)`.
- **Always use `.alert(_:isPresented:actions:message:)`** instead of `alert(isPresented:content:)`.

Both take a title `String`, `isPresented: Binding<Bool>`, an `actions` builder with `Button` items (supporting `role: .destructive` / `.cancel`), and an optional `message` builder:

```swift
.alert("Delete Item?", isPresented: $showAlert) {
    Button("Delete", role: .destructive) { deleteItem() }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("This action cannot be undone.")
}
```

### Text Input

**Always use `onSubmit(of:_:)` and `focused(_:equals:)` instead of `TextField` `onEditingChanged`/`onCommit` callbacks.**

```swift
@FocusState private var isFocused: Bool

TextField("Search", text: $query)
    .focused($isFocused)
    .onSubmit { performSearch() }
```

### Accessibility

**Always use dedicated accessibility modifiers instead of the generic `accessibility(...)` variants.** Use `.accessibilityLabel()`, `.accessibilityValue()`, `.accessibilityHint()`, `.accessibilityAddTraits()`, `.accessibilityHidden()` instead of `.accessibility(label:)`, `.accessibility(value:)`, etc.

### Custom Environment / Container Values

**Always use the `@Entry` macro instead of manual `EnvironmentKey` conformance.** The `@Entry` macro was introduced in Xcode 16 and back-deploys to all OS versions.

```swift
// Modern — one line replaces ~10 lines of EnvironmentKey boilerplate
extension EnvironmentValues {
    @Entry var myCustomValue: String = "Default value"
}
```

### Styling

**Always use `Button` instead of `onTapGesture()` unless you need tap location or count.**

```swift
Button("Tap me") { performAction() }

// Use onTapGesture only when you need location or count
Image("photo")
    .onTapGesture(count: 2) { handleDoubleTap() }
```

---

## When Targeting iOS 16+

### Navigation

**Use `NavigationStack` (or `NavigationSplitView`) instead of `NavigationView`.** Value-based `NavigationLink(value:)` with `.navigationDestination(for:)` replaces destination-based links.

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) { Text(item.name) }
    }
    .navigationDestination(for: Item.self) { DetailView(item: $0) }
}
```

### Simple Renames

- **`tint(_:)`** instead of `accentColor(_:)`
- **`autocorrectionDisabled(_:)`** instead of `disableAutocorrection(_:)`

### Clipboard

**Prefer `PasteButton` for user-initiated paste UI** to avoid paste prompts. It handles permissions automatically. Use `UIPasteboard` only when you need programmatic or non-`Transferable` clipboard access (triggers the paste permission prompt).

```swift
PasteButton(payloadType: String.self) { strings in
    pastedText = strings.first ?? ""
}
```

---

## When Targeting iOS 17+

### State Management

- **Prefer `@Observable` over `ObservableObject` for new code.** Use `@State` instead of `@StateObject`; use `@Bindable` instead of `@ObservedObject`. See `state-management.md` for full `@Observable` migration patterns.

### Events

**Use `onChange(of:initial:_:)` or `onChange(of:) { }` instead of `onChange(of:perform:)`.**

The deprecated variant passes only the new value. The modern variants provide either both old and new values, or a no-parameter closure.

- **No-parameter** (most common): `.onChange(of: value) { doSomething() }`
- **Old and new values**: `.onChange(of: value) { old, new in ... }`
- **With initial trigger**: `.onChange(of: value, initial: true) { ... }`
- **Deprecated**: `.onChange(of: value) { newValue in ... }` — single-parameter closure

### Sensory Feedback

**Prefer `sensoryFeedback(_:trigger:)` and related overloads instead of `UIImpactFeedbackGenerator`, `UISelectionFeedbackGenerator`, and `UINotificationFeedbackGenerator` in SwiftUI views.**

Attach haptics declaratively to the view that owns the state change, rather than imperatively firing UIKit generators inside button actions.

```swift
@State private var isFavorite = false

Button("Favorite", systemImage: isFavorite ? "heart.fill" : "heart") {
    isFavorite.toggle()
}
.sensoryFeedback(.selection, trigger: isFavorite)
```

Use the conditional overload when feedback should fire only for specific transitions:

```swift
.sensoryFeedback(.selection, trigger: phase) { old, new in
    old == .inactive || new == .expanded
}
```

### Gestures

- **`MagnifyGesture`** instead of `MagnificationGesture` (access magnitude via `value.magnification`)
- **`RotateGesture`** instead of `RotationGesture` (access angle via `value.rotation`)

### Layout

**Consider `containerRelativeFrame()` or `visualEffect()` as alternatives to `GeometryReader` for sizing and position-based effects.** `GeometryReader` is not deprecated and remains necessary for many measurement-based layouts.

```swift
Image("hero")
    .resizable()
    .containerRelativeFrame(.horizontal) { length, axis in length * 0.8 }
```

- **`visualEffect { content, geometry in ... }`** — position-based effects (parallax, offsets) without a `GeometryReader` wrapper.
- **`onGeometryChange(for:of:action:)`** — react to geometry changes of a specific view; useful for driving state/effects. `GeometryReader` is still better when layout itself depends on geometry. Note the two-closure shape:
  ```swift
  .onGeometryChange(for: CGFloat.self) { proxy in proxy.size.height } action: { newHeight in height = newHeight }
  ```
- **`.coordinateSpace(.named("scroll"))`** instead of `.coordinateSpace(name: "scroll")`.

---

## When Targeting iOS 18+

### Tabs

**Use the `Tab` API instead of `tabItem(_:)`.**

```swift
TabView {
    Tab("Home", systemImage: "house") { HomeView() }
    Tab("Search", systemImage: "magnifyingglass") { SearchView() }
    Tab("Profile", systemImage: "person") { ProfileView() }
}
```

When using `Tab(role:)`, all tabs must use the `Tab` syntax. Mixing `Tab(role:)` with `.tabItem()` causes compilation errors.

### Previews

**Use `@Previewable` for dynamic properties in previews.**

```swift
// Modern (iOS 18+)
#Preview {
    @Previewable @State var isOn = false
    Toggle("Setting", isOn: $isOn)
}
```

---

## When Targeting iOS 26+

For Liquid Glass APIs (`glassEffect`, `GlassEffectContainer`, glass button styles), see [liquid-glass.md](liquid-glass.md).

### Scroll Edge Effects

**Use `scrollEdgeEffectStyle(_:for:)` to configure scroll edge behavior.**

```swift
ScrollView {
    // content
}
.scrollEdgeEffectStyle(.soft, for: .top)
```

### Background Extension

**Use `backgroundExtensionEffect()` for edge-extending blurred backgrounds.**

Views behind a Liquid Glass sidebar can appear clipped. This modifier mirrors and blurs content outside the safe area so artwork remains visible.

```swift
Image("hero")
    .backgroundExtensionEffect()
```

> Source: "Build a SwiftUI app with the new design" (WWDC25, session 323)

### Tab Bar

**Use `tabBarMinimizeBehavior(_:)` to control tab bar minimization on scroll.**

```swift
TabView {
    // tabs
}
.tabBarMinimizeBehavior(.onScrollDown)
```

**Use `tabViewBottomAccessory` for persistent controls above the tab bar.** Read `tabViewBottomAccessoryPlacement` from the environment to adapt content when the accessory collapses into the tab bar area.

```swift
TabView {
    // tabs
}
.tabViewBottomAccessory {
    NowPlayingBar()
}
```

**Use `Tab(role: .search)` for a dedicated search tab.** The tab separates from the rest and morphs into a search field when selected.

```swift
TabView {
    Tab("Home", systemImage: "house") { HomeView() }
    Tab("Profile", systemImage: "person") { ProfileView() }
    Tab(role: .search) { SearchResultsView() }
}
```

> Source: "What's new in SwiftUI" (WWDC25, session 256) and "Build a SwiftUI app with the new design" (WWDC25, session 323)

### Toolbars

**Use `ToolbarSpacer` to control grouping of toolbar items.** Fixed spacers visually separate related groups; flexible spacers push items apart.

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button("Up", systemImage: "chevron.up") { }
    }
    ToolbarItem(placement: .topBarTrailing) {
        Button("Down", systemImage: "chevron.down") { }
    }
    ToolbarSpacer(.fixed)
    ToolbarItem(placement: .topBarTrailing) {
        Button("Settings", systemImage: "gear") { }
    }
}
```

**Use `sharedBackgroundVisibility(.hidden)` to remove the glass group background from an individual toolbar item.**

```swift
ToolbarItem(placement: .topBarTrailing) {
    Image(systemName: "person.circle.fill")
        .sharedBackgroundVisibility(.hidden)
}
```

**Use `badge(_:)` on toolbar item content to display an indicator.**

```swift
ToolbarItem(placement: .topBarTrailing) {
    Button("Notifications", systemImage: "bell") { }
        .badge(unreadCount)
}
```

> Source: "Build a SwiftUI app with the new design" (WWDC25, session 323)

### Search

**Use `searchToolbarBehavior(.minimizable)` to opt into a minimized search button.** The system may automatically minimize search into a toolbar button depending on available space. Use this modifier to explicitly opt in.

```swift
NavigationStack {
    ContentView()
        .searchable(text: $query)
        .searchToolbarBehavior(.minimizable)
}
```

> Source: "Build a SwiftUI app with the new design" (WWDC25, session 323)

### Animations

**Use `@Animatable` macro instead of manual `animatableData` declarations.** The macro auto-synthesizes `animatableData` from all animatable properties. Use `@AnimatableIgnored` to exclude specific properties.

```swift
@Animatable
struct Wedge: Shape {
    var startAngle: Angle
    var endAngle: Angle
    @AnimatableIgnored var drawClockwise: Bool

    func path(in rect: CGRect) -> Path { /* ... */ }
}
```

> Source: "What's new in SwiftUI" (WWDC25, session 256)

### Presentations

**Use `navigationZoomTransition` to morph sheets out of their source view.** Toolbar items and buttons can serve as the transition source.

```swift
.toolbar {
    ToolbarItem {
        Button("Add", systemImage: "plus") { showSheet = true }
            .navigationTransitionSource(id: "addSheet", namespace: namespace)
    }
}
.sheet(isPresented: $showSheet) {
    AddItemView()
        .navigationTransitionDestination(id: "addSheet", namespace: namespace)
}
```

> Source: "Build a SwiftUI app with the new design" (WWDC25, session 323)

### Controls

**Use `controlSize(.extraLarge)` for extra-large prominent action buttons.**

```swift
Button("Get Started") { }
    .buttonStyle(.borderedProminent)
    .controlSize(.extraLarge)
```

**Use `concentric` corner style for buttons that match their container's corners.**

```swift
Button("Confirm") { }
    .clipShape(.rect(cornerRadius: 12, style: .concentric))
```

**Sliders now support tick marks and a neutral value.**

```swift
Slider(value: $speed, in: 0.5...2.0, step: 0.25) {
    Text("Speed")
} ticks: {
    SliderTick(value: 0.6)
    SliderTick(value: 0.9)
}
.sliderNeutralValue(1.0)
```

> Source: "Build a SwiftUI app with the new design" (WWDC25, session 323)

### Rich Text

**Use `TextEditor` with an `AttributedString` binding for rich text editing.** Supports bold, italic, underline, strikethrough, custom fonts, foreground/background colors, paragraph styles, and Genmoji.

```swift
@State private var text: AttributedString = "Hello, world!"

var body: some View {
    TextEditor(text: $text)
}
```

> Source: "Cook up a rich text experience in SwiftUI with AttributedString" (WWDC25, session 280)

### Web Content

**Use `WebView` to display web content.** For richer interaction, create a `WebPage` observable model.

```swift
// Simple URL display
WebView(url: URL(string: "https://example.com")!)

// With observable model
@State private var page = WebPage()

WebView(page)
    .onAppear { page.load(URLRequest(url: myURL)) }
    .navigationTitle(page.title ?? "")
```

> Source: "Meet WebKit for SwiftUI" (WWDC25, session 231)

### Drag and Drop

**Use `dragContainer` for multi-item drag operations.** Combine with `DragConfiguration` for custom drag behavior and `onDragSessionUpdated` to observe events.

```swift
PhotoGrid(photos: photos)
    .dragContainer(for: Photo.self) { selection in
        return selection.map { $0.transferable }
    }
    .onDragSessionUpdated { session in
        if session.phase == .endedWithDelete {
            deleteSelectedPhotos()
        }
    }
```

> Source: "What's new in SwiftUI" (WWDC25, session 256)

### Scene Bridging

**UIKit and AppKit lifecycle apps can now request SwiftUI scenes.** This enables using SwiftUI-only scene types like `MenuBarExtra` and `ImmersiveSpace` from imperative lifecycle apps via `UIApplication.shared.activateSceneSession(for:errorHandler:)`.

> Source: "What's new in SwiftUI" (WWDC25, session 256)

---

## Quick Lookup Table

| Deprecated | Recommended | Since |
|-----------|-------------|-------|
| `navigationBarTitle(_:)` | `navigationTitle(_:)` | iOS 15+ |
| `navigationBarItems(...)` | `toolbar { ToolbarItem(...) }` | iOS 15+ |
| `navigationBarHidden(_:)` | `toolbarVisibility(.hidden, for: .navigationBar)` | iOS 15+ |
| `statusBar(hidden:)` | `statusBarHidden(_:)` | iOS 15+ |
| `edgesIgnoringSafeArea(_:)` | `ignoresSafeArea(_:edges:)` | iOS 15+ |
| `colorScheme(_:)` | `preferredColorScheme(_:)` | iOS 15+ |
| `foregroundColor(_:)` | `foregroundStyle(_:)` | iOS 15+ |
| `cornerRadius(_:)` | `clipShape(.rect(cornerRadius:))` | iOS 15+ |
| `actionSheet(...)` | `confirmationDialog(...)` | iOS 15+ |
| `alert(isPresented:content:)` | `alert(_:isPresented:actions:message:)` | iOS 15+ |
| `autocapitalization(_:)` | `textInputAutocapitalization(_:)` | iOS 15+ |
| `accessibility(label:)` etc. | `accessibilityLabel()` etc. | iOS 15+ |
| `TextField` `onCommit`/`onEditingChanged` | `onSubmit` + `focused` | iOS 15+ |
| `animation(_:)` (no value) | `animation(_:value:)` | Back-deploys (iOS 13+) |
| Manual `EnvironmentKey` | `@Entry` macro | Back-deploys (Xcode 16+) |
| `NavigationView` | `NavigationStack` / `NavigationSplitView` | iOS 16+ |
| `accentColor(_:)` | `tint(_:)` | iOS 16+ |
| `disableAutocorrection(_:)` | `autocorrectionDisabled(_:)` | iOS 16+ |
| `UIPasteboard.general` | `PasteButton` | iOS 16+ |
| `onChange(of:perform:)` | `onChange(of:) { }` or `onChange(of:) { old, new in }` | iOS 17+ |
| `UIImpactFeedbackGenerator` / `UISelectionFeedbackGenerator` / `UINotificationFeedbackGenerator` | `sensoryFeedback(_:trigger:)` | iOS 17+ |
| `MagnificationGesture` | `MagnifyGesture` | iOS 17+ |
| `RotationGesture` | `RotateGesture` | iOS 17+ |
| `coordinateSpace(name:)` | `coordinateSpace(.named(...))` | iOS 17+ |
| `ObservableObject` | `@Observable` | iOS 17+ |
| `tabItem(_:)` | `Tab` API | iOS 18+ |
| Manual `animatableData` | `@Animatable` macro | iOS 26+ |
| `presentationBackground(_:)` on sheets | Default Liquid Glass sheet material | iOS 26+ |
| Custom toolbar background hacks | `scrollEdgeEffectStyle(_:for:)` | iOS 26+ |

---

## Narrative: Modern API patterns (extended)

Example-first guidance that complements the deprecation matrix above. For authoritative **deprecated → modern** names, use **Part 1** (sections by OS version); this part adds code samples and rationale.

### Overview

This reference covers modern SwiftUI API usage patterns and deprecated API replacements. Always use the latest APIs to ensure forward compatibility and access to new features.

### Styling and Appearance

#### foregroundStyle() vs foregroundColor()

**Always use `foregroundStyle()` instead of `foregroundColor()`.**

```swift
// Modern (Correct)
Text("Hello")
    .foregroundStyle(.primary)

Image(systemName: "star")
    .foregroundStyle(.blue)

// Legacy (Avoid)
Text("Hello")
    .foregroundColor(.primary)
```

**Why**: `foregroundStyle()` supports hierarchical styles, gradients, and materials, making it more flexible and future-proof.

#### clipShape() vs cornerRadius()

**Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`.**

```swift
// Modern (Correct)
Image("photo")
    .clipShape(.rect(cornerRadius: 12))

VStack {
    // content
}
.clipShape(.rect(cornerRadius: 16))

// Legacy (Avoid)
Image("photo")
    .cornerRadius(12)
```

**Why**: `cornerRadius()` is deprecated. `clipShape()` is more explicit and supports all shape types.

#### fontWeight() vs bold()

**Don't apply `fontWeight()` unless there's a good reason. Always use `bold()` for bold text.**

```swift
// Correct
Text("Important")
    .bold()

// Avoid (unless you need a specific weight)
Text("Important")
    .fontWeight(.bold)

// Acceptable (specific weight needed)
Text("Semibold")
    .fontWeight(.semibold)
```

### Navigation

#### NavigationStack vs NavigationView

**Always use `NavigationStack` instead of `NavigationView`.**

```swift
// Modern (Correct)
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            Text(item.name)
        }
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}

// Legacy (Avoid)
NavigationView {
    List(items) { item in
        NavigationLink(destination: DetailView(item: item)) {
            Text(item.name)
        }
    }
}
```

#### navigationDestination(for:)

**Use `navigationDestination(for:)` for type-safe navigation.**

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Profile", value: Route.profile)
                NavigationLink("Settings", value: Route.settings)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .profile:
                    ProfileView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }
}

enum Route: Hashable {
    case profile
    case settings
}
```

### Tabs

#### Tab API vs tabItem()

**For iOS 18 and later, prefer the `Tab` API over `tabItem()` to access modern tab features, and use availability checks or `tabItem()` for earlier OS versions.**

```swift
// Modern (Correct) - iOS 18+
TabView {
    Tab("Home", systemImage: "house") {
        HomeView()
    }
    
    Tab("Search", systemImage: "magnifyingglass") {
        SearchView()
    }
    
    Tab("Profile", systemImage: "person") {
        ProfileView()
    }
}

// Legacy (Avoid)
TabView {
    HomeView()
        .tabItem {
            Label("Home", systemImage: "house")
        }
}
```

**Important**: When using `Tab(role:)` with roles, you must use the new `Tab { } label: { }` syntax for all tabs. Mixing with `.tabItem()` causes compilation errors.

```swift
// Correct - all tabs use Tab syntax
TabView {
    Tab(role: .search) {
        SearchView()
    } label: {
        Label("Search", systemImage: "magnifyingglass")
    }
    
    Tab {
        HomeView()
    } label: {
        Label("Home", systemImage: "house")
    }
}

// Wrong - mixing Tab and tabItem causes errors
TabView {
    Tab(role: .search) {
        SearchView()
    } label: {
        Label("Search", systemImage: "magnifyingglass")
    }
    
    HomeView()  // Error: can't mix with Tab(role:)
        .tabItem {
            Label("Home", systemImage: "house")
        }
}
```

### Interactions

#### Button vs onTapGesture()

**Never use `onTapGesture()` unless you specifically need tap location or tap count. Always use `Button` otherwise.**

```swift
// Correct - standard tap action
Button("Tap me") {
    performAction()
}

// Correct - need tap location
Text("Tap anywhere")
    .onTapGesture { location in
        handleTap(at: location)
    }

// Correct - need tap count
Image("photo")
    .onTapGesture(count: 2) {
        handleDoubleTap()
    }

// Wrong - use Button instead
Text("Tap me")
    .onTapGesture {
        performAction()
    }
```

**Why**: `Button` provides proper accessibility, visual feedback, and semantic meaning. Use `onTapGesture()` only when you need its specific features.

#### Button with Images

**Always specify text alongside images in buttons for accessibility.**

```swift
// Correct - includes text label
Button("Add Item", systemImage: "plus") {
    addItem()
}

// Also correct - custom label
Button {
    addItem()
} label: {
    Label("Add Item", systemImage: "plus")
}

// Wrong - image only, no text
Button {
    addItem()
} label: {
    Image(systemName: "plus")
}
```

### Layout and Sizing

#### Avoid UIScreen.main.bounds

**Never use `UIScreen.main.bounds` to read available space.**

```swift
// Wrong - uses UIKit, doesn't respect safe areas
let screenWidth = UIScreen.main.bounds.width

// Correct - use GeometryReader
GeometryReader { geometry in
    Text("Width: \(geometry.size.width)")
}

// Better - use containerRelativeFrame (iOS 17+)
Text("Full width")
    .containerRelativeFrame(.horizontal)

// Best - let SwiftUI handle sizing
Text("Auto-sized")
    .frame(maxWidth: .infinity)
```

#### GeometryReader Alternatives

> **iOS 17+**: `containerRelativeFrame` and `visualEffect` require iOS 17 or later.

**Don't use `GeometryReader` if a newer alternative works.**

```swift
// Modern - containerRelativeFrame
Image("hero")
    .resizable()
    .containerRelativeFrame(.horizontal) { length, axis in
        length * 0.8
    }

// Modern - visualEffect for position-based effects
Text("Parallax")
    .visualEffect { content, geometry in
        content.offset(y: geometry.frame(in: .global).minY * 0.5)
    }

// Legacy - only use if necessary
GeometryReader { geometry in
    Image("hero")
        .frame(width: geometry.size.width * 0.8)
}
```

### Type Erasure

#### Avoid AnyView

**Avoid `AnyView` unless absolutely required.**

```swift
// Prefer - use @ViewBuilder
@ViewBuilder
func content() -> some View {
    if condition {
        Text("Option A")
    } else {
        Image(systemName: "photo")
    }
}

// Avoid - type erasure has performance cost
func content() -> AnyView {
    if condition {
        return AnyView(Text("Option A"))
    } else {
        return AnyView(Image(systemName: "photo"))
    }
}

// Acceptable - when protocol conformance requires it
var body: some View {
    // Complex conditional logic that requires type erasure
}
```

### Styling Best Practices

#### Dynamic Type

**Don't force specific font sizes. Prefer Dynamic Type.**

```swift
// Correct - respects user's text size preferences
Text("Title")
    .font(.title)

Text("Body")
    .font(.body)

// Avoid - fixed size doesn't scale
Text("Title")
    .font(.system(size: 24))
```

#### UIKit Colors

**Avoid using UIKit colors in SwiftUI code.**

```swift
// Correct - SwiftUI colors
Text("Hello")
    .foregroundStyle(.blue)
    .background(.gray.opacity(0.2))

// Wrong - UIKit colors
Text("Hello")
    .foregroundColor(Color(UIColor.systemBlue))
    .background(Color(UIColor.systemGray))
```

### Static Member Lookup

**Prefer static member lookup to struct instances.**

```swift
// Correct - static member lookup
Circle()
    .fill(.blue)
Button("Action") { }
    .buttonStyle(.borderedProminent)

// Verbose - unnecessary struct instantiation
Circle()
    .fill(Color.blue)
Button("Action") { }
    .buttonStyle(BorderedProminentButtonStyle())
```

### Summary Checklist

- [ ] Use `foregroundStyle()` instead of `foregroundColor()`
- [ ] Use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`
- [ ] Use `Tab` API instead of `tabItem()`
- [ ] Use `Button` instead of `onTapGesture()` (unless need location/count)
- [ ] Use `NavigationStack` instead of `NavigationView`
- [ ] Use `navigationDestination(for:)` for type-safe navigation
- [ ] Avoid `AnyView` unless required
- [ ] Avoid `UIScreen.main.bounds`
- [ ] Avoid `GeometryReader` when alternatives exist
- [ ] Use Dynamic Type instead of fixed font sizes
- [ ] Avoid hard-coded padding/spacing unless requested
- [ ] Avoid UIKit colors in SwiftUI
- [ ] Use static member lookup (`.blue` vs `Color.blue`)
- [ ] Include text labels with button images
- [ ] Use `bold()` instead of `fontWeight(.bold)`
