//
//  BetaTestViewController.swift
//  Tester One
//
//  Created by Codex on 09/02/26.
//

import UIKit

// MARK: - BetaTestViewController

/// Figma-driven function check screen using UIKit and Auto Layout (iOS 12+).
///
/// AppDelegate integration snippet (kept as docs only per request):
/// let rootViewController = BetaTestViewController()
/// let navigationController = UINavigationController(rootViewController: rootViewController)
/// window?.rootViewController = navigationController
final class BetaTestViewController: UIViewController {

  // MARK: Internal

  struct ProcessResult {
    let index: Int
    let title: String
    let state: BetaTestCardState
  }

  enum RunPhase: Equatable {
    case idle
    case processing
    case finished
  }

  enum ProcessingEvent {
    case stepCompleted(ProcessResult)
    case runCompleted([ProcessResult])
  }

  /// Single callback surface for processing lifecycle to avoid duplicated hooks.
  var onProcessingEvent: ((ProcessingEvent) -> Void)?

  /// Optional callback invoked when continue button is tapped.
  var onContinueButtonTapped: (() -> Void)?

  /// Optional callback invoked when retry is tapped for a failed card.
  var onRetryButtonTapped: ((_ index: Int, _ title: String) -> Void)?

  /// Optional callback invoked when a single retry completes.
  var onRetryCompleted: ((ProcessResult) -> Void)?

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Starts loading -> result transition for all cards in chained sequential order.
  func beginProcessing() {
    guard runPhase != .processing else { return }

    let runID = runCoordinator.beginProcessingRun()
    setRunPhase(.processing)
    processNextItem(at: 0, runID: runID, results: [])
  }

  /// Manually set a single card state (useful for external action chains).
  func setState(_ state: BetaTestCardState, at index: Int) {
    updateItemState(state, at: index, animated: false)
  }

  /// Manually set all card states.
  func setAllStates(_ state: BetaTestCardState) {
    updateAllItemStates(state)
  }

  /// Customize one cell content without touching others.
  func updateItemContent(at index: Int, mutate: (inout BetaTestItem.Content) -> Void) {
    guard items.indices.contains(index) else { return }
    mutate(&items[index].content)
    reloadItem(at: index)
  }

  /// Customize one cell execution behavior without touching others.
  func updateItemExecutionHandler(at index: Int, handler: @escaping BetaTestItem.ExecutionHandler) {
    guard items.indices.contains(index) else { return }
    items[index].executionHandler = handler
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBarAppearance()
    setupViewHierarchy()
    setupConstraints()
    setupObservers()
    setRunPhase(.idle)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateCollectionLayoutIfNeeded()
    updateContinueButtonShadowPathIfNeeded()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    guard
      previousTraitCollection?.preferredContentSizeCategory
        != traitCollection.preferredContentSizeCategory
    else { return }

    cachedRowMeasurements = nil
    collectionView.collectionViewLayout.invalidateLayout()
  }

  #if DEBUG
    func debug_runPhase() -> RunPhase { runPhase }
    func debug_itemState(at index: Int) -> BetaTestCardState? {
      guard items.indices.contains(index) else { return nil }
      return items[index].state
    }

    func debug_triggerRetry(at index: Int) { handleRetryTap(at: index) }
  #endif

  // MARK: Private

  private struct RunCoordinator {

    // MARK: Internal

    mutating func beginProcessingRun() -> UUID {
      activeProcessRunID = UUID()
      activeRetryRunIDs.removeAll()
      return activeProcessRunID
    }

    func isProcessingRunActive(_ id: UUID) -> Bool {
      activeProcessRunID == id
    }

    func isRetryIdle(at index: Int) -> Bool {
      activeRetryRunIDs[index] == nil
    }

    mutating func beginRetry(at index: Int) -> UUID? {
      guard activeRetryRunIDs[index] == nil else { return nil }
      let id = UUID()
      activeRetryRunIDs[index] = id
      return id
    }

    func isRetryActive(_ id: UUID, at index: Int) -> Bool {
      activeRetryRunIDs[index] == id
    }

