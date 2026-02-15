//
//  BetaTestCollectionViewCell.swift
//  Tester One
//

import UIKit

// MARK: - BetaTestCollectionViewCell

final class BetaTestCollectionViewCell: UICollectionViewCell {

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

  static func clearFallbackImageCache() {
    fallbackImageCache.removeAll()
  }

  static func preferredHeight(
    for itemWidth: CGFloat,
    title: String,
    traitCollection: UITraitCollection,
  ) -> CGFloat {
    guard itemWidth > 0 else { return 0 }

    // Use an offscreen sizing cell so measured height exactly matches runtime Auto Layout.
    let cell = sizingCell
    cell.bounds = CGRect(x: 0, y: 0, width: itemWidth, height: 2000)
    cell.contentView.bounds = cell.bounds
    cell.applyScaledMetrics(
      traitCollection: traitCollection,
      referenceWidth: itemWidth,
      force: true,
    )
    cell.applySizingTitle(title, traitCollection: traitCollection, referenceWidth: itemWidth)
    cell.setNeedsLayout()
    cell.layoutIfNeeded()

    let target = CGSize(width: itemWidth, height: UIView.layoutFittingCompressedSize.height)
    let measured = cell.contentView.systemLayoutSizeFitting(
      target,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel,
    )

    let minimumHeight = minimumMeasuredCardHeight(
      for: itemWidth,
      traitCollection: traitCollection,
    )
    return ceil(max(measured.height, minimumHeight))
  }

  static func preferredHeightsByRow(
    for itemWidth: CGFloat,
    titles: [String],
    itemsPerRow: Int,
    traitCollection: UITraitCollection,
  ) -> [CGFloat] {
    guard itemWidth > 0 else { return [] }
    guard itemsPerRow > 0 else { return [] }

    var rowHeights = [CGFloat]()
    var startIndex = 0
    let minimumHeight = minimumMeasuredCardHeight(for: itemWidth, traitCollection: traitCollection)

    while startIndex < titles.count {
      let endIndex = min(startIndex + itemsPerRow, titles.count)
      let rowTitles = Array(titles[startIndex..<endIndex])
      let rowMax = rowTitles.reduce(CGFloat(0)) { current, title in
        max(
          current,
          preferredHeight(for: itemWidth, title: title, traitCollection: traitCollection),
        )
      }
      rowHeights.append(ceil(max(rowMax, minimumHeight)))
      startIndex = endIndex
    }

    return rowHeights
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
    else { return }

    applyScaledMetricsIfNeeded(force: true)
  }

