import XCTest
@testable import Tester_One

// MARK: - BetaTestModuleTests

final class BetaTestModuleTests: XCTestCase {

  // MARK: Internal

  @MainActor
  func testFactoryCreatesViewControllerWithConfiguredScreenTitle() {
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          makeItem(title: "CPU", initialIconAssetName: "cpuImage", initialResult: .success)
        ],
        layoutStrategy: .adaptiveMosaic,
        screen: .init(title: "Custom Check"),
      )
    )

    _ = vc.view
    XCTAssertEqual(vc.title, "Custom Check")
  }

  @MainActor
  func testFactoryWiresModuleLevelCallbacksFromConfiguration() {
    let callbackFired = expectation(description: "config callback fired")
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          makeItem(title: "CPU", initialIconAssetName: "cpuImage", initialResult: .success)
        ],
        onProcessingEvent: { event in
          if case .runCompleted = event {
            callbackFired.fulfill()
          }
        },
      )
    )

    _ = vc.view
    vc.beginProcessing()
    wait(for: [callbackFired], timeout: TestTiming.timeout)
  }

  @MainActor
  func testFactoryUsesItemExecutionHandlers() {
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          makeItem(title: "CPU", initialIconAssetName: "cpuImage", initialResult: .success)
        ]
      )
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
          makeItem(
            title: "CPU",
            initialIconAssetName: "cpuImage",
            initialResult: .success,
            simulatedDuration: 0.05,
          ),
          makeItem(
            title: "Battery",
            initialIconAssetName: "batteryImage",
            initialResult: .success,
            simulatedDuration: 0.05,
          ),
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
  }

  @MainActor
  func testFailureThenRetryPathCompletesSuccessfully() {
    let vc = BetaTestModule.makeViewController(
      configuration: .init(
        items: [
          makeItem(
            title: "CPU",
            initialIconAssetName: "cpuImage",
            initialResult: .failed,
            retryResult: .success,
            simulatedDuration: 0.05,
          )
        ]
      )
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
    vc.retryItem(at: 0)
    wait(for: [retryCompleted], timeout: TestTiming.retryTimeout)
  }

  // MARK: Private

  private enum TestTiming {
    static let timeout: TimeInterval = 3.0
    static let retryTimeout: TimeInterval = 4.0
  }

  private func makeItem(
    title: String,
    initialIconAssetName: String? = nil,
    initialResult: BetaTestCardState,
    retryResult: BetaTestCardState = .success,
    simulatedDuration: TimeInterval = 0.01,
  ) -> BetaTestModuleConfiguration.Item {
    BetaTestModuleConfiguration.Item(
      title: title,
      initialIconAssetName: initialIconAssetName,
      executionHandler: { phase, completion in
        let result: BetaTestCardState =
          switch phase {
          case .initial:
            initialResult
          case .retry:
            retryResult
          }
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedDuration) {
          completion(result)
        }
      },
    )
  }

}
