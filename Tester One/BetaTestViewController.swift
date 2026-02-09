//
//  BetaTestViewController.swift
//  Tester One
//
//  Created by Codex on 09/02/26.
//

import UIKit

// MARK: - BetaTestViewController

/// Figma-driven function check screen using UIKit and Auto Layout (iOS 12+).
///
/// AppDelegate integration snippet (kept as docs only per request):
/// let rootViewController = BetaTestViewController()
/// let navigationController = UINavigationController(rootViewController: rootViewController)
/// window?.rootViewController = navigationController
final class BetaTestViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupViewHierarchy()
    setupConstraints()
    updateCollectionLayoutIfNeeded()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupNavigationBar()
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateCollectionLayoutIfNeeded()
  }

  // MARK: Private

  private enum Layout {
    static let contentTopCornerRadius: CGFloat = 30

    static let gridTopInset: CGFloat = 20
    static let gridHorizontalInset: CGFloat = 20
    static let gridBottomInset: CGFloat = 20
    static let gridInterItemSpacing: CGFloat = 12
    static let gridLineSpacing: CGFloat = 12
    static let cardAspectRatio: CGFloat = 102.0 / 160.0

    static let bottomSectionTopInset: CGFloat = 16
    static let bottomSectionBottomInset: CGFloat = 16
    static let buttonHorizontalInset: CGFloat = 20
    static let buttonHeight: CGFloat = 55
    static let buttonCornerRadius: CGFloat = 27.5
  }

  private let items: [BetaTestItem] = [
    BetaTestItem(title: "CPU", icon: .cpu, state: .success),
    BetaTestItem(title: "Hard Disk", icon: .hardDisk, state: .success),
    BetaTestItem(title: "Kondisi Baterai", icon: .battery, state: .success),
    BetaTestItem(title: "Tes Jailbreak", icon: .jailbreak, state: .success),
    BetaTestItem(title: "Tes Biometric 1", icon: .biometricOne, state: .success),
    BetaTestItem(title: "Tes Biometric 2", icon: .biometricTwo, state: .success),
    BetaTestItem(title: "Tombol Silent", icon: .silent, state: .failed),
    BetaTestItem(title: "Tombol Volume", icon: .volume, state: .success),
    BetaTestItem(title: "Tombol On/Off", icon: .power, state: .disabled),
    BetaTestItem(title: "Tes Kamera", icon: .camera, state: .disabled),
    BetaTestItem(title: "Tes Layar Sentuh", icon: .touch, state: .disabled),
    BetaTestItem(title: "Tes Kartu SIM", icon: .sim, state: .disabled),
  ]

  private var lastCollectionWidth: CGFloat = 0

  private lazy var collectionLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.sectionInset = UIEdgeInsets(
      top: Layout.gridTopInset,
      left: Layout.gridHorizontalInset,
      bottom: Layout.gridBottomInset,
      right: Layout.gridHorizontalInset,
    )
    layout.minimumInteritemSpacing = Layout.gridInterItemSpacing
    layout.minimumLineSpacing = Layout.gridLineSpacing
    return layout
  }()

  private lazy var contentContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .white
    view.layer.cornerRadius = Layout.contentTopCornerRadius
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.clipsToBounds = true
    return view
  }()

  private lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.fonezyLightGray
    view.alwaysBounceVertical = true
    view.showsVerticalScrollIndicator = false
    view.dataSource = self
    view.delegate = self
    view.register(BetaTestCollectionViewCell.self, forCellWithReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier)
    return view
  }()

  private lazy var bottomOverlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.fonezyLightGray
    view.clipsToBounds = true
    return view
  }()

  private lazy var continueButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Lanjut", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    button.backgroundColor = .fonezyHeaderGreen
    button.layer.cornerRadius = Layout.buttonCornerRadius
    button.clipsToBounds = true
    button.contentHorizontalAlignment = .center
    return button
  }()

  private func setupViewHierarchy() {
    view.backgroundColor = .fonezyHeaderGreen

    view.addSubview(contentContainerView)
    contentContainerView.addSubview(collectionView)
    contentContainerView.addSubview(bottomOverlayView)

    bottomOverlayView.addSubview(continueButton)
  }

  private func setupNavigationBar() {
    title = "Cek Fungsi"
    navigationItem.largeTitleDisplayMode = .never

    guard let navigationBar = navigationController?.navigationBar else { return }
    navigationBar.tintColor = .white
    navigationBar.barStyle = .black

    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = .fonezyHeaderGreen
      appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
      appearance.shadowColor = .clear
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
      navigationBar.compactAppearance = appearance
    } else {
      navigationBar.isTranslucent = false
      navigationBar.barTintColor = .fonezyHeaderGreen
      navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
      navigationBar.shadowImage = UIImage()
      navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      contentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      collectionView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: bottomOverlayView.topAnchor),

      bottomOverlayView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
      bottomOverlayView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
      bottomOverlayView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

      continueButton.leadingAnchor.constraint(equalTo: bottomOverlayView.leadingAnchor, constant: Layout.buttonHorizontalInset),
      continueButton.trailingAnchor.constraint(
        equalTo: bottomOverlayView.trailingAnchor,
        constant: -Layout.buttonHorizontalInset,
      ),
      continueButton.topAnchor.constraint(equalTo: bottomOverlayView.topAnchor, constant: Layout.bottomSectionTopInset),
      continueButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
      continueButton.bottomAnchor.constraint(
        equalTo: bottomOverlayView.safeAreaLayoutGuide.bottomAnchor,
        constant: -Layout.bottomSectionBottomInset,
      ),
    ])
  }

  private func updateCollectionLayoutIfNeeded() {
    let collectionWidth = collectionView.bounds.width
    guard collectionWidth > 0 else { return }
    guard abs(collectionWidth - lastCollectionWidth) > 0.5 else { return }
    lastCollectionWidth = collectionWidth

    let horizontalInsets = collectionLayout.sectionInset.left + collectionLayout.sectionInset.right
    let totalSpacing = Layout.gridInterItemSpacing
    let availableWidth = collectionWidth - horizontalInsets - totalSpacing
    let itemWidth = floor(availableWidth / 2.0)
    let itemHeight = floor(itemWidth * Layout.cardAspectRatio)
    let newSize = CGSize(width: itemWidth, height: itemHeight)

    if collectionLayout.itemSize != newSize {
      collectionLayout.itemSize = newSize
      collectionLayout.invalidateLayout()
    }
  }
}

