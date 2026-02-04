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
    view.layer.cornerRadius = Layout.screenWidth * 0.085
    // Shadow properties set inline
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.30
    view.layer.shadowRadius = 3
    view.layer.shadowOffset = CGSize(width: 0, height: 0)
    view.accessibilityIdentifier = "AlphaTestCell.baseView"
    return view
  }()

  /// Light gray outer border view that creates the "outer half-circle" frame effect
  private lazy var borderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * 0.085
    view.clipsToBounds = true
    view.backgroundColor = .white
    view.accessibilityIdentifier = "AlphaTestCell.borderView"
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * 0.03
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
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.13),
      imageView.heightAnchor.constraint(equalToConstant: Layout.screenWidth * 0.13),
    ])
    return imageView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    // Use preferred font for Dynamic Type support
    label.font = .preferredFont(forTextStyle: .body)
    label.textAlignment = .left
    // Support multiple lines (0 = unlimited)
    label.numberOfLines = 0
    label.accessibilityIdentifier = "AlphaTestCell.titleLabel"
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
    stack.spacing = Layout.screenWidth * 0.03
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
    let outerPadding = Layout.screenWidth * 0.02
    let contentPadding = Layout.screenWidth * 0.03
    let stackSpacing = Layout.screenWidth * 0.03
    let minCellHeight = Layout.screenWidth * 0.16
    let borderWidth: CGFloat = 3

    NSLayoutConstraint.activate([
      // Base view - wraps contentView, has shadow (no clipping)
      baseView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor,
        constant: outerPadding,
      ),
      baseView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor,
        constant: -outerPadding,
      ),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: outerPadding),
      baseView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -outerPadding,
      ),
      baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: minCellHeight),

      // Border view - fills baseView, creates the outer half-circle frame
      borderView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      borderView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      borderView.topAnchor.constraint(equalTo: baseView.topAnchor),
      borderView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // Card view - slightly inset from borderView to show the outer frame
      cardView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: borderWidth),
      cardView.trailingAnchor.constraint(
        equalTo: borderView.trailingAnchor,
        constant: -borderWidth,
      ),
      cardView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: borderWidth),
      cardView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -borderWidth),

      // Icon - center vertically, with minimum top/bottom padding
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: contentPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      iconImageView.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor,
        constant: contentPadding,
      ),

      // Action stack - fixed width to allow titleLabel to fill remaining space
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -contentPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      actionStackView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.28),

      // Status indicator
      statusImageView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),
      statusImageView.heightAnchor.constraint(equalToConstant: Layout.screenWidth * 0.06),

      // Title - center vertically for single line, expand for multi-line
      titleLabel.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: stackSpacing,
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -stackSpacing,
      ),
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      titleLabel.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor,
        constant: contentPadding,
      ),
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
