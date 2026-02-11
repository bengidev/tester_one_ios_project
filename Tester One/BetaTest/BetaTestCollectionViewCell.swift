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

    // iOS 12 fallback: choose icon-specific assets when available, then fallback safely.
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
