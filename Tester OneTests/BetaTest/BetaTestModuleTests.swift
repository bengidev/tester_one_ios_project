import XCTest
@testable import Tester_One

// MARK: - BetaTestModuleTests

final class BetaTestModuleTests: XCTestCase {
  private enum TestTiming {
    static let timeout: TimeInterval = 3.0
    static let retryTimeout: TimeInterval = 4.0
  }

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
    wait(for: [exp], timeout: TestTiming.timeout)
  }

  @MainActor
  func testEndToEndRunEmitsStepEventsAndFinishes() {
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          .init(title: "CPU", icon: .cpu, initialState: .success, simulatedDuration: 0.05),
          .init(title: "Battery", icon: .battery, initialState: .success, simulatedDuration: 0.05),
        ]
      )
    )

    var started = [Int]()
    var completed = [Int]()
    let exp = expectation(description: "run completed")

    vc.onProcessingEvent = { event in
      switch event {
      case .stepStarted(let step):
        started.append(step.index)
      case .stepCompleted(let result):
        completed.append(result.index)
      case .runCompleted(let results):
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.map(\.state), [.success, .success])
        exp.fulfill()
      }
    }

    _ = vc.view
    vc.beginProcessing()

    wait(for: [exp], timeout: TestTiming.timeout)
    XCTAssertEqual(started, [0, 1])
    XCTAssertEqual(completed, [0, 1])
    XCTAssertEqual(vc.debug_runPhase(), .finished)
  }

  @MainActor
  func testFailureThenRetryPathCompletesSuccessfully() {
    let provider = RetryAwareExecutionProvider()
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          .init(title: "CPU", icon: .cpu, initialState: .failed, retryState: .success, simulatedDuration: 0.05)
        ]
      ),
      executionProvider: provider,
    )

    let runCompleted = expectation(description: "initial run completed with failure")
    let retryCompleted = expectation(description: "retry completed with success")

    vc.onProcessingEvent = { event in
      switch event {
      case .runCompleted(let results):
        XCTAssertEqual(results.first?.state, .failed)
        runCompleted.fulfill()
      default:
        break
      }
    }

    vc.onRetryCompleted = { result in
      XCTAssertEqual(result.index, 0)
      XCTAssertEqual(result.state, .success)
      retryCompleted.fulfill()
    }

    _ = vc.view
    vc.beginProcessing()

    wait(for: [runCompleted], timeout: TestTiming.timeout)
    vc.debug_triggerRetry(at: 0)
    wait(for: [retryCompleted], timeout: TestTiming.retryTimeout)
    XCTAssertEqual(vc.debug_itemState(at: 0), .success)
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

private final class RetryAwareExecutionProvider: BetaTestExecutionProviding {
  func execute(
    item: BetaTestModuleConfiguration.Item,
    phase: BetaTestItem.ExecutionPhase,
    completion: @escaping (BetaTestCardState) -> Void,
  ) {
    switch phase {
    case .initial:
      completion(item.initialState)
    case .retry:
      completion(item.retryState)
    }
  }
}
