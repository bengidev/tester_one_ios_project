//
//  AppDelegate.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import CoreData
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: Internal

  var window: UIWindow?

  lazy var persistentContainer: NSPersistentContainer = {
    // The persistent container for the application. This implementation
    // creates and returns a container, having loaded the store for the
    // application to it. This property is optional since there are legitimate
    // error conditions that could cause the creation of the store to fail.
    let container = NSPersistentContainer(name: "Tester_One")
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        // Typical reasons for an error here include:
        // * The parent directory does not exist, cannot be created, or disallows writing.
        // * The persistent store is not accessible, due to permissions or data protection when the device is locked.
        // * The device is out of space.
        // * The store could not be migrated to the current model version.
        // Check the error message to determine what the actual problem was.
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let rootViewController = BetaTestModule.makeViewController(
      configuration: .init(
        items: makeBetaTestItemsForHost(),
        layoutStrategy: .adaptiveMosaic,
        screen: .init(),
      )
    )

    configureStateAutomationIfNeeded(for: rootViewController)

    let navigationController = UINavigationController(rootViewController: rootViewController)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    return true
  }

  func applicationDidEnterBackground(_: UIApplication) {
    saveContext()
  }

  func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  // MARK: Private

  private func configureStateAutomationIfNeeded(for viewController: BetaTestViewController) {
    let env = ProcessInfo.processInfo.environment
    guard env["BETA_TEST_STATE_AUTOMATION"] == "1" else { return }

    let outputDir = stateSnapshotOutputDirectory()
    try? FileManager.default.removeItem(at: outputDir)
    try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

    let retryAllMode = env["BETA_TEST_RETRY_ALL_AUTOMATION"] == "1"

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
      viewController.beginProcessing()

      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self?.captureStateSnapshot(named: "state_loading_run")
      }
    }

    if retryAllMode {
      var retryQueue = [Int]()
      var isRetryFlowRunning = false

      func runNextRetryIfNeeded(_ vc: BetaTestViewController?) {
        guard let vc else { return }
        guard !isRetryFlowRunning else { return }
        guard !retryQueue.isEmpty else { return }

        isRetryFlowRunning = true
        let nextIndex = retryQueue.removeFirst()
        vc.debug_triggerRetry(at: nextIndex)
      }

      viewController.onRetryCompleted = { [weak viewController] _ in
        isRetryFlowRunning = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
          runNextRetryIfNeeded(viewController)
        }
      }

      viewController.onProcessingEvent = { [weak self, weak viewController] event in
        guard case .runCompleted(let results) = event else { return }
        guard let vc = viewController else { return }

        let failedIndexes = results
          .filter { $0.state == .failed }
          .map(\.index)
          .sorted()

        guard !failedIndexes.isEmpty else { return }

        retryQueue = failedIndexes

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
          vc.debug_scrollToBottom(animated: true)

          DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            vc.debug_scrollToMiddle(animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
              vc.debug_scrollToTop(animated: true)

              DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                runNextRetryIfNeeded(viewController)
              }
            }
          }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
          self?.captureStateSnapshot(named: "state_failed_after_run")
        }
      }

      return
    }

    viewController.onProcessingEvent = { [weak self, weak viewController] event in
      guard case .runCompleted(let results) = event else { return }
      guard let failedResult = results.first(where: { $0.state == .failed }) else { return }

      // Give UIKit an extra frame budget on slower simulators so the bottom button
      // title/state has time to render before snapshot capture.
      let settleDelay: TimeInterval = 0.35

      DispatchQueue.main.asyncAfter(deadline: .now() + settleDelay) {
        self?.captureStateSnapshot(named: "state_failed_after_run")
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 + settleDelay) {
        viewController?.setState(.loading, at: failedResult.index)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
          self?.captureStateSnapshot(named: "state_loading_after_failed")
        }
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 2.6 + settleDelay) {
        viewController?.setState(.success, at: failedResult.index)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
          self?.captureStateSnapshot(named: "state_success_after_loading")
        }
      }
    }
  }

  private func stateSnapshotOutputDirectory() -> URL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
      ?? URL(fileURLWithPath: NSTemporaryDirectory())
    return docs.appendingPathComponent("state-verify-inapp", isDirectory: true)
  }

  private func captureStateSnapshot(named: String) {
    guard let window else { return }

    let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
    let image = renderer.image { _ in
      window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    }

    guard let data = image.pngData() else { return }
    let fileURL = stateSnapshotOutputDirectory().appendingPathComponent("\(named).png")
    try? data.write(to: fileURL, options: .atomic)
  }

  private func makeBetaTestItemsForHost() -> [BetaTestModuleConfiguration.Item] {
    [
      makeHostItem(
        title: "Neque porro quis ",
        icon: .cpu,
        initialState: .success,
      ),
      makeHostItem(title: "Hard Disk", icon: .hardDisk, initialState: .success),
      makeHostItem(title: "Kondisi Baterai", icon: .battery, initialState: .success),
      makeHostItem(title: "Tes Jailbreak", icon: .jailbreak, initialState: .success),
      makeHostItem(title: "Tes Biometric 1", icon: .biometricOne, initialState: .success),
      makeHostItem(title: "Tes Biometric 2", icon: .biometricTwo, initialState: .success),
      makeHostItem(title: "Tombol Silent", icon: .silent, initialState: .failed),
      makeHostItem(title: "Tombol Volume", icon: .volume, initialState: .success),
      makeHostItem(title: "Tombol On/Off", icon: .power, initialState: .success),
      makeHostItem(title: "Tes Kamera", icon: .camera, initialState: .success),
      makeHostItem(title: "Tes Layar Sentuh", icon: .touch, initialState: .success),
      makeHostItem(title: "Tes Kartu SIM", icon: .sim, initialState: .success),
    ]
  }

  private func makeHostItem(
    title: String,
    icon: BetaTestItem.IconType,
    initialState: BetaTestCardState,
    retryState: BetaTestCardState = .failed,
    simulatedDuration: TimeInterval = 0.25,
  ) -> BetaTestModuleConfiguration.Item {
    BetaTestModuleConfiguration.Item(
      title: title,
      icon: icon,
      initialState: initialState,
      retryState: retryState,
      simulatedDuration: simulatedDuration,
    )
  }

}
