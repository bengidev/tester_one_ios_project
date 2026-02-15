import XCTest
@testable import Tester_One

// MARK: - BetaTestModuleTests

final class BetaTestModuleTests: XCTestCase {
  @MainActor
  func testFactoryCreatesViewControllerWithConfiguredScreenTitle() {
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          .init(title: "CPU", icon: .cpu, initialState: .success)
        ],
        layoutStrategy: .adaptiveMosaic,
        screen: .init(title: "Custom Check"),
      )
    )

    _ = vc.view
    XCTAssertEqual(vc.title, "Custom Check")
  }

  @MainActor
  func testFactoryInjectedExecutionProviderIsUsed() {
    let provider = MockExecutionProvider()
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          .init(title: "CPU", icon: .cpu, initialState: .failed, retryState: .failed)
        ]
      ),
      executionProvider: provider,
    )

    let exp = expectation(description: "run completed")
    vc.onProcessingEvent = { event in
      if case .runCompleted(let results) = event {
        XCTAssertEqual(results.first?.state, .success)
        exp.fulfill()
      }
    }

    _ = vc.view
    vc.beginProcessing()
    wait(for: [exp], timeout: 3.0)
  }
}

// MARK: - MockExecutionProvider

private final class MockExecutionProvider: BetaTestExecutionProviding {
  func execute(
    item _: BetaTestModuleConfiguration.Item,
    phase _: BetaTestItem.ExecutionPhase,
    completion: @escaping (BetaTestCardState) -> Void,
  ) {
    completion(.success)
  }
}
