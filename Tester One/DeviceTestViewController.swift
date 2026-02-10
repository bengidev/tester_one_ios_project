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

    static var navigationTitleColor: UIColor {
      if #available(iOS 13.0, *) {
        .label
      } else {
        .black
      }
    }

    static var tableBackgroundColor: UIColor {
      if #available(iOS 13.0, *) {
        .secondarySystemBackground
      } else {
        UIColor(
          red: 232.0 / 255.0,
          green: 238.0 / 255.0,
          blue: 241.0 / 255.0,
          alpha: 1,
        )
      }
    }

    /// Bottom button colors
    static var primaryBlue: UIColor {
      if #available(iOS 13.0, *) {
        .systemBlue
      } else {
        UIColor(
          red: 51.0 / 255.0,
          green: 185.0 / 255.0,
          blue: 255.0 / 255.0,
          alpha: 1,
        )
      }
    }

    static var disabledBackground: UIColor {
      if #available(iOS 13.0, *) {
        .tertiarySystemFill
      } else {
        UIColor(
          red: 215.0 / 255.0,
          green: 220.0 / 255.0,
          blue: 222.0 / 255.0,
          alpha: 1,
        )
      }
    }

    static var disabledTitle: UIColor {
      if #available(iOS 13.0, *) {
        .secondaryLabel
      } else {
        UIColor(
          red: 173.0 / 255.0,
          green: 177.0 / 255.0,
          blue: 178.0 / 255.0,
          alpha: 1,
        )
      }
    }
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

  /// Ordered procedures to mirror the real-device-test workflow.
  private enum TestProcedure {
    case simCard
    case wifi
    case bluetooth
    case proximity
    case charging
    case storage
    case processor
    case camera
    case location
    case touchscreen
  }

  private enum TestRunPhase {
    case initial
    case retry
  }

  private struct TestRunPlan {
    var loadingDuration: TimeInterval
    var initialProcedure: TestProcedure
    var retryProcedure: TestProcedure
    var successState: AlphaTestTableViewCell.ActionSectionState
    var failureState: AlphaTestTableViewCell.ActionSectionState
  }

  /// Test item model with customizable content and sequential run plan.
  private struct TestItem {
    var content: AlphaTestTableViewCell.Content
    var runPlan: TestRunPlan
    var actionState = AlphaTestTableViewCell.ActionSectionState.hidden
  }

  private var testItems: [TestItem] = [
    DeviceTestViewController.makeTestItem(
      title: "Short title",
      initialProcedure: .simCard,
      retryProcedure: .simCard,
    ),
    DeviceTestViewController.makeTestItem(
      title: "Lorem ipsum dolor sit amet",
      initialProcedure: .wifi,
      retryProcedure: .wifi,
    ),
    DeviceTestViewController.makeTestItem(
      title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
      initialProcedure: .bluetooth,
      retryProcedure: .bluetooth,
    ),
    DeviceTestViewController.makeTestItem(
      title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
      initialProcedure: .proximity,
      retryProcedure: .proximity,
    ),
    DeviceTestViewController.makeTestItem(
      title: "One liner",
      initialProcedure: .charging,
      retryProcedure: .charging,
    ),
    DeviceTestViewController.makeTestItem(
      title:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
      initialProcedure: .storage,
      retryProcedure: .storage,
    ),
    DeviceTestViewController.makeTestItem(
      title: "Medium length title here",
      initialProcedure: .processor,
      retryProcedure: .processor,
    ),
    DeviceTestViewController.makeTestItem(
      title:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
      initialProcedure: .camera,
      retryProcedure: .camera,
    ),
    DeviceTestViewController.makeTestItem(
      title: "Test",
      initialProcedure: .location,
      retryProcedure: .location,
    ),
    DeviceTestViewController.makeTestItem(
      title:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      initialProcedure: .touchscreen,
      retryProcedure: .touchscreen,
    ),
  ]

  /// Current bottom button state
  private var bottomButtonState = BottomButtonState.start
  private var activeSequenceID = UUID()
  private var activeRetryIDs = [Int: UUID]()
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
    let baseFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    button.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: baseFont)
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.layer.cornerRadius = Layout.actionButtonCornerRadius
    button.clipsToBounds = true
    return button
  }()

  /// Builder used to keep test-item customization simple and centralized.
  private static func makeTestItem(
    title: String,
    iconName: String = "cpuImage",
    retryButtonTitle: String = "ULANGI",
    successIndicatorName: String = "successImage",
    failedIndicatorName: String = "failedImage",
    initialProcedure: TestProcedure,
    retryProcedure: TestProcedure? = nil,
    loadingDuration: TimeInterval = 1.2,
    successState: AlphaTestTableViewCell.ActionSectionState = .success,
    failureState: AlphaTestTableViewCell.ActionSectionState = .failed,
  ) -> TestItem {
    let content = AlphaTestTableViewCell.Content(
      title: title,
      iconImage: UIImage(named: iconName),
      retryButtonTitle: retryButtonTitle,
      successIndicatorImage: UIImage(named: successIndicatorName),
      failedIndicatorImage: UIImage(named: failedIndicatorName),
    )

    let runPlan = TestRunPlan(
      loadingDuration: loadingDuration,
      initialProcedure: initialProcedure,
      retryProcedure: retryProcedure ?? initialProcedure,
      successState: successState,
      failureState: failureState,
    )

    return TestItem(content: content, runPlan: runPlan)
  }

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
      actionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.actionButtonHeight),
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
      startSequentialTests()

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

  /// Starts the run in strict sequence: each test runs loading -> result -> next test.
  private func startSequentialTests() {
    activeSequenceID = UUID()
    activeRetryIDs.removeAll()

    // Reset to hidden before running a fresh sequence.
    for index in testItems.indices {
      testItems[index].actionState = .hidden
    }
    tableView.reloadData()

    bottomButtonState = .wait
    updateActionButton()
    runInitialSimCardStep(sequenceID: activeSequenceID)
  }

  private func runInitialSimCardStep(sequenceID: UUID) {
    runInitialStep(for: .simCard, sequenceID: sequenceID) { [weak self] in
      self?.runInitialWifiStep(sequenceID: sequenceID)
    }
  }

  private func runInitialWifiStep(sequenceID: UUID) {
    runInitialStep(for: .wifi, sequenceID: sequenceID) { [weak self] in
      self?.runInitialBluetoothStep(sequenceID: sequenceID)
    }
  }

  private func runInitialBluetoothStep(sequenceID: UUID) {
    runInitialStep(for: .bluetooth, sequenceID: sequenceID) { [weak self] in
      self?.runInitialProximityStep(sequenceID: sequenceID)
    }
  }

  private func runInitialProximityStep(sequenceID: UUID) {
    runInitialStep(for: .proximity, sequenceID: sequenceID) { [weak self] in
      self?.runInitialChargingStep(sequenceID: sequenceID)
    }
  }

  private func runInitialChargingStep(sequenceID: UUID) {
    runInitialStep(for: .charging, sequenceID: sequenceID) { [weak self] in
      self?.runInitialStorageStep(sequenceID: sequenceID)
    }
  }

  private func runInitialStorageStep(sequenceID: UUID) {
    runInitialStep(for: .storage, sequenceID: sequenceID) { [weak self] in
      self?.runInitialProcessorStep(sequenceID: sequenceID)
    }
  }

  private func runInitialProcessorStep(sequenceID: UUID) {
    runInitialStep(for: .processor, sequenceID: sequenceID) { [weak self] in
      self?.runInitialCameraStep(sequenceID: sequenceID)
    }
  }

  private func runInitialCameraStep(sequenceID: UUID) {
    runInitialStep(for: .camera, sequenceID: sequenceID) { [weak self] in
      self?.runInitialLocationStep(sequenceID: sequenceID)
    }
  }

  private func runInitialLocationStep(sequenceID: UUID) {
    runInitialStep(for: .location, sequenceID: sequenceID) { [weak self] in
      self?.runInitialTouchscreenStep(sequenceID: sequenceID)
    }
  }

  private func runInitialTouchscreenStep(sequenceID: UUID) {
    runInitialStep(for: .touchscreen, sequenceID: sequenceID) { [weak self] in
      self?.completeSequentialTests(sequenceID: sequenceID)
    }
  }

  private func runInitialStep(
    for procedure: TestProcedure,
    sequenceID: UUID,
    next: @escaping () -> Void,
  ) {
    guard sequenceID == activeSequenceID else { return }
    guard let row = indexOfInitialProcedure(procedure) else {
      next()
      return
    }

    let indexPath = IndexPath(row: row, section: 0)
    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)

    setTestState(.loading, at: indexPath, animated: true) { [weak self] in
      guard let self else { return }
      guard activeSequenceID == sequenceID else { return }

      executeRunPlan(forRow: row, phase: .initial) { [weak self] resultState in
        guard let self else { return }
        guard activeSequenceID == sequenceID else { return }

        setTestState(resultState, at: indexPath, animated: true) { [weak self] in
          guard let self else { return }
          guard activeSequenceID == sequenceID else { return }
          next()
        }
      }
    }
  }

  private func indexOfInitialProcedure(_ procedure: TestProcedure) -> Int? {
    testItems.firstIndex(where: { $0.runPlan.initialProcedure == procedure })
  }

  private func completeSequentialTests(sequenceID: UUID) {
    guard sequenceID == activeSequenceID else { return }
    bottomButtonState = .finish
    updateActionButton()
  }

  /// Handle retry button tap for a specific row
  private func handleRetryButtonTapped(at indexPath: IndexPath) {
    guard indexPath.row < testItems.count else { return }

    let row = indexPath.row
    let retryID = UUID()
    activeRetryIDs[row] = retryID

    setTestState(.loading, at: indexPath, animated: true) { [weak self] in
      guard let self else { return }
      guard activeRetryIDs[row] == retryID else { return }

      executeRunPlan(forRow: row, phase: .retry) { [weak self] retryState in
        guard let self else { return }
        guard activeRetryIDs[row] == retryID else { return }
        setTestState(retryState, at: indexPath, animated: true)
      }
    }
  }

  /// Handle "Lanjut" button tap
  private func handleFinishTapped() {
    print("All tests finished!")
    // Could navigate to next screen or show completion
  }

  /// Converts one procedure execution into a final cell state.
  private func executeRunPlan(
    forRow row: Int,
    phase: TestRunPhase,
    completion: @escaping (AlphaTestTableViewCell.ActionSectionState) -> Void,
  ) {
    guard row < testItems.count else {
      completion(.failed)
      return
    }

    let plan = testItems[row].runPlan
    let procedure = phase == .initial ? plan.initialProcedure : plan.retryProcedure
    let startedAt = CACurrentMediaTime()

    performTestProcedure(procedure) { isSuccess in
      let elapsed = CACurrentMediaTime() - startedAt
      let remainingDelay = max(0, plan.loadingDuration - elapsed)

      DispatchQueue.main.asyncAfter(deadline: .now() + remainingDelay) {
        let state = isSuccess ? plan.successState : plan.failureState
        completion(state)
      }
    }
  }

  /// Single routing point for procedure calls.
  /// Replace each `runMock...` function with your real implementation later.
  private func performTestProcedure(
    _ procedure: TestProcedure,
    completion: @escaping (Bool) -> Void,
  ) {
    switch procedure {
    case .simCard:
      runMockSimCardTest(completion: completion)
    case .wifi:
      runMockWifiTest(completion: completion)
    case .bluetooth:
      runMockBluetoothTest(completion: completion)
    case .proximity:
      runMockProximityTest(completion: completion)
    case .charging:
      runMockChargingTest(completion: completion)
    case .storage:
      runMockStorageTest(completion: completion)
    case .processor:
      runMockProcessorTest(completion: completion)
    case .camera:
      runMockCameraTest(completion: completion)
    case .location:
      runMockLocationTest(completion: completion)
    case .touchscreen:
      runMockTouchscreenTest(completion: completion)
    }
  }

  private func runMockSimCardTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.35, success: true, completion: completion)
  }

  private func runMockWifiTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.45, success: false, completion: completion)
  }

  private func runMockBluetoothTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.30, success: true, completion: completion)
  }

  private func runMockProximityTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.40, success: false, completion: completion)
  }

  private func runMockChargingTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.50, success: true, completion: completion)
  }

  private func runMockStorageTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.32, success: false, completion: completion)
  }

  private func runMockProcessorTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.38, success: true, completion: completion)
  }

  private func runMockCameraTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.42, success: false, completion: completion)
  }

  private func runMockLocationTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.36, success: true, completion: completion)
  }

  private func runMockTouchscreenTest(completion: @escaping (Bool) -> Void) {
    simulateMockProcedure(delay: 0.34, success: false, completion: completion)
  }

  private func simulateMockProcedure(
    delay: TimeInterval,
    success: Bool,
    completion: @escaping (Bool) -> Void,
  ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      completion(success)
    }
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

  /// Utility wrapper for per-item customization of icon/text/button/indicators and run result behavior.
  private func updateTestItemConfiguration(
    at row: Int,
    content: AlphaTestTableViewCell.Content? = nil,
    runPlan: TestRunPlan? = nil,
  ) {
    guard row >= 0, row < testItems.count else { return }
    if let content {
      testItems[row].content = content
    }
    if let runPlan {
      testItems[row].runPlan = runPlan
    }
    tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
  }

  private func configureCell(_ cell: AlphaTestTableViewCell, at indexPath: IndexPath) {
    let item = testItems[indexPath.row]
    cell.configure(content: item.content)
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

  private func setTestState(
    _ state: AlphaTestTableViewCell.ActionSectionState,
    at indexPath: IndexPath,
    animated: Bool,
    completion: (() -> Void)? = nil,
  ) {
    guard indexPath.row < testItems.count else {
      completion?()
      return
    }

    testItems[indexPath.row].actionState = state

    guard let cell = tableView.cellForRow(at: indexPath) as? AlphaTestTableViewCell else {
      completion?()
      return
    }

    guard animated else {
      cell.setActionSectionState(state, animated: false)
      completion?()
      return
    }

    tableView.performBatchUpdates(
      {
        cell.setActionSectionState(state, animated: true)
        cell.layoutIfNeeded()
      },
      completion: { _ in
        completion?()
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
