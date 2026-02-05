//
//  CharlieTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 05/02/26.
//

import UIKit

// MARK: - Colors

private enum Colors {
  /// Green action button (#8EC63F)
  static let actionButton = UIColor(
    red: 142.0 / 255.0,
    green: 198.0 / 255.0,
    blue: 63.0 / 255.0,
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
  /// Pending gray (#C7C7CC)
  static let pending = UIColor(
    red: 199.0 / 255.0,
    green: 199.0 / 255.0,
    blue: 204.0 / 255.0,
    alpha: 1,
  )
}

// MARK: - CharlieTestTableViewCell

/// A table view cell displaying a test item with icon, expandable title,
/// and conditional action button with status indicator.
/// Designed to match Figma concept: card expands with multi-line text while
/// icon and action controls remain centered vertically.
final class CharlieTestTableViewCell: UITableViewCell {

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

  func configure(title: String, icon: UIImage? = nil, status: Status) {
    titleLabel.text = title
    if let icon {
      iconImageView.image = icon
    }
    applyStatus(status)
  }

  // MARK: Private

  private enum Constants {
    static let reuseIdentifier = "CharlieTestCell"
    static let actionButtonTitle = "ULANGI"
    static let defaultIconName = "cpuImage"
  }

  private enum Layout {
    static let screenWidth = UIScreen.main.bounds.width
    /// Icon size: 10% of screen width
    static let iconSizeRatio: CGFloat = 0.10
    /// Card corner radius - matches design spec
    static let cardCornerRadius: CGFloat = 10
    /// Status indicator size: 6% of screen width
    static let statusIndicatorSizeRatio: CGFloat = 0.06
  }

  /// Base container for shadow
  private lazy var baseView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.layer.cornerRadius = Layout.cardCornerRadius
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.15
    view.layer.shadowRadius = 6
    view.layer.shadowOffset = CGSize(width: 0, height: 3)
    view.accessibilityIdentifier = "CharlieTestCell.baseView"
    return view
  }()

