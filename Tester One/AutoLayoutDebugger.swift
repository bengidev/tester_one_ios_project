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
    swizzleConstraintMethods()
    print("🔍 AutoLayoutDebugger: Activated - constraint violations will crash the app")
    #endif
  }

  // MARK: Private

  #if DEBUG
  private static var hasSwizzled = false

  private static func swizzleConstraintMethods() {
    guard !hasSwizzled else { return }
    hasSwizzled = true

    // Swizzle UIViewAlertForUnsatisfiableConstraints
    let originalSelector = NSSelectorFromString("UIViewAlertForUnsatisfiableConstraints")
    let swizzledSelector = #selector(UIView.autoLayoutDebugger_alertForUnsatisfiableConstraints)

    guard let originalMethod = class_getClassMethod(UIView.self, originalSelector),
          let swizzledMethod = class_getClassMethod(UIView.self, swizzledSelector)
    else {
      print("⚠️ AutoLayoutDebugger: Failed to swizzle constraint method")
      return
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
  }
  #endif
}

// MARK: - UIView Extension

extension UIView {

  #if DEBUG
  @objc
  dynamic class func autoLayoutDebugger_alertForUnsatisfiableConstraints(
    _ constraint: NSLayoutConstraint,
    withOtherConstraint otherConstraint: NSLayoutConstraint?)
  {
    // Call original implementation first to log the issue
    autoLayoutDebugger_alertForUnsatisfiableConstraints(constraint, withOtherConstraint: otherConstraint)

    // Build error message
    var errorMessage = """
    
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    AUTO LAYOUT CONSTRAINT VIOLATION                          ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    
    ❌ Build failed due to Auto Layout constraint conflict!
    
    Constraint: \(constraint)
    """

    if let other = otherConstraint {
      errorMessage += "\nConflicts with: \(other)"
    }

    errorMessage += """
    
    
    To fix this issue:
    1. Check the constraint priorities
    2. Ensure constraints don't conflict
    3. Use Debug View Hierarchy to visualize the issue
    
    ╚══════════════════════════════════════════════════════════════════════════════╝
    
    """

    // Crash the app
    fatalError(errorMessage)
  }
  #endif
}
