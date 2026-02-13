import Foundation

// MARK: - BetaTestExecutionProviding

protocol BetaTestExecutionProviding {
  func execute(
    item: BetaTestModuleConfiguration.Item,
    phase: BetaTestItem.ExecutionPhase,
    completion: @escaping (BetaTestCardState) -> Void,
  )
}

// MARK: - BetaTestDefaultExecutionProvider

struct BetaTestDefaultExecutionProvider: BetaTestExecutionProviding {
  func execute(
    item: BetaTestModuleConfiguration.Item,
    phase: BetaTestItem.ExecutionPhase,
    completion: @escaping (BetaTestCardState) -> Void,
  ) {
    let state = phase == .initial ? item.initialState : item.retryState
    DispatchQueue.main.asyncAfter(deadline: .now() + item.simulatedDuration) {
      completion(state)
    }
  }
}
