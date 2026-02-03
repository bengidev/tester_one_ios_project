//
//  DeviceTestViewController.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import UIKit

// MARK: - DeviceTestViewController

final class DeviceTestViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    setupViewHierarchy()
    setupConstraints()
    configureTableView()
    configureActionButton()
    configureNavigationTitle()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateTableSpacerViews()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }

  // MARK: Private

  private enum Constants {
    static let navigationTitle = "Cek Fungsi Software"
    static let navigationTitleColor = UIColor(red: 0, green: 102.0 / 255.0, blue: 200.0 / 255.0, alpha: 1)
    static let tableBackgroundColor = UIColor(red: 232.0 / 255.0, green: 238.0 / 255.0, blue: 241.0 / 255.0, alpha: 1)
    static let cellReuseIdentifier = "DeviceTestCell"
    static let estimatedRowHeight: CGFloat = 64
    static let tableContentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    static let actionEnabledTitle = "Mulai Tes"
    static let actionDisabledTitle = "Dalam Pengecekan"
    static let actionEnabledColor = UIColor(red: 51.0 / 255.0, green: 185.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
    static let actionDisabledColor = UIColor(red: 215.0 / 255.0, green: 220.0 / 255.0, blue: 222.0 / 255.0, alpha: 1)
    static let actionDisabledTextColor = UIColor(red: 154.0 / 255.0, green: 160.0 / 255.0, blue: 163.0 / 255.0, alpha: 1)
  }

  private enum Layout {
    static let actionHorizontalInset: CGFloat = 20
    static let actionVerticalInset: CGFloat = 16
    static let actionButtonHeight: CGFloat = 48
    static let actionButtonCornerRadius: CGFloat = 10
  }

  private let fullScreenView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    return tableView
  }()

  private let actionContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()

  private let actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.layer.cornerRadius = Layout.actionButtonCornerRadius
    button.clipsToBounds = true
    return button
  }()

  private let items = [
    "Battery Health — Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.",
    "Camera Check — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    "Speaker Test — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
    "Microphone Test — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
    "Display Brightness — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.",
    "Touchscreen Responsiveness — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.",
    "Wi-Fi Connection — Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "Bluetooth Pairing — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
    "Charging Port — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
    "Vibration Motor — Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "Face ID / Touch ID — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
    "GPS Signal — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
    "Proximity Sensor — Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "Ambient Light Sensor — Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.",
  ]

  private var isActionEnabled = false {
    didSet {
      updateActionButtonAppearance()
    }
  }

  private func configureView() {
    applyColors()
  }

  private func setupViewHierarchy() {
    view.addSubview(fullScreenView)
    fullScreenView.addSubview(tableView)
    fullScreenView.addSubview(actionContainerView)
    actionContainerView.addSubview(actionButton)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      fullScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      fullScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      fullScreenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      fullScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      tableView.leadingAnchor.constraint(equalTo: fullScreenView.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: fullScreenView.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: fullScreenView.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: actionContainerView.topAnchor),

      actionContainerView.leadingAnchor.constraint(equalTo: fullScreenView.leadingAnchor),
      actionContainerView.trailingAnchor.constraint(equalTo: fullScreenView.trailingAnchor),
      actionContainerView.bottomAnchor.constraint(equalTo: fullScreenView.safeAreaLayoutGuide.bottomAnchor),

      actionButton.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor, constant: Layout.actionHorizontalInset),
      actionButton.trailingAnchor.constraint(
        equalTo: actionContainerView.trailingAnchor,
        constant: -Layout.actionHorizontalInset,
      ),
      actionButton.topAnchor.constraint(equalTo: actionContainerView.topAnchor, constant: Layout.actionVerticalInset),
      actionButton.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: -Layout.actionVerticalInset),
      actionButton.heightAnchor.constraint(equalToConstant: Layout.actionButtonHeight),
    ])
  }

  private func configureNavigationTitle() {
    let titleLabel = UILabel()
    titleLabel.text = Constants.navigationTitle
    titleLabel.textColor = Constants.navigationTitleColor
    titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    navigationItem.titleView = titleLabel
  }

  private func configureTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(DeviceTestTableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
    tableView.tableHeaderView = makeTableSpacerView(height: Constants.tableContentInset.top)
    tableView.tableFooterView = makeTableSpacerView(height: Constants.tableContentInset.bottom)
    tableView.backgroundColor = Constants.tableBackgroundColor
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = Constants.estimatedRowHeight
    if #available(iOS 11.0, *) {
      tableView.contentInsetAdjustmentBehavior = .never
    } else {
      automaticallyAdjustsScrollViewInsets = false
    }
  }

  private func configureActionButton() {
    actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    updateActionButtonAppearance()
  }

  private func updateActionButtonAppearance() {
    if isActionEnabled {
      actionButton.setTitle(Constants.actionEnabledTitle, for: .normal)
      actionButton.backgroundColor = Constants.actionEnabledColor
      actionButton.setTitleColor(.white, for: .normal)
    } else {
      actionButton.setTitle(Constants.actionDisabledTitle, for: .normal)
      actionButton.backgroundColor = Constants.actionDisabledColor
      actionButton.setTitleColor(Constants.actionDisabledTextColor, for: .normal)
    }
  }

  private func makeTableSpacerView(height: CGFloat) -> UIView {
    UIView(frame: CGRect(x: 0, y: 0, width: 1, height: height))
  }

  private func updateTableSpacerViews() {
    guard tableView.bounds.width > 0 else { return }

    if let header = tableView.tableHeaderView {
      let height = header.frame.height
      header.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height)
      tableView.tableHeaderView = header
    }

    if let footer = tableView.tableFooterView {
      let height = footer.frame.height
      footer.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height)
      tableView.tableFooterView = footer
    }
  }

  @objc
  private func actionButtonTapped() {
    isActionEnabled.toggle()
  }

  private func applyColors() {
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
      fullScreenView.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
      fullScreenView.backgroundColor = .white
    }
  }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension DeviceTestViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    items.count
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath,
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.cellReuseIdentifier,
      for: indexPath,
    )

    if let deviceCell = cell as? DeviceTestTableViewCell {
      deviceCell.configure(title: items[indexPath.row])
    }

    cell.backgroundColor = Constants.tableBackgroundColor
    return cell
  }
}
