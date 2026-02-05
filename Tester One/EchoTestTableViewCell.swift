//
//  EchoTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 05/02/26.
//

import UIKit

// MARK: - Colors

private enum Colors {
  /// Action button green (#8EC63F)
  static let actionButton = UIColor(
    red: 142.0 / 255.0,
    green: 198.0 / 255.0,
    blue: 63.0 / 255.0,
    alpha: 1,
  )
  /// Card border gray
  static let cardBorder = UIColor(
    red: 207.0 / 255.0,
    green: 212.0 / 255.0,
    blue: 216.0 / 255.0,
    alpha: 1,
  )
  /// Text container border gray
  static let textBorder = UIColor(
    red: 200.0 / 255.0,
    green: 205.0 / 255.0,
    blue: 210.0 / 255.0,
    alpha: 1,
  )
  /// Pending indicator gray
  static let pendingBorder = UIColor(
    red: 170.0 / 255.0,
    green: 175.0 / 255.0,
    blue: 180.0 / 255.0,
    alpha: 1,
  )
  /// Success green (#34C759)
  static let success = UIColor(
    red: 52.0 / 255.0,
    green: 199.0 / 255.0,
    blue: 89.0 / 255.0,
    alpha: 1,
  )
  /// Failure red (#EA3A3A)
  static let failure = UIColor(
    red: 234.0 / 255.0,
    green: 58.0 / 255.0,
    blue: 58.0 / 255.0,
    alpha: 1,
  )
}

// MARK: - EchoTestTableViewCell

/// Card-style cell with icon, expandable middle text, and action/status controls.
/// The card expands with multi-line text while icon and action remain centered.
final class EchoTestTableViewCell: UITableViewCell {

  // MARK: Internal

  enum Status {
    case success
    case failure
    case pending
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupCell()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateShadowPath()
  }

  func configure(
    title: String,
    status: Status,
    icon: UIImage? = nil,
    showsActionButton: Bool = true,
  ) {
    titleLabel.text = title
    iconImageView.image = icon ?? UIImage(named: Constants.iconName)
    actionButton.isHidden = !showsActionButton
    applyStatus(status)
  }

  // MARK: Private

  private enum Constants {
    static let reuseIdentifier = "EchoTestCell"
    static let actionButtonTitle = "ULANGI"
    static let iconName = "cpuImage"
  }

  private enum Layout {
    static let screenWidth = UIScreen.main.bounds.width
    static let iconSizeRatio: CGFloat = 0.10
    static let statusIndicatorSizeRatio: CGFloat = 0.055
    static let cardCornerRadius: CGFloat = 10
    static let textCornerRadius: CGFloat = 4
    static let cardBorderWidth: CGFloat = 1
    static let textBorderWidth: CGFloat = 1
  }

