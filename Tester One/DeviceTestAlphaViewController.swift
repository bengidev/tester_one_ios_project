//
//  DeviceTestAlphaViewController.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import UIKit

enum TestStatus: Equatable {
  case pending
  case success
  case failed

  var accessibilityLabel: String {
    switch self {
    case .pending: return "Pending"
    case .success: return "Success"
    case .failed: return "Failed"
    }
  }
}

struct TestItem {
  let id = UUID()
  let title: String
  let iconName: String
  let fallbackIcon: String
  var status: TestStatus
}

final class DeviceTestAlphaViewController: UIViewController {

  private var testItems: [TestItem] = []
  private let cellReuseIdentifier = "TestItemCell"

  private var screenWidth: CGFloat {
    UIScreen.main.bounds.width
  }

  private var iconSize: CGFloat {
    screenWidth * 0.09
  }

  private var cardPadding: CGFloat {
    screenWidth * 0.04
  }

  private var statusIconSize: CGFloat {
    screenWidth * 0.055
  }

  private lazy var tableView: UITableView = {
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.backgroundColor = .clear
    table.separatorStyle = .none
    table.rowHeight = UITableView.automaticDimension
    table.estimatedRowHeight = 72
    table.delegate = self
    table.dataSource = self
    table.register(TestItemCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    return table
  }()

  private lazy var bottomButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Dalam Pengecekkan", for: .normal)
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    button.setTitleColor(.gray, for: .normal)
    button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    button.layer.cornerRadius = 8
    button.isEnabled = false

    // Inner padding (touch target + breathing room for the title)
    button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    return button
  }()

  /// Provides horizontal padding so the button doesn't hug the phone edges.
  private lazy var bottomButtonContainer: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .clear

    container.addSubview(bottomButton)

    NSLayoutConstraint.activate([
      bottomButton.leadingAnchor.constraint(
        equalTo: container.leadingAnchor, constant: cardPadding),
      bottomButton.trailingAnchor.constraint(
        equalTo: container.trailingAnchor, constant: -cardPadding),
      bottomButton.topAnchor.constraint(equalTo: container.topAnchor),
      bottomButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    return container
  }()

  private lazy var contentStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [tableView, bottomButtonContainer])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.backgroundColor = .red
    stack.spacing = 16
    stack.alignment = .fill
    stack.distribution = .fill
    return stack
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupMockData()
    configureTitle()
  }

  private func configureTitle() {
    title = "Cek Fungsi Software"

    let blueColor: UIColor = .systemBlue
    navigationController?.navigationBar.titleTextAttributes = [
      .foregroundColor: blueColor,
      .font: UIFont.preferredFont(forTextStyle: .headline),
    ]
  }

  private func setupUI() {
    view.backgroundColor = .white

    view.addSubview(contentStackView)

    NSLayoutConstraint.activate([
      contentStackView.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentStackView.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
    ])
  }

  private func setupMockData() {
    testItems = [
      TestItem(title: "CPU", iconName: "cpu", fallbackIcon: "⚙️", status: .pending),
      TestItem(title: "Hard Disk", iconName: "externaldrive", fallbackIcon: "💾", status: .pending),
      TestItem(
        title: "Kondisi Baterai", iconName: "battery.100", fallbackIcon: "🔋", status: .pending),
      TestItem(title: "Tombol Silent", iconName: "bell.slash", fallbackIcon: "🔕", status: .pending),
      TestItem(
        title: "Tombol Volume", iconName: "speaker.wave.2", fallbackIcon: "🔊", status: .pending),
      TestItem(title: "Tombol On/Off", iconName: "power", fallbackIcon: "⏻", status: .pending),
      TestItem(title: "Tes Kamera", iconName: "camera", fallbackIcon: "📷", status: .pending),
      TestItem(title: "Layar Sentuh", iconName: "hand.tap", fallbackIcon: "👆", status: .pending),
      TestItem(
        title: "Tes Bluetooth", iconName: "antenna.radiowaves.left.and.right", fallbackIcon: "📡",
        status: .pending),
    ]

    tableView.reloadData()

    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
      self?.finalizeInitialLoad()
    }
  }

  private func finalizeInitialLoad() {
    for i in 0..<testItems.count {
      testItems[i].status = i < 2 ? .success : .failed
    }
    tableView.reloadData()
  }

  @objc
  private func retryButtonTapped(_ sender: UIButton) {
    let index = sender.tag
    guard index < testItems.count else { return }

    testItems[index].status = .pending
    tableView.reloadData()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      guard let self = self else { return }
      self.testItems[index].status = Bool.random() ? .success : .failed
      self.tableView.reloadData()
    }
  }
}

extension DeviceTestAlphaViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return testItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        as? TestItemCell
    else {
      return UITableViewCell()
    }

    let item = testItems[indexPath.row]
    cell.configure(with: item)
    cell.retryButton.tag = indexPath.row
    cell.retryButton.addTarget(self, action: #selector(retryButtonTapped(_:)), for: .touchUpInside)

    return cell
  }
}

extension DeviceTestAlphaViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    if testItems[indexPath.row].status == .pending {
      testItems[indexPath.row].status = .success
      if let cell = tableView.cellForRow(at: indexPath) as? TestItemCell {
        cell.configure(with: testItems[indexPath.row])
      }
    }
  }
}

final class TestItemCell: UITableViewCell {