    mutating func endRetry(at index: Int, id: UUID) {
      guard activeRetryRunIDs[index] == id else { return }
      activeRetryRunIDs[index] = nil
    }

    // MARK: Private

    private var activeProcessRunID = UUID()
    private var activeRetryRunIDs = [Int: UUID]()

  }

  private enum Layout {
    static let contentTopCornerRadius: CGFloat = 30

    static let gridTopInset: CGFloat = 20
    static let gridHorizontalInset: CGFloat = 20
    static let gridBottomInset: CGFloat = 20
    static let gridInterItemSpacing: CGFloat = 12
    static let gridLineSpacing: CGFloat = 12
    static let cardsPerRow = 2

    static let bottomSectionTopInset: CGFloat = 16
    static let bottomSectionBottomInset: CGFloat = 16
    static let buttonHorizontalInset: CGFloat = 20
    static let buttonHeight: CGFloat = 55
    static let buttonCornerRadius: CGFloat = 27.5
  }

  private var items = BetaTestViewController.defaultItems()
  private var runPhase = RunPhase.idle
  private var runCoordinator = RunCoordinator()

  private var lastCollectionWidth: CGFloat = 0
  private var lastContinueButtonShadowBounds = CGRect.zero
  private var cachedRowMeasurements:
    (
      width: CGFloat,
      contentSizeCategory: UIContentSizeCategory,
      heightsByRow: [CGFloat],
    )?

