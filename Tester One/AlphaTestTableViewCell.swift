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

    // Spacing
    static let outerPadding = screenWidth * 0.02
    static let contentPadding = screenWidth * 0.03
    static let stackSpacing = screenWidth * 0.03

    // Sizing
    static let iconSize = screenWidth * 0.10
    static let statusSize = screenWidth * 0.06
    static let minCellHeight = screenWidth * 0.16
    static let cornerRadius = screenWidth * 0.03

    /// Fonts
    static let buttonFontSize = min(max(screenWidth * 0.032, 11), 15)

    // Shadow - soft, modern shadow that stays within cell bounds
    static let shadowRadius: CGFloat = 3
    static let shadowOffset = CGSize(width: 0, height: 0)
    static let shadowOpacity: Float = 0.30
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
    view.layer.cornerRadius = Layout.cornerRadius
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.cornerRadius
    view.clipsToBounds = true
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: Constants.iconName)
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
    return label
  }()

  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(Constants.actionButtonTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: Layout.buttonFontSize, weight: .semibold)
    button.backgroundColor = Colors.actionButton
    button.layer.cornerRadius = Layout.screenWidth * 0.02
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    return button
  }()

  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [actionButton, statusImageView])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = Layout.stackSpacing
    return stack
  }()

  private func setupCell() {
    selectionStyle = .none
    clipsToBounds = false
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.clipsToBounds = false

    setupAppearance()
    setupShadow()
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

  private func setupShadow() {
    // Apply shadow to baseView (no clipping), not cardView (has clipping)
    baseView.layer.shadowColor = UIColor.black.cgColor
    baseView.layer.shadowOpacity = Layout.shadowOpacity
    baseView.layer.shadowRadius = Layout.shadowRadius
    baseView.layer.shadowOffset = Layout.shadowOffset
  }

  private func setupViewHierarchy() {
    contentView.addSubview(baseView)
    baseView.addSubview(cardView)
    cardView.addSubview(iconImageView)
    cardView.addSubview(titleLabel)
    cardView.addSubview(actionStackView)
  }

  private func setupConstraints() {
    let statusSize = Layout.statusSize

    NSLayoutConstraint.activate([
      // Base view - wraps contentView, has shadow (no clipping)
      baseView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor, constant: Layout.outerPadding),
      baseView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor, constant: -Layout.outerPadding),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.outerPadding),
      baseView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor, constant: -Layout.outerPadding),
      baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.minCellHeight),

      // Card view - fills baseView, handles content clipping
      cardView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      cardView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      cardView.topAnchor.constraint(equalTo: baseView.topAnchor),
      cardView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // Icon - center vertically, with minimum top/bottom padding
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: Layout.contentPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      iconImageView.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor,
        constant: Layout.contentPadding,
      ),
      iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
      iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),

      // Action stack - fixed width to allow titleLabel to fill remaining space
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -Layout.contentPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      actionStackView.widthAnchor.constraint(equalToConstant: Layout.screenWidth * 0.28),

      // Status indicator
      statusImageView.widthAnchor.constraint(equalToConstant: statusSize),
      statusImageView.heightAnchor.constraint(equalToConstant: statusSize),

      // Title - center vertically for single line, expand for multi-line
      titleLabel.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: Layout.stackSpacing,
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -Layout.stackSpacing,
      ),
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      titleLabel.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor,
        constant: Layout.contentPadding,
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
        size: Layout.statusSize,
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
