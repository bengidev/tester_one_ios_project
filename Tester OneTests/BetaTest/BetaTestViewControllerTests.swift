//
//  Tester_OneTests.swift
//  Tester OneTests
//

import XCTest
@testable import Tester_One

final class Tester_OneTests: XCTestCase {

  @MainActor
  func testBetaTestItemAccessibilityTokenNormalization() {
    let item = BetaTestItem(title: "Tes Kartu SIM #1", icon: .sim, state: .initial)
    XCTAssertEqual(item.accessibilityToken, "tes_kartu_sim_1")
  }

  @MainActor
  func testBeginProcessingTransitionsToFinishedAndReturnsResults() {
    let sut = BetaTestViewController()
    _ = sut.view

    let exp = expectation(description: "processing completed")
    var capturedResults = [BetaTestViewController.ProcessResult]()

    sut.onProcessingEvent = { event in
      if case let .runCompleted(results) = event {
        capturedResults = results
        exp.fulfill()
      }
    }

    sut.beginProcessing()

    wait(for: [exp], timeout: 1.0)

    XCTAssertEqual(sut.debug_runPhase(), .finished)
    XCTAssertEqual(capturedResults.count, 12)
    XCTAssertEqual(capturedResults[6].state, .failed)
  }

  @MainActor
  func testRetryFlowIgnoresStaleCompletionWhenNewRunStarts() {
    let sut = BetaTestViewController()
    _ = sut.view

    // Make index 0 retryable.
    sut.setState(.failed, at: 0)
    sut.debug_triggerRetry(at: 0)

    // Start a new processing run before retry callback resolves.
    sut.beginProcessing()

    let exp = expectation(description: "new run completed")
    sut.onProcessingEvent = { event in
      if case .runCompleted = event {
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1.0)

    // New run should complete using each item's configured execution handler (index 0 success).
    XCTAssertEqual(sut.debug_itemState(at: 0), .success)
    XCTAssertEqual(sut.debug_runPhase(), .finished)
  }

  @MainActor
  func testSetStateNoOpKeepsStateStable() {
    let sut = BetaTestViewController()
    _ = sut.view

    sut.setState(.initial, at: 0)
    let first = sut.debug_itemState(at: 0)

    sut.setState(.initial, at: 0)
    let second = sut.debug_itemState(at: 0)

    XCTAssertEqual(first, .initial)
    XCTAssertEqual(second, .initial)
  }
}