  private lazy var collectionLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.estimatedItemSize = .zero
    layout.sectionInset = UIEdgeInsets(
      top: Layout.gridTopInset,
      left: Layout.gridHorizontalInset,
      bottom: Layout.gridBottomInset,
      right: Layout.gridHorizontalInset,
    )
    layout.minimumInteritemSpacing = Layout.gridInterItemSpacing
    layout.minimumLineSpacing = Layout.gridLineSpacing
    return layout
  }()

  private lazy var contentContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.layer.cornerRadius = Layout.contentTopCornerRadius
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.clipsToBounds = true
    view.accessibilityIdentifier = "BetaTestViewController.contentContainerView"
    return view
  }()

  private lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .betaTestSurface
    view.alwaysBounceVertical = true
    view.showsVerticalScrollIndicator = false
    view.delaysContentTouches = false
    view.dataSource = self
    view.delegate = self
    view.accessibilityIdentifier = "BetaTestViewController.collectionView"
    view.register(
      BetaTestCollectionViewCell.self,
      forCellWithReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier)
    return view
  }()

  private lazy var bottomOverlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .betaTestSurface
    view.clipsToBounds = false
    view.accessibilityIdentifier = "BetaTestViewController.bottomSectionView"
    return view
  }()

  private lazy var continueButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Lanjut", for: .normal)
    button.setTitleColor(.white, for: .normal)
    let baseFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
    button.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: baseFont)
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.backgroundColor = .betaTestHeaderGreen
    button.layer.cornerRadius = Layout.buttonCornerRadius
    button.clipsToBounds = true
    button.contentHorizontalAlignment = .center
    button.addTarget(self, action: #selector(handleContinueTap), for: .touchUpInside)
    button.accessibilityIdentifier = "BetaTestViewController.continueButton"
    return button
  }()

  private lazy var continueButtonShadowView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.layer.masksToBounds = false
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.3
    view.layer.shadowRadius = 9
    view.layer.shadowOffset = .zero
    view.accessibilityIdentifier = "BetaTestViewController.continueButtonShadowView"
    return view
  }()

  private static func defaultItems() -> [BetaTestItem] {
    [
      makeDefaultItem(title: "CPU", icon: .cpu, initialState: .success),
      makeDefaultItem(title: "Hard Disk", icon: .hardDisk, initialState: .success),
      makeDefaultItem(title: "Kondisi Baterai", icon: .battery, initialState: .success),
      makeDefaultItem(title: "Tes Jailbreak", icon: .jailbreak, initialState: .success),
      makeDefaultItem(title: "Tes Biometric 1", icon: .biometricOne, initialState: .success),
      makeDefaultItem(title: "Tes Biometric 2", icon: .biometricTwo, initialState: .success),
      makeDefaultItem(title: "Tombol Silent", icon: .silent, initialState: .failed),
      makeDefaultItem(title: "Tombol Volume", icon: .volume, initialState: .success),
      makeDefaultItem(title: "Tombol On/Off", icon: .power, initialState: .success),
      makeDefaultItem(title: "Tes Kamera", icon: .camera, initialState: .success),
      makeDefaultItem(title: "Tes Layar Sentuh", icon: .touch, initialState: .success),
      makeDefaultItem(title: "Tes Kartu SIM", icon: .sim, initialState: .success),
    ]
  }

  private static func makeDefaultItem(
    title: String,
    icon: BetaTestItem.IconType,
    initialState: BetaTestCardState,
    retryState: BetaTestCardState = .success,
    simulatedDuration: TimeInterval = 0.25,
  ) -> BetaTestItem {
    BetaTestItem(
      title: title,
      icon: icon,
      state: .initial,
      executionHandler: { phase, completion in
        // let state: BetaTestCardState = (phase == .initial) ? initialState : retryState
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedDuration) {
          completion(.failed)
        }
      },
    )
  }

  private func setupObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleMemoryWarningNotification),
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil,
    )
  }

  @objc
  private func handleMemoryWarningNotification() {
    BetaTestCollectionViewCell.clearFallbackImageCache()
  }

  private func setupViewHierarchy() {
    view.backgroundColor = .betaTestHeaderGreen
    view.accessibilityIdentifier = "BetaTestViewController.view"

    view.addSubview(contentContainerView)
    contentContainerView.addSubview(collectionView)
    contentContainerView.addSubview(bottomOverlayView)

    bottomOverlayView.addSubview(continueButtonShadowView)
    continueButtonShadowView.addSubview(continueButton)
  }

  private func configureNavigationBarAppearance() {
    title = "Cek Fungsi"
    navigationItem.largeTitleDisplayMode = .never

    guard let navigationBar = navigationController?.navigationBar else { return }
    navigationBar.accessibilityIdentifier = "BetaTestViewController.navigationBar"
    navigationBar.prefersLargeTitles = false
    navigationBar.tintColor = .white
    navigationBar.barStyle = .black

    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .betaTestHeaderGreen
      appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
      appearance.shadowColor = .clear
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.compactAppearance = appearance
    } else {
      navigationBar.isTranslucent = false
      navigationBar.barTintColor = .betaTestHeaderGreen
      navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
      navigationBar.shadowImage = UIImage()
      navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      contentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      collectionView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: bottomOverlayView.topAnchor),

      bottomOverlayView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
      bottomOverlayView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
      bottomOverlayView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

      continueButtonShadowView.leadingAnchor.constraint(
        equalTo: bottomOverlayView.leadingAnchor,
        constant: Layout.buttonHorizontalInset,
      ),
      continueButtonShadowView.trailingAnchor.constraint(
        equalTo: bottomOverlayView.trailingAnchor,
        constant: -Layout.buttonHorizontalInset,
      ),
      continueButtonShadowView.topAnchor.constraint(
        equalTo: bottomOverlayView.topAnchor, constant: Layout.bottomSectionTopInset),
      continueButtonShadowView.heightAnchor.constraint(
        greaterThanOrEqualToConstant: Layout.buttonHeight),
      continueButtonShadowView.bottomAnchor.constraint(
        equalTo: bottomOverlayView.safeAreaLayoutGuide.bottomAnchor,
        constant: -Layout.bottomSectionBottomInset,
      ),

      continueButton.leadingAnchor.constraint(equalTo: continueButtonShadowView.leadingAnchor),
      continueButton.trailingAnchor.constraint(equalTo: continueButtonShadowView.trailingAnchor),
      continueButton.topAnchor.constraint(equalTo: continueButtonShadowView.topAnchor),
      continueButton.bottomAnchor.constraint(equalTo: continueButtonShadowView.bottomAnchor),
    ])
  }

  private func updateCollectionLayoutIfNeeded() {
    let collectionWidth = collectionView.bounds.width
    guard collectionWidth > 0 else { return }
    guard abs(collectionWidth - lastCollectionWidth) > 0.5 else { return }
    lastCollectionWidth = collectionWidth
    cachedRowMeasurements = nil

    collectionView.collectionViewLayout.invalidateLayout()
  }

  private func updateContinueButtonShadowPathIfNeeded() {
    let bounds = continueButtonShadowView.bounds
    guard bounds.width > 0, bounds.height > 0 else { return }
    guard bounds != lastContinueButtonShadowBounds else { return }

    lastContinueButtonShadowBounds = bounds
    continueButtonShadowView.layer.shadowPath =
      UIBezierPath(
        roundedRect: bounds,
        cornerRadius: Layout.buttonCornerRadius,
      ).cgPath
  }

  @objc
  private func handleContinueTap() {
    switch runPhase {
    case .idle:
      onContinueButtonTapped?()
      beginProcessing()

    case .processing:
      return

    case .finished:
      onContinueButtonTapped?()
    }
  }

  private func updateAllItemStates(_ state: BetaTestCardState) {
    for index in items.indices {
      items[index].state = state
      updateItemState(
        state,
        at: index,
        animated: false,
        completion: nil,
      )
    }
  }

  private func reloadItem(at index: Int) {
    guard items.indices.contains(index) else { return }
    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
  }

  private func updateItemState(
    _ state: BetaTestCardState,
    at index: Int,
    animated: Bool,
    completion: (() -> Void)? = nil,
  ) {
    guard items.indices.contains(index) else {
      completion?()
      return
    }

    items[index].state = state
    let indexPath = IndexPath(item: index, section: 0)

    if let cell = collectionView.cellForItem(at: indexPath) as? BetaTestCollectionViewCell {
      cell.transition(to: state, item: items[index], animated: animated, completion: completion)
      return
    }

    collectionView.reloadItems(at: [indexPath])
    completion?()
  }

  private func processNextItem(
    at index: Int,
    runID: UUID,
    results: [ProcessResult],
  ) {
    guard runCoordinator.isProcessingRunActive(runID) else { return }

    guard items.indices.contains(index) else {
      setRunPhase(.finished)
      onProcessingEvent?(.runCompleted(results))
      return
    }

    executeItem(at: index, phase: .initial) { [weak self] result in
      guard let self else { return }
      guard runCoordinator.isProcessingRunActive(runID) else { return }

      onProcessingEvent?(.stepCompleted(result))
      processNextItem(at: index + 1, runID: runID, results: results + [result])
    }
  }

  private func setRunPhase(_ phase: RunPhase) {
    runPhase = phase

    switch phase {
    case .idle:
      continueButton.setTitle("Mulai Tes", for: .normal)
      continueButton.setTitleColor(.white, for: .normal)
      continueButton.backgroundColor = .betaTestHeaderGreen
      continueButton.isEnabled = true

    case .processing:
      continueButton.setTitle("Dalam Pengecekan", for: .normal)
      continueButton.setTitleColor(.betaTestLoadingText, for: .normal)
      continueButton.backgroundColor = .betaTestLoadingBackground
      continueButton.isEnabled = false

    case .finished:
      continueButton.setTitle("Lanjut", for: .normal)
      continueButton.setTitleColor(.white, for: .normal)
      continueButton.backgroundColor = .betaTestHeaderGreen
      continueButton.isEnabled = true
    }
  }

  private func handleRetryTap(at index: Int) {
    guard items.indices.contains(index) else { return }
    guard items[index].state == .failed else { return }
    guard runCoordinator.isRetryIdle(at: index) else { return }

    let title = items[index].title
    onRetryButtonTapped?(index, title)

    guard let retryRunID = runCoordinator.beginRetry(at: index) else { return }
    executeItem(at: index, phase: .retry) { [weak self] result in
      guard let self else { return }
      guard runCoordinator.isRetryActive(retryRunID, at: index) else { return }

      runCoordinator.endRetry(at: index, id: retryRunID)
      onProcessingEvent?(.stepCompleted(result))
      onRetryCompleted?(result)
    }
  }

  private func executeItem(
    at index: Int,
    phase: BetaTestItem.ExecutionPhase,
    completion: @escaping (ProcessResult) -> Void,
  ) {
    guard items.indices.contains(index) else { return }

    updateItemState(.loading, at: index, animated: true) { [weak self] in
      guard let self else { return }
      guard items.indices.contains(index) else { return }

      performItemExecution(at: index, phase: phase) { [weak self] finalState in
        guard let self else { return }
        guard items.indices.contains(index) else { return }

        let title = items[index].title
        updateItemState(finalState, at: index, animated: true) {
          completion(ProcessResult(index: index, title: title, state: finalState))
        }
      }
    }
  }

  private func performItemExecution(
    at index: Int,
    phase: BetaTestItem.ExecutionPhase,
    completion: @escaping (BetaTestCardState) -> Void,
  ) {
    guard items.indices.contains(index) else { return }

    let handler = items[index].executionHandler ?? { _, done in
      assertionFailure("Missing executionHandler for item at index \(index)")
      done(.failed)
    }

    handler(phase) { state in
      DispatchQueue.main.async {
        completion(state)
      }
    }
  }
}

