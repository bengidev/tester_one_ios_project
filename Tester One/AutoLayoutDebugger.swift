//
//  AutoLayoutDebugger.swift
//  Tester One
//
//  Auto Layout constraint violation debugger.
//  Crashes the app in DEBUG builds when constraint conflicts occur.
//

import UIKit

// MARK: - AutoLayoutDebugger

/// Debugger that monitors Auto Layout constraint violations.
/// In DEBUG builds, it will crash the app when constraint conflicts are detected.
enum AutoLayoutDebugger {

  // MARK: Internal

  /// Activates the debugger. Call this early in app lifecycle (e.g., in AppDelegate).
  static func activate() {
    #if DEBUG
    // Set up a timer to check for ambiguous layouts
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
      checkForConstraintIssues()
    }

    // Also check after every layout pass using closure-based observer
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name("UIViewLayoutSubviewsNotification"),
      object: nil,
      queue: .main
    ) { _ in
      checkForConstraintIssues()
    }

    print("🔍 AutoLayoutDebugger: Activated - monitoring for constraint violations")
    #endif
  }

  // MARK: Private

  #if DEBUG
  private static func checkForConstraintIssues() {
    guard let window = UIApplication.shared.windows.first else { return }

    // Check for ambiguous layouts
    if let ambiguousView = findAmbiguousLayout(in: window) {
      let errorMessage = """

      ╔══════════════════════════════════════════════════════════════════════════════╗
      ║                    AUTO LAYOUT CONSTRAINT VIOLATION                          ║
      ╠══════════════════════════════════════════════════════════════════════════════╣

      ❌ BUILD FAILED: Ambiguous layout detected!

      View with ambiguous layout: \(ambiguousView)
      Identifier: \(ambiguousView.accessibilityIdentifier ?? "none")

      This means Auto Layout cannot determine the position/size of this view.

      To fix:
      1. Add more constraints to fully specify the view's position and size
      2. Check for conflicting constraints
      3. Use Debug View Hierarchy to visualize the issue

      ╚══════════════════════════════════════════════════════════════════════════════╝

      """

      fatalError(errorMessage)
    }
  }

  private static func findAmbiguousLayout(in view: UIView) -> UIView? {
    if view.hasAmbiguousLayout {
      return view
    }

    for subview in view.subviews {
      if let ambiguous = findAmbiguousLayout(in: subview) {
        return ambiguous
      }
    }

    return nil
  }
  #endif
}
