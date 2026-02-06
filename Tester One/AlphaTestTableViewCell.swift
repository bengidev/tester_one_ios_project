//
//  AlphaTestTableViewCell.swift
//  Tester One
//
//  Created by ENB Mac Mini on 03/02/26.
//

import UIKit

// MARK: - AlphaTestTableViewCell

/// A table view cell displaying a test item with icon, title, action button, and status indicator.
/// Designed for "card-like" expansion where the icon and action button remain centered relative to the text.
final class AlphaTestTableViewCell: UITableViewCell {

  // MARK: Internal

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

  static let reuseIdentifier = "AlphaTestCell"

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
    updateMetricsForCurrentWidth()
    updateTitlePreferredMaxLayoutWidth()
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
    // Mark for layout recalculation on the next pass for reused cells.
    setNeedsLayout()
  }

  func setActionSectionState(_ state: ActionSectionState, animated: Bool = false) {
    let previousState = currentActionSectionState
    currentActionSectionState = state

    let shouldAnimateTransition =
      animated && window != nil && shouldAnimateTextRelayout(from: previousState, to: state)

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
    static let titleChangeKey = "AlphaTestCell.titleFade"
    static let titleChangeDuration: CFTimeInterval = 0.22
  }

  private enum Constants {
    static let actionButtonTitle = "ULANGI"
    static let iconName = "cpuImage"
  }

  private enum Layout {
    static let fallbackMetricsWidth: CGFloat = 390
    static let baseCornerRadiusRatio: CGFloat = 0.08
    static let cardCornerRadiusRatio: CGFloat = 0.075
    static let iconSizeRatio: CGFloat = 0.13
    static let actionStackSpacingRatio: CGFloat = 0.02
    static let contentPaddingRatio: CGFloat = 0.03
    static let iconLeadingPaddingRatio: CGFloat = 0.012
    static let stackSpacingRatio: CGFloat = 0.015
    static let borderWidth: CGFloat = 3
    static let verticalPaddingRatio: CGFloat = 0.01
    static let horizontalPaddingRatio: CGFloat = 0.025
    static let thinPaddingRatio: CGFloat = 0.015
    static let statusIndicatorSizeRatio: CGFloat = 0.06
    static let cardMinHeightRatio: CGFloat = 0.15
    static let actionButtonCornerRadiusRatio: CGFloat = 0.02
    static let actionButtonFontSizeRatio: CGFloat = 0.032
    static let actionButtonFontSizeMin: CGFloat = 11
    static let actionButtonFontSizeMax: CGFloat = 15
  }

  private enum Colors {
    static let actionButton = UIColor(
      red: 142.0 / 255.0,
      green: 198.0 / 255.0,
      blue: 63.0 / 255.0,
      alpha: 1,
    )
  }

  private struct Metrics {
    let baseCornerRadius: CGFloat
    let cardCornerRadius: CGFloat
    let iconSize: CGFloat
    let actionStackSpacing: CGFloat
    let contentPadding: CGFloat
    let iconLeadingPadding: CGFloat
    let stackSpacing: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let thinPadding: CGFloat
    let statusIndicatorSize: CGFloat
    let cardMinHeight: CGFloat
    let actionButtonCornerRadius: CGFloat
    let actionButtonFontSize: CGFloat
  }

  private var currentActionSectionState = ActionSectionState.hidden
  private var currentMetrics = AlphaTestTableViewCell.metrics(for: Layout.fallbackMetricsWidth)
  private var lastAppliedWidth: CGFloat = 0

  private var baseLeadingConstraint: NSLayoutConstraint?
  private var baseTrailingConstraint: NSLayoutConstraint?
  private var baseTopConstraint: NSLayoutConstraint?
  private var baseBottomConstraint: NSLayoutConstraint?
  private var cardLeadingConstraint: NSLayoutConstraint?
  private var cardTrailingConstraint: NSLayoutConstraint?
  private var cardTopConstraint: NSLayoutConstraint?
  private var cardBottomConstraint: NSLayoutConstraint?
  private var titleLeadingConstraint: NSLayoutConstraint?
  private var titleTrailingConstraint: NSLayoutConstraint?
  private var titleTopConstraint: NSLayoutConstraint?
  private var titleBottomConstraint: NSLayoutConstraint?
  private var iconLeadingConstraint: NSLayoutConstraint?
  private var actionTrailingConstraint: NSLayoutConstraint?
  private var iconWidthConstraint: NSLayoutConstraint?
  private var iconHeightConstraint: NSLayoutConstraint?
  private var actionStackWidthConstraint: NSLayoutConstraint?
  private var statusWidthConstraint: NSLayoutConstraint?
  private var statusHeightConstraint: NSLayoutConstraint?
  private var loadingWidthConstraint: NSLayoutConstraint?
  private var loadingHeightConstraint: NSLayoutConstraint?
  private var minHeightConstraint: NSLayoutConstraint?

  private lazy var baseView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.layer.cornerRadius = currentMetrics.baseCornerRadius

    // Shadow properties
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.05
    view.layer.shadowRadius = 2
    view.layer.shadowOffset = CGSize(width: 0, height: 0)

    view.accessibilityIdentifier = "AlphaTestCell.baseView"
    return view
  }()

  /// Light gray outer border view
  private lazy var borderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = currentMetrics.baseCornerRadius
    view.clipsToBounds = true
    view.accessibilityIdentifier = "AlphaTestCell.borderView"
    return view
  }()

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = currentMetrics.cardCornerRadius
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

    iconWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: currentMetrics.iconSize)
    iconHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: currentMetrics.iconSize)
    NSLayoutConstraint.activate([
      iconWidthConstraint!,
      iconHeightConstraint!,
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
    label.accessibilityIdentifier = "AlphaTestCell.titleLabel"
    // Vertical: required so text pushes cell height
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    // Horizontal: allow compression so text wraps when action section is visible
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return label
  }()

  /// ULANGI button (shown only in failed state)
  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(Constants.actionButtonTitle, for: .normal)
    button.setTitleColor(.white, for: .normal)

    button.titleLabel?.font = .systemFont(
      ofSize: currentMetrics.actionButtonFontSize,
      weight: .semibold,
    )
    button.backgroundColor = Colors.actionButton
    button.layer.cornerRadius = currentMetrics.actionButtonCornerRadius
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    button.accessibilityIdentifier = "AlphaTestCell.actionButton"
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
    imageView.accessibilityIdentifier = "AlphaTestCell.statusImageView"
    imageView.isHidden = true
    // Fixed size for status indicator
    statusWidthConstraint = imageView.widthAnchor.constraint(
      equalToConstant: currentMetrics.statusIndicatorSize)
    statusHeightConstraint = imageView.heightAnchor.constraint(
      equalToConstant: currentMetrics.statusIndicatorSize)
    NSLayoutConstraint.activate([
      statusWidthConstraint!,
      statusHeightConstraint!,
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
    indicator.accessibilityIdentifier = "AlphaTestCell.loadingIndicator"

    // Fixed size to match status image
    loadingWidthConstraint = indicator.widthAnchor.constraint(
      equalToConstant: currentMetrics.statusIndicatorSize)
    loadingHeightConstraint = indicator.heightAnchor.constraint(
      equalToConstant: currentMetrics.statusIndicatorSize)
    NSLayoutConstraint.activate([
      loadingWidthConstraint!,
      loadingHeightConstraint!,
    ])
    return indicator
  }()

  private lazy var actionStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .fill
    stack.spacing = currentMetrics.actionStackSpacing
    stack.accessibilityIdentifier = "AlphaTestCell.actionStackView"
    // High hugging so stack collapses when all children are hidden
    stack.setContentHuggingPriority(.required, for: .horizontal)
    stack.setContentCompressionResistancePriority(.required, for: .horizontal)
    return stack
  }()

  private static func metrics(for width: CGFloat) -> Metrics {
    let normalizedWidth = max(width, 1)
    let actionButtonFontSize = min(
      max(normalizedWidth * Layout.actionButtonFontSizeRatio, Layout.actionButtonFontSizeMin),
      Layout.actionButtonFontSizeMax,
    )

    return Metrics(
      baseCornerRadius: normalizedWidth * Layout.baseCornerRadiusRatio,
      cardCornerRadius: normalizedWidth * Layout.cardCornerRadiusRatio,
      iconSize: normalizedWidth * Layout.iconSizeRatio,
      actionStackSpacing: normalizedWidth * Layout.actionStackSpacingRatio,
      contentPadding: normalizedWidth * Layout.contentPaddingRatio,
      iconLeadingPadding: normalizedWidth * Layout.iconLeadingPaddingRatio,
      stackSpacing: normalizedWidth * Layout.stackSpacingRatio,
      verticalPadding: normalizedWidth * Layout.verticalPaddingRatio,
      horizontalPadding: normalizedWidth * Layout.horizontalPaddingRatio,
      thinPadding: normalizedWidth * Layout.thinPaddingRatio,
      statusIndicatorSize: normalizedWidth * Layout.statusIndicatorSizeRatio,
      cardMinHeight: normalizedWidth * Layout.cardMinHeightRatio,
      actionButtonCornerRadius: normalizedWidth * Layout.actionButtonCornerRadiusRatio,
      actionButtonFontSize: actionButtonFontSize,
    )
  }

  private func applyActionSectionState(_ state: ActionSectionState) {
    removeAllActionArrangedSubviews()
    loadingIndicator.stopAnimating()

    switch state {
    case .hidden:
      break

    case .loading:
      loadingIndicator.isHidden = false
      actionStackView.addArrangedSubview(loadingIndicator)
      loadingIndicator.startAnimating()

    case .success:
      statusImageView.isHidden = false
      statusImageView.image = UIImage(named: "successImage")
      actionStackView.addArrangedSubview(statusImageView)

    case .failed:
      actionButton.isHidden = false
      statusImageView.isHidden = false
      statusImageView.image = UIImage(named: "failedImage")
      actionStackView.addArrangedSubview(actionButton)
      actionStackView.addArrangedSubview(statusImageView)
    }

    applyStateDrivenWidthConstraints(for: state)
    updateTitlePreferredMaxLayoutWidth()
  }

  private func removeAllActionArrangedSubviews() {
    for view in actionStackView.arrangedSubviews {
      actionStackView.removeArrangedSubview(view)
      view.removeFromSuperview()
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
    cardView.transform = CGAffineTransform(
      scaleX: Animation.cardStartScale,
      y: Animation.cardStartScale,
    )
  }

  private func resetTransitionAppearance() {
    titleLabel.alpha = 1
    titleLabel.transform = .identity
    iconImageView.alpha = 1
    actionStackView.alpha = 1
    cardView.transform = .identity
  }

  private func shouldAnimateTextRelayout(
    from oldState: ActionSectionState,
    to newState: ActionSectionState,
  ) -> Bool {
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
      contentWidth - (currentMetrics.horizontalPadding * 2) - (Layout.borderWidth * 2)

    let occupiedWidth =
      currentMetrics.iconLeadingPadding + currentMetrics.iconSize + (currentMetrics.stackSpacing * 2)
        + currentMetrics.contentPadding + actionContentWidth(for: state)

    return max(0, cardWidth - occupiedWidth)
  }

  private func actionContentWidth(for state: ActionSectionState) -> CGFloat {
    switch state {
    case .hidden:
      return 0
    case .loading, .success:
      return currentMetrics.statusIndicatorSize
    case .failed:
      let buttonWidth = max(
        actionButton.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width,
        actionButton.intrinsicContentSize.width,
      )
      return buttonWidth + currentMetrics.statusIndicatorSize + actionStackView.spacing
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
      greaterThanOrEqualToConstant: currentMetrics.cardMinHeight)
    minHeightConstraint.priority = .defaultHigh
    minHeightConstraint.isActive = true
    self.minHeightConstraint = minHeightConstraint

    baseLeadingConstraint = baseView.leadingAnchor.constraint(
      equalTo: contentView.leadingAnchor,
      constant: currentMetrics.horizontalPadding,
    )
    baseTrailingConstraint = baseView.trailingAnchor.constraint(
      equalTo: contentView.trailingAnchor,
      constant: -currentMetrics.horizontalPadding,
    )
    baseTopConstraint = baseView.topAnchor.constraint(
      equalTo: contentView.topAnchor,
      constant: currentMetrics.verticalPadding,
    )
    baseBottomConstraint = baseView.bottomAnchor.constraint(
      equalTo: contentView.bottomAnchor,
      constant: -currentMetrics.verticalPadding,
    )

    cardLeadingConstraint = cardView.leadingAnchor.constraint(
      equalTo: borderView.leadingAnchor,
      constant: Layout.borderWidth,
    )
    cardTrailingConstraint = cardView.trailingAnchor.constraint(
      equalTo: borderView.trailingAnchor,
      constant: -Layout.borderWidth,
    )
    cardTopConstraint = cardView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: Layout.borderWidth)
    cardBottomConstraint = cardView.bottomAnchor.constraint(
      equalTo: borderView.bottomAnchor,
      constant: -Layout.borderWidth,
    )

    titleLeadingConstraint = titleLabel.leadingAnchor.constraint(
      equalTo: iconImageView.trailingAnchor,
      constant: currentMetrics.stackSpacing,
    )
    titleTrailingConstraint = titleLabel.trailingAnchor.constraint(
      equalTo: actionStackView.leadingAnchor,
      constant: -currentMetrics.stackSpacing,
    )
    titleTopConstraint = titleLabel.topAnchor.constraint(
      greaterThanOrEqualTo: cardView.topAnchor,
      constant: currentMetrics.thinPadding,
    )
    titleBottomConstraint = titleLabel.bottomAnchor.constraint(
      lessThanOrEqualTo: cardView.bottomAnchor,
      constant: -currentMetrics.thinPadding,
    )

    iconLeadingConstraint = iconImageView.leadingAnchor.constraint(
      equalTo: cardView.leadingAnchor,
      constant: currentMetrics.iconLeadingPadding,
    )
    actionTrailingConstraint = actionStackView.trailingAnchor.constraint(
      equalTo: cardView.trailingAnchor,
      constant: -currentMetrics.contentPadding,
    )
    actionStackWidthConstraint = actionStackView.widthAnchor.constraint(
      equalToConstant: actionContentWidth(for: currentActionSectionState))

    NSLayoutConstraint.activate([
      // 1. Base View (Container)
      baseLeadingConstraint!,
      baseTrailingConstraint!,
      baseTopConstraint!,
      baseBottomConstraint!,

      // 2. Border View (Fills Base)
      borderView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
      borderView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
      borderView.topAnchor.constraint(equalTo: baseView.topAnchor),
      borderView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),

      // 3. Card View (Inset from Border)
      cardLeadingConstraint!,
      cardTrailingConstraint!,
      cardTopConstraint!,
      cardBottomConstraint!,

      // 4. Title Label (The anchor for height)
      titleLeadingConstraint!,
      titleTrailingConstraint!,
      titleTopConstraint!,
      titleBottomConstraint!,
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // 5. Icon Image View (Centered relative to Card -> Centered relative to Text)
      iconLeadingConstraint!,
      iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      // 6. Action Stack View (Centered relative to Card -> Centered relative to Text)
      actionTrailingConstraint!,
      actionStackWidthConstraint!,
      actionStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
    ])
  }

  private func updateMetricsForCurrentWidth(force: Bool = false) {
    let measuredWidth = contentView.bounds.width > 0 ? contentView.bounds.width : bounds.width
    guard measuredWidth > 0 else { return }

    guard force || abs(measuredWidth - lastAppliedWidth) > 0.5 else { return }

    currentMetrics = AlphaTestTableViewCell.metrics(for: measuredWidth)
    lastAppliedWidth = measuredWidth
    applyCurrentMetrics()
  }

  private func applyCurrentMetrics() {
    baseView.layer.cornerRadius = currentMetrics.baseCornerRadius
    borderView.layer.cornerRadius = currentMetrics.baseCornerRadius
    cardView.layer.cornerRadius = currentMetrics.cardCornerRadius

    actionStackView.spacing = currentMetrics.actionStackSpacing
    actionButton.layer.cornerRadius = currentMetrics.actionButtonCornerRadius
    actionButton.titleLabel?.font = .systemFont(ofSize: currentMetrics.actionButtonFontSize, weight: .semibold)

    baseLeadingConstraint?.constant = currentMetrics.horizontalPadding
    baseTrailingConstraint?.constant = -currentMetrics.horizontalPadding
    baseTopConstraint?.constant = currentMetrics.verticalPadding
    baseBottomConstraint?.constant = -currentMetrics.verticalPadding

    titleLeadingConstraint?.constant = currentMetrics.stackSpacing
    titleTrailingConstraint?.constant = -currentMetrics.stackSpacing
    titleTopConstraint?.constant = currentMetrics.thinPadding
    titleBottomConstraint?.constant = -currentMetrics.thinPadding

    iconLeadingConstraint?.constant = currentMetrics.iconLeadingPadding
    actionTrailingConstraint?.constant = -currentMetrics.contentPadding

    iconWidthConstraint?.constant = currentMetrics.iconSize
    iconHeightConstraint?.constant = currentMetrics.iconSize

    statusWidthConstraint?.constant = currentMetrics.statusIndicatorSize
    statusHeightConstraint?.constant = currentMetrics.statusIndicatorSize
    loadingWidthConstraint?.constant = currentMetrics.statusIndicatorSize
    loadingHeightConstraint?.constant = currentMetrics.statusIndicatorSize

    minHeightConstraint?.constant = currentMetrics.cardMinHeight
    applyStateDrivenWidthConstraints(for: currentActionSectionState)
    updateTitlePreferredMaxLayoutWidth()
  }

  private func applyStateDrivenWidthConstraints(for state: ActionSectionState) {
    actionStackWidthConstraint?.isActive = true
    actionStackWidthConstraint?.constant = actionContentWidth(for: state)
  }

  private func updateTitlePreferredMaxLayoutWidth() {
    let width = availableTitleWidth(for: currentActionSectionState)
    guard width > 0 else { return }
    guard abs(titleLabel.preferredMaxLayoutWidth - width) > 0.5 else { return }
    titleLabel.preferredMaxLayoutWidth = width
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
