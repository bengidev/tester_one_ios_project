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
    updateTableRowHeightsForWidthChangeIfNeeded()
  }

  // MARK: Private

  private enum Constants {
    static let navigationTitle = "Cek Fungsi Software"
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

  private enum BottomButtonState {
    case start
    case wait
    case finish
  }

  private struct StateUpdate {
    let indexPath: IndexPath
    let state: AlphaTestTableViewCell.ActionSectionState
  }

  /// Test item model with state
  private struct TestItem {
    let title: String
    var actionState = AlphaTestTableViewCell.ActionSectionState.hidden
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
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."
    ),
  ]

  /// Current bottom button state
  private var bottomButtonState = BottomButtonState.start
  private var pendingStateUpdates = [StateUpdate]()
  private var isProcessingStateUpdate = false
  private var hasLoggedDequeuedCellClass = false
  private var lastKnownTableWidth: CGFloat = 0

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
      AlphaTestTableViewCell.self,
      forCellReuseIdentifier: AlphaTestTableViewCell.reuseIdentifier,
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
    let updates = sortedVisibleIndexPaths().map { ($0, AlphaTestTableViewCell.ActionSectionState.loading) }
    enqueueStateUpdates(updates)

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
    enqueueStateUpdates(updates)
  }

  /// Handle retry button tap for a specific row
  private func handleRetryButtonTapped(at indexPath: IndexPath) {
    guard indexPath.row < testItems.count else { return }

    // Reset to loading and update in place (no reload to avoid glitch)
    testItems[indexPath.row].actionState = .loading
    enqueueStateUpdates([(indexPath, .loading)])

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
    enqueueStateUpdates([(indexPath, .failed)])
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

  private func updateTableRowHeightsForWidthChangeIfNeeded() {
    let currentWidth = tableView.bounds.width
    guard currentWidth > 0 else { return }
    guard abs(currentWidth - lastKnownTableWidth) > 0.5 else { return }

    lastKnownTableWidth = currentWidth
    UIView.performWithoutAnimation {
      tableView.beginUpdates()
      tableView.endUpdates()
    }
  }

  private func configureCell(_ cell: AlphaTestTableViewCell, at indexPath: IndexPath) {
    let item = testItems[indexPath.row]
    cell.configure(title: item.title)
    cell.setActionSectionState(item.actionState, animated: false)

    // Retry button tap handler
    cell.onRetryButtonTapped = { [weak self, weak cell] in
      guard
        let self,
        let cell,
        let currentIndexPath = tableView.indexPath(for: cell)
      else { return }
      handleRetryButtonTapped(at: currentIndexPath)
    }
  }

  private func enqueueStateUpdates(_ updates: [(IndexPath, AlphaTestTableViewCell.ActionSectionState)]) {
    guard !updates.isEmpty else { return }
    pendingStateUpdates.append(contentsOf: updates.map { StateUpdate(indexPath: $0.0, state: $0.1) })
    processNextStateUpdateIfNeeded()
  }

  private func processNextStateUpdateIfNeeded() {
    guard !isProcessingStateUpdate else { return }
    guard !pendingStateUpdates.isEmpty else { return }

    isProcessingStateUpdate = true
    let nextUpdate = pendingStateUpdates.removeFirst()
    applyStateUpdate(nextUpdate) { [weak self] in
      guard let self else { return }
      isProcessingStateUpdate = false
      processNextStateUpdateIfNeeded()
    }
  }

  private func applyStateUpdate(_ update: StateUpdate, completion: @escaping () -> Void) {
    guard update.indexPath.row < testItems.count else {
      completion()
      return
    }

    guard let cell = tableView.cellForRow(at: update.indexPath) as? AlphaTestTableViewCell else {
      completion()
      return
    }

    // Perform batch updates to animate height/layout changes
    tableView.performBatchUpdates(
      {
        cell.setActionSectionState(update.state, animated: true)
        cell.layoutIfNeeded() // Animate layout changes
      },
      completion: { _ in
        completion()
      },
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

}

// MARK: UITableViewDataSource

extension DeviceTestViewController: UITableViewDataSource {

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    testItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: AlphaTestTableViewCell.reuseIdentifier,
      for: indexPath,
    )

    if let testCell = cell as? AlphaTestTableViewCell {
      if !hasLoggedDequeuedCellClass {
        print("Dequeued runtime cell class: \(type(of: testCell)) with reuseId: \(type(of: testCell).reuseIdentifier)")
        hasLoggedDequeuedCellClass = true
      }
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
