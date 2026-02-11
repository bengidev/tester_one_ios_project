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

  typealias StateResolver = (_ index: Int, _ title: String) -> BetaTestCardState

  /// Duration for simulated process transition from loading -> final state.
  var processDuration: TimeInterval = 1.2

  /// Custom resolver for final item state after loading. Defaults to internal resolver when nil.
  var stateResolver: StateResolver?

  /// Callback invoked after all items finish processing.
  var onProcessCompleted: (([ProcessResult]) -> Void)?

  /// Optional callback invoked when continue button is tapped.
  var onContinueButtonTapped: (() -> Void)?

  /// Optional callback invoked when retry is tapped for a failed card.
  var onRetryButtonTapped: ((_ index: Int, _ title: String) -> Void)?

  /// Optional callback invoked when a single retry completes.
  var onRetryCompleted: ((ProcessResult) -> Void)?

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Starts loading -> result transition for all cards.
  func beginProcessing() {
    guard runPhase != .processing else { return }

    let runID = runCoordinator.beginProcessingRun()
    setRunPhase(.processing)
    updateAllItemStates(.loading)

    DispatchQueue.main.asyncAfter(deadline: .now() + processDuration) { [weak self] in
      guard let self else { return }
      guard runCoordinator.isProcessingRunActive(runID) else { return }

      var results = [ProcessResult]()

      for index in items.indices {
        let title = items[index].title
        let resolvedState = stateResolver?(index, title) ?? defaultFinalState(for: index)
        setItemState(resolvedState, at: index, reload: false)
        results.append(ProcessResult(index: index, title: title, state: resolvedState))
      }

      reloadAllItems()
      setRunPhase(.finished)
      onProcessCompleted?(results)
    }
  }

  /// Manually set a single card state (useful for external action chains).
  func setState(_ state: BetaTestCardState, at index: Int) {
    setItemState(state, at: index, reload: true)
  }

  /// Manually set all card states.
  func setAllStates(_ state: BetaTestCardState) {
    updateAllItemStates(state)
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
  func debug_defaultFinalState(for index: Int) -> BetaTestCardState { defaultFinalState(for: index) }
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
  private var cachedRowMeasurements: (
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
    view.register(BetaTestCollectionViewCell.self, forCellWithReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier)
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
      BetaTestItem(title: "CPU", icon: .cpu, state: .initial),
      BetaTestItem(title: "Hard Disk", icon: .hardDisk, state: .initial),
      BetaTestItem(title: "Kondisi Baterai", icon: .battery, state: .initial),
      BetaTestItem(title: "Tes Jailbreak", icon: .jailbreak, state: .initial),
      BetaTestItem(title: "Tes Biometric 1", icon: .biometricOne, state: .initial),
      BetaTestItem(title: "Tes Biometric 2", icon: .biometricTwo, state: .initial),
      BetaTestItem(title: "Tombol Silent", icon: .silent, state: .initial),
      BetaTestItem(title: "Tombol Volume", icon: .volume, state: .initial),
      BetaTestItem(title: "Tombol On/Off", icon: .power, state: .initial),
      BetaTestItem(title: "Tes Kamera", icon: .camera, state: .initial),
      BetaTestItem(title: "Tes Layar Sentuh", icon: .touch, state: .initial),
      BetaTestItem(title: "Tes Kartu SIM", icon: .sim, state: .initial),
    ]
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
      continueButtonShadowView.topAnchor.constraint(equalTo: bottomOverlayView.topAnchor, constant: Layout.bottomSectionTopInset),
      continueButtonShadowView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.buttonHeight),
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
    continueButtonShadowView.layer.shadowPath = UIBezierPath(
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
      setItemState(state, at: index, reload: false)
    }
    reloadAllItems()
  }

  private func setItemState(_ state: BetaTestCardState, at index: Int, reload: Bool) {
    guard items.indices.contains(index) else { return }
    guard items[index].state != state else { return }

    items[index].state = state

    guard reload else { return }
    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
  }

  private func reloadAllItems() {
    guard !items.isEmpty else { return }
    collectionView.reloadData()
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
    setItemState(.loading, at: index, reload: true)

    DispatchQueue.main.asyncAfter(deadline: .now() + processDuration) { [weak self] in
      guard let self else { return }
      guard runCoordinator.isRetryActive(retryRunID, at: index) else { return }
      guard items.indices.contains(index) else { return }

      let resolvedState = stateResolver?(index, title) ?? defaultFinalState(for: index)
      setItemState(resolvedState, at: index, reload: true)
      runCoordinator.endRetry(at: index, id: retryRunID)

      onRetryCompleted?(ProcessResult(index: index, title: title, state: resolvedState))
    }
  }

  private func defaultFinalState(for index: Int) -> BetaTestCardState {
    // Keep current behavior: only "Tombol Silent" card (index 6 in default dataset) fails by default.
    index == 6 ? .failed : .success
  }

}

// MARK: UICollectionViewDataSource

extension BetaTestViewController: UICollectionViewDataSource {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    if
      let cachedRowMeasurements,
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
