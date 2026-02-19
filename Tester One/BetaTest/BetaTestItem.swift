//
//  BetaTestItem.swift
//  Tester One
//

import UIKit

struct BetaTestItem {

  // MARK: Internal

  /// MUST call `continueExecutionWithState(...)` exactly once to continue the sequential chain.
  typealias ExecutionHandler = (_ phase: ExecutionPhase, _ continueExecutionWithState: @escaping (BetaTestCardState) -> Void)
    -> Void

  struct Content {
    var title: String
    var initialIconImage: UIImage?
    var failedIconImage: UIImage?
    var successIconImage: UIImage?
    var statusImage: UIImage?
    var retryButtonTitle: String

    init(
      title: String,
      initialIconImage: UIImage? = nil,
      failedIconImage: UIImage? = nil,
      successIconImage: UIImage? = nil,
      statusImage: UIImage? = nil,
      retryButtonTitle: String = "Ulangi",
    ) {
      self.title = title
      self.initialIconImage = initialIconImage
      self.failedIconImage = failedIconImage
      self.successIconImage = successIconImage
      self.statusImage = statusImage
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
  var initialIconImage: UIImage? { content.initialIconImage }
  var failedIconImage: UIImage? { content.failedIconImage }
  var successIconImage: UIImage? { content.successIconImage }
  var statusImage: UIImage? { content.statusImage }
  var accessibilityToken: String { Self.makeAccessibilityToken(from: content.title) }

  init(
    title: String,
    initialIconImage: UIImage? = nil,
    failedIconImage: UIImage? = nil,
    successIconImage: UIImage? = nil,
    statusImage: UIImage? = nil,
    state: BetaTestCardState,
    retryButtonTitle: String = "Ulangi",
    executionHandler: ExecutionHandler? = nil,
  ) {
    content = Content(
      title: title,
      initialIconImage: initialIconImage,
      failedIconImage: failedIconImage,
      successIconImage: successIconImage,
      statusImage: statusImage,
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
