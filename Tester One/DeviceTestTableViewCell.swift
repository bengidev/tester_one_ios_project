//
//  DeviceTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 03/02/26.
//

import UIKit

final class DeviceTestTableViewCell: UITableViewCell {

  // MARK: Internal

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureCell()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(title: String) {
    titleLabel.text = title
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateShadowPath()
    updateCornerRadii()
    updateLayoutMetrics()
  }

  // MARK: Private

  private enum Constants {
    static let defaultTitle = "Alpha"
  }

  private enum Layout {
    static let outerPadding: CGFloat = 8
    static let contentPadding: CGFloat = 8
    static let iconSizeRatio: CGFloat = 0.1
    static let iconContainerInset: CGFloat = 6
    static let actionSpacing: CGFloat = 8
    static let actionButtonCornerRadius: CGFloat = 8
    static let indicatorSize: CGFloat = 22
    static let actionWidthRatio: CGFloat = 0.24
    static let cellCornerRadius: CGFloat = 12
  }

  private let baseContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.clipsToBounds = false
    return view
  }()

  private let cellContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.cellCornerRadius
    view.clipsToBounds = false
    return view
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = Constants.defaultTitle
    label.font = .preferredFont(forTextStyle: .body)
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()

  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  private let actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("ULANGI", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
    button.backgroundColor = UIColor(
      red: 142.0 / 255.0,
      green: 198.0 / 255.0,
      blue: 63.0 / 255.0,
      alpha: 1,
    )
    button.layer.cornerRadius = Layout.actionButtonCornerRadius
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    return button
  }()

  private let statusImageView: UIImageView = {
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
    stack.spacing = Layout.actionSpacing
    return stack
  }()

  private lazy var firstStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .fill
    stack.spacing = Layout.contentPadding
    stack.clipsToBounds = true
    return stack
  }()

  private var iconSizeConstraint: NSLayoutConstraint?
  private var actionStackWidthConstraint: NSLayoutConstraint?
  private var statusFallbackImage: UIImage?

  private func configureCell() {
    selectionStyle = .none
    clipsToBounds = false
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.clipsToBounds = false

    configureAppearance()
    configureShadow()
    configureIcons()
    setupViewHierarchy()
    setupConstraints()
  }

  private func configureAppearance() {
    baseContainerView.backgroundColor = .clear
    cellContainerView.backgroundColor = .white
    firstStackView.backgroundColor = .white
  }

  private func configureShadow() {
    cellContainerView.layer.shadowColor = UIColor.black.cgColor
    cellContainerView.layer.shadowOpacity = 0.28
    cellContainerView.layer.shadowRadius = 6
    cellContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
  }

  private func configureIcons() {
    if #available(iOS 13.0, *) {
      iconImageView.image = UIImage(systemName: "battery.100")?.withRenderingMode(.alwaysTemplate)
      iconImageView.tintColor = .white
      statusImageView.image = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(
        .alwaysTemplate)
      statusImageView.tintColor = UIColor(
        red: 234.0 / 255.0,
        green: 58.0 / 255.0,
        blue: 58.0 / 255.0,
        alpha: 1,
      )
    } else {
      iconImageView.image = nil
      statusFallbackImage = makeStatusFallbackImage(diameter: Layout.indicatorSize)
      statusImageView.image = statusFallbackImage
    }
  }

  private func setupViewHierarchy() {
    contentView.addSubview(baseContainerView)
    baseContainerView.addSubview(cellContainerView)
    cellContainerView.addSubview(firstStackView)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      baseContainerView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor,
        constant: Layout.outerPadding,
      ),
      baseContainerView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor,
        constant: -Layout.outerPadding,
      ),
      baseContainerView.topAnchor.constraint(
        equalTo: contentView.topAnchor,
        constant: Layout.outerPadding,
      ),
      baseContainerView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -Layout.outerPadding,
      ),

      cellContainerView.leadingAnchor.constraint(equalTo: baseContainerView.leadingAnchor),
      cellContainerView.trailingAnchor.constraint(equalTo: baseContainerView.trailingAnchor),
      cellContainerView.topAnchor.constraint(equalTo: baseContainerView.topAnchor),
      cellContainerView.bottomAnchor.constraint(equalTo: baseContainerView.bottomAnchor),

      firstStackView.leadingAnchor.constraint(
        equalTo: cellContainerView.leadingAnchor,
        constant: Layout.contentPadding,
      ),
      firstStackView.trailingAnchor.constraint(
        equalTo: cellContainerView.trailingAnchor,
        constant: -Layout.contentPadding,
      ),
      firstStackView.topAnchor.constraint(
        equalTo: cellContainerView.topAnchor,
        constant: Layout.contentPadding,
      ),
      firstStackView.bottomAnchor.constraint(
        equalTo: cellContainerView.bottomAnchor,
        constant: -Layout.contentPadding,
      ),
    ])
  }

  private func updateShadowPath() {
    cellContainerView.layer.shadowPath =
      UIBezierPath(
        roundedRect: cellContainerView.bounds,
        cornerRadius: cellContainerView.layer.cornerRadius,
      ).cgPath
  }

  private func updateCornerRadii() {
    firstStackView.layer.cornerRadius = max(
      cellContainerView.layer.cornerRadius - Layout.contentPadding,
      0,
    )
  }

  private func updateLayoutMetrics() {
    let iconSize = UIScreen.main.bounds.width * Layout.iconSizeRatio
    if iconSizeConstraint?.constant != iconSize {
      iconSizeConstraint?.constant = iconSize
    }

    let actionWidth = UIScreen.main.bounds.width * Layout.actionWidthRatio
    if actionStackWidthConstraint?.constant != actionWidth {
      actionStackWidthConstraint?.constant = actionWidth
    }
  }

  private func makeStatusFallbackImage(diameter: CGFloat) -> UIImage {
    let size = CGSize(width: diameter, height: diameter)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    defer { UIGraphicsEndImageContext() }

    let rect = CGRect(origin: .zero, size: size)
    let circlePath = UIBezierPath(ovalIn: rect)
    UIColor(red: 234.0 / 255.0, green: 58.0 / 255.0, blue: 58.0 / 255.0, alpha: 1).setFill()
    circlePath.fill()

    let inset: CGFloat = diameter * 0.30
    let lineWidth: CGFloat = max(2, diameter * 0.08)
    let xPath = UIBezierPath()
    xPath.lineWidth = lineWidth
    xPath.lineCapStyle = .round
    xPath.move(to: CGPoint(x: inset, y: inset))
    xPath.addLine(to: CGPoint(x: diameter - inset, y: diameter - inset))
    xPath.move(to: CGPoint(x: diameter - inset, y: inset))
    xPath.addLine(to: CGPoint(x: inset, y: diameter - inset))
    UIColor.white.setStroke()
    xPath.stroke()

    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
  }
}
