//
//  BetaTestItem.swift
//  Tester One
//

import Foundation

struct BetaTestItem {

  // MARK: Internal

  struct Content {
    var title: String
    var icon: IconType
    var retryButtonTitle: String

    init(
      title: String,
      icon: IconType,
      retryButtonTitle: String = "Ulangi",
    ) {
      self.title = title
      self.icon = icon
      self.retryButtonTitle = retryButtonTitle
    }
  }

  struct RunPlan {
    var loadingDuration: TimeInterval
    var initialFinalState: BetaTestCardState?
    var retryFinalState: BetaTestCardState?

    init(
      loadingDuration: TimeInterval = 0,
      initialFinalState: BetaTestCardState? = nil,
      retryFinalState: BetaTestCardState? = nil,
    ) {
      self.loadingDuration = loadingDuration
      self.initialFinalState = initialFinalState
      self.retryFinalState = retryFinalState
    }
  }

  enum IconType: CaseIterable {
    case cpu
    case hardDisk
    case battery
    case jailbreak
    case biometricOne
    case biometricTwo
    case silent
    case volume
    case power
    case camera
    case touch
    case sim
  }

  var content: Content
  var runPlan: RunPlan
  var state: BetaTestCardState

  var title: String { content.title }
  var icon: IconType { content.icon }
  var accessibilityToken: String { Self.makeAccessibilityToken(from: content.title) }

  init(
    title: String,
    icon: IconType,
    state: BetaTestCardState,
    retryButtonTitle: String = "Ulangi",
    runPlan: RunPlan = RunPlan(),
  ) {
    content = Content(title: title, icon: icon, retryButtonTitle: retryButtonTitle)
    self.runPlan = runPlan
    self.state = state
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
