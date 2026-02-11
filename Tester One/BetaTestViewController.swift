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

  enum ContinueButtonState {
    case start
    case loading
    case finish
  }

  struct ProcessResult {
    let index: Int
    let title: String
    let state: BetaTestCardState
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

  /// Starts loading -> result transition for all cards.
  func beginProcessing() {
    guard !isProcessing else { return }
    isProcessing = true
    setContinueButtonState(.loading)
    updateAllItemStates(.loading)

    DispatchQueue.main.asyncAfter(deadline: .now() + processDuration) { [weak self] in
      guard let self else { return }
      var results = [ProcessResult]()

      for index in items.indices {
        let title = items[index].title
        let resolvedState = stateResolver?(index, title) ?? defaultFinalState(for: index, title: title)
        items[index].state = resolvedState
        results.append(ProcessResult(index: index, title: title, state: resolvedState))
      }

      isProcessing = false
      reloadAllItems()
      setContinueButtonState(.finish)
      onProcessCompleted?(results)
    }
  }

  /// Manually set a single card state (useful for external action chains).
  func setState(_ state: BetaTestCardState, at index: Int) {
    guard items.indices.contains(index) else { return }
    items[index].state = state
    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
  }

  /// Manually set all card states.
  func setAllStates(_ state: BetaTestCardState) {
    updateAllItemStates(state)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupViewHierarchy()
    setupConstraints()
    updateCollectionLayoutIfNeeded()
    setContinueButtonState(.start)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupNavigationBar()
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

  // MARK: Private

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
  private var isProcessing = false
  private var retryingIndices = Set<Int>()
  private var continueButtonState = ContinueButtonState.start

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
    button.layer.masksToBounds = true
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

  private func setupViewHierarchy() {
    view.backgroundColor = .betaTestHeaderGreen
    view.accessibilityIdentifier = "BetaTestViewController.view"

    view.addSubview(contentContainerView)
    contentContainerView.addSubview(collectionView)
    contentContainerView.addSubview(bottomOverlayView)

    bottomOverlayView.addSubview(continueButtonShadowView)
    continueButtonShadowView.addSubview(continueButton)
  }

  private func setupNavigationBar() {
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
    switch continueButtonState {
    case .start:
      onContinueButtonTapped?()
      beginProcessing()

    case .loading:
      return

    case .finish:
      onContinueButtonTapped?()
    }
  }

  private func updateAllItemStates(_ state: BetaTestCardState) {
    for index in items.indices {
      items[index].state = state
    }
    reloadAllItems()
  }

  private func reloadAllItems() {
    let indexPaths = items.indices.map { IndexPath(item: $0, section: 0) }
    guard !indexPaths.isEmpty else { return }

    collectionView.performBatchUpdates({
      collectionView.reloadItems(at: indexPaths)
    })
  }

  private func setContinueButtonState(_ state: ContinueButtonState) {
    continueButtonState = state

    switch state {
    case .start:
      continueButton.setTitle("Mulai Tes", for: .normal)
      continueButton.setTitleColor(.white, for: .normal)
      continueButton.backgroundColor = .betaTestHeaderGreen
      continueButton.isEnabled = true

    case .loading:
      continueButton.setTitle("Dalam Pengecekan", for: .normal)
      continueButton.setTitleColor(.betaTestLoadingText, for: .normal)
      continueButton.backgroundColor = .betaTestLoadingBackground
      continueButton.isEnabled = false

    case .finish:
      continueButton.setTitle("Lanjut", for: .normal)
      continueButton.setTitleColor(.white, for: .normal)
      continueButton.backgroundColor = .betaTestHeaderGreen
      continueButton.isEnabled = true
    }
  }

  private func handleRetryTap(at index: Int) {
    guard items.indices.contains(index) else { return }
    guard items[index].state == .failed else { return }
    guard !retryingIndices.contains(index) else { return }

    let title = items[index].title
    onRetryButtonTapped?(index, title)

    retryingIndices.insert(index)
    items[index].state = .loading
    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])

    DispatchQueue.main.asyncAfter(deadline: .now() + processDuration) { [weak self] in
      guard let self else { return }
      guard items.indices.contains(index) else { return }

      let resolvedState = stateResolver?(index, title) ?? defaultFinalState(for: index, title: title)
      items[index].state = resolvedState
      retryingIndices.remove(index)
      collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])

      onRetryCompleted?(ProcessResult(index: index, title: title, state: resolvedState))
    }
  }

  private func defaultFinalState(for index: Int, title: String) -> BetaTestCardState {
    if title == "Tombol Silent" {
      return .failed
    }
    return index == 6 ? .failed : .success
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

// MARK: - BetaTestItem

private struct BetaTestItem {
  enum IconType {
    case cpu
    case hardDisk
    case battery
    case jailbreak
    case biometricOne
    case biometricTwo
    case silent
    case volume
    case power
    case camera
    case touch
    case sim
  }

  let title: String
  let icon: IconType
  var state: BetaTestCardState
}

// MARK: - BetaTestCardState

enum BetaTestCardState {
  case initial
  case loading
  case success
  case failed
}

// MARK: - BetaTestCollectionViewCell

private final class BetaTestCollectionViewCell: UICollectionViewCell {

  // MARK: Internal

  static let reuseIdentifier = "BetaTestCollectionViewCell"

  var onRetryTapped: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupCell()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  static func preferredHeightsByRow(
    for itemWidth: CGFloat,
    titles: [String],
    itemsPerRow: Int,
    traitCollection: UITraitCollection,
  ) -> [CGFloat] {
    guard itemWidth > 0 else { return [] }
    guard itemsPerRow > 0 else { return [] }

    let titleWidth = max(itemWidth - (Layout.contentInset * 2), 1)
    let baseFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    let titleFont: UIFont =
      if #available(iOS 11.0, *) {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont, compatibleWith: traitCollection)
      } else {
        UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
      }

    let bottomInset = Layout.titleBottomInset
    let semanticBottomSpacing = semanticCardBottomSpacing(for: titleFont)
    var rowHeights = [CGFloat]()
    var startIndex = 0

    while startIndex < titles.count {
      let endIndex = min(startIndex + itemsPerRow, titles.count)
      let rowTitles = Array(titles[startIndex ..< endIndex])
      let maximumTitleHeight = maxTitleHeight(for: rowTitles, width: titleWidth, font: titleFont)
      let cardHeight =
        Layout.contentInset
          + Layout.iconCircleSize
          + Layout.topRowSpacing
          + maximumTitleHeight
          + bottomInset
          + semanticBottomSpacing
      rowHeights.append(ceil(cardHeight))
      startIndex = endIndex
    }

    return rowHeights
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    iconImageView.image = nil
    retryBadgeButton.isHidden = true
    statusImageView.isHidden = true
    loadingIndicator.stopAnimating()
    onRetryTapped = nil
  }

  func configure(with item: BetaTestItem) {
    let token = Self.accessibilityToken(for: item.title)
    accessibilityIdentifier = "BetaTestCell.\(token)"
    contentView.accessibilityIdentifier = "BetaTestCell.\(token).contentView"
    cardView.accessibilityIdentifier = "BetaTestCell.\(token).cardView"
    iconCircleView.accessibilityIdentifier = "BetaTestCell.\(token).iconCircleView"
    iconImageView.accessibilityIdentifier = "BetaTestCell.\(token).iconImageView"
    statusImageView.accessibilityIdentifier = "BetaTestCell.\(token).statusImageView"
    loadingIndicator.accessibilityIdentifier = "BetaTestCell.\(token).loadingIndicator"
    retryBadgeButton.accessibilityIdentifier = "BetaTestCell.\(token).retryButton"
    titleLabel.accessibilityIdentifier = "BetaTestCell.\(token).titleLabel"

    titleLabel.text = item.title

    applyState(item.state)
    applyIcon(for: item.icon, state: item.state)
  }

  // MARK: Private

  private enum Layout {
    static let cornerRadius: CGFloat = 20
    static let cardInset: CGFloat = 0
    static let contentInset: CGFloat = 15
    static let titleBottomInset: CGFloat = 15
    static let iconCircleSize: CGFloat = 50
    static let iconSize: CGFloat = 25
    static let statusSize: CGFloat = 30
    static let topRowSpacing: CGFloat = 20
    static let retryHeight: CGFloat = 30
  }

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.cornerRadius
    view.layer.borderWidth = 1
    view.clipsToBounds = true
    return view
  }()

  private lazy var iconCircleView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.iconCircleSize / 2
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()

  private lazy var statusImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()

  private lazy var loadingIndicator: UIActivityIndicatorView = {
    let indicator =
      if #available(iOS 13.0, *) {
        UIActivityIndicatorView(style: .medium)
      } else {
        UIActivityIndicatorView(style: .gray)
      }
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    indicator.color = UIColor.betaTestDisabledIcon
    let baseIndicatorSize: CGFloat = 20
    let scale = Layout.statusSize / baseIndicatorSize
    indicator.transform = CGAffineTransform(scaleX: scale, y: scale)
    return indicator
  }()

  private lazy var retryBadgeButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Ulangi", for: .normal)
    button.setTitleColor(.betaTestPrimaryText, for: .normal)
    let baseFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    button.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.backgroundColor = .betaTestBadgeBackground
    button.layer.cornerRadius = Layout.retryHeight / 2
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.betaTestDarkGray.cgColor
    button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)
    button.isUserInteractionEnabled = true
    button.addTarget(self, action: #selector(handleRetryButtonTap), for: .touchUpInside)
    button.isHidden = true
    return button
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    let baseFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
    label.adjustsFontForContentSizeCategory = true
    label.numberOfLines = 0
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return label
  }()

  private static func successStatusImage() -> UIImage? {
    if let image = UIImage(named: "successImage") {
      return image.withRenderingMode(.alwaysOriginal)
    }

    if #available(iOS 13.0, *) {
      return UIImage(systemName: "checkmark.circle.fill")?.withTintColor(
        UIColor.betaTestStatusGreen,
        renderingMode: .alwaysOriginal,
      )
    }

    return nil
  }

  private static func accessibilityToken(for title: String) -> String {
    let normalized = String(title.lowercased().map { character in
      character.isLetter || character.isNumber ? character : "_"
    })
    let collapsed = normalized.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
    return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
  }

  private static func maxTitleHeight(for titles: [String], width: CGFloat, font: UIFont) -> CGFloat {
    guard width > 0 else { return ceil(font.lineHeight) }

    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    let constraint = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)

    return titles.reduce(ceil(font.lineHeight)) { currentMax, title in
      let measured = (title as NSString).boundingRect(
        with: constraint,
        options: options,
        attributes: attributes,
        context: nil,
      )
      return max(currentMax, ceil(measured.height))
    }
  }

  private static func semanticCardBottomSpacing(for titleFont: UIFont) -> CGFloat {
    let proportionalSpacing = ceil(titleFont.lineHeight * 0.20)
    return min(max(proportionalSpacing, 2), 10)
  }

  private func setupCell() {
    contentView.backgroundColor = .clear
    backgroundColor = .clear

    contentView.addSubview(cardView)
    cardView.addSubview(iconCircleView)
    iconCircleView.addSubview(iconImageView)
    cardView.addSubview(statusImageView)
    cardView.addSubview(loadingIndicator)
    cardView.addSubview(retryBadgeButton)
    cardView.addSubview(titleLabel)

    NSLayoutConstraint.activate([
      cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cardInset),
      cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cardInset),
      cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cardInset),
      cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cardInset),

      iconCircleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.contentInset),
      iconCircleView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.contentInset),
      iconCircleView.widthAnchor.constraint(equalToConstant: Layout.iconCircleSize),
      iconCircleView.heightAnchor.constraint(equalToConstant: Layout.iconCircleSize),

      iconImageView.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
      iconImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
      iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),

      statusImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      statusImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      statusImageView.widthAnchor.constraint(equalToConstant: Layout.statusSize),
      statusImageView.heightAnchor.constraint(equalToConstant: Layout.statusSize),

      loadingIndicator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      loadingIndicator.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      loadingIndicator.widthAnchor.constraint(equalToConstant: Layout.statusSize),
      loadingIndicator.heightAnchor.constraint(equalToConstant: Layout.statusSize),

      retryBadgeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      retryBadgeButton.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      retryBadgeButton.heightAnchor.constraint(equalToConstant: Layout.retryHeight),

      titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.contentInset),
      titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      titleLabel.topAnchor.constraint(equalTo: iconCircleView.bottomAnchor, constant: Layout.topRowSpacing),
      titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -Layout.titleBottomInset),
    ])
  }

  @objc
  private func handleRetryButtonTap() {
    onRetryTapped?()
  }

  private func applyState(_ state: BetaTestCardState) {
    retryBadgeButton.isHidden = true
    statusImageView.isHidden = true
    loadingIndicator.stopAnimating()
    titleLabel.textColor = .betaTestPrimaryText

    switch state {
    case .initial:
      // Initial state is neutral grey (not success-green).
      cardView.backgroundColor = UIColor.betaTestInitialCard
      cardView.layer.borderWidth = 0
      iconCircleView.backgroundColor = UIColor.betaTestDisabledCircle

    case .loading:
      // Loading should keep initial styling while showing activity on status position.
      cardView.backgroundColor = UIColor.betaTestDisabledCard
      cardView.layer.borderWidth = 0
      iconCircleView.backgroundColor = UIColor.betaTestDisabledCircle
      loadingIndicator.color = UIColor.betaTestDisabledIcon
      loadingIndicator.startAnimating()

    case .success:
      cardView.backgroundColor = .betaTestSurface
      cardView.layer.borderColor = UIColor.betaTestSapGreen.cgColor
      cardView.layer.borderWidth = 1
      iconCircleView.backgroundColor = UIColor.betaTestSuccessCircle

      statusImageView.isHidden = false
      statusImageView.image = Self.successStatusImage()

    case .failed:
      cardView.backgroundColor = .betaTestSurface
      cardView.layer.borderColor = UIColor.betaTestErrorRed.cgColor
      cardView.layer.borderWidth = 1
      iconCircleView.backgroundColor = UIColor.betaTestErrorCircle

      retryBadgeButton.isHidden = false
    }
  }

  private func applyIcon(for icon: BetaTestItem.IconType, state: BetaTestCardState) {
    let tintColor =
      switch state {
      case .failed:
        UIColor.betaTestErrorRed
      case .initial, .loading:
        UIColor.betaTestDisabledIcon
      case .success:
        UIColor.betaTestSapGreen
      }

    if #available(iOS 13.0, *), let symbolImage = UIImage(systemName: systemSymbolName(for: icon)) {
      iconImageView.tintColor = tintColor
      iconImageView.image = symbolImage.withRenderingMode(.alwaysTemplate)
      return
    }

    // iOS 12 fallback: reuse provided assets first before any custom drawing.
    if let fallbackImage = UIImage(named: "cpuImage") {
      iconImageView.tintColor = tintColor
      iconImageView.image = fallbackImage.withRenderingMode(.alwaysTemplate)
    } else if let fallbackImage = UIImage(named: "failedImage") {
      iconImageView.tintColor = tintColor
      iconImageView.image = fallbackImage.withRenderingMode(.alwaysTemplate)
    } else {
      iconImageView.image = nil
    }
  }

  private func systemSymbolName(for icon: BetaTestItem.IconType) -> String {
    switch icon {
    case .cpu:
      "cpu"
    case .hardDisk:
      "externaldrive"
    case .battery:
      "battery.100"
    case .jailbreak:
      "key"
    case .biometricOne:
      "faceid"
    case .biometricTwo:
      "touchid"
    case .silent:
      "bell.slash"
    case .volume:
      "speaker.wave.2.fill"
    case .power:
      "power"
    case .camera:
      "camera"
    case .touch:
      "hand.point.up.left.fill"
    case .sim:
      "simcard"
    }
  }

}

