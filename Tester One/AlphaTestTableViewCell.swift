//
//  AlphaTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 03/02/26.
//

import UIKit

// MARK: - AlphaTestTableViewCell

/// A table view cell displaying a test item with icon, title, action button, and status indicator.
final class AlphaTestTableViewCell: UITableViewCell {

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

  func configure(title: String, status: Status) {
    titleLabel.text = title
    applyStatus(status)
  }

  // MARK: Private

  private enum Constants {
    static let reuseIdentifier = "AlphaTestCell"
    static let actionButtonTitle = "ULANGI"
    static let iconName = "cpuImage"
  }

  private enum Layout {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
  }

  private enum Colors {
    static let actionButton = UIColor(
      red: 142.0 / 255.0,
      green: 198.0 / 255.0,
      blue: 63.0 / 255.0,
      alpha: 1,
    )
    static let success = UIColor(
      red: 52.0 / 255.0,
      green: 199.0 / 255.0,
      blue: 89.0 / 255.0,
      alpha: 1,
    )
    static let failure = UIColor(
      red: 234.0 / 255.0,
      green: 58.0 / 255.0,
      blue: 58.0 / 255.0,
      alpha: 1,
    )
    static let pending = UIColor(
      red: 199.0 / 255.0,
      green: 199.0 / 255.0,
      blue: 204.0 / 255.0,
      alpha: 1,
    )
  }

  private lazy var baseView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.layer.cornerRadius = Layout.screenWidth * 0.08
    // Shadow properties set inline
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.05
    view.layer.shadowRadius = 2
    view.layer.shadowOffset = CGSize(width: 0, height: 0)
    view.accessibilityIdentifier = "AlphaTestCell.baseView"
    return view
  }()

  /// Light gray outer border view that creates the "outer half-circle" frame effect
  private lazy var borderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * 0.08
    view.clipsToBounds = true
    view.accessibilityIdentifier = "AlphaTestCell.borderView"
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * 0.075
    view.clipsToBounds = true
    view.accessibilityIdentifier = "AlphaTestCell.cardView"
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: Constants.iconName)
    imageView.accessibilityIdentifier = "AlphaTestCell.iconImageView"
    // Icon size: 13% of screen width (slightly smaller)
    let iconSize = Layout.screenWidth * 0.13
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: iconSize),
      imageView.heightAnchor.constraint(equalToConstant: iconSize),
    ])
    return imageView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    // Back to body font size
    label.font = .preferredFont(forTextStyle: .body)
    label.textAlignment = .left
    // Support multiple lines (0 = unlimited)
    label.numberOfLines = 0
    label.accessibilityIdentifier = "AlphaTestCell.titleLabel"
    // Ensure label can expand without being compressed
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    return label
  }()

  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(Constants.actionButtonTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    let buttonFontSize = min(max(Layout.screenWidth * 0.032, 11), 15)
    button.titleLabel?.font = .systemFont(ofSize: buttonFontSize, weight: .semibold)
    button.backgroundColor = Colors.actionButton
    button.layer.cornerRadius = Layout.screenWidth * 0.02
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    button.accessibilityIdentifier = "AlphaTestCell.actionButton"
    // Button should size to fit content
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    return button
  }()

  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.accessibilityIdentifier = "AlphaTestCell.statusImageView"
    return imageView
  }()

  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [actionButton, statusImageView])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = Layout.screenWidth * 0.02
    stack.accessibilityIdentifier = "AlphaTestCell.actionStackView"
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

  // Shadow is configured inline in baseView lazy var

  private func setupViewHierarchy() {
    contentView.addSubview(baseView)
    baseView.addSubview(borderView)
    borderView.addSubview(cardView)
    cardView.addSubview(iconImageView)
    cardView.addSubview(titleLabel)
    cardView.addSubview(actionStackView)
  }

  private func setupConstraints() {
    let contentPadding = Layout.screenWidth * 0.03
    // Icon moved slightly right (was 0.5%, now 1.5%)
    let iconLeadingPadding = Layout.screenWidth * 0.012
    // Uniform thin padding around content
    let thinPadding = Layout.screenWidth * 0.015
    let stackSpacing = Layout.screenWidth * 0.015
    let borderWidth: CGFloat = 3
    // Vertical padding for baseView (slightly increased)
    let verticalPadding = Layout.screenWidth * 0.015
    // Slightly more horizontal padding for baseView
    let horizontalPadding = Layout.screenWidth * 0.025

    // Minimum height: 15% (icon 13% + 1% padding each side)
    let minHeightConstraint = cardView.heightAnchor.constraint(
      greaterThanOrEqualToConstant: Layout.screenWidth * 0.15)
    minHeightConstraint.priority = .defaultHigh
    minHeightConstraint.isActive = true

    NSLayoutConstraint.activate([
      // Base view - with more horizontal padding for better visual separation
      baseView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor, constant: horizontalPadding),
      baseView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
      baseView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor, constant: -verticalPadding),

      // Border view - fills baseView, creates the outer half-circle frame
      borderView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      borderView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      borderView.topAnchor.constraint(equalTo: baseView.topAnchor),
      borderView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // Card view - slightly inset from borderView, fills borderView
      cardView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: borderWidth),
      cardView.trailingAnchor.constraint(
        equalTo: borderView.trailingAnchor,
        constant: -borderWidth,
      ),
      cardView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: borderWidth),
      cardView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -borderWidth),

      // Title - expands vertically as needed

      // Title - expands vertically as needed
      titleLabel.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: stackSpacing,
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -stackSpacing,
      ),
      // Title has same thin padding as icon (uniform gap)
      titleLabel.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor, constant: thinPadding),
      titleLabel.bottomAnchor.constraint(
        lessThanOrEqualTo: cardView.bottomAnchor, constant: -thinPadding),
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // Icon - centered vertically, closer to left edge
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: iconLeadingPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // Action stack - centered with icon, hugs content
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -contentPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // Status indicator
      statusImageView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
      statusImageView.heightAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
    ])
  }

  private func applyStatus(_ status: Status) {
    let imageName: String
    let color: UIColor

    switch status {
    case .success:
      imageName = "checkmark.circle.fill"
      color = Colors.success

    case .failure:
      imageName = "xmark.circle.fill"
      color = Colors.failure

    case .pending:
      imageName = "circle"
      color = Colors.pending
    }

    if #available(iOS 13.0, *) {
      statusImageView.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
    } else {
      statusImageView.image = FallbackImages.statusIndicator(
        color: color,
        status: status,
        size: Layout.screenWidth * 0.06,
      )
    }
    statusImageView.tintColor = color
  }

  private func updateShadowPath() {
    baseView.layer.shadowPath =
      UIBezierPath(
        roundedRect: baseView.bounds,
        cornerRadius: baseView.layer.cornerRadius,
      ).cgPath
  }
}

// MARK: - FallbackImages

private enum FallbackImages {

  // MARK: Internal

  static func statusIndicator(color: UIColor, status: AlphaTestTableViewCell.Status, size: CGFloat)
    -> UIImage
  {
    switch status {
    case .success:
      UIImage(named: "successImage") ?? UIImage()
    case .failure:
      UIImage(named: "failedImage") ?? UIImage()
    case .pending:
      makeEmptyCircle(color: color, size: size)
    }
  }

  // MARK: Private

  private static func makeEmptyCircle(color: UIColor, size: CGFloat) -> UIImage {
    let imageSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: imageSize)
    let circlePath = UIBezierPath(ovalIn: rect)
    color.setFill()
    circlePath.fill()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }
}
