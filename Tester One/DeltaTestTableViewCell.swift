//
//  DeltaTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 03/02/26.
//

import UIKit

// MARK: - DeltaTestTableViewCell

/// A table view cell displaying a test item with icon, title, action button, and status indicator.
/// Designed for "card-like" expansion where the icon and action button remain centered relative to the text.
final class DeltaTestTableViewCell: UITableViewCell {

  // MARK: Internal

  /// Bottom button states (controlled by DeviceTestViewController)
  enum BottomButtonState {
    /// "Mulai Tes" - #33B9FF bg, white title, enabled
    case start
    /// "Dalam Pengecekan" - #D7DCDE bg, #ADB1B2 title, disabled
    case wait
    /// "Lanjut" - #33B9FF bg, white title, enabled
    case finish
  }

  /// Action section states (ULANGI button + indicator area)
  enum ActionSectionState {
    /// Nothing shown (initial)
    case hidden
    /// Loading indicator shown
    case loading
    /// Success image only (no ULANGI button)
    case success
    /// ULANGI button + failed image
    case failed
  }

  /// Called when the ULANGI (retry) button is tapped
  var onRetryButtonTapped: (() -> Void)?

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

  override func prepareForReuse() {
    super.prepareForReuse()
    onRetryButtonTapped = nil
    titleLabel.text = nil
    currentActionSectionState = .hidden
    resetTransitionAppearance()
    applyActionSectionState(.hidden)
  }

  func configure(title: String, animated: Bool = false) {
    if animated, titleLabel.text != nil, titleLabel.text != title, window != nil {
      animateTitleChange()
    }
    titleLabel.text = title
    // Force layout recalculation for cell reuse with different content
    setNeedsLayout()
    layoutIfNeeded()
  }