extension UIColor {

  // MARK: Fileprivate

  fileprivate static let betaTestPrimaryText = betaTestDynamic(light: .black, dark: .white)
  fileprivate static let betaTestSurface = betaTestDynamic(
    light: .white,
    dark: UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestBadgeBackground = betaTestDynamic(
    light: UIColor(white: 1.0, alpha: 0.92),
    dark: UIColor(white: 0.22, alpha: 0.92),
  )

  fileprivate static let betaTestHeaderGreen = betaTestDynamic(
    light: UIColor(red: 54.0 / 255.0, green: 132.0 / 255.0, blue: 3.0 / 255.0, alpha: 1),
    dark: UIColor(red: 32.0 / 255.0, green: 92.0 / 255.0, blue: 24.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestLoadingText = betaTestDynamic(
    light: UIColor(red: 173.0 / 255.0, green: 177.0 / 255.0, blue: 178.0 / 255.0, alpha: 1),
    dark: UIColor(red: 178.0 / 255.0, green: 181.0 / 255.0, blue: 182.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestLoadingBackground = betaTestDynamic(
    light: UIColor(red: 215.0 / 255.0, green: 220.0 / 255.0, blue: 222.0 / 255.0, alpha: 1),
    dark: UIColor(red: 70.0 / 255.0, green: 74.0 / 255.0, blue: 77.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestSapGreen = betaTestDynamic(
    light: UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 28.0 / 255.0, alpha: 1),
    dark: UIColor(red: 122.0 / 255.0, green: 201.0 / 255.0, blue: 84.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestLabelGreen = betaTestHeaderGreen
  fileprivate static let betaTestStatusGreen = betaTestDynamic(
    light: UIColor(red: 76.0 / 255.0, green: 153.0 / 255.0, blue: 31.0 / 255.0, alpha: 1),
    dark: UIColor(red: 132.0 / 255.0, green: 210.0 / 255.0, blue: 95.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestErrorRed = betaTestDynamic(
    light: UIColor(red: 194.0 / 255.0, green: 50.0 / 255.0, blue: 0, alpha: 1),
    dark: UIColor(red: 255.0 / 255.0, green: 105.0 / 255.0, blue: 97.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestDarkGray = betaTestDynamic(
    light: UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1),
    dark: UIColor(red: 198.0 / 255.0, green: 198.0 / 255.0, blue: 198.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestLightGray = betaTestDynamic(
    light: UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1),
    dark: UIColor(red: 44.0 / 255.0, green: 44.0 / 255.0, blue: 46.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestInitialCard = betaTestLightGray
  fileprivate static let betaTestDisabledCard = betaTestLightGray
  fileprivate static let betaTestDisabledCircle = betaTestDynamic(
    light: UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1),
    dark: UIColor(red: 84.0 / 255.0, green: 84.0 / 255.0, blue: 88.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestDisabledIcon = betaTestDynamic(
    light: UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 80.0 / 255.0, alpha: 1),
    dark: UIColor(red: 196.0 / 255.0, green: 196.0 / 255.0, blue: 196.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestSuccessCircle = betaTestDynamic(
    light: UIColor(red: 218.0 / 255.0, green: 229.0 / 255.0, blue: 212.0 / 255.0, alpha: 1),
    dark: UIColor(red: 43.0 / 255.0, green: 74.0 / 255.0, blue: 47.0 / 255.0, alpha: 1),
  )
  fileprivate static let betaTestErrorCircle = betaTestDynamic(
    light: UIColor(red: 234.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1),
    dark: UIColor(red: 84.0 / 255.0, green: 44.0 / 255.0, blue: 44.0 / 255.0, alpha: 1),
  )

  // MARK: Private

  private static func betaTestDynamic(light: UIColor, dark: UIColor) -> UIColor {
    if #available(iOS 13.0, *) {
      UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? dark : light
      }
    } else {
      light
    }
  }

}
