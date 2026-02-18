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
  func updateItemContent(
    at index: Int,
    transform: (BetaTestItem.Content) -> BetaTestItem.Content,
  ) {
    guard items.indices.contains(index) else { return }
    items[index].content = transform(items[index].content)
    invalidateMeasurementCache()
    reloadItem(at: index)
  }

  /// Customize one cell execution behavior without touching others.
  /// The provided handler MUST call `continueExecutionWithState(...)` exactly once.
  /// If not called, sequential processing will stall at that cell.
  func updateItemExecutionHandler(at index: Int, handler: @escaping BetaTestItem.ExecutionHandler) {
    guard items.indices.contains(index) else { return }
    items[index].executionHandler = handler
  }

  func retryItem(at index: Int) {
    handleRetryTap(at: index)
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
    applyAdaptiveLayoutMetricsIfNeeded()
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

    invalidateMeasurementCache()
    applyAdaptiveLayoutMetricsIfNeeded(force: true)
    applyBottomControlMetricsIfNeeded(force: true)
    collectionView.collectionViewLayout.invalidateLayout()
  }

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

  private struct MeasurementCache {
    let widthKey: Int
    let contentSizeCategory: UIContentSizeCategory
    let heightsByIndex: [CGFloat]
    let heightsByRow: [CGFloat]
    let expandedEligibilityByIndex: [Bool]
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
  private var lastAdaptiveLayoutSignature: (isNarrow: Bool, isAccessibilityCategory: Bool)?
  private var runPhase = RunPhase.idle
  private var isRetryInteractionEnabled = true
  private var runCoordinator = RunCoordinator()

  private var lastCollectionWidth: CGFloat = 0
  private var lastContinueButtonShadowBounds = CGRect.zero
  private var lastBottomControlMetrics: BottomControlMetrics?
  private var measurementCache: MeasurementCache?

  private var continueButtonShadowLeadingConstraint: NSLayoutConstraint?
  private var continueButtonShadowTrailingConstraint: NSLayoutConstraint?
  private var continueButtonShadowTopConstraint: NSLayoutConstraint?
  private var continueButtonShadowBottomConstraint: NSLayoutConstraint?
  private var continueButtonShadowMinHeightConstraint: NSLayoutConstraint?

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

      continueButtonShadowLeadingConstraint!,
      continueButtonShadowTrailingConstraint!,
      continueButtonShadowTopConstraint!,
      continueButtonShadowMinHeightConstraint!,
      continueButtonShadowBottomConstraint!,

      continueButton.leadingAnchor.constraint(equalTo: continueButtonShadowView.leadingAnchor),
      continueButton.trailingAnchor.constraint(equalTo: continueButtonShadowView.trailingAnchor),
      continueButton.topAnchor.constraint(equalTo: continueButtonShadowView.topAnchor),
      continueButton.bottomAnchor.constraint(equalTo: continueButtonShadowView.bottomAnchor),
    ])
  }

  private func invalidateMeasurementCache() {
    measurementCache = nil
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

  private func applyAdaptiveLayoutMetricsIfNeeded(force: Bool = false) {
    guard layoutStrategy == .adaptiveMosaic else { return }

    let width = collectionView.bounds.width
    guard width > 0 else { return }

    let isNarrow = width <= 360
    let isAccessibilityCategory = traitCollection.preferredContentSizeCategory
      .isAccessibilityCategory
    if
      !force,
      let lastAdaptiveLayoutSignature,
      lastAdaptiveLayoutSignature.isNarrow == isNarrow,
      lastAdaptiveLayoutSignature.isAccessibilityCategory == isAccessibilityCategory
    {
      return
    }

    adaptiveMosaicLayout.sectionInsets =
      isNarrow
        ? UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        : UIEdgeInsets(
          top: Layout.gridTopInset,
          left: Layout.gridHorizontalInset,
          bottom: Layout.gridBottomInset,
          right: Layout.gridHorizontalInset,
        )
    adaptiveMosaicLayout.interItemSpacing = isNarrow ? 8 : Layout.gridInterItemSpacing
    adaptiveMosaicLayout.lineSpacing = isNarrow ? 8 : Layout.gridLineSpacing
    adaptiveMosaicLayout.rowUnit = isNarrow ? 7 : 8
    adaptiveMosaicLayout.minimumItemHeight = isAccessibilityCategory ? 150 : (isNarrow ? 100 : 120)
    adaptiveMosaicLayout.overlapTolerance = 0.5
    adaptiveMosaicLayout.bigItemMinimumSpan = isNarrow ? 16 : 20
    adaptiveMosaicLayout.bigItemMaximumSpan = isNarrow ? 30 : 42
    mosaicBigItemMinimumHeight = isAccessibilityCategory ? 260 : (isNarrow ? 180 : 220)
    lastAdaptiveLayoutSignature = (isNarrow, isAccessibilityCategory)
    invalidateMeasurementCache()
  }

  private func updateCollectionLayoutIfNeeded() {
    let collectionWidth = collectionView.bounds.width
    guard collectionWidth > 0 else { return }
    guard abs(collectionWidth - lastCollectionWidth) > 0.5 else { return }
    lastCollectionWidth = collectionWidth
    invalidateMeasurementCache()

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
    var nonVisibleIndexPaths = [IndexPath]()

    for index in items.indices {
      items[index].state = state

      let indexPath = IndexPath(item: index, section: 0)
      if let cell = collectionView.cellForItem(at: indexPath) as? BetaTestCollectionViewCell {
        cell.transition(to: state, item: items[index], animated: false, completion: nil)
      } else {
        nonVisibleIndexPaths.append(indexPath)
      }
    }

    reloadItemsInBatch(nonVisibleIndexPaths)
  }

  private func reloadItem(at index: Int) {
    guard items.indices.contains(index) else { return }
    reloadItemsInBatch([IndexPath(item: index, section: 0)])
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

    reloadItemsInBatch([indexPath])
    completion?()
  }

  private func reloadItemsInBatch(_ indexPaths: [IndexPath]) {
    let validIndexPaths = indexPaths.filter { $0.section == 0 && items.indices.contains($0.item) }
    guard !validIndexPaths.isEmpty else { return }

    collectionView.performBatchUpdates {
      collectionView.reloadItems(at: validIndexPaths)
    }
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
    setInteractionLock(isLocked: phase == .processing)

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

  private func setInteractionLock(isLocked: Bool) {
    let isInteractionEnabled = !isLocked
    isRetryInteractionEnabled = isInteractionEnabled
    collectionView.isScrollEnabled = isInteractionEnabled
    updateVisibleRetryInteractions()
  }

  private func updateVisibleRetryInteractions() {
    for case let cell as BetaTestCollectionViewCell in collectionView.visibleCells {
      cell.setRetryInteractionEnabled(isRetryInteractionEnabled)
    }
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

    let indexPath = IndexPath(item: index, section: 0)
    guard collectionView.numberOfSections > 0 else { return }
    guard collectionView.numberOfItems(inSection: 0) > index else { return }

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
        let visibleRect = CGRect(
          origin: collectionView.contentOffset,
          size: collectionView.bounds.size,
        )
        let comfortRect = visibleRect.insetBy(dx: 0, dy: 40)
        if comfortRect.contains(attributes.frame) {
          return
        }
      }

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

    let handler =
      items[index].executionHandler ?? { _, done in
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
    betaCell.setRetryInteractionEnabled(isRetryInteractionEnabled)
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
    _: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt _: IndexPath,
  ) {
    guard let betaCell = cell as? BetaTestCollectionViewCell else { return }
    betaCell.setRetryInteractionEnabled(isRetryInteractionEnabled)
  }

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
  private func measurementData(for itemWidth: CGFloat) -> MeasurementCache {
    let roundedWidth = round(itemWidth * 100) / 100
    let widthKey = Int((roundedWidth * 100).rounded())
    let contentSizeCategory = traitCollection.preferredContentSizeCategory

    if
      let measurementCache,
      measurementCache.widthKey == widthKey,
      measurementCache.contentSizeCategory == contentSizeCategory,
      measurementCache.heightsByIndex.count == items.count
    {
      return measurementCache
    }

    let heightsByIndex = items.map {
      BetaTestCollectionViewCell.preferredHeight(
        for: roundedWidth,
        title: $0.title,
        traitCollection: traitCollection,
      )
    }

    var heightsByRow = [CGFloat]()
    var startIndex = 0
    while startIndex < heightsByIndex.count {
      let endIndex = min(startIndex + Layout.cardsPerRow, heightsByIndex.count)
      let rowHeight = heightsByIndex[startIndex..<endIndex].max() ?? 0
      heightsByRow.append(rowHeight)
      startIndex = endIndex
    }

    let expandedEligibilityByIndex = heightsByIndex.map { $0 >= mosaicBigItemMinimumHeight }
    let resolved = MeasurementCache(
      widthKey: widthKey,
      contentSizeCategory: contentSizeCategory,
      heightsByIndex: heightsByIndex,
      heightsByRow: heightsByRow,
      expandedEligibilityByIndex: expandedEligibilityByIndex,
    )
    measurementCache = resolved
    return resolved
  }

  private func adaptiveCardHeight(for itemWidth: CGFloat, at itemIndex: Int) -> CGFloat {
    let measurements = measurementData(for: itemWidth)
    let rowIndex = max(0, itemIndex / Layout.cardsPerRow)
    if rowIndex < measurements.heightsByRow.count {
      return measurements.heightsByRow[rowIndex]
    }

    return measurements.heightsByRow.last ?? 0
  }
}

// MARK: BetaTestAdaptiveMosaicLayout.Delegate

extension BetaTestViewController: BetaTestAdaptiveMosaicLayout.Delegate {

  func adaptiveMosaicLayout(
    _: BetaTestAdaptiveMosaicLayout,
    preferredHeightForItemAt indexPath: IndexPath,
    fitting width: CGFloat,
  ) -> CGFloat {
    guard items.indices.contains(indexPath.item) else { return 110 }
    let measurements = measurementData(for: width)
    guard indexPath.item < measurements.heightsByIndex.count else { return 110 }
    return measurements.heightsByIndex[indexPath.item]
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
    let measurements = measurementData(for: itemWidth)
    guard indexPath.item < measurements.expandedEligibilityByIndex.count else { return false }
    return measurements.expandedEligibilityByIndex[indexPath.item]
  }
}

// MARK: - BetaTestCollectionViewCell

// Extracted to BetaTestCollectionViewCell.swift