  func setActionSectionState(_ state: ActionSectionState, animated: Bool = false) {
    let previousState = currentActionSectionState
    currentActionSectionState = state

    let shouldAnimateTransition =
      animated &&
      window != nil &&
      shouldAnimateTextRelayout(from: previousState, to: state)

    if shouldAnimateTransition {
      prepareTransitionAppearance()
    }

    applyActionSectionState(state)

    guard shouldAnimateTransition else {
      resetTransitionAppearance()
      return
    }

    UIView.animate(
      withDuration: Animation.transitionDuration,
      delay: 0,
      usingSpringWithDamping: Animation.springDamping,
      initialSpringVelocity: Animation.springVelocity,
      options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState],
      animations: {
        self.resetTransitionAppearance()
        self.layoutIfNeeded()
      },
      completion: nil,
    )
  }

  // MARK: Private

  private enum Animation {
    static let transitionDuration: TimeInterval = 0.34
    static let springDamping: CGFloat = 0.9
    static let springVelocity: CGFloat = 0.15
    static let minimumHeightDelta: CGFloat = 1
    static let titleStartAlpha: CGFloat = 0.84
    static let textScale: CGFloat = 0.992
    static let iconStartAlpha: CGFloat = 0.9
    static let actionStackStartAlpha: CGFloat = 0.82
    static let cardStartScale: CGFloat = 0.998
    static let titleChangeKey = "DeltaTestCell.titleFade"
    static let titleChangeDuration: CFTimeInterval = 0.22
  }

  private enum Constants {
    static let reuseIdentifier = "DeltaTestCell"
    static let actionButtonTitle = "ULANGI"
    static let iconName = "cpuImage"
  }

  private enum Layout {
    static let screenWidth = UIScreen.main.bounds.width
    static let baseCornerRadiusRatio: CGFloat = 0.08
    static let cardCornerRadiusRatio: CGFloat = 0.075
    static let iconSizeRatio: CGFloat = 0.13
    static let iconSize = screenWidth * iconSizeRatio
    static let actionStackSpacing = screenWidth * 0.02
    static let contentPadding = screenWidth * 0.03
    static let iconLeadingPadding = screenWidth * 0.012
    static let stackSpacing = screenWidth * 0.015
    static let borderWidth: CGFloat = 3
    static let verticalPadding = screenWidth * 0.015
    static let horizontalPadding = screenWidth * 0.025
    static let thinPadding = screenWidth * 0.015
    static let statusIndicatorSize = screenWidth * 0.06
    static let cardMinHeight = screenWidth * 0.15
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

  private var currentActionSectionState = ActionSectionState.hidden

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

    view.accessibilityIdentifier = "DeltaTestCell.baseView"
    return view
  }()

  /// Light gray outer border view
  private lazy var borderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * Layout.baseCornerRadiusRatio
    view.clipsToBounds = true
    view.accessibilityIdentifier = "DeltaTestCell.borderView"
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.screenWidth * Layout.cardCornerRadiusRatio
    view.clipsToBounds = true
    view.accessibilityIdentifier = "DeltaTestCell.cardView"
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.image = UIImage(named: Constants.iconName)
    imageView.accessibilityIdentifier = "DeltaTestCell.iconImageView"

    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
      imageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
    ])
    return imageView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .preferredFont(forTextStyle: .body)
    label.textAlignment = .left
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.accessibilityIdentifier = "DeltaTestCell.titleLabel"
    // Vertical: required so text pushes cell height
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    // Horizontal: allow compression so text wraps when action section is visible
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return label
  }()

  /// ULANGI button (shown only in failed state)
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

    button.accessibilityIdentifier = "DeltaTestCell.actionButton"
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
    button.isHidden = true
    button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
    return button
  }()

  /// Status indicator (success/failed image)
  private lazy var statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.accessibilityIdentifier = "DeltaTestCell.statusImageView"
    imageView.isHidden = true
    // Fixed size for status indicator
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: Layout.statusIndicatorSize),
      imageView.heightAnchor.constraint(equalToConstant: Layout.statusIndicatorSize),
    ])
    return imageView
  }()

  /// Loading indicator (shown during loading state)
  private lazy var loadingIndicator: UIActivityIndicatorView = {
    let indicator =
      if #available(iOS 13.0, *) {
        UIActivityIndicatorView(style: .medium)
      } else {
        UIActivityIndicatorView(style: .gray)
      }
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    indicator.accessibilityIdentifier = "DeltaTestCell.loadingIndicator"

    // Fixed size to match status image
    NSLayoutConstraint.activate([
      indicator.widthAnchor.constraint(equalToConstant: Layout.statusIndicatorSize),
      indicator.heightAnchor.constraint(equalToConstant: Layout.statusIndicatorSize),
    ])
    return indicator
  }()

  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [actionButton, statusImageView, loadingIndicator])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = Layout.actionStackSpacing
    stack.accessibilityIdentifier = "DeltaTestCell.actionStackView"
    // High hugging so stack collapses when all children are hidden
    stack.setContentHuggingPriority(.required, for: .horizontal)
    stack.setContentCompressionResistancePriority(.required, for: .horizontal)
    return stack
  }()

  private func applyActionSectionState(_ state: ActionSectionState) {
    // Hide all first
    actionButton.isHidden = true
    statusImageView.isHidden = true
    loadingIndicator.stopAnimating()

    switch state {
    case .hidden:
      // Everything stays hidden
      break

    case .loading:
      loadingIndicator.startAnimating()

    case .success:
      statusImageView.isHidden = false
      statusImageView.image = UIImage(named: "successImage")

    case .failed:
      actionButton.isHidden = false
      statusImageView.isHidden = false
      statusImageView.image = UIImage(named: "failedImage")
    }
  }

  private func animateTitleChange() {
    let transition = CATransition()
    transition.type = .fade
    transition.duration = Animation.titleChangeDuration
    titleLabel.layer.add(transition, forKey: Animation.titleChangeKey)
  }

  private func prepareTransitionAppearance() {
    titleLabel.alpha = Animation.titleStartAlpha
    titleLabel.transform = CGAffineTransform(scaleX: Animation.textScale, y: Animation.textScale)
    iconImageView.alpha = Animation.iconStartAlpha
    actionStackView.alpha = Animation.actionStackStartAlpha
    cardView.transform = CGAffineTransform(scaleX: Animation.cardStartScale, y: Animation.cardStartScale)
  }

  private func resetTransitionAppearance() {
    titleLabel.alpha = 1
    titleLabel.transform = .identity
    iconImageView.alpha = 1
    actionStackView.alpha = 1
    cardView.transform = .identity
  }

  private func shouldAnimateTextRelayout(from oldState: ActionSectionState, to newState: ActionSectionState)
    -> Bool
  {
    guard oldState != newState else { return false }

    let oldHeight = estimatedTitleHeight(for: oldState, text: titleLabel.text)
    let newHeight = estimatedTitleHeight(for: newState, text: titleLabel.text)
    return abs(oldHeight - newHeight) > Animation.minimumHeightDelta
  }

  private func estimatedTitleHeight(for state: ActionSectionState, text: String?) -> CGFloat {
    guard
      let text,
      !text.isEmpty
    else {
      return 0
    }

    let width = availableTitleWidth(for: state)
    guard width > 0 else { return 0 }

    let attributes: [NSAttributedString.Key: Any] = [.font: titleLabel.font as Any]
    let boundingRect = (text as NSString).boundingRect(
      with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: attributes,
      context: nil,
    )
    return ceil(boundingRect.height)
  }

  private func availableTitleWidth(for state: ActionSectionState) -> CGFloat {
    let contentWidth = contentView.bounds.width
    guard contentWidth > 0 else { return 0 }

    let cardWidth =
      contentWidth -
      (Layout.horizontalPadding * 2) -
      (Layout.borderWidth * 2)

    let occupiedWidth =
      Layout.iconLeadingPadding +
      Layout.iconSize +
      (Layout.stackSpacing * 2) +
      Layout.contentPadding +
      actionContentWidth(for: state)

    return max(0, cardWidth - occupiedWidth)
  }

  private func actionContentWidth(for state: ActionSectionState) -> CGFloat {
    switch state {
    case .hidden:
      return 0
    case .loading, .success:
      return Layout.statusIndicatorSize
    case .failed:
      let buttonWidth = max(
        actionButton.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width,
        actionButton.intrinsicContentSize.width,
      )
      return buttonWidth + Layout.statusIndicatorSize + actionStackView.spacing
    }
  }

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
    // Minimum height constraint
    let minHeightConstraint = cardView.heightAnchor.constraint(
      greaterThanOrEqualToConstant: Layout.cardMinHeight)
    minHeightConstraint.priority = .defaultHigh
    minHeightConstraint.isActive = true

    NSLayoutConstraint.activate([
      // 1. Base View (Container)
      baseView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor,
        constant: Layout.horizontalPadding,
      ),
      baseView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor,
        constant: -Layout.horizontalPadding,
      ),
      baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.verticalPadding),
      baseView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor,
        constant: -Layout.verticalPadding,
      ),

      // 2. Border View (Fills Base)
      borderView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      borderView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      borderView.topAnchor.constraint(equalTo: baseView.topAnchor),
      borderView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // 3. Card View (Inset from Border)
      cardView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: Layout.borderWidth),
      cardView.trailingAnchor.constraint(
        equalTo: borderView.trailingAnchor,
        constant: -Layout.borderWidth,
      ),
      cardView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: Layout.borderWidth),
      cardView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -Layout.borderWidth),

      // 4. Title Label (The anchor for height)
      titleLabel.leadingAnchor.constraint(
        equalTo: iconImageView.trailingAnchor,
        constant: Layout.stackSpacing,
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: actionStackView.leadingAnchor,
        constant: -Layout.stackSpacing,
      ),
      titleLabel.topAnchor.constraint(
        greaterThanOrEqualTo: cardView.topAnchor,
        constant: Layout.thinPadding,
      ),
      titleLabel.bottomAnchor.constraint(
        lessThanOrEqualTo: cardView.bottomAnchor,
        constant: -Layout.thinPadding,
      ),
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // 5. Icon Image View (Centered relative to Card -> Centered relative to Text)
      iconImageView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor,
        constant: Layout.iconLeadingPadding,
      ),
      iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // 6. Action Stack View (Centered relative to Card -> Centered relative to Text)
      actionStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor,
        constant: -Layout.contentPadding,
      ),
      actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
    ])
  }

  @objc
  private func retryButtonTapped() {
    onRetryButtonTapped?()
  }

  private func updateShadowPath() {
    baseView.layer.shadowPath =
      UIBezierPath(
        roundedRect: baseView.bounds,
        cornerRadius: baseView.layer.cornerRadius,
      ).cgPath
  }
}
