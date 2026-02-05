//
//  BetaTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 03/02/26.
//

import UIKit

// MARK: - BetaTestTableViewCell

/// A table view cell displaying a test item with icon, title, action button, and status indicator.
/// Designed for "card-like" expansion where the icon and action button remain centered relative to the text.
final class BetaTestTableViewCell: UITableViewCell {

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
    static let reuseIdentifier = "BetaTestCell"
    static let actionButtonTitle = "ULANGI"
    static let iconName = "cpuImage"
  }

  private enum Layout {
    static let screenWidth = UIScreen.main.bounds.width
    /// Using 0.08 like Alpha for consistency in base corner radius
    static let baseCornerRadiusRatio: CGFloat = 0.08
    /// Card corner radius
    static let cardCornerRadiusRatio: CGFloat = 0.075
    /// Icon size ~13% of screen
    static let iconSizeRatio: CGFloat = 0.13
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
    view.layer.cornerRadius = Layout.screenWidth * Layout.baseCornerRadiusRatio

    // Shadow properties
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.05
    view.layer.shadowRadius = 2
    view.layer.shadowOffset = CGSize(width: 0, height: 0)

    view.accessibilityIdentifier = "BetaTestCell.baseView"
    return view
  }()

  /// Light gray outer border view
  private lazy var borderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * Layout.baseCornerRadiusRatio
    view.clipsToBounds = true
    view.accessibilityIdentifier = "BetaTestCell.borderView"
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * Layout.cardCornerRadiusRatio
    view.clipsToBounds = true
    view.accessibilityIdentifier = "BetaTestCell.cardView"
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: Constants.iconName)
    imageView.accessibilityIdentifier = "BetaTestCell.iconImageView"

    let iconSize = Layout.screenWidth * Layout.iconSizeRatio
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: iconSize),
      imageView.heightAnchor.constraint(equalToConstant: iconSize),
    ])
    return imageView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .preferredFont(forTextStyle: .body)
    label.textAlignment = .left
    label.numberOfLines = 0
    label.accessibilityIdentifier = "BetaTestCell.titleLabel"
    // Vertical compression resistance to ensure text pushes the cell height
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

    button.accessibilityIdentifier = "BetaTestCell.actionButton"
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    return button
  }()

  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.accessibilityIdentifier = "BetaTestCell.statusImageView"
    // Fixed size for status indicator
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
      imageView.heightAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
    ])
    return imageView
  }()

  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [actionButton, statusImageView])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = Layout.screenWidth * 0.02
    stack.accessibilityIdentifier = "BetaTestCell.actionStackView"
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

  private func setupViewHierarchy() {
    contentView.addSubview(baseView)
    baseView.addSubview(borderView)
    borderView.addSubview(cardView)

    cardView.addSubview(iconImageView)
    cardView.addSubview(titleLabel)
    cardView.addSubview(actionStackView)
  }

  private func setupConstraints() {
    // Spacing constants based on screen width
    let contentPadding = Layout.screenWidth * 0.03
    let iconLeadingPadding = Layout.screenWidth * 0.012
    let stackSpacing = Layout.screenWidth * 0.015
    let borderWidth: CGFloat = 3
    let verticalPadding = Layout.screenWidth * 0.015
    let horizontalPadding = Layout.screenWidth * 0.025
    let thinPadding = Layout.screenWidth * 0.015

    // Minimum height constraint
    let minHeightConstraint = cardView.heightAnchor.constraint(
      greaterThanOrEqualToConstant: Layout.screenWidth * 0.15)
    minHeightConstraint.priority = .defaultHigh
    minHeightConstraint.isActive = true

    NSLayoutConstraint.activate([
      // 1. Base View (Container)
      baseView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor,
        constant: horizontalPadding,
      ),
      baseView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor,
        constant: -horizontalPadding,
      ),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
      baseView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -verticalPadding,
      ),

      // 2. Border View (Fills Base)
      borderView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      borderView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      borderView.topAnchor.constraint(equalTo: baseView.topAnchor),
      borderView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // 3. Card View (Inset from Border)
      cardView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: borderWidth),
      cardView.trailingAnchor.constraint(
        equalTo: borderView.trailingAnchor,
        constant: -borderWidth,
      ),
      cardView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: borderWidth),
      cardView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -borderWidth),

      // 4. Title Label (The anchor for height)
      // Leading: Right of Icon
      titleLabel.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: stackSpacing,
      ),
      // Trailing: Left of Action Stack
      titleLabel.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -stackSpacing,
      ),

      // Vertical Constraints for Title Label:
      // It pushes the card height. We use >= constraints for top/bottom to allow growth.
      // But we primarily want it centered.
      // Strategy: Pin Top/Bottom with priority required, but allow the label to be centered if the card is taller (due to minHeight).
      // However, to satisfy "card expanding when text expands", we need the text to drive the card height.
      titleLabel.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor,
        constant: thinPadding,
      ),
      titleLabel.bottomAnchor.constraint(
        lessThanOrEqualTo: cardView.bottomAnchor,
        constant: -thinPadding,
      ),
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // 5. Icon Image View (Centered relative to Card -> Centered relative to Text)
      // Since Card expands with Text, Card.centerY is Text.centerY
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: iconLeadingPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // 6. Action Stack View (Centered relative to Card -> Centered relative to Text)
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -contentPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
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

  static func statusIndicator(color: UIColor, status: BetaTestTableViewCell.Status, size: CGFloat)
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
