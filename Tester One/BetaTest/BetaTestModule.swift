import UIKit

enum BetaTestModule {
  static func makeViewController(
    configuration: BetaTestModuleConfiguration.Module
  ) -> BetaTestViewController {
    let items = configuration.items.map { source in
      BetaTestItem(
        title: source.title,
        initialIconAssetName: source.initialIconAssetName,
        failedIconAssetName: source.failedIconAssetName,
        successIconAssetName: source.successIconAssetName,
        statusAssetName: source.statusAssetName,
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
