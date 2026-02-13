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
    let item = BetaTestItem(title: "Tes Kartu SIM #1", icon: .sim, state: .initial)
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

    wait(for: [exp], timeout: 1.0)

    XCTAssertEqual(sut.debug_runPhase(), .finished)
    XCTAssertEqual(capturedResults.count, 12)
    XCTAssertEqual(capturedResults[6].state, .failed)
  }

  @MainActor
  func testRetryFlowIgnoresStaleCompletionWhenNewRunStarts() {
    let sut = BetaTestViewController(items: makeFixtureItems())
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
    let sut = BetaTestViewController(items: makeFixtureItems())
    _ = sut.view

    sut.setState(.initial, at: 0)
    let first = sut.debug_itemState(at: 0)

    sut.setState(.initial, at: 0)
    let second = sut.debug_itemState(at: 0)

    XCTAssertEqual(first, .initial)
    XCTAssertEqual(second, .initial)
  }

  // MARK: Private

  private func makeFixtureItems() -> [BetaTestItem] {
    [
      makeFixtureItem(title: "Tester", icon: .jailbreak, initialState: .success),
      makeFixtureItem(title: "CPU", icon: .cpu, initialState: .success),
      makeFixtureItem(title: "Hard Disk", icon: .hardDisk, initialState: .success),
      makeFixtureItem(title: "Kondisi Baterai", icon: .battery, initialState: .success),
      makeFixtureItem(title: "Tes Jailbreak", icon: .jailbreak, initialState: .success),
      makeFixtureItem(title: "Tes Biometric 1", icon: .biometricOne, initialState: .success),
      makeFixtureItem(title: "Tombol Silent", icon: .silent, initialState: .failed),
      makeFixtureItem(title: "Tombol Volume", icon: .volume, initialState: .success),
      makeFixtureItem(title: "Tombol On/Off", icon: .power, initialState: .success),
      makeFixtureItem(title: "Tes Kamera", icon: .camera, initialState: .success),
      makeFixtureItem(title: "Tes Layar Sentuh", icon: .touch, initialState: .success),
      makeFixtureItem(title: "Tes Kartu SIM", icon: .sim, initialState: .success),
    ]
  }

  private func makeFixtureItem(
    title: String,
    icon: BetaTestItem.IconType,
    initialState: BetaTestCardState,
    retryState: BetaTestCardState = .success,
    simulatedDuration: TimeInterval = 0.01,
  ) -> BetaTestItem {
    BetaTestItem(
      title: title,
      icon: icon,
      state: .initial,
      executionHandler: { phase, continueExecutionWithState in
        let state: BetaTestCardState = (phase == .initial) ? initialState : retryState
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedDuration) {
          continueExecutionWithState(state)
        }
      },
    )
  }
}
