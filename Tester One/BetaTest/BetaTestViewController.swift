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

  struct ProcessStep {
    let index: Int
    let title: String
    let phase: BetaTestItem.ExecutionPhase
  }

  enum RunPhase: Equatable {
    case idle
    case processing
    case finished
  }

  enum ProcessingEvent {
    case stepStarted(ProcessStep)
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

  init(
    items: [BetaTestItem],
    layoutStrategy: BetaTestLayoutStrategy = .uniformGrid,
    screen: BetaTestModuleConfiguration.Screen = .init(),
  ) {
    self.items = items
    self.layoutStrategy = layoutStrategy
    self.screen = screen
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Starts loading -> result transition for all cards in chained sequential order.
  func beginProcessing() {
    guard runPhase != .processing else { return }

    focusAttemptedIndexes.removeAll(keepingCapacity: true)
    focusScrolledIndexes.removeAll(keepingCapacity: true)

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
    cachedRowMeasurements = nil
    cachedMosaicMeasurements = nil
    reloadItem(at: index)
  }

  /// Customize one cell execution behavior without touching others.
  /// The provided handler MUST call `continueExecutionWithState(...)` exactly once.
  /// If not called, sequential processing will stall at that cell.
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
    applyMosaicTuningProfileIfNeeded()
    applyBottomControlMetricsIfNeeded()
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
    cachedMosaicMeasurements = nil
    applyMosaicTuningProfileIfNeeded(force: true)
    applyBottomControlMetricsIfNeeded(force: true)
    collectionView.collectionViewLayout.invalidateLayout()
  }

  #if DEBUG
  func debug_runPhase() -> RunPhase { runPhase }
  func debug_itemState(at index: Int) -> BetaTestCardState? {
    guard items.indices.contains(index) else { return nil }
    return items[index].state
  }

  func debug_triggerRetry(at index: Int) { handleRetryTap(at: index) }
  func debug_focusAttemptedIndexes() -> [Int] { focusAttemptedIndexes }
  func debug_focusScrolledIndexes() -> [Int] { focusScrolledIndexes }
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

  private struct MosaicTuningProfile: Equatable {
    let rowUnit: CGFloat
    let minimumItemHeight: CGFloat
    let singleColumnBreakpoint: CGFloat
    let overlapTolerance: CGFloat
    let bigItemMinimumSpan: Int
    let bigItemMaximumSpan: Int
    let bigItemMinimumHeight: CGFloat
  }

  private struct BottomControlMetrics: Equatable {
    let horizontalInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    let minimumHeight: CGFloat
    let verticalContentInset: CGFloat
    let shadowRadius: CGFloat
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

  private var items: [BetaTestItem]
  private let layoutStrategy: BetaTestLayoutStrategy
  private let screen: BetaTestModuleConfiguration.Screen
  private var mosaicBigItemMinimumHeight: CGFloat = 220
  private var lastAppliedMosaicProfile: MosaicTuningProfile?
  private var runPhase = RunPhase.idle
  private var runCoordinator = RunCoordinator()

  private var lastCollectionWidth: CGFloat = 0
  private var lastContinueButtonShadowBounds = CGRect.zero
  private var lastBottomControlMetrics: BottomControlMetrics?
  private var focusAttemptedIndexes = [Int]()
  private var focusScrolledIndexes = [Int]()

  private var continueButtonShadowLeadingConstraint: NSLayoutConstraint?
  private var continueButtonShadowTrailingConstraint: NSLayoutConstraint?
  private var continueButtonShadowTopConstraint: NSLayoutConstraint?
  private var continueButtonShadowBottomConstraint: NSLayoutConstraint?
  private var continueButtonShadowMinHeightConstraint: NSLayoutConstraint?
  private var cachedRowMeasurements:
    (
      width: CGFloat,
      contentSizeCategory: UIContentSizeCategory,
      heightsByRow: [CGFloat],
    )?
  private var cachedMosaicMeasurements:
    (
      width: CGFloat,
      contentSizeCategory: UIContentSizeCategory,
      heightsByIndex: [Int: CGFloat],
      expandedEligibilityByIndex: [Int: Bool],
    )?

  private lazy var uniformGridLayout: UICollectionViewFlowLayout = {
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

  private lazy var adaptiveMosaicLayout: BetaTestAdaptiveMosaicLayout = {
    let layout = BetaTestAdaptiveMosaicLayout()
    layout.delegate = self
    layout.sectionInsets = UIEdgeInsets(
      top: Layout.gridTopInset,
      left: Layout.gridHorizontalInset,
      bottom: Layout.gridBottomInset,
      right: Layout.gridHorizontalInset,
    )
    layout.interItemSpacing = Layout.gridInterItemSpacing
    layout.lineSpacing = Layout.gridLineSpacing
    layout.rowUnit = 8
    layout.minimumItemHeight = 120
    layout.singleColumnBreakpoint = 345
    layout.overlapTolerance = 0.5
    layout.bigItemMinimumSpan = 20
    layout.bigItemMaximumSpan = 42
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
    let view = UICollectionView(frame: .zero, collectionViewLayout: activeCollectionLayout)
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
      forCellWithReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier,
    )
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

  private var activeCollectionLayout: UICollectionViewLayout {
    switch layoutStrategy {
    case .uniformGrid:
      uniformGridLayout
    case .adaptiveMosaic:
      adaptiveMosaicLayout
    }
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
    title = screen.title
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
    continueButtonShadowLeadingConstraint = continueButtonShadowView.leadingAnchor.constraint(
      equalTo: bottomOverlayView.leadingAnchor,
      constant: Layout.buttonHorizontalInset,
    )
    continueButtonShadowTrailingConstraint = continueButtonShadowView.trailingAnchor.constraint(
      equalTo: bottomOverlayView.trailingAnchor,
      constant: -Layout.buttonHorizontalInset,
    )
    continueButtonShadowTopConstraint = continueButtonShadowView.topAnchor.constraint(
      equalTo: bottomOverlayView.topAnchor,
      constant: Layout.bottomSectionTopInset,
    )
    continueButtonShadowMinHeightConstraint = continueButtonShadowView.heightAnchor.constraint(
      greaterThanOrEqualToConstant: Layout.buttonHeight
    )
    continueButtonShadowBottomConstraint = continueButtonShadowView.bottomAnchor.constraint(
      equalTo: bottomOverlayView.safeAreaLayoutGuide.bottomAnchor,
      constant: -Layout.bottomSectionBottomInset,
    )

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

      continueButtonShadowLeadingConstraint,
      continueButtonShadowTrailingConstraint,
      continueButtonShadowTopConstraint,
      continueButtonShadowMinHeightConstraint,
      continueButtonShadowBottomConstraint,

      continueButton.leadingAnchor.constraint(equalTo: continueButtonShadowView.leadingAnchor),
      continueButton.trailingAnchor.constraint(equalTo: continueButtonShadowView.trailingAnchor),
      continueButton.topAnchor.constraint(equalTo: continueButtonShadowView.topAnchor),
      continueButton.bottomAnchor.constraint(equalTo: continueButtonShadowView.bottomAnchor),
    ].compactMap { $0 })
  }

  private func bottomControlMetrics(
    for width: CGFloat,
    contentSizeCategory: UIContentSizeCategory,
  ) -> BottomControlMetrics {
    let widthScale: CGFloat = min(max(width / 390, 0.92), 1.16)
    let dynamicScaleRaw = UIFontMetrics(forTextStyle: .headline).scaledValue(
      for: 1,
      compatibleWith: traitCollection,
    )
    let dynamicScale = min(max(dynamicScaleRaw, 1), 1.5)

    let spacingScale = min(max(widthScale * (1 + ((dynamicScale - 1) * 0.25)), 0.92), 1.30)
    let buttonScale = min(max(widthScale * (1 + ((dynamicScale - 1) * 0.35)), 0.92), 1.35)

    let minimumHeight = max(
      Layout.buttonHeight * buttonScale,
      contentSizeCategory.isAccessibilityCategory ? 62 : 0,
    )

    return BottomControlMetrics(
      horizontalInset: round(Layout.buttonHorizontalInset * spacingScale),
      topInset: round(Layout.bottomSectionTopInset * spacingScale),
      bottomInset: round(Layout.bottomSectionBottomInset * spacingScale),
      minimumHeight: round(minimumHeight),
      verticalContentInset: max(8, round(10 * spacingScale)),
      shadowRadius: max(7, round(9 * spacingScale)),
    )
  }

  private func applyBottomControlMetricsIfNeeded(force: Bool = false) {
    let width = view.bounds.width > 0 ? view.bounds.width : UIScreen.main.bounds.width
    let metrics = bottomControlMetrics(
      for: width,
      contentSizeCategory: traitCollection.preferredContentSizeCategory,
    )

    guard force || metrics != lastBottomControlMetrics else { return }
    lastBottomControlMetrics = metrics

    continueButtonShadowLeadingConstraint?.constant = metrics.horizontalInset
    continueButtonShadowTrailingConstraint?.constant = -metrics.horizontalInset
    continueButtonShadowTopConstraint?.constant = metrics.topInset
    continueButtonShadowBottomConstraint?.constant = -metrics.bottomInset
    continueButtonShadowMinHeightConstraint?.constant = metrics.minimumHeight

    continueButton.contentEdgeInsets = UIEdgeInsets(
      top: metrics.verticalContentInset,
      left: 16,
      bottom: metrics.verticalContentInset,
      right: 16,
    )
    continueButtonShadowView.layer.shadowRadius = metrics.shadowRadius
  }

  private func applyMosaicTuningProfileIfNeeded(force: Bool = false) {
    guard layoutStrategy == .adaptiveMosaic else { return }

    let width = collectionView.bounds.width
    guard width > 0 else { return }

    let profile = mosaicProfile(for: width, contentSizeCategory: traitCollection.preferredContentSizeCategory)
    guard force || profile != lastAppliedMosaicProfile else { return }

    adaptiveMosaicLayout.rowUnit = profile.rowUnit
    adaptiveMosaicLayout.minimumItemHeight = profile.minimumItemHeight
    adaptiveMosaicLayout.singleColumnBreakpoint = profile.singleColumnBreakpoint
    adaptiveMosaicLayout.overlapTolerance = profile.overlapTolerance
    adaptiveMosaicLayout.bigItemMinimumSpan = profile.bigItemMinimumSpan
    adaptiveMosaicLayout.bigItemMaximumSpan = profile.bigItemMaximumSpan
    mosaicBigItemMinimumHeight = profile.bigItemMinimumHeight

    // Adjust insets for narrow screens to fit 2-column
    if width <= 360 {
      adaptiveMosaicLayout.sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
      adaptiveMosaicLayout.interItemSpacing = 6
      adaptiveMosaicLayout.lineSpacing = 6
    } else if width <= 400 {
      adaptiveMosaicLayout.sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
      adaptiveMosaicLayout.interItemSpacing = 10
      adaptiveMosaicLayout.lineSpacing = 10
    } else {
      adaptiveMosaicLayout.sectionInsets = UIEdgeInsets(
        top: Layout.gridTopInset,
        left: Layout.gridHorizontalInset,
        bottom: Layout.gridBottomInset,
        right: Layout.gridHorizontalInset,
      )
      adaptiveMosaicLayout.interItemSpacing = Layout.gridInterItemSpacing
      adaptiveMosaicLayout.lineSpacing = Layout.gridLineSpacing
    }

    lastAppliedMosaicProfile = profile
  }

  private func mosaicProfile(
    for width: CGFloat,
    contentSizeCategory: UIContentSizeCategory,
  ) -> MosaicTuningProfile {
    if contentSizeCategory.isAccessibilityCategory {
      // AX sizes: 2-column concept with adjusted sizing for larger text
      return MosaicTuningProfile(
        rowUnit: 10,
        minimumItemHeight: 160,
        singleColumnBreakpoint: 0, // NEVER use 1-column
        overlapTolerance: 1.0,
        bigItemMinimumSpan: 20,
        bigItemMaximumSpan: 44,
        bigItemMinimumHeight: 260,
      )
    }

    if width <= 360 {
      // Narrow devices: 2-column with minimal spacing
      return MosaicTuningProfile(
        rowUnit: 6, // Smaller grid unit
        minimumItemHeight: 90, // Smaller cards for narrow screens
        singleColumnBreakpoint: 0, // Force 2-column
        overlapTolerance: 0.5,
        bigItemMinimumSpan: 14, // Smaller big cards (140pt min)
        bigItemMaximumSpan: 28, // Cap expansion
        bigItemMinimumHeight: 160, // Lower threshold
      )
    }

    if width <= 400 {
      return MosaicTuningProfile(
        rowUnit: 8,
        minimumItemHeight: 120,
        singleColumnBreakpoint: 0, // NEVER use 1-column
        overlapTolerance: 0.5,
        bigItemMinimumSpan: 20,
        bigItemMaximumSpan: 42,
        bigItemMinimumHeight: 220,
      )
    }

    // MARK: Large devices → Structured mosaic with expansion
    return MosaicTuningProfile(
      rowUnit: 10,
      minimumItemHeight: 120,
      singleColumnBreakpoint: 0, // NEVER use 1-column
      overlapTolerance: 1.0,
      bigItemMinimumSpan: 20,
      bigItemMaximumSpan: 50,
      bigItemMinimumHeight: 240,
    )
  }

  private func updateCollectionLayoutIfNeeded() {
    let collectionWidth = collectionView.bounds.width
    guard collectionWidth > 0 else { return }
    guard abs(collectionWidth - lastCollectionWidth) > 0.5 else { return }
    lastCollectionWidth = collectionWidth
    cachedRowMeasurements = nil
    cachedMosaicMeasurements = nil

    collectionView.collectionViewLayout.invalidateLayout()
  }

  private func updateContinueButtonShadowPathIfNeeded() {
    let bounds = continueButtonShadowView.bounds
    guard bounds.width > 0, bounds.height > 0 else { return }

    let dynamicCornerRadius = bounds.height / 2
    if abs(continueButton.layer.cornerRadius - dynamicCornerRadius) > 0.5 {
      continueButton.layer.cornerRadius = dynamicCornerRadius
    }

    guard bounds != lastContinueButtonShadowBounds else { return }

    lastContinueButtonShadowBounds = bounds
    continueButtonShadowView.layer.shadowPath =
      UIBezierPath(
        roundedRect: bounds,
        cornerRadius: dynamicCornerRadius,
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
      applyContinueButtonAppearance(
        title: screen.continueButtonTitleIdle,
        titleColor: .white,
        backgroundColor: .betaTestHeaderGreen,
        isEnabled: true,
      )

    case .processing:
      applyContinueButtonAppearance(
        title: screen.continueButtonTitleLoading,
        titleColor: .betaTestLoadingText,
        backgroundColor: .betaTestLoadingBackground,
        isEnabled: false,
      )

    case .finished:
      applyContinueButtonAppearance(
        title: screen.continueButtonTitleFinished,
        titleColor: .white,
        backgroundColor: .betaTestHeaderGreen,
        isEnabled: true,
      )
    }
  }

  private func applyContinueButtonAppearance(
    title: String,
    titleColor: UIColor,
    backgroundColor: UIColor,
    isEnabled: Bool,
  ) {
    continueButton.setTitle(title, for: .normal)
    continueButton.setTitle(title, for: .disabled)
    continueButton.setTitle(title, for: .highlighted)
    continueButton.setTitle(title, for: .selected)

    continueButton.setTitleColor(titleColor, for: .normal)
    continueButton.setTitleColor(titleColor, for: .disabled)

    continueButton.backgroundColor = backgroundColor
    continueButton.isEnabled = isEnabled
    continueButton.titleLabel?.isHidden = false
    continueButton.setNeedsLayout()
    continueButton.layoutIfNeeded()
  }

  private func handleRetryTap(at index: Int) {
    guard items.indices.contains(index) else { return }
    guard runPhase != .processing else { return }
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

    let title = items[index].title
    onProcessingEvent?(.stepStarted(.init(index: index, title: title, phase: phase)))
    focusOnItemIfNeeded(at: index)

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

  private func focusOnItemIfNeeded(at index: Int) {
    guard items.indices.contains(index) else { return }

    focusAttemptedIndexes.append(index)

    let indexPath = IndexPath(item: index, section: 0)
    guard collectionView.numberOfSections > 0 else { return }
    guard collectionView.numberOfItems(inSection: 0) > index else { return }

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      if
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
      {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let comfortRect = visibleRect.insetBy(dx: 0, dy: 40)
        if comfortRect.contains(attributes.frame) {
          return
        }
      }

      focusScrolledIndexes.append(index)
      let animated = !UIAccessibility.isReduceMotionEnabled
      collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: animated)
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

    handler(phase) { resultingState in
      DispatchQueue.main.async {
        completion(resultingState)
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
    guard layoutStrategy == .uniformGrid else {
      return .zero
    }
    let sectionInsets = uniformGridLayout.sectionInset
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

// MARK: BetaTestAdaptiveMosaicLayout.Delegate

extension BetaTestViewController: BetaTestAdaptiveMosaicLayout.Delegate {

  // MARK: Internal

  func adaptiveMosaicLayout(
    _: BetaTestAdaptiveMosaicLayout,
    preferredHeightForItemAt indexPath: IndexPath,
    fitting width: CGFloat,
  ) -> CGFloat {
    guard items.indices.contains(indexPath.item) else { return 110 }

    ensureMosaicMeasurements(for: width)
    if
      let cachedMosaicMeasurements,
      let cachedHeight = cachedMosaicMeasurements.heightsByIndex[indexPath.item]
    {
      return cachedHeight
    }

    return BetaTestCollectionViewCell.preferredHeight(
      for: width,
      title: items[indexPath.item].title,
      traitCollection: traitCollection,
    )
  }

  func adaptiveMosaicLayout(
    _ layout: BetaTestAdaptiveMosaicLayout,
    prefersExpandedItemAt indexPath: IndexPath,
  ) -> Bool {
    guard items.indices.contains(indexPath.item) else { return false }

    let availableWidth = max(
      0,
      collectionView.bounds.width - layout.sectionInsets.left - layout.sectionInsets.right
        - layout.interItemSpacing,
    )
    let itemWidth = max(0, availableWidth / 2)
    guard itemWidth > 0 else { return false }

    ensureMosaicMeasurements(for: itemWidth)
    if
      let cachedMosaicMeasurements,
      let isExpanded = cachedMosaicMeasurements.expandedEligibilityByIndex[indexPath.item]
    {
      return isExpanded
    }

    let preferredHeight = BetaTestCollectionViewCell.preferredHeight(
      for: itemWidth,
      title: items[indexPath.item].title,
      traitCollection: traitCollection,
    )
    return preferredHeight >= mosaicBigItemMinimumHeight
  }

  // MARK: Private

  private func ensureMosaicMeasurements(for width: CGFloat) {
    let roundedWidth = round(width * 100) / 100
    let contentSizeCategory = traitCollection.preferredContentSizeCategory

    if
      let cachedMosaicMeasurements,
      abs(cachedMosaicMeasurements.width - roundedWidth) < 0.5,
      cachedMosaicMeasurements.contentSizeCategory == contentSizeCategory,
      cachedMosaicMeasurements.heightsByIndex.count == items.count
    {
      return
    }

    var heightsByIndex = [Int: CGFloat]()
    var expandedEligibilityByIndex = [Int: Bool]()

    for index in items.indices {
      let preferredHeight = BetaTestCollectionViewCell.preferredHeight(
        for: roundedWidth,
        title: items[index].title,
        traitCollection: traitCollection,
      )
      heightsByIndex[index] = preferredHeight
      expandedEligibilityByIndex[index] = preferredHeight >= mosaicBigItemMinimumHeight
    }

    cachedMosaicMeasurements = (
      width: roundedWidth,
      contentSizeCategory: contentSizeCategory,
      heightsByIndex: heightsByIndex,
      expandedEligibilityByIndex: expandedEligibilityByIndex,
    )
  }
}

// MARK: - BetaTestCollectionViewCell

// Extracted to BetaTestCollectionViewCell.swift
