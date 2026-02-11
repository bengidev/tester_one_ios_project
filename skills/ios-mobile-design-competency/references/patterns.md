# iOS Mobile Design Competency — Patterns & Snippets

## SwiftUI snippets

### NavigationStack routing
```swift
NavigationStack {
  List(items) { item in
    NavigationLink(value: item) {
      Row(item: item)
    }
  }
  .navigationDestination(for: Item.self) { item in
    DetailView(item: item)
  }
}
```

### TabView
```swift
TabView {
  HomeView()
    .tabItem { Label("Home", systemImage: "house") }

  SettingsView()
    .tabItem { Label("Settings", systemImage: "gear") }
}
```

### Sheet / full screen cover
```swift
.sheet(isPresented: $showingSheet) {
  SheetView()
}
.fullScreenCover(isPresented: $showingFullScreen) {
  FullScreenView()
}
```

### Dynamic Type friendly text
- Prefer semantic styles:
```swift
Text(title)
  .font(.headline)
```
- Avoid fixed frames that truncate.

### Accessibility
```swift
Button("Save") { save() }
  .accessibilityLabel("Save")
  .accessibilityHint("Saves your changes")
```

## UIKit snippets

### Auto Layout anchors
```swift
view.addSubview(stack)
stack.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
  stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
  stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
  stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
])
```

### Dynamic Type (UIKit)
```swift
label.font = .preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
label.numberOfLines = 0
```

### SF Symbols
```swift
imageView.image = UIImage(systemName: "star.fill")
```

### Accessibility
```swift
button.accessibilityLabel = "Save"
button.accessibilityHint = "Saves your changes"
button.accessibilityTraits.insert(.button)
```

## Practical review checklist (copy/paste)
- Safe areas respected
- 44x44pt tappables
- Semantic colors (no hard-coded hex)
- Semantic fonts + Dynamic Type
- Dark Mode + increased contrast checked
- VoiceOver labels/traits/focus order
- iPad layout decisions are intentional
