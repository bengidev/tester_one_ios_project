//
//  UIViewController+Injection.swift
//  Tester One
//
//  InjectionIII Hot Reload Support
//

import UIKit

#if DEBUG
extension UIViewController {
  /// Called by InjectionIII after code injection
  @objc
  func injected() {
    print("💉 InjectionIII: Reloaded \(type(of: self))")

    // Re-run view setup to reflect changes
    viewDidLoad()

    // Force view refresh
    view.setNeedsLayout()
    view.layoutIfNeeded()

    // For table/collection views, reload data
    if let tableView = view.subviews.first(where: { $0 is UITableView }) as? UITableView {
      tableView.reloadData()
    }
    if let collectionView = view.subviews.first(where: { $0 is UICollectionView }) as? UICollectionView {
      collectionView.reloadData()
    }
  }
}

extension UITableViewCell {
  /// Called when a cell is injected
  @objc
  func injected() {
    print("💉 InjectionIII: Reloaded cell \(type(of: self))")
    setNeedsLayout()
    layoutIfNeeded()
  }
}
#endif
