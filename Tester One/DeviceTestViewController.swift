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

  // MARK: Internal

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

  // MARK: Private

  private enum Constants {
    static let navigationTitle = "Cek Fungsi Software"
    static let cellReuseIdentifier = "DeltaTestCell"
    static let estimatedRowHeight: CGFloat = 120
    static let tableContentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    static let mockResultDelay: TimeInterval = 2.0

    static let navigationTitleColor = UIColor(
      red: 0,
      green: 102.0 / 255.0,
      blue: 200.0 / 255.0,
      alpha: 1,
    )
    static let tableBackgroundColor = UIColor(
      red: 232.0 / 255.0,
      green: 238.0 / 255.0,
      blue: 241.0 / 255.0,
      alpha: 1,
    )

    /// Bottom button colors
    static let primaryBlue = UIColor(
      red: 51.0 / 255.0,
      green: 185.0 / 255.0,
      blue: 255.0 / 255.0,
      alpha: 1,
    )
    static let disabledBackground = UIColor(
      red: 215.0 / 255.0,
      green: 220.0 / 255.0,
      blue: 222.0 / 255.0,
      alpha: 1,
    )
    static let disabledTitle = UIColor(
      red: 173.0 / 255.0,
      green: 177.0 / 255.0,
      blue: 178.0 / 255.0,
      alpha: 1,
    )
  }

  private enum Layout {
    static let actionHorizontalInset: CGFloat = 20
    static let actionVerticalInset: CGFloat = 16
    static let actionButtonHeight: CGFloat = 48
    static let actionButtonCornerRadius: CGFloat = 10
  }

  /// Test item model with state
  private struct TestItem {
    let title: String
    var actionState = DeltaTestTableViewCell.ActionSectionState.hidden
  }

  private var testItems: [TestItem] = [
    TestItem(title: "Short title"),
    TestItem(title: "Lorem ipsum dolor sit amet"),
    TestItem(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"),
    TestItem(
      title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor"),
    TestItem(title: "One liner"),
    TestItem(
      title:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"
    ),
    TestItem(title: "Medium length title here"),
    TestItem(
      title:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
    ),
    TestItem(title: "Test"),
    TestItem(
      title:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    ),
  ]

  /// Current bottom button state
  private var bottomButtonState = DeltaTestTableViewCell.BottomButtonState.start

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
      .foregroundColor: Constants.navigationTitleColor
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
      actionContainerView.bottomAnchor.constraint(
        equalTo: fullScreenView.safeAreaLayoutGuide.bottomAnchor),

      // Action button
      actionButton.leadingAnchor.constraint(
        equalTo: actionContainerView.leadingAnchor,
        constant: Layout.actionHorizontalInset,
      ),
      actionButton.trailingAnchor.constraint(
        equalTo: actionContainerView.trailingAnchor,
        constant: -Layout.actionHorizontalInset,
      ),
      actionButton.topAnchor.constraint(
        equalTo: actionContainerView.topAnchor,
        constant: Layout.actionVerticalInset,
      ),
      actionButton.bottomAnchor.constraint(
        equalTo: actionContainerView.bottomAnchor,
        constant: -Layout.actionVerticalInset,
      ),
      actionButton.heightAnchor.constraint(equalToConstant: Layout.actionButtonHeight),
    ])
  }

  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(
      DeltaTestTableViewCell.self,
      forCellReuseIdentifier: Constants.cellReuseIdentifier,
    )

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

  @objc
  private func actionButtonTapped() {
    switch bottomButtonState {
    case .start:
      // Start test: change to "Dalam Pengecekan", show loading on all cells
      bottomButtonState = .wait
      updateActionButton()
      startAllTests()

    case .wait:
      // Still waiting, do nothing
      break

    case .finish:
      // "Lanjut" tapped - could navigate to next screen
      handleFinishTapped()
    }
  }

  private func updateActionButton() {
    switch bottomButtonState {
    case .start:
      actionButton.setTitle("Mulai Tes", for: .normal)
      actionButton.setTitleColor(.white, for: .normal)
      actionButton.backgroundColor = Constants.primaryBlue
      actionButton.isEnabled = true

    case .wait:
      actionButton.setTitle("Dalam Pengecekan", for: .normal)
      actionButton.setTitleColor(Constants.disabledTitle, for: .normal)
      actionButton.backgroundColor = Constants.disabledBackground
      actionButton.isEnabled = false

    case .finish:
      actionButton.setTitle("Lanjut", for: .normal)
      actionButton.setTitleColor(.white, for: .normal)
      actionButton.backgroundColor = Constants.primaryBlue
      actionButton.isEnabled = true
    }
  }

  /// Start all tests - show loading indicators
  private func startAllTests() {
    // Update all models first
    for i in 0..<testItems.count {
      testItems[i].actionState = .loading
    }

    // Animate each visible cell one-by-one so text self-sizing transitions stay focused.
    let updates = sortedVisibleIndexPaths().map { ($0, DeltaTestTableViewCell.ActionSectionState.loading) }
    applyVisibleStateUpdatesSequentially(updates)

    // Simulate async result after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.mockResultDelay) { [weak self] in
      self?.handleTestResults()
    }
  }

  /// Handle test results (mock: even rows succeed, odd rows fail)
  private func handleTestResults() {
    // Update models
    for i in 0..<testItems.count {
      let isSuccess = (i % 2 == 0)
      testItems[i].actionState = isSuccess ? .success : .failed
    }
    bottomButtonState = .finish
    updateActionButton()

    // Animate each visible cell one-by-one so height/text transitions are easier to follow.
    let updates = sortedVisibleIndexPaths().map { indexPath in
      (indexPath, self.testItems[indexPath.row].actionState)
    }
    applyVisibleStateUpdatesSequentially(updates)
  }

  /// Handle retry button tap for a specific row
  private func handleRetryButtonTapped(at indexPath: IndexPath) {
    guard indexPath.row < testItems.count else { return }

    // Reset to loading and update in place (no reload to avoid glitch)
    testItems[indexPath.row].actionState = .loading
    updateCellInPlace(at: indexPath, state: .loading)

    // Simulate async result after 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.mockResultDelay) { [weak self] in
      self?.handleSingleTestResult(at: indexPath)
    }
  }

  /// Handle single test result
  private func handleSingleTestResult(at indexPath: IndexPath) {
    guard indexPath.row < testItems.count else { return }

    // Mock: for retry, keep it failed to test repeated ULANGI taps consistently
    testItems[indexPath.row].actionState = .failed
    updateCellInPlace(at: indexPath, state: .failed)
  }

  /// Handle "Lanjut" button tap
  private func handleFinishTapped() {
    print("All tests finished!")
    // Could navigate to next screen or show completion
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

  private func configureCell(_ cell: DeltaTestTableViewCell, at indexPath: IndexPath) {
    let item = testItems[indexPath.row]
    cell.configure(title: item.title)
    cell.setActionSectionState(item.actionState, animated: false)

    // Retry button tap handler
    cell.onRetryButtonTapped = { [weak self] in
      self?.handleRetryButtonTapped(at: indexPath)
    }
  }

  private func updateCellInPlace(
    at indexPath: IndexPath,
    state: DeltaTestTableViewCell.ActionSectionState,
  ) {
    guard let cell = tableView.cellForRow(at: indexPath) as? DeltaTestTableViewCell else {
      return
    }

    // Perform batch updates to animate height/layout changes
    tableView.performBatchUpdates(
      {
        cell.setActionSectionState(state, animated: true)
        cell.layoutIfNeeded() // Animate layout changes
      },
      completion: nil,
    )
  }

  private func sortedVisibleIndexPaths() -> [IndexPath] {
    (tableView.indexPathsForVisibleRows ?? []).sorted { lhs, rhs in
      if lhs.section == rhs.section {
        return lhs.row < rhs.row
      }
      return lhs.section < rhs.section
    }
  }

  private func applyVisibleStateUpdatesSequentially(
    _ updates: [(IndexPath, DeltaTestTableViewCell.ActionSectionState)],
    currentIndex: Int = 0,
  ) {
    guard currentIndex < updates.count else { return }

    let (indexPath, state) = updates[currentIndex]

    guard let cell = tableView.cellForRow(at: indexPath) as? DeltaTestTableViewCell else {
      applyVisibleStateUpdatesSequentially(updates, currentIndex: currentIndex + 1)
      return
    }

    tableView.performBatchUpdates(
      {
        cell.setActionSectionState(state, animated: true)
        cell.layoutIfNeeded() // Animate layout changes
      },
      completion: { [weak self] _ in
        self?.applyVisibleStateUpdatesSequentially(updates, currentIndex: currentIndex + 1)
      },
    )
  }
}

// MARK: UITableViewDataSource

extension DeviceTestViewController: UITableViewDataSource {

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    testItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.cellReuseIdentifier,
      for: indexPath,
    )

    if let testCell = cell as? DeltaTestTableViewCell {
      configureCell(testCell, at: indexPath)
    }

    cell.backgroundColor = .clear
    return cell
  }
}

// MARK: UITableViewDelegate

extension DeviceTestViewController: UITableViewDelegate {
  // Add delegate methods here if needed (e.g., didSelectRowAt)
}
