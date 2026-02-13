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

  private func makeBetaTestItemsForHost() -> [BetaTestModuleConfiguration.Item] {
    [
      makeHostItem(
        title: "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velitNeque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velitNeque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit",
        icon: .cpu,
        initialState: .failed,
      ),
      makeHostItem(title: "Hard Disk", icon: .hardDisk, initialState: .failed),
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
    retryState: BetaTestCardState = .success,
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
