//
//  BetaTestItem.swift
//  Tester One
//

import Foundation

struct BetaTestItem {

  // MARK: Internal

  /// MUST call `continueExecutionWithState(...)` exactly once to continue the sequential chain.
  typealias ExecutionHandler = (_ phase: ExecutionPhase, _ continueExecutionWithState: @escaping (BetaTestCardState) -> Void)
    -> Void

  struct Content {
    var title: String
    var initialIconAssetName: String?
    var failedIconAssetName: String?
    var successIconAssetName: String?
    var statusAssetName: String?
    var retryButtonTitle: String

    init(
      title: String,
      initialIconAssetName: String? = nil,
      failedIconAssetName: String? = nil,
      successIconAssetName: String? = nil,
      statusAssetName: String? = "successImage",
      retryButtonTitle: String = "Ulangi",
    ) {
      self.title = title
      self.initialIconAssetName = initialIconAssetName
      self.failedIconAssetName = failedIconAssetName
      self.successIconAssetName = successIconAssetName
      self.statusAssetName = statusAssetName
      self.retryButtonTitle = retryButtonTitle
    }
  }

  enum ExecutionPhase {
    case initial
    case retry
  }

  var content: Content
  var state: BetaTestCardState
  var executionHandler: ExecutionHandler?

  var title: String { content.title }
  var initialIconAssetName: String? { content.initialIconAssetName }
  var failedIconAssetName: String? { content.failedIconAssetName }
  var successIconAssetName: String? { content.successIconAssetName }
  var statusAssetName: String? { content.statusAssetName }
  var accessibilityToken: String { Self.makeAccessibilityToken(from: content.title) }

  init(
    title: String,
    initialIconAssetName: String? = nil,
    failedIconAssetName: String? = nil,
    successIconAssetName: String? = nil,
    statusAssetName: String? = "successImage",
    state: BetaTestCardState,
    retryButtonTitle: String = "Ulangi",
    executionHandler: ExecutionHandler? = nil,
  ) {
    content = Content(
      title: title,
      initialIconAssetName: initialIconAssetName,
      failedIconAssetName: failedIconAssetName,
      successIconAssetName: successIconAssetName,
      statusAssetName: statusAssetName,
      retryButtonTitle: retryButtonTitle,
    )
    self.state = state
    self.executionHandler = executionHandler
  }

  // MARK: Private

  private static func makeAccessibilityToken(from title: String) -> String {
    let normalized = String(title.lowercased().map { character in
      character.isLetter || character.isNumber ? character : "_"
    })
    let collapsed = normalized.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
    return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
  }
}
