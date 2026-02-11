# State Machine Templates (UIKit)

## Goal
Use explicit state transitions for deterministic UI behavior.

## Template A: Screen state
```swift
enum ScreenState {
  case idle
  case loading
  case loaded([Item])
  case failed(Error)
}
```

## Template B: Latest-intent-wins tokening
```swift
private var activeToken = UUID()

func load() {
  let token = UUID()
  activeToken = token
  state = .loading
  service.fetch { [weak self] result in
    guard let self, self.activeToken == token else { return }
    self.state = result.map(ScreenState.loaded) ?? .failed(MyError.failed)
  }
}
```

## Template C: Per-row retry guard
```swift
private var retryTokens = [ID: UUID]()

func retry(id: ID) {
  let token = UUID()
  retryTokens[id] = token
  setRowState(id, .loading)
  service.retry(id: id) { [weak self] success in
    guard let self, self.retryTokens[id] == token else { return }
    self.setRowState(id, success ? .success : .failed)
  }
}
```

## Rules
- One state owner per concern.
- Always guard async completions.
- Render through explicit state, not scattered mutations.