// MARK: UICollectionViewDataSource

extension BetaTestViewController: UICollectionViewDataSource {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier,
      for: indexPath,
    )

    guard let betaCell = cell as? BetaTestCollectionViewCell else {
      return cell
    }

    betaCell.configure(with: items[indexPath.item])
    betaCell.onRetryTapped = { [weak self, weak betaCell, weak collectionView] in
      guard let self, let betaCell, let collectionView else { return }
      guard let resolvedIndexPath = collectionView.indexPath(for: betaCell) else { return }
      handleRetryTap(at: resolvedIndexPath.item)
    }
    return betaCell
  }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BetaTestViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath,
  ) -> CGSize {
    let sectionInsets = collectionLayout.sectionInset
    let horizontalInsets = sectionInsets.left + sectionInsets.right
    let contentWidth = collectionView.bounds.width - horizontalInsets
    guard contentWidth > 0 else { return .zero }

    let totalSpacing = Layout.gridInterItemSpacing * CGFloat(Layout.cardsPerRow - 1)
    let itemWidth = floor((contentWidth - totalSpacing) / CGFloat(Layout.cardsPerRow))
    guard itemWidth > 0 else { return .zero }

    let itemHeight = adaptiveCardHeight(for: itemWidth, at: indexPath.item)
    return CGSize(width: itemWidth, height: itemHeight)
  }
}

