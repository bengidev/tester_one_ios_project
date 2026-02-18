import Foundation

enum BetaTestModuleConfiguration {
  struct Item {
    var title: String
    var initialIconAssetName: String?
    var failedIconAssetName: String?
    var successIconAssetName: String?
    var statusAssetName: String?
    var retryButtonTitle: String
    var executionHandler: BetaTestItem.ExecutionHandler

    init(
      title: String,
      initialIconAssetName: String? = nil,
      failedIconAssetName: String? = nil,
      successIconAssetName: String? = nil,
      statusAssetName: String? = "successImage",
      retryButtonTitle: String = "Ulangi",
      executionHandler: @escaping BetaTestItem.ExecutionHandler,
    ) {
      self.title = title
      self.initialIconAssetName = initialIconAssetName
      self.failedIconAssetName = failedIconAssetName
      self.successIconAssetName = successIconAssetName
      self.statusAssetName = statusAssetName
      self.retryButtonTitle = retryButtonTitle
      self.executionHandler = executionHandler
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
    var onProcessingEvent: ((BetaTestViewController.ProcessingEvent) -> Void)?
    var onRetryCompleted: ((BetaTestViewController.ProcessResult) -> Void)?
    var onContinueButtonTapped: (() -> Void)?
    var onRetryButtonTapped: ((_ index: Int, _ title: String) -> Void)?

    init(
      items: [Item],
      layoutStrategy: BetaTestLayoutStrategy = .adaptiveMosaic,
      screen: Screen = .init(),
      onProcessingEvent: ((BetaTestViewController.ProcessingEvent) -> Void)? = nil,
      onRetryCompleted: ((BetaTestViewController.ProcessResult) -> Void)? = nil,
      onContinueButtonTapped: (() -> Void)? = nil,
      onRetryButtonTapped: ((_ index: Int, _ title: String) -> Void)? = nil,
    ) {
      self.items = items
      self.layoutStrategy = layoutStrategy
      self.screen = screen
      self.onProcessingEvent = onProcessingEvent
      self.onRetryCompleted = onRetryCompleted
      self.onContinueButtonTapped = onContinueButtonTapped
      self.onRetryButtonTapped = onRetryButtonTapped
    }
  }
}
