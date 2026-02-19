import UIKit

enum BetaTestModule {
  static func makeViewController(
    configuration: BetaTestModuleConfiguration.Module
  ) -> BetaTestViewController {
    let items = configuration.items.map { source in
      BetaTestItem(
        title: source.title,
        initialIconImage: source.initialIconImage,
        failedIconImage: source.failedIconImage,
        successIconImage: source.successIconImage,
        statusImage: source.statusImage,
        state: .initial,
        retryButtonTitle: source.retryButtonTitle,
        executionHandler: source.executionHandler,
      )
    }

    let viewController = BetaTestViewController(
      items: items,
      layoutStrategy: configuration.layoutStrategy,
      screen: configuration.screen,
    )

    viewController.onProcessingEvent = configuration.onProcessingEvent
    viewController.onRetryCompleted = configuration.onRetryCompleted
    viewController.onContinueButtonTapped = configuration.onContinueButtonTapped
    viewController.onRetryButtonTapped = configuration.onRetryButtonTapped

    return viewController
  }
}