extension BetaTestViewController {
  private func adaptiveCardHeight(for itemWidth: CGFloat, at itemIndex: Int) -> CGFloat {
    let contentSizeCategory = traitCollection.preferredContentSizeCategory
    let rowIndex = max(0, itemIndex / Layout.cardsPerRow)
    if let cachedRowMeasurements,
      abs(cachedRowMeasurements.width - itemWidth) < 0.5,
      cachedRowMeasurements.contentSizeCategory == contentSizeCategory,
      rowIndex < cachedRowMeasurements.heightsByRow.count
    {
      return cachedRowMeasurements.heightsByRow[rowIndex]
    }

    let measuredHeights = BetaTestCollectionViewCell.preferredHeightsByRow(
      for: itemWidth,
      titles: items.map(\.title),
      itemsPerRow: Layout.cardsPerRow,
      traitCollection: traitCollection,
    )
    cachedRowMeasurements = (
      width: itemWidth,
      contentSizeCategory: contentSizeCategory,
      heightsByRow: measuredHeights,
    )

    if rowIndex < measuredHeights.count {
      return measuredHeights[rowIndex]
    }

    return measuredHeights.last ?? 0
  }
}

// MARK: - BetaTestCollectionViewCell

// Extracted to BetaTestCollectionViewCell.swift
