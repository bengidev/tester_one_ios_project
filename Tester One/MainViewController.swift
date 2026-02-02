//
//  MainViewController.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import UIKit

// MARK: - MainViewController

final class MainViewController: UIViewController {

  // MARK: Properties

  private let contentView = MainView()

  // MARK: Functions

  override func loadView() {
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureActions()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    contentView.animateInIfNeeded()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }

  private func configureActions() {
    contentView.startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    contentView.startButton.addTarget(
      self,
      action: #selector(primaryButtonPressed),
      for: .touchDown,
    )
    contentView.startButton.addTarget(
      self,
      action: #selector(primaryButtonReleased),
      for: .touchDragExit,
    )
    contentView.startButton.addTarget(
      self,
      action: #selector(primaryButtonReleased),
      for: .touchCancel,
    )
    contentView.startButton.addTarget(
      self,
      action: #selector(primaryButtonReleased),
      for: .touchUpInside,
    )
  }

  @objc
  private func primaryButtonPressed() {
    contentView.setPrimaryButtonPressed(true)
  }

  @objc
  private func primaryButtonReleased() {
    contentView.setPrimaryButtonPressed(false)
  }

  @objc
  private func startTapped() {
    contentView.animatePrimaryButtonTap()

    let viewController = DeviceTestAlphaViewController()
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - MainView

final class MainView: UIView {

  // MARK: Nested Types

  private enum Layout {
    static let horizontalInset: CGFloat = 24
    static let contentTopInset: CGFloat = 40
    static let contentBottomInset: CGFloat = 32
    static let heroMaxWidth: CGFloat = 280
    static let heroMinWidth: CGFloat = 200
    static let heroAspectRatio: CGFloat = 0.78
    static let buttonHeight: CGFloat = 44
    static let buttonCornerRadius: CGFloat = 18
  }

  private enum Animation {
    static let short: TimeInterval = 0.12
    static let medium: TimeInterval = 0.22
    static let long: TimeInterval = 0.5
  }

  // MARK: Properties

  let startButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Let’s Start", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 26, bottom: 10, right: 26)
    button.layer.cornerRadius = Layout.buttonCornerRadius
    button.clipsToBounds = true
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let heroImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()

  private let headlineLabel: UILabel = {
    let label = UILabel()
    label.text = "Get Started on"
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    return label
  }()

  private let brandLabel: UILabel = {
    let label = UILabel()
    label.text = "MoneyMate"
    label.font = .systemFont(ofSize: 28, weight: .semibold)
    label.textAlignment = .center
    return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "Organizing Finance, Creating Balance — Plan Your Financial Future Wisely"
    label.font = .systemFont(ofSize: 12, weight: .regular)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()

  private lazy var textStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [headlineLabel, brandLabel, subtitleLabel])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 6
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private lazy var contentStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [heroImageView, textStack, startButton])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 20
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private var hasAnimatedIn = false
  private var primaryColor = UIColor.systemGreen
  private var buttonTextColor = UIColor.black

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    layoutMargins = UIEdgeInsets(
      top: Layout.contentTopInset,
      left: Layout.horizontalInset,
      bottom: Layout.contentBottomInset,
      right: Layout.horizontalInset,
    )

    applyColors()
    configureHeroImage()
    setupViewHierarchy()
    setupConstraints()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Functions

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    if
      #available(iOS 13.0, *),
      previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle
    {
      applyColors()
    }
  }

  func setPrimaryButtonPressed(_ pressed: Bool) {
    let transform = pressed ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity

    UIView.animate(withDuration: Animation.short) {
      self.startButton.transform = transform
    }
  }

  func animatePrimaryButtonTap() {
    UIView.animate(
      withDuration: Animation.short,
      animations: {
        self.startButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
      },
      completion: { _ in
        UIView.animate(withDuration: Animation.short) {
          self.startButton.transform = .identity
        }
      },
    )
  }

  func animateInIfNeeded() {
    guard !hasAnimatedIn else { return }
    hasAnimatedIn = true

    let elements = [heroImageView, textStack, startButton]
    for element in elements {
      element.alpha = 0
      element.transform = CGAffineTransform(translationX: 0, y: 12)
    }

    UIView.animate(
      withDuration: Animation.long,
      delay: 0,
      options: [.curveEaseOut],
      animations: {
        for element in elements {
          element.alpha = 1
          element.transform = .identity
        }
      },
    )
  }

  private func setupViewHierarchy() {
    addSubview(contentStack)
  }

  private func setupConstraints() {
    let margins = layoutMarginsGuide

    NSLayoutConstraint.activate([
      contentStack.topAnchor.constraint(equalTo: margins.topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
      contentStack.bottomAnchor.constraint(lessThanOrEqualTo: margins.bottomAnchor),

      heroImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.heroMaxWidth),
      heroImageView.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.heroMinWidth),
      heroImageView.widthAnchor.constraint(lessThanOrEqualTo: margins.widthAnchor),
      heroImageView.heightAnchor.constraint(
        equalTo: heroImageView.widthAnchor,
        multiplier: Layout.heroAspectRatio,
      ),

      startButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),

      subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: margins.widthAnchor),
    ])

    contentStack.setCustomSpacing(24, after: heroImageView)
    contentStack.setCustomSpacing(26, after: textStack)
  }

  private func configureHeroImage() {
    if let hero = UIImage(named: "MoneyMateHero") {
      heroImageView.image = hero
      heroImageView.tintColor = nil
      heroImageView.backgroundColor = .clear
      heroImageView.layer.cornerRadius = 0
    } else if #available(iOS 13.0, *) {
      heroImageView.image = UIImage(systemName: "chart.pie.fill")?.withRenderingMode(
        .alwaysTemplate)
      heroImageView.tintColor = primaryColor
      heroImageView.backgroundColor = .clear
      heroImageView.layer.cornerRadius = 0
    } else {
      heroImageView.image = nil
      heroImageView.tintColor = nil
      heroImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
      heroImageView.layer.cornerRadius = 16
      heroImageView.layer.masksToBounds = true
    }
  }

  private func applyColors() {
    if #available(iOS 13.0, *) {
      backgroundColor = .systemBackground
      primaryColor = UIColor(red: 0.44, green: 0.74, blue: 0.45, alpha: 1)
      headlineLabel.textColor = .secondaryLabel
      subtitleLabel.textColor = .secondaryLabel
      brandLabel.textColor = primaryColor
      buttonTextColor = UIColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1)
    } else {
      backgroundColor = .white
      primaryColor = UIColor(red: 0.42, green: 0.7, blue: 0.4, alpha: 1)
      headlineLabel.textColor = .darkGray
      subtitleLabel.textColor = .gray
      brandLabel.textColor = primaryColor
      buttonTextColor = .black
    }

    startButton.backgroundColor = primaryColor.withAlphaComponent(0.35)
    startButton.setTitleColor(buttonTextColor, for: .normal)
    configureHeroImage()
  }

}