// MARK: UICollectionViewDataSource

extension BetaTestViewController: UICollectionViewDataSource {

  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier,
      for: indexPath,
    )

    guard let betaCell = cell as? BetaTestCollectionViewCell else {
      return cell
    }

    betaCell.configure(with: items[indexPath.item])
    return betaCell
  }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BetaTestViewController: UICollectionViewDelegateFlowLayout {
  // Reserved for future interactions.
}

// MARK: - BetaTestItem

private struct BetaTestItem {
  enum IconType {
    case cpu
    case hardDisk
    case battery
    case jailbreak
    case biometricOne
    case biometricTwo
    case silent
    case volume
    case power
    case camera
    case touch
    case sim
  }

  let title: String
  let icon: IconType
  let state: BetaTestItemState
}

// MARK: - BetaTestItemState

private enum BetaTestItemState {
  case success
  case failed
  case disabled
}

// MARK: - BetaTestCollectionViewCell

private final class BetaTestCollectionViewCell: UICollectionViewCell {

  // MARK: Internal

  static let reuseIdentifier = "BetaTestCollectionViewCell"

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupCell()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    iconImageView.image = nil
    retryBadgeButton.isHidden = true
    statusImageView.isHidden = true
  }

  func configure(with item: BetaTestItem) {
    titleLabel.text = item.title
    titleLabel.textColor = UIColor(red: 54.0 / 255.0, green: 54.0 / 255.0, blue: 54.0 / 255.0, alpha: 1)

    applyState(item.state)
    applyIcon(for: item.icon, state: item.state)
  }

  // MARK: Private

  private enum Layout {
    static let cornerRadius: CGFloat = 20
    static let cardInset: CGFloat = 0
    static let contentInset: CGFloat = 15
    static let iconCircleSize: CGFloat = 40
    static let iconSize: CGFloat = 22
    static let statusSize: CGFloat = 24
    static let topRowSpacing: CGFloat = 10
    static let retryHeight: CGFloat = 26
  }

  private lazy var cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.cornerRadius
    view.layer.borderWidth = 1
    view.clipsToBounds = true
    return view
  }()

  private lazy var iconCircleView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = Layout.iconCircleSize / 2
    return view
  }()

  private lazy var iconImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()

  private lazy var statusImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()

  private lazy var retryBadgeButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Ulangi", for: .normal)
    button.setTitleColor(.fonezyDarkGray, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    button.backgroundColor = UIColor(white: 1.0, alpha: 0.92)
    button.layer.cornerRadius = Layout.retryHeight / 2
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.fonezyDarkGray.cgColor
    button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
    button.isUserInteractionEnabled = false
    button.isHidden = true
    return button
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.numberOfLines = 2
    label.lineBreakMode = .byWordWrapping
    label.setContentCompressionResistancePriority(.required, for: .vertical)
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return label
  }()

  private static func successStatusImage() -> UIImage? {
    if let image = UIImage(named: "successImage") {
      return image.withRenderingMode(.alwaysOriginal)
    }

    if #available(iOS 13.0, *) {
      return UIImage(systemName: "checkmark.circle.fill")?.withTintColor(
        UIColor.fonezyStatusGreen,
        renderingMode: .alwaysOriginal,
      )
    }

    return nil
  }

  private func setupCell() {
    contentView.backgroundColor = .clear
    backgroundColor = .clear

    contentView.addSubview(cardView)
    cardView.addSubview(iconCircleView)
    iconCircleView.addSubview(iconImageView)
    cardView.addSubview(statusImageView)
    cardView.addSubview(retryBadgeButton)
    cardView.addSubview(titleLabel)

    NSLayoutConstraint.activate([
      cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.cardInset),
      cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.cardInset),
      cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.cardInset),
      cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.cardInset),

      iconCircleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.contentInset),
      iconCircleView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: Layout.contentInset),
      iconCircleView.widthAnchor.constraint(equalToConstant: Layout.iconCircleSize),
      iconCircleView.heightAnchor.constraint(equalToConstant: Layout.iconCircleSize),

      iconImageView.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
      iconImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
      iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),

      statusImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      statusImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      statusImageView.widthAnchor.constraint(equalToConstant: Layout.statusSize),
      statusImageView.heightAnchor.constraint(equalToConstant: Layout.statusSize),

      retryBadgeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      retryBadgeButton.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
      retryBadgeButton.heightAnchor.constraint(equalToConstant: Layout.retryHeight),

      titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.contentInset),
      titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
      titleLabel.topAnchor.constraint(greaterThanOrEqualTo: iconCircleView.bottomAnchor, constant: Layout.topRowSpacing),
      titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
    ])
  }

  private func applyState(_ state: BetaTestItemState) {
    switch state {
    case .success:
      cardView.backgroundColor = .white
      cardView.layer.borderColor = UIColor.fonezySapGreen.cgColor
      cardView.layer.borderWidth = 1
      iconCircleView.backgroundColor = UIColor.fonezySuccessCircle

      retryBadgeButton.isHidden = true
      statusImageView.isHidden = false
      statusImageView.image = Self.successStatusImage()

    case .failed:
      cardView.backgroundColor = .white
      cardView.layer.borderColor = UIColor.fonezyErrorRed.cgColor
      cardView.layer.borderWidth = 1
      iconCircleView.backgroundColor = UIColor.fonezyErrorCircle

      statusImageView.isHidden = true
      retryBadgeButton.isHidden = false

    case .disabled:
      cardView.backgroundColor = UIColor.fonezyDisabledCard
      cardView.layer.borderWidth = 0
      iconCircleView.backgroundColor = UIColor.fonezyDisabledCircle

      retryBadgeButton.isHidden = true
      statusImageView.isHidden = true
    }
  }

  private func applyIcon(for icon: BetaTestItem.IconType, state: BetaTestItemState) {
    if icon == .cpu, let cpu = UIImage(named: "cpuImage") {
      iconImageView.image = cpu.withRenderingMode(.alwaysOriginal)
      return
    }

    let tintColor =
      switch state {
      case .failed:
        UIColor.fonezyErrorRed
      case .disabled:
        UIColor.fonezyDisabledIcon
      case .success:
        UIColor.fonezySapGreen
      }

    if #available(iOS 13.0, *), let symbolImage = UIImage(systemName: systemSymbolName(for: icon)) {
      iconImageView.tintColor = tintColor
      iconImageView.image = symbolImage.withRenderingMode(.alwaysTemplate)
      return
    }

    // iOS 12 fallback: reuse provided assets first before any custom drawing.
    if let fallbackImage = UIImage(named: "cpuImage") {
      iconImageView.tintColor = tintColor
      iconImageView.image = fallbackImage.withRenderingMode(.alwaysTemplate)
    } else if let fallbackImage = UIImage(named: "failedImage") {
      iconImageView.tintColor = tintColor
      iconImageView.image = fallbackImage.withRenderingMode(.alwaysTemplate)
    } else {
      iconImageView.image = nil
    }
  }

  private func systemSymbolName(for icon: BetaTestItem.IconType) -> String {
    switch icon {
    case .cpu:
      "cpu"
    case .hardDisk:
      "externaldrive"
    case .battery:
      "battery.100"
    case .jailbreak:
      "key"
    case .biometricOne:
      "faceid"
    case .biometricTwo:
      "touchid"
    case .silent:
      "bell.slash"
    case .volume:
      "speaker.wave.2.fill"
    case .power:
      "power"
    case .camera:
      "camera"
    case .touch:
      "hand.point.up.left.fill"
    case .sim:
      "simcard"
    }
  }

}

extension UIColor {
  fileprivate static let fonezyHeaderGreen = UIColor(red: 54.0 / 255.0, green: 132.0 / 255.0, blue: 3.0 / 255.0, alpha: 1)
  fileprivate static let fonezySapGreen = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 28.0 / 255.0, alpha: 1)
  fileprivate static let fonezyStatusGreen = UIColor(red: 76.0 / 255.0, green: 153.0 / 255.0, blue: 31.0 / 255.0, alpha: 1)
  fileprivate static let fonezyErrorRed = UIColor(red: 194.0 / 255.0, green: 50.0 / 255.0, blue: 0, alpha: 1)
  fileprivate static let fonezyDarkGray = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1)
  fileprivate static let fonezyLightGray = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
  fileprivate static let fonezyDisabledCard = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
  fileprivate static let fonezyDisabledCircle = UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1)
  fileprivate static let fonezyDisabledIcon = UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
  fileprivate static let fonezySuccessCircle = UIColor(red: 218.0 / 255.0, green: 229.0 / 255.0, blue: 212.0 / 255.0, alpha: 1)
  fileprivate static let fonezyErrorCircle = UIColor(red: 234.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1)
}