  /// White card container
  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.cardCornerRadius
    view.clipsToBounds = true
    view.accessibilityIdentifier = "CharlieTestCell.cardView"
    return view
  }()

  /// Icon image view - uses cpuImage asset (already has blue bg + white icon)
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: Constants.defaultIconName)
    imageView.accessibilityIdentifier = "CharlieTestCell.iconImageView"
    return imageView
  }()

  /// Title label (drives cell height when multi-line)
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15, weight: .regular)
    label.textAlignment = .left
    label.numberOfLines = 0
    label.accessibilityIdentifier = "CharlieTestCell.titleLabel"
    return label
  }()

  /// Green "ULANGI" button (only visible for failure status)
  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(Constants.actionButtonTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
    button.backgroundColor = Colors.actionButton
    button.layer.cornerRadius = 4
    button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    button.accessibilityIdentifier = "CharlieTestCell.actionButton"
    button.isHidden = true
    return button
  }()

  /// Status indicator image view
  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.accessibilityIdentifier = "CharlieTestCell.statusImageView"
    return imageView
  }()

  /// Horizontal stack for action button + status
  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = 8
    stack.accessibilityIdentifier = "CharlieTestCell.actionStackView"
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
    } else {
      cardView.backgroundColor = .white
      titleLabel.textColor = .black
    }
  }

  private func setupViewHierarchy() {
    contentView.addSubview(baseView)
    baseView.addSubview(cardView)

    cardView.addSubview(iconImageView)
    cardView.addSubview(titleLabel)
    cardView.addSubview(actionStackView)

    actionStackView.addArrangedSubview(actionButton)
    actionStackView.addArrangedSubview(statusImageView)
  }

  private func setupConstraints() {
    let iconSize = Layout.screenWidth * Layout.iconSizeRatio
    let statusIndicatorSize = Layout.screenWidth * Layout.statusIndicatorSizeRatio
    let horizontalPadding: CGFloat = 12
    let verticalPadding: CGFloat = 12
    let iconToTitleSpacing: CGFloat = 12
    let titleToActionSpacing: CGFloat = 8

    NSLayoutConstraint.activate([
      // MARK: Base View (shadow container)
      baseView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor,
        constant: horizontalPadding,
      ),
      baseView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor,
        constant: -horizontalPadding,
      ),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
      baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

      // MARK: Card View (content container)
      cardView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      cardView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      cardView.topAnchor.constraint(equalTo: baseView.topAnchor),
      cardView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // MARK: Icon Image View (fixed size, centered with title)
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: horizontalPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
      iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
      iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
      iconImageView.heightAnchor.constraint(equalToConstant: iconSize),

      // MARK: Title Label (drives card height)
      titleLabel.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: iconToTitleSpacing,
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -titleToActionSpacing,
      ),
      titleLabel.topAnchor.constraint(
        equalTo: cardView.topAnchor,
        constant: verticalPadding,
      ),
      titleLabel.bottomAnchor.constraint(
        equalTo: cardView.bottomAnchor,
        constant: -verticalPadding,
      ),

      // MARK: Action Stack (right side, centered with title)
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -horizontalPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

      // MARK: Status Indicator (fixed size)
      statusImageView.widthAnchor.constraint(equalToConstant: statusIndicatorSize),
      statusImageView.heightAnchor.constraint(equalToConstant: statusIndicatorSize),
    ])

    // Minimum card height to ensure icon fits with padding
    let minCardHeight = iconSize + (verticalPadding * 2)
    let minHeightConstraint = cardView.heightAnchor.constraint(
      greaterThanOrEqualToConstant: minCardHeight
    )
    minHeightConstraint.priority = .defaultHigh
    minHeightConstraint.isActive = true
  }

  private func setupContentPriorities() {
    // Title label: allow vertical expansion, horizontal flexibility
    titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

    // Action button: hug content to show "ULANGI" fully
    actionButton.setContentHuggingPriority(.required, for: .horizontal)
    actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

    // Action stack: hug content
    actionStackView.setContentHuggingPriority(.required, for: .horizontal)
    actionStackView.setContentCompressionResistancePriority(.required, for: .horizontal)

    // Status image: fixed size, high resistance
    statusImageView.setContentHuggingPriority(.required, for: .horizontal)
    statusImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private func applyStatus(_ status: Status) {
    switch status {
    case .success:
      actionButton.isHidden = true
      if #available(iOS 13.0, *) {
        statusImageView.image = UIImage(systemName: "checkmark.circle.fill")?
          .withRenderingMode(.alwaysTemplate)
        statusImageView.tintColor = Colors.success
      } else {
        statusImageView.image = FallbackImages.successIndicator(
          size: Layout.screenWidth * Layout.statusIndicatorSizeRatio
        )
      }

    case .failure:
      actionButton.isHidden = false
      if #available(iOS 13.0, *) {
        statusImageView.image = UIImage(systemName: "xmark.circle.fill")?
          .withRenderingMode(.alwaysTemplate)
        statusImageView.tintColor = Colors.failure
      } else {
        statusImageView.image = FallbackImages.failureIndicator(
          size: Layout.screenWidth * Layout.statusIndicatorSizeRatio
        )
      }

    case .pending:
      actionButton.isHidden = true
      if #available(iOS 13.0, *) {
        statusImageView.image = UIImage(systemName: "circle")?
          .withRenderingMode(.alwaysTemplate)
        statusImageView.tintColor = Colors.pending
      } else {
        statusImageView.image = FallbackImages.pendingIndicator(
          size: Layout.screenWidth * Layout.statusIndicatorSizeRatio
        )
      }
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
    UIImage(named: "successImage") ?? makeCircleCheckmark(size: size, color: Colors.success)
  }

  static func failureIndicator(size: CGFloat) -> UIImage {
    UIImage(named: "failedImage") ?? makeCircleX(size: size, color: Colors.failure)
  }

  static func pendingIndicator(size: CGFloat) -> UIImage {
    makeEmptyCircle(size: size, color: Colors.pending)
  }

  // MARK: Private

  private static func makeEmptyCircle(size: CGFloat, color: UIColor) -> UIImage {
    let imageSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: imageSize)
    let circlePath = UIBezierPath(ovalIn: rect)
    color.setFill()
    circlePath.fill()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }

  private static func makeCircleCheckmark(size: CGFloat, color: UIColor) -> UIImage {
    let imageSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: imageSize)

    // Draw circle background
    let circlePath = UIBezierPath(ovalIn: rect)
    color.setFill()
    circlePath.fill()

    // Draw checkmark
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

    // Draw circle background
    let circlePath = UIBezierPath(ovalIn: rect)
    color.setFill()
    circlePath.fill()

    // Draw X
    let lineWidth = max(2, size * 0.08)
    let inset = size * 0.30

    let xPath = UIBezierPath()
    xPath.lineWidth = lineWidth
    xPath.lineCapStyle = .round

    // First diagonal
    xPath.move(to: CGPoint(x: inset, y: inset))
    xPath.addLine(to: CGPoint(x: size - inset, y: size - inset))

    // Second diagonal
    xPath.move(to: CGPoint(x: size - inset, y: inset))
    xPath.addLine(to: CGPoint(x: inset, y: size - inset))

    UIColor.white.setStroke()
    xPath.stroke()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }
}
