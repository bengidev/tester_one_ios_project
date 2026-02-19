//
//  Tester_OneTests.swift
//  Tester OneTests
//

import XCTest
@testable import Tester_One

final class Tester_OneTests: XCTestCase {

  // MARK: Internal

  @MainActor
  func testBetaTestItemAccessibilityTokenNormalization() {
    let item = BetaTestItem(title: "Tes Kartu SIM #1", state: .initial)
    XCTAssertEqual(item.accessibilityToken, "tes_kartu_sim_1")
  }

  @MainActor
  func testBeginProcessingTransitionsToFinishedAndReturnsResults() {
    let sut = BetaTestViewController(items: makeFixtureItems())
    _ = sut.view

    let exp = expectation(description: "processing completed")
    var capturedResults = [BetaTestViewController.ProcessResult]()

    sut.onProcessingEvent = { event in
      if case .runCompleted(let results) = event {
        capturedResults = results
        exp.fulfill()
      }
    }

    sut.beginProcessing()

    wait(for: [exp], timeout: TestTiming.timeout)

    XCTAssertEqual(capturedResults.count, 12)
    XCTAssertEqual(capturedResults[6].state, .failed)
  }

  @MainActor
  func testRetryFlowIgnoresStaleCompletionWhenNewRunStarts() {
    let sut = BetaTestViewController(items: makeFixtureItems())
    _ = sut.view

    // Make index 0 retryable.
    sut.setState(.failed, at: 0)
    sut.retryItem(at: 0)

    // Start a new processing run before retry callback resolves.
    sut.beginProcessing()

    let exp = expectation(description: "new run completed")
    var completedResults = [BetaTestViewController.ProcessResult]()
    sut.onProcessingEvent = { event in
      if case .runCompleted(let results) = event {
        completedResults = results
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: TestTiming.timeout)

    XCTAssertEqual(completedResults.first?.state, .success)
  }

  @MainActor
  func testSetStateNoOpKeepsStateStable() {
    let sut = BetaTestViewController(items: makeFixtureItems())
    _ = sut.view

    sut.setState(.failed, at: 0)
    sut.setState(.failed, at: 0)

    let retryCompleted = expectation(description: "retry completed")
    sut.onRetryCompleted = { result in
      XCTAssertEqual(result.index, 0)
      XCTAssertEqual(result.state, .success)
      retryCompleted.fulfill()
    }

    sut.retryItem(at: 0)
    wait(for: [retryCompleted], timeout: TestTiming.timeout)
  }

  @MainActor
  func testBeginProcessingEmitsStepStartedInOrder() {
    let sut = BetaTestViewController(items: makeFixtureItems())
    _ = sut.view

    let exp = expectation(description: "run completed")
    var startedIndexes = [Int]()

    sut.onProcessingEvent = { event in
      switch event {
      case .stepStarted(let step):
        startedIndexes.append(step.index)
      case .runCompleted:
        exp.fulfill()
      default:
        break
      }
    }

    sut.beginProcessing()
    wait(for: [exp], timeout: TestTiming.timeout)

    XCTAssertEqual(startedIndexes, Array(0..<12))
  }

  @MainActor
  func testRetryIgnoredWhileProcessingRunIsActive() {
    var items = makeFixtureItems()
    items[0] = makeFixtureItem(
      title: "Tester",
      initialResult: .failed,
      simulatedDuration: 0.10,
    )

    let sut = BetaTestViewController(items: items)
    _ = sut.view

    let runCompleted = expectation(description: "run completed")
    var runResults = [BetaTestViewController.ProcessResult]()
    let retryShouldNotFire = expectation(description: "retry callback should stay idle")
    retryShouldNotFire.isInverted = true

    sut.onRetryCompleted = { _ in
      retryShouldNotFire.fulfill()
    }

    sut.onProcessingEvent = { event in
      switch event {
      case .stepCompleted(let result) where result.index == 0:
        sut.retryItem(at: 0)

      case .runCompleted(let results):
        runResults = results
        runCompleted.fulfill()

      default:
        break
      }
    }

    sut.beginProcessing()

    wait(for: [runCompleted], timeout: TestTiming.timeout)
    wait(for: [retryShouldNotFire], timeout: TestTiming.settle)
    XCTAssertEqual(runResults.first?.state, .failed)
  }

  @MainActor
  func testRetryEmitsStepStartedWithRetryPhase() {
    var items = makeFixtureItems()
    items[0] = makeFixtureItem(
      title: "Tester",
      initialResult: .failed,
      retryResult: .success,
    )

    let sut = BetaTestViewController(items: items)
    _ = sut.view

    sut.setState(.failed, at: 0)

    let retryStarted = expectation(description: "retry started event")
    let retryCompleted = expectation(description: "retry completed")

    sut.onProcessingEvent = { event in
      switch event {
      case .stepStarted(let step) where step.index == 0 && step.phase == .retry:
        retryStarted.fulfill()
      case .stepCompleted(let result) where result.index == 0 && result.state == .success:
        retryCompleted.fulfill()
      default:
        break
      }
    }

    sut.retryItem(at: 0)

    wait(for: [retryStarted, retryCompleted], timeout: TestTiming.timeout)
  }

  @MainActor
  func testSmartFollowCompletesForLongDynamicList() {
    let longItems = (1...24).map { index in
      makeFixtureItem(
        title: "Item \(index) lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        initialResult: .success,
        simulatedDuration: 0.03,
      )
    }

    let sut = BetaTestViewController(items: longItems)
    _ = sut.view

    let completed = expectation(description: "long run completed")
    var completedResults = [BetaTestViewController.ProcessResult]()
    sut.onProcessingEvent = { event in
      if case .runCompleted(let results) = event {
        completedResults = results
        completed.fulfill()
      }
    }

    sut.beginProcessing()
    wait(for: [completed], timeout: TestTiming.timeout)

    XCTAssertEqual(completedResults.count, longItems.count)
  }

  // MARK: Private

  private enum TestTiming {
    static let settle: TimeInterval = 0.10
    static let timeout: TimeInterval = 3.0
  }

  private func makeFixtureItems() -> [BetaTestItem] {
    [
      makeFixtureItem(title: "Tester", initialResult: .success),
      makeFixtureItem(title: "CPU", initialResult: .success),
      makeFixtureItem(title: "Hard Disk", initialResult: .success),
      makeFixtureItem(title: "Kondisi Baterai", initialResult: .success),
      makeFixtureItem(title: "Tes Jailbreak", initialResult: .success),
      makeFixtureItem(title: "Tes Biometric 1", initialResult: .success),
      makeFixtureItem(title: "Tombol Silent", initialResult: .failed),
      makeFixtureItem(title: "Tombol Volume", initialResult: .success),
      makeFixtureItem(title: "Tombol On/Off", initialResult: .success),
      makeFixtureItem(title: "Tes Kamera", initialResult: .success),
      makeFixtureItem(title: "Tes Layar Sentuh", initialResult: .success),
      makeFixtureItem(title: "Tes Kartu SIM", initialResult: .success),
    ]
  }

  private func makeFixtureItem(
    title: String,
    initialResult: BetaTestCardState,
    retryResult: BetaTestCardState = .success,
    simulatedDuration: TimeInterval = 0.01,
  ) -> BetaTestItem {
    BetaTestItem(
      title: title,
      state: .initial,
      executionHandler: { phase, continueExecutionWithState in
        let state: BetaTestCardState =
          switch phase {
          case .initial:
            initialResult
          case .retry:
            retryResult
          }

        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedDuration) {
          continueExecutionWithState(state)
        }
      },
    )
  }
}