  override func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes
  ) -> UICollectionViewLayoutAttributes {
    let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    let targetSize = CGSize(
      width: layoutAttributes.size.width,
      height: UIView.layoutFittingCompressedSize.height,
    )
    let autoLayoutSize = contentView.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel,
    )
    attributes.size.height = autoLayoutSize.height
    return attributes
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
    let token = item.accessibilityToken
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
    retryBadgeButton.setTitle(item.content.retryButtonTitle, for: .normal)

    applyState(item.state)
    applyIcon(for: item.icon, state: item.state)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    applyScaledMetricsIfNeeded()

    // Update preferredMaxLayoutWidth for proper multiline text sizing.
    let availableWidth = cardView.bounds.width - (currentMetrics?.contentInset ?? Layout.contentInset) * 2
    titleLabel.preferredMaxLayoutWidth = max(0, availableWidth)
  }

  func transition(
    to state: BetaTestCardState,
    item: BetaTestItem,
    animated: Bool,
    completion: (() -> Void)? = nil,
  ) {
    let applyChanges = { [self] in
      titleLabel.text = item.title
      retryBadgeButton.setTitle(item.content.retryButtonTitle, for: .normal)
      applyState(state)
      applyIcon(for: item.icon, state: state)
      layoutIfNeeded()
    }

    let shouldAnimate = animated && !UIAccessibility.isReduceMotionEnabled
    guard shouldAnimate else {
      applyChanges()
      completion?()
      return
    }

    UIView.transition(
      with: cardView,
      duration: 0.24,
      options: [.transitionCrossDissolve, .allowAnimatedContent, .curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
      animations: applyChanges,
      completion: { _ in completion?() },
    )
  }

  // MARK: Private

  private struct ScaledMetrics: Equatable {
    let cornerRadius: CGFloat
    let contentInset: CGFloat
    let titleBottomInset: CGFloat
    let iconCircleSize: CGFloat
    let iconSize: CGFloat
    let statusSize: CGFloat
    let topRowSpacing: CGFloat
    let retryHeight: CGFloat
    let retryVerticalInset: CGFloat
    let retryHorizontalInset: CGFloat
  }

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
    static let minimumMeasuredCardHeight: CGFloat = 120
  }

  private static let fallbackAssetNamesByIcon: [BetaTestItem.IconType: [String]] = [
    .cpu: ["cpuImage", "failedImage"],
    .hardDisk: ["hardDiskImage", "storageImage", "cpuImage", "failedImage"],
    .battery: ["batteryImage", "cpuImage", "failedImage"],
    .jailbreak: ["securityImage", "cpuImage", "failedImage"],
    .biometricOne: ["faceIDImage", "biometricImage", "cpuImage", "failedImage"],
    .biometricTwo: ["touchIDImage", "biometricImage", "cpuImage", "failedImage"],
    .silent: ["silentImage", "audioImage", "cpuImage", "failedImage"],
    .volume: ["volumeImage", "audioImage", "cpuImage", "failedImage"],
    .power: ["powerImage", "cpuImage", "failedImage"],
    .camera: ["cameraImage", "cpuImage", "failedImage"],
    .touch: ["touchImage", "screenImage", "cpuImage", "failedImage"],
    .sim: ["simImage", "networkImage", "cpuImage", "failedImage"],
  ]

  private static var fallbackImageCache = [BetaTestItem.IconType: UIImage?]()
  private static let sizingCell = BetaTestCollectionViewCell(frame: .zero)

  private var currentMetrics: ScaledMetrics?

  private var iconCircleLeadingConstraint: NSLayoutConstraint?
  private var iconCircleTopConstraint: NSLayoutConstraint?
  private var iconCircleWidthConstraint: NSLayoutConstraint?
  private var iconCircleHeightConstraint: NSLayoutConstraint?

  private var iconImageWidthConstraint: NSLayoutConstraint?
  private var iconImageHeightConstraint: NSLayoutConstraint?

  private var statusTrailingConstraint: NSLayoutConstraint?
  private var statusWidthConstraint: NSLayoutConstraint?
  private var statusHeightConstraint: NSLayoutConstraint?

  private var loadingTrailingConstraint: NSLayoutConstraint?
  private var loadingWidthConstraint: NSLayoutConstraint?
  private var loadingHeightConstraint: NSLayoutConstraint?

  private var retryTrailingConstraint: NSLayoutConstraint?
  private var retryHeightConstraint: NSLayoutConstraint?

  private var titleLeadingConstraint: NSLayoutConstraint?
  private var titleTrailingConstraint: NSLayoutConstraint?
  private var titleTopConstraint: NSLayoutConstraint?
  private var titleBottomConstraint: NSLayoutConstraint?

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
    label.preferredMaxLayoutWidth = 0
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

  private static func widthScaleFactor(for referenceWidth: CGFloat) -> CGFloat {
    switch referenceWidth {
    case ..<145:
      0.90
    case ..<170:
      1.00
    case ..<190:
      1.06
    case ..<215:
      1.12
    default:
      1.16
    }
  }

  private static func dynamicTypeScale(for traitCollection: UITraitCollection) -> CGFloat {
    let scale = UIFontMetrics(forTextStyle: .body).scaledValue(for: 1, compatibleWith: traitCollection)
    return min(max(scale, 1.0), 1.6)
  }

  private static func minimumMeasuredCardHeight(
    for referenceWidth: CGFloat,
    traitCollection: UITraitCollection,
  ) -> CGFloat {
    let widthScale = widthScaleFactor(for: referenceWidth)
    let typeScale = dynamicTypeScale(for: traitCollection)
    let finalScale = min(max(widthScale * (1 + ((typeScale - 1) * 0.4)), 0.95), 1.5)
    return ceil(Layout.minimumMeasuredCardHeight * finalScale)
  }

  private func scaledMetrics(
    for traitCollection: UITraitCollection,
    referenceWidth: CGFloat,
  ) -> ScaledMetrics {
    let widthScale = Self.widthScaleFactor(for: referenceWidth)
    let typeScale = Self.dynamicTypeScale(for: traitCollection)

    let componentScale = min(max(widthScale * (1 + ((typeScale - 1) * 0.45)), 0.90), 1.45)
    let spacingScale = min(max(widthScale * (1 + ((typeScale - 1) * 0.30)), 0.90), 1.35)
    let cornerScale = min(max(widthScale * (1 + ((typeScale - 1) * 0.20)), 0.90), 1.25)

    return ScaledMetrics(
      cornerRadius: round(Layout.cornerRadius * cornerScale),
      contentInset: round(Layout.contentInset * spacingScale),
      titleBottomInset: round(Layout.titleBottomInset * spacingScale),
      iconCircleSize: round(Layout.iconCircleSize * componentScale),
      iconSize: round(Layout.iconSize * componentScale),
      statusSize: round(Layout.statusSize * componentScale),
      topRowSpacing: round(Layout.topRowSpacing * spacingScale),
      retryHeight: round(Layout.retryHeight * componentScale),
      retryVerticalInset: max(2, round(3 * spacingScale)),
      retryHorizontalInset: max(10, round(12 * spacingScale)),
    )
  }

  private func applyScaledMetricsIfNeeded(force: Bool = false) {
    let referenceWidth = max(bounds.width, contentView.bounds.width)
    guard referenceWidth > 0 else { return }

    applyScaledMetrics(
      traitCollection: traitCollection,
      referenceWidth: referenceWidth,
      force: force,
    )
  }

  private func applyScaledMetrics(
    traitCollection: UITraitCollection,
    referenceWidth: CGFloat,
    force: Bool,
  ) {
    let metrics = scaledMetrics(for: traitCollection, referenceWidth: referenceWidth)
    guard force || metrics != currentMetrics else { return }

    currentMetrics = metrics

    iconCircleLeadingConstraint?.constant = metrics.contentInset
    iconCircleTopConstraint?.constant = metrics.contentInset
    iconCircleWidthConstraint?.constant = metrics.iconCircleSize
    iconCircleHeightConstraint?.constant = metrics.iconCircleSize

    iconImageWidthConstraint?.constant = metrics.iconSize
    iconImageHeightConstraint?.constant = metrics.iconSize

    statusTrailingConstraint?.constant = -metrics.contentInset
    statusWidthConstraint?.constant = metrics.statusSize
    statusHeightConstraint?.constant = metrics.statusSize

    loadingTrailingConstraint?.constant = -metrics.contentInset
    loadingWidthConstraint?.constant = metrics.statusSize
    loadingHeightConstraint?.constant = metrics.statusSize

    retryTrailingConstraint?.constant = -metrics.contentInset
    retryHeightConstraint?.constant = metrics.retryHeight

    titleLeadingConstraint?.constant = metrics.contentInset
    titleTrailingConstraint?.constant = -metrics.contentInset
    titleTopConstraint?.constant = metrics.topRowSpacing
    titleBottomConstraint?.constant = -metrics.titleBottomInset

    cardView.layer.cornerRadius = metrics.cornerRadius
    iconCircleView.layer.cornerRadius = metrics.iconCircleSize / 2
    retryBadgeButton.layer.cornerRadius = metrics.retryHeight / 2
    retryBadgeButton.contentEdgeInsets = UIEdgeInsets(
      top: metrics.retryVerticalInset,
      left: metrics.retryHorizontalInset,
      bottom: metrics.retryVerticalInset,
      right: metrics.retryHorizontalInset,
    )

    let baseIndicatorSize: CGFloat = 20
    let indicatorScale = max(1.0, metrics.statusSize / baseIndicatorSize)
    loadingIndicator.transform = CGAffineTransform(scaleX: indicatorScale, y: indicatorScale)
  }

  private func applySizingTitle(
    _ title: String,
    traitCollection: UITraitCollection,
    referenceWidth: CGFloat,
  ) {
    let baseFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    let scaledFont = UIFontMetrics(forTextStyle: .body).scaledFont(
      for: baseFont,
      compatibleWith: traitCollection,
    )

    titleLabel.font = scaledFont
    titleLabel.text = title
    titleLabel.numberOfLines = 0

    let contentInset = scaledMetrics(
      for: traitCollection,
      referenceWidth: referenceWidth,
    ).contentInset
    let availableWidth = max(bounds.width - (contentInset * 2), 1)
    titleLabel.preferredMaxLayoutWidth = availableWidth

    retryBadgeButton.isHidden = true
    statusImageView.isHidden = true
    loadingIndicator.stopAnimating()
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

    iconCircleLeadingConstraint = iconCircleView.leadingAnchor.constraint(
      equalTo: cardView.leadingAnchor,
      constant: Layout.contentInset,
    )
    iconCircleTopConstraint = iconCircleView.topAnchor.constraint(
      equalTo: cardView.topAnchor,
      constant: Layout.contentInset,
    )
    iconCircleWidthConstraint = iconCircleView.widthAnchor.constraint(equalToConstant: Layout.iconCircleSize)
    iconCircleHeightConstraint = iconCircleView.heightAnchor.constraint(equalToConstant: Layout.iconCircleSize)

    iconImageWidthConstraint = iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize)
    iconImageHeightConstraint = iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize)

    statusTrailingConstraint = statusImageView.trailingAnchor.constraint(
      equalTo: cardView.trailingAnchor,
      constant: -Layout.contentInset,
    )
    statusWidthConstraint = statusImageView.widthAnchor.constraint(equalToConstant: Layout.statusSize)
    statusHeightConstraint = statusImageView.heightAnchor.constraint(equalToConstant: Layout.statusSize)

    loadingTrailingConstraint = loadingIndicator.trailingAnchor.constraint(
      equalTo: cardView.trailingAnchor,
      constant: -Layout.contentInset,
    )
    loadingWidthConstraint = loadingIndicator.widthAnchor.constraint(equalToConstant: Layout.statusSize)
    loadingHeightConstraint = loadingIndicator.heightAnchor.constraint(equalToConstant: Layout.statusSize)

    retryTrailingConstraint = retryBadgeButton.trailingAnchor.constraint(
      equalTo: cardView.trailingAnchor,
      constant: -Layout.contentInset,
    )
    retryHeightConstraint = retryBadgeButton.heightAnchor.constraint(equalToConstant: Layout.retryHeight)

    titleLeadingConstraint = titleLabel.leadingAnchor.constraint(
      equalTo: cardView.leadingAnchor,
      constant: Layout.contentInset,
    )
    titleTrailingConstraint = titleLabel.trailingAnchor.constraint(
      equalTo: cardView.trailingAnchor,
      constant: -Layout.contentInset,
    )
    titleTopConstraint = titleLabel.topAnchor.constraint(
      equalTo: iconCircleView.bottomAnchor,
      constant: Layout.topRowSpacing,
    )
    titleBottomConstraint = titleLabel.bottomAnchor.constraint(
      equalTo: cardView.bottomAnchor,
      constant: -Layout.titleBottomInset,
    )

    NSLayoutConstraint.activate([
      cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cardInset),
      cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cardInset),
      cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cardInset),
      cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cardInset),

      iconCircleLeadingConstraint,
      iconCircleTopConstraint,
      iconCircleWidthConstraint,
      iconCircleHeightConstraint,

      iconImageView.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
      iconImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      iconImageWidthConstraint,
      iconImageHeightConstraint,

      statusTrailingConstraint,
      statusImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      statusWidthConstraint,
      statusHeightConstraint,

      loadingTrailingConstraint,
      loadingIndicator.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      loadingWidthConstraint,
      loadingHeightConstraint,

      retryTrailingConstraint,
      retryBadgeButton.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      retryHeightConstraint,

      titleLeadingConstraint,
      titleTrailingConstraint,
      titleTopConstraint,
      titleBottomConstraint,
    ].compactMap { $0 })

    applyScaledMetricsIfNeeded(force: true)
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
      cardView.backgroundColor = UIColor.betaTestInitialCard
      cardView.layer.borderWidth = 0
      iconCircleView.backgroundColor = UIColor.betaTestDisabledCircle

    case .loading:
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

    if #available(iOS 13.0, *) {
      let pointSize = currentMetrics?.iconSize ?? Layout.iconSize
      let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
      if let symbolImage = UIImage(systemName: systemSymbolName(for: icon), withConfiguration: config) {
        iconImageView.tintColor = tintColor
        iconImageView.image = symbolImage.withRenderingMode(.alwaysTemplate)
        return
      }
    }

    if let fallbackImage = fallbackImage(for: icon) {
      iconImageView.tintColor = tintColor
      iconImageView.image = fallbackImage.withRenderingMode(.alwaysTemplate)
    } else {
      iconImageView.image = nil
    }
  }

  private func fallbackImage(for icon: BetaTestItem.IconType) -> UIImage? {
    assert(Thread.isMainThread, "UI image lookups should happen on main thread.")

    if let cached = Self.fallbackImageCache[icon] {
      return cached
    }

    let resolvedImage = fallbackAssetNames(for: icon).lazy.compactMap { UIImage(named: $0) }.first
    Self.fallbackImageCache[icon] = resolvedImage
    return resolvedImage
  }

  private func fallbackAssetNames(for icon: BetaTestItem.IconType) -> [String] {
    Self.fallbackAssetNamesByIcon[icon] ?? ["cpuImage", "failedImage"]
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