  private lazy var baseView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.layer.cornerRadius = Layout.cardCornerRadius
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.04
    view.layer.shadowRadius = 3
    view.layer.shadowOffset = CGSize(width: 0, height: 1)
    view.accessibilityIdentifier = "EchoTestCell.baseView"
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.cardCornerRadius
    view.layer.borderWidth = Layout.cardBorderWidth
    view.layer.borderColor = Colors.cardBorder.cgColor
    view.clipsToBounds = true
    view.accessibilityIdentifier = "EchoTestCell.cardView"
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: Constants.iconName)
    imageView.accessibilityIdentifier = "EchoTestCell.iconImageView"
    return imageView
  }()

  private lazy var textContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.textCornerRadius
    view.layer.borderWidth = Layout.textBorderWidth
    view.layer.borderColor = Colors.textBorder.cgColor
    view.backgroundColor = .white
    view.accessibilityIdentifier = "EchoTestCell.textContainerView"
    return view
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 14, weight: .regular)
    label.textAlignment = .left
    label.numberOfLines = 0
    label.accessibilityIdentifier = "EchoTestCell.titleLabel"
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(Constants.actionButtonTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
    button.backgroundColor = Colors.actionButton
    button.layer.cornerRadius = 4
    button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    button.accessibilityIdentifier = "EchoTestCell.actionButton"
    return button
  }()

  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.accessibilityIdentifier = "EchoTestCell.statusImageView"
    return imageView
  }()

  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = 6
    stack.accessibilityIdentifier = "EchoTestCell.actionStackView"
    return stack
  }()

  private func setupCell() {
    selectionStyle = .none
    clipsToBounds = false
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.clipsToBounds = false

    setupAppearance()
    setupViewHierarchy()
    setupConstraints()
    setupContentPriorities()
  }

  private func setupAppearance() {
    if #available(iOS 13.0, *) {
      cardView.backgroundColor = .systemBackground
      titleLabel.textColor = .label
      textContainerView.backgroundColor = .systemBackground
    } else {
      cardView.backgroundColor = .white
      titleLabel.textColor = .black
      textContainerView.backgroundColor = .white
    }
  }

  private func setupViewHierarchy() {
    contentView.addSubview(baseView)
    baseView.addSubview(cardView)

    cardView.addSubview(iconImageView)
    cardView.addSubview(textContainerView)
    cardView.addSubview(actionStackView)

    textContainerView.addSubview(titleLabel)

    actionStackView.addArrangedSubview(actionButton)
    actionStackView.addArrangedSubview(statusImageView)
  }

  private func setupConstraints() {
    let iconSize = Layout.screenWidth * Layout.iconSizeRatio
    let statusSize = Layout.screenWidth * Layout.statusIndicatorSizeRatio
    let horizontalPadding: CGFloat = 10
    let verticalPadding: CGFloat = 8
    let iconToTextSpacing: CGFloat = 10
    let textToActionSpacing: CGFloat = 8
    let textPadding: CGFloat = 6

    NSLayoutConstraint.activate([
      // Base View (shadow container)
      baseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      baseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
      baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

      // Card View (content container)
      cardView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      cardView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      cardView.topAnchor.constraint(equalTo: baseView.topAnchor),
      cardView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // Icon
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: horizontalPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: textContainerView.centerYAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
      iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

      // Text Container (drives card height)
      textContainerView.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: iconToTextSpacing,
      ),
      textContainerView.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -textToActionSpacing,
      ),
      textContainerView.topAnchor.constraint(
        equalTo: cardView.topAnchor,
        constant: verticalPadding,
      ),
      textContainerView.bottomAnchor.constraint(
        equalTo: cardView.bottomAnchor,
        constant: -verticalPadding,
      ),

      // Title Label (inside text container)
      titleLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: textPadding),
      titleLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -textPadding),
      titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: textPadding),
      titleLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -textPadding),

      // Action Stack (right side, centered with text)
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -horizontalPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: textContainerView.centerYAnchor),

      // Status Indicator size
      statusImageView.widthAnchor.constraint(equalToConstant: statusSize),
      statusImageView.heightAnchor.constraint(equalToConstant: statusSize),
    ])

    // Ensure icon fits even with short text
    let minCardHeight = iconSize + (verticalPadding * 2)
    let minHeightConstraint = cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: minCardHeight)
    minHeightConstraint.priority = .defaultHigh
    minHeightConstraint.isActive = true
  }

  private func setupContentPriorities() {
    // Allow title to wrap, keep button/indicator size
    titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    actionButton.setContentHuggingPriority(.required, for: .horizontal)
    actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    actionStackView.setContentHuggingPriority(.required, for: .horizontal)
    actionStackView.setContentCompressionResistancePriority(.required, for: .horizontal)

    statusImageView.setContentHuggingPriority(.required, for: .horizontal)
    statusImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private func applyStatus(_ status: Status) {
    let statusSize = Layout.screenWidth * Layout.statusIndicatorSizeRatio

    switch status {
    case .success:
      statusImageView.image = UIImage(named: "successImage")
        ?? FallbackImages.successIndicator(size: statusSize)

    case .failure:
      statusImageView.image = UIImage(named: "failedImage")
        ?? FallbackImages.failureIndicator(size: statusSize)

    case .pending:
      statusImageView.image = FallbackImages.pendingIndicator(size: statusSize)
    }
  }

  private func updateShadowPath() {
    baseView.layer.shadowPath = UIBezierPath(
      roundedRect: baseView.bounds,
      cornerRadius: baseView.layer.cornerRadius,
    ).cgPath
  }
}

// MARK: - FallbackImages

private enum FallbackImages {

  // MARK: Internal

  static func successIndicator(size: CGFloat) -> UIImage {
    makeCircleCheckmark(size: size, color: Colors.success)
  }

  static func failureIndicator(size: CGFloat) -> UIImage {
    makeCircleX(size: size, color: Colors.failure)
  }

  static func pendingIndicator(size: CGFloat) -> UIImage {
    makeEmptySquare(size: size, color: Colors.pendingBorder)
  }

  // MARK: Private

  private static func makeEmptySquare(size: CGFloat, color: UIColor) -> UIImage {
    let imageSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: imageSize)
    let path = UIBezierPath(rect: rect.insetBy(dx: 1, dy: 1))
    color.setStroke()
    path.lineWidth = max(1, size * 0.08)
    path.stroke()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }

  private static func makeCircleCheckmark(size: CGFloat, color: UIColor) -> UIImage {
    let imageSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: imageSize)

    let circlePath = UIBezierPath(ovalIn: rect)
    color.setFill()
    circlePath.fill()

    let context = UIGraphicsGetCurrentContext()
    context?.setStrokeColor(UIColor.white.cgColor)
    context?.setLineWidth(max(2, size * 0.08))
    context?.setLineCap(.round)
    context?.setLineJoin(.round)

    let inset = size * 0.25
    let checkPath = UIBezierPath()
    checkPath.move(to: CGPoint(x: inset, y: size * 0.55))
    checkPath.addLine(to: CGPoint(x: size * 0.45, y: size * 0.75))
    checkPath.addLine(to: CGPoint(x: size - inset, y: inset))
    checkPath.stroke()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }

  private static func makeCircleX(size: CGFloat, color: UIColor) -> UIImage {
    let imageSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: imageSize)

    let circlePath = UIBezierPath(ovalIn: rect)
    color.setFill()
    circlePath.fill()

    let lineWidth = max(2, size * 0.08)
    let inset = size * 0.30

    let xPath = UIBezierPath()
    xPath.lineWidth = lineWidth
    xPath.lineCapStyle = .round

    xPath.move(to: CGPoint(x: inset, y: inset))
    xPath.addLine(to: CGPoint(x: size - inset, y: size - inset))

    xPath.move(to: CGPoint(x: size - inset, y: inset))
    xPath.addLine(to: CGPoint(x: inset, y: size - inset))

    UIColor.white.setStroke()
    xPath.stroke()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }
}
