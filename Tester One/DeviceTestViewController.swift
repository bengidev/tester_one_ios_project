//
//  DeviceTestViewController.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import UIKit

// MARK: - DeviceTestViewController

/// View controller displaying a list of device diagnostic tests.
final class DeviceTestViewController: UIViewController {

  // MARK: - Types

  private enum TestStatus {
    case enabled
    case disabled

    var title: String {
      switch self {
      case .enabled: return "Mulai Tes"
      case .disabled: return "Dalam Pengecekan"
      }
    }

    var backgroundColor: UIColor {
      switch self {
      case .enabled:
        return UIColor(red: 51.0 / 255.0, green: 185.0 / 255.0, blue: 255.0 / 255.0, alpha: 1)
      case .disabled:
        return UIColor(red: 215.0 / 255.0, green: 220.0 / 255.0, blue: 222.0 / 255.0, alpha: 1)
      }
    }

    var textColor: UIColor {
      switch self {
      case .enabled: return .white
      case .disabled:
        return UIColor(red: 154.0 / 255.0, green: 160.0 / 255.0, blue: 163.0 / 255.0, alpha: 1)
      }
    }
  }

  // MARK: - Constants

  private enum Constants {
    static let navigationTitle = "Cek Fungsi Software"
    static let cellReuseIdentifier = "AlphaTestCell"
    static let estimatedRowHeight: CGFloat = 64
    static let tableContentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

    static let navigationTitleColor = UIColor(red: 0, green: 102.0 / 255.0, blue: 200.0 / 255.0, alpha: 1)
    static let tableBackgroundColor = UIColor(red: 232.0 / 255.0, green: 238.0 / 255.0, blue: 241.0 / 255.0, alpha: 1)
  }

  private enum Layout {
    static let actionHorizontalInset: CGFloat = 20
    static let actionVerticalInset: CGFloat = 16
    static let actionButtonHeight: CGFloat = 48
    static let actionButtonCornerRadius: CGFloat = 10
  }

  // MARK: - Properties

  private let testItems: [String] = [
    "Battery Health",
    "Camera Check",
    "Speaker Test",
    "Microphone Test",
    "Display Brightness",
    "Touchscreen ResponsivenessTouchscreen Responsiveness",
    "Wi-Fi Connection",
    "Bluetooth Pairing",
    "Charging Port",
    "Vibration Motor",
    "Face ID / Touch ID",
    "GPS Signal",
    "Proximity Sensor",
    "Ambient Light SensorAmbient Light SensorAmbient Light SensorAmbient Light Sensor",
  ]

  private var currentStatus: TestStatus = .disabled

  // MARK: - UI Components

  private lazy var fullScreenView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    tableView.backgroundColor = Constants.tableBackgroundColor
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = Constants.estimatedRowHeight
    tableView.delaysContentTouches = false
    return tableView
  }()

  private lazy var actionContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    return view
  }()

  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.layer.cornerRadius = Layout.actionButtonCornerRadius
    button.clipsToBounds = true
    return button
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewController()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateTableSpacerViews()
  }

  // MARK: - Setup

  private func setupViewController() {
    setupAppearance()
    setupNavigationBar()
    setupViewHierarchy()
    setupConstraints()
    setupTableView()
    setupActionButton()
  }

  private func setupAppearance() {
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
      fullScreenView.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
      fullScreenView.backgroundColor = .white
    }
  }

  private func setupNavigationBar() {
    title = Constants.navigationTitle
    navigationController?.navigationBar.titleTextAttributes = [
      .foregroundColor: Constants.navigationTitleColor,
    ]
  }

  private func setupViewHierarchy() {
    view.addSubview(fullScreenView)
    fullScreenView.addSubview(tableView)
    fullScreenView.addSubview(actionContainerView)
    actionContainerView.addSubview(actionButton)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // Full screen view
      fullScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      fullScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      fullScreenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      fullScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      // Table view
      tableView.leadingAnchor.constraint(equalTo: fullScreenView.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: fullScreenView.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: fullScreenView.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: actionContainerView.topAnchor),

      // Action container
      actionContainerView.leadingAnchor.constraint(equalTo: fullScreenView.leadingAnchor),
      actionContainerView.trailingAnchor.constraint(equalTo: fullScreenView.trailingAnchor),
      actionContainerView.bottomAnchor.constraint(equalTo: fullScreenView.safeAreaLayoutGuide.bottomAnchor),

      // Action button
      actionButton.leadingAnchor.constraint(equalTo: actionContainerView.leadingAnchor, constant: Layout.actionHorizontalInset),
      actionButton.trailingAnchor.constraint(equalTo: actionContainerView.trailingAnchor, constant: -Layout.actionHorizontalInset),
      actionButton.topAnchor.constraint(equalTo: actionContainerView.topAnchor, constant: Layout.actionVerticalInset),
      actionButton.bottomAnchor.constraint(equalTo: actionContainerView.bottomAnchor, constant: -Layout.actionVerticalInset),
      actionButton.heightAnchor.constraint(equalToConstant: Layout.actionButtonHeight),
    ])
  }

  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(AlphaTestTableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)

    tableView.tableHeaderView = createSpacerView(height: Constants.tableContentInset.top)
    tableView.tableFooterView = createSpacerView(height: Constants.tableContentInset.bottom)

    if #available(iOS 11.0, *) {
      tableView.contentInsetAdjustmentBehavior = .never
    } else {
      automaticallyAdjustsScrollViewInsets = false
    }
  }

  private func setupActionButton() {
    actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    updateActionButton()
  }

  // MARK: - Actions

  @objc private func actionButtonTapped() {
    currentStatus = (currentStatus == .enabled) ? .disabled : .enabled
    updateActionButton()
  }

  // MARK: - Private Methods

  private func updateActionButton() {
    actionButton.setTitle(currentStatus.title, for: .normal)
    actionButton.backgroundColor = currentStatus.backgroundColor
    actionButton.setTitleColor(currentStatus.textColor, for: .normal)
  }

  private func createSpacerView(height: CGFloat) -> UIView {
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

  // MARK: - Cell Configuration

  private func configureCell(_ cell: AlphaTestTableViewCell, at indexPath: IndexPath) {
    let title = testItems[indexPath.row]
    let status = statusForRow(at: indexPath)
    cell.configure(title: title, status: status)
  }

  private func statusForRow(at indexPath: IndexPath) -> AlphaTestTableViewCell.Status {
    // Alternate status for demonstration: every 3rd row shows failure
    switch indexPath.row % 3 {
    case 0: return .failure
    case 1: return .success
    default: return .pending
    }
  }
}

// MARK: - UITableViewDataSource

extension DeviceTestViewController: UITableViewDataSource {

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return testItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.cellReuseIdentifier,
      for: indexPath
    )

    if let testCell = cell as? AlphaTestTableViewCell {
      configureCell(testCell, at: indexPath)
    }

    cell.backgroundColor = Constants.tableBackgroundColor
    return cell
  }
}

// MARK: - UITableViewDelegate

extension DeviceTestViewController: UITableViewDelegate {
  // Add delegate methods here if needed (e.g., didSelectRowAt)
}
