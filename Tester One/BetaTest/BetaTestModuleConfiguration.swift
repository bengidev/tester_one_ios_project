import Foundation

enum BetaTestModuleConfiguration {
  struct Item {
    var title: String
    var icon: BetaTestItem.IconType
    var initialState: BetaTestCardState
    var retryState: BetaTestCardState
    var retryButtonTitle: String
    var simulatedDuration: TimeInterval

    init(
      title: String,
      icon: BetaTestItem.IconType,
      initialState: BetaTestCardState,
      retryState: BetaTestCardState = .success,
      retryButtonTitle: String = "Ulangi",
      simulatedDuration: TimeInterval = 0.25,
    ) {
      self.title = title
      self.icon = icon
      self.initialState = initialState
      self.retryState = retryState
      self.retryButtonTitle = retryButtonTitle
      self.simulatedDuration = simulatedDuration
    }
  }

  struct Screen {
    var title: String
    var continueButtonTitleIdle: String
    var continueButtonTitleLoading: String
    var continueButtonTitleFinished: String

    init(
      title: String = "Cek Fungsi",
      continueButtonTitleIdle: String = "Mulai Tes",
      continueButtonTitleLoading: String = "Dalam Pengecekan",
      continueButtonTitleFinished: String = "Lanjut",
    ) {
      self.title = title
      self.continueButtonTitleIdle = continueButtonTitleIdle
      self.continueButtonTitleLoading = continueButtonTitleLoading
      self.continueButtonTitleFinished = continueButtonTitleFinished
    }
  }

  struct Module {
    var items: [Item]
    var layoutStrategy: BetaTestLayoutStrategy
    var screen: Screen

    init(
      items: [Item],
      layoutStrategy: BetaTestLayoutStrategy = .adaptiveMosaic,
      screen: Screen = .init(),
    ) {
      self.items = items
      self.layoutStrategy = layoutStrategy
      self.screen = screen
    }
  }
}
