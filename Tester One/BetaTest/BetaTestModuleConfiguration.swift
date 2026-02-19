import UIKit

enum BetaTestModuleConfiguration {
  struct Item {
    var title: String
    var initialIconImage: UIImage?
    var failedIconImage: UIImage?
    var successIconImage: UIImage?
    var statusImage: UIImage?
    var retryButtonTitle: String
    var executionHandler: BetaTestItem.ExecutionHandler

    init(
      title: String,
      initialIconImage: UIImage? = nil,
      failedIconImage: UIImage? = nil,
      successIconImage: UIImage? = nil,
      statusImage: UIImage? = nil,
      retryButtonTitle: String = "Ulangi",
      executionHandler: @escaping BetaTestItem.ExecutionHandler,
    ) {
      self.title = title
      self.initialIconImage = initialIconImage
      self.failedIconImage = failedIconImage
      self.successIconImage = successIconImage
      self.statusImage = statusImage
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
