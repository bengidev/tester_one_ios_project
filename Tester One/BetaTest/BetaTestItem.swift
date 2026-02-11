//
//  BetaTestItem.swift
//  Tester One
//

import Foundation

struct BetaTestItem {

  // MARK: Internal

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

  let title: String
  let icon: IconType
  let accessibilityToken: String
  var state: BetaTestCardState

  init(title: String, icon: IconType, state: BetaTestCardState) {
    self.title = title
    self.icon = icon
    self.state = state
    accessibilityToken = Self.makeAccessibilityToken(from: title)
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
