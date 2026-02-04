//
//  AutoLayoutDebugger.swift
//  Tester One
//
//  Auto Layout constraint violation debugger.
//  Crashes the app in DEBUG builds when constraint conflicts occur.
//

import UIKit

// MARK: - UIView Extension for Method Swizzling

extension UIView {

  // MARK: Internal

  /// Swizzle the layout constraint violation method
  static let swizzleLayoutMethod: Void = {
    #if DEBUG
    // Method to swizzle: _UIViewAlertForUnsatisfiableConstraints
    let selector = NSSelectorFromString("_UIViewAlertForUnsatisfiableConstraints")

    guard let method = class_getClassMethod(UIView.self, selector) else {
      print("⚠️ AutoLayoutDebugger: Could not find method to swizzle")
      return
    }

    let originalIMP = method_getImplementation(method)
    let originalType = method_getTypeEncoding(method)

    // Create a new implementation that crashes
    let newIMP: IMP = imp_implementationWithBlock { (_: Any, constraint: NSLayoutConstraint) in
      // Call original first to log the issue
      let originalFunc = unsafeBitCast(originalIMP, to: (@convention(c) (Any, Selector, NSLayoutConstraint) -> Void).self)
      originalFunc(UIView.self, selector, constraint)

      // Now crash with detailed info
      let errorMessage = """

      ╔══════════════════════════════════════════════════════════════════════════════╗
      ║                    AUTO LAYOUT CONSTRAINT VIOLATION                          ║
      ╠══════════════════════════════════════════════════════════════════════════════╣

      ❌ BUILD FAILED: Auto Layout constraint conflict detected!

      Constraint: \(constraint)

      This would normally just warn, but we're treating it as a fatal error.

      To fix:
      1. Check the console output above for the conflicting constraints list
      2. Use Debug View Hierarchy to visualize the issue
      3. Fix the conflicting constraints in your code

      ╚══════════════════════════════════════════════════════════════════════════════╝

      """

      fatalError(errorMessage)
    }

    method_setImplementation(method, newIMP)
    print("🔍 AutoLayoutDebugger: Activated - constraint violations will CRASH the app")
    #endif
  }()
}

// MARK: - AutoLayoutDebugger

/// Debugger that monitors Auto Layout constraint violations.
/// In DEBUG builds, it will crash the app when constraint conflicts are detected.
enum AutoLayoutDebugger {

  // MARK: Internal

  /// Activates the debugger. Call this early in app lifecycle (e.g., in AppDelegate).
  static func activate() {
    #if DEBUG
    _ = UIView.swizzleLayoutMethod
    #endif
  }
}