  private let iconContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .systemBlue
    view.layer.cornerRadius = 18
    view.clipsToBounds = true
    return view
  }()

  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.preferredFont(forTextStyle: .body)
    if #available(iOS 13.0, *) {
      label.textColor = .label
    } else {
      label.textColor = .black
    }
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    return label
  }()

  private let statusStackView: UIStackView = {
    let stack = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.spacing = 8
    stack.alignment = .center
    stack.distribution = .fill
    return stack
  }()

  private let statusImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .systemGreen
    return imageView
  }()

  private let retryContainerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false

    // Default transparent; we set an explicit color per-state in `configure(with:)`.
    view.backgroundColor = .clear
    view.layer.cornerRadius = 4
    return view
  }()

  let retryButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("ULANGI", for: .normal)
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
    button.setTitleColor(.white, for: .normal)
    return button
  }()

  private let failedImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .systemRed
    return imageView
  }()

  private lazy var loadingIndicator: UIActivityIndicatorView = {
    let style: UIActivityIndicatorView.Style
    if #available(iOS 13.0, *) {
      style = .medium
    } else {
      style = .gray
    }
    let indicator = UIActivityIndicatorView(style: style)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true

    // Grey spinner (visible on light backgrounds, no extra pill background needed).
    if #available(iOS 13.0, *) {
      indicator.color = .systemGray
    } else {
      indicator.color = .gray
    }

    return indicator
  }()

  private let cardView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    if #available(iOS 13.0, *) {
      view.backgroundColor = .systemBackground
    } else {
      view.backgroundColor = .white
    }
    view.layer.cornerRadius = 12
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
    view.layer.shadowRadius = 4
    view.layer.shadowOpacity = 0.1
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
    setupConstraints()
    backgroundColor = .clear
    selectionStyle = .none
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupViews() {
    contentView.addSubview(cardView)
    cardView.addSubview(iconContainerView)
    iconContainerView.addSubview(iconImageView)
    cardView.addSubview(titleLabel)
    cardView.addSubview(statusStackView)

    statusStackView.addArrangedSubview(retryContainerView)
    statusStackView.addArrangedSubview(failedImageView)
    statusStackView.addArrangedSubview(statusImageView)

    retryContainerView.addSubview(retryButton)
    retryContainerView.addSubview(loadingIndicator)
  }

  private func setupConstraints() {
    let iconSize: CGFloat = min(36, UIScreen.main.bounds.width * 0.09)
    let statusIconSize: CGFloat = min(22, UIScreen.main.bounds.width * 0.055)
    let padding: CGFloat = UIScreen.main.bounds.width * 0.032

    NSLayoutConstraint.activate([
      cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
      cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
      cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64),

      iconContainerView.leadingAnchor.constraint(
        equalTo: cardView.leadingAnchor, constant: padding),
      iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      iconContainerView.widthAnchor.constraint(equalToConstant: iconSize),
      iconContainerView.heightAnchor.constraint(equalToConstant: iconSize),

      iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
      iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
      iconImageView.widthAnchor.constraint(
        equalTo: iconContainerView.widthAnchor, multiplier: 0.55),
      iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),

      titleLabel.leadingAnchor.constraint(
        equalTo: iconContainerView.trailingAnchor, constant: padding),
      titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
      titleLabel.trailingAnchor.constraint(
        lessThanOrEqualTo: statusStackView.leadingAnchor, constant: -8),

      statusStackView.trailingAnchor.constraint(
        equalTo: cardView.trailingAnchor, constant: -padding),
      statusStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

      retryButton.leadingAnchor.constraint(equalTo: retryContainerView.leadingAnchor, constant: 8),
      retryButton.trailingAnchor.constraint(
        equalTo: retryContainerView.trailingAnchor, constant: -8),
      retryButton.topAnchor.constraint(equalTo: retryContainerView.topAnchor, constant: 4),
      retryButton.bottomAnchor.constraint(equalTo: retryContainerView.bottomAnchor, constant: -4),

      // Keep the container visible even when the button is hidden (pending state).
      retryContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: statusIconSize + 12),
      retryContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: statusIconSize + 12),

      failedImageView.widthAnchor.constraint(equalToConstant: statusIconSize),
      failedImageView.heightAnchor.constraint(equalToConstant: statusIconSize),

      statusImageView.widthAnchor.constraint(equalToConstant: statusIconSize),
      statusImageView.heightAnchor.constraint(equalToConstant: statusIconSize),

      loadingIndicator.centerXAnchor.constraint(equalTo: retryContainerView.centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: retryContainerView.centerYAnchor),
    ])
  }

  func configure(with item: TestItem) {
    titleLabel.text = item.title

    if #available(iOS 13.0, *) {
      let iconSize: CGFloat = 20
      let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
      iconImageView.image = UIImage(systemName: item.iconName, withConfiguration: config)
    } else {
      iconImageView.image = nil
    }

    switch item.status {
    case .pending:
      statusImageView.isHidden = true
      retryContainerView.isHidden = false
      failedImageView.isHidden = true
      retryButton.isHidden = true
      loadingIndicator.startAnimating()
      retryContainerView.backgroundColor = .clear

    case .success:
      statusImageView.isHidden = false
      retryContainerView.isHidden = true
      failedImageView.isHidden = true
      loadingIndicator.stopAnimating()

      if #available(iOS 13.0, *) {
        statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
      }
      statusImageView.tintColor = UIColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0)

    case .failed:
      statusImageView.isHidden = true
      retryContainerView.isHidden = false
      failedImageView.isHidden = false
      loadingIndicator.stopAnimating()
      retryButton.isHidden = false

      if #available(iOS 13.0, *) {
        failedImageView.image = UIImage(systemName: "xmark.circle.fill")
        failedImageView.tintColor = .systemRed
      } else {
        failedImageView.image = nil
        failedImageView.tintColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
      }
      retryContainerView.backgroundColor = UIColor(red: 0.4, green: 0.7, blue: 0.3, alpha: 1.0)
    }

    accessibilityLabel = "\(item.title), \(item.status.accessibilityLabel)"
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    retryButton.removeTarget(nil, action: nil, for: .allEvents)
  }
}
