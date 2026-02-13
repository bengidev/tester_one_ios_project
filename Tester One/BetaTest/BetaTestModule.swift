import UIKit

enum BetaTestModule {
  static func makeViewController(
    configuration: BetaTestModuleConfiguration.Module,
    executionProvider: BetaTestExecutionProviding = BetaTestDefaultExecutionProvider(),
  ) -> BetaTestViewController {
    let items = configuration.items.map { source in
      BetaTestItem(
        title: source.title,
        icon: source.icon,
        state: .initial,
        retryButtonTitle: source.retryButtonTitle,
        executionHandler: { phase, continueExecutionWithState in
          executionProvider.execute(item: source, phase: phase, completion: continueExecutionWithState)
        },
      )
    }

    return BetaTestViewController(
      items: items,
      layoutStrategy: configuration.layoutStrategy,
      screen: configuration.screen,
    )
  }
}
