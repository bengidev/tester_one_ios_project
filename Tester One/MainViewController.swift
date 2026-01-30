//
//  MainViewController.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import UIKit

final class MainViewController: UIViewController {
  private let contentView = MainView()

  override func loadView() {
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Main"
    contentView.deviceTestButton.addTarget(
      self, action: #selector(deviceTestTapped), for: .touchUpInside)
  }

  @objc private func deviceTestTapped() {
    let viewController = DeviceTestViewController()
    navigationController?.pushViewController(viewController, animated: true)
  }
}

final class MainView: UIView {
  let deviceTestButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Go to Device Test", for: .normal)
    return button
  }()

  private lazy var stackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [deviceTestButton])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    if #available(iOS 13.0, *) {
      backgroundColor = .systemBackground
    } else {
      backgroundColor = .white
    }

    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
