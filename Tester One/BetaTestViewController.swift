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

    struct ProcessResult {
        let index: Int
        let title: String
        let state: BetaTestCardState
    }

    typealias StateResolver = (_ index: Int, _ title: String) -> BetaTestCardState

    /// Duration for simulated process transition from loading -> final state.
    var processDuration: TimeInterval = 1.2

    /// Custom resolver for final item state after loading. Defaults to internal resolver when nil.
    var stateResolver: StateResolver?

    /// Callback invoked after all items finish processing.
    var onProcessCompleted: (([ProcessResult]) -> Void)?

    /// Optional callback invoked when continue button is tapped.
    var onContinueButtonTapped: (() -> Void)?

    /// Optional callback invoked when retry is tapped for a failed card.
    var onRetryButtonTapped: ((_ index: Int, _ title: String) -> Void)?

    /// Optional callback invoked when a single retry completes.
    var onRetryCompleted: ((ProcessResult) -> Void)?

    /// Customize continue button title.
    var continueButtonTitle = "Lanjut" {
        didSet {
            continueButton.setTitle(continueButtonTitle, for: .normal)
        }
    }

    /// Starts loading -> result transition for all cards.
    func beginProcessing() {
        guard !isProcessing else { return }
        isProcessing = true
        updateAllItemStates(.loading)

        DispatchQueue.main.asyncAfter(deadline: .now() + processDuration) { [weak self] in
            guard let self else { return }
            var results = [ProcessResult]()

            for index in items.indices {
                let title = items[index].title
                let resolvedState = stateResolver?(index, title) ?? defaultFinalState(for: index, title: title)
                items[index].state = resolvedState
                results.append(ProcessResult(index: index, title: title, state: resolvedState))
            }

            isProcessing = false
            collectionView.reloadData()
            onProcessCompleted?(results)
        }
    }

    /// Manually set a single card state (useful for external action chains).
    func setState(_ state: BetaTestCardState, at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].state = state
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    /// Manually set all card states.
    func setAllStates(_ state: BetaTestCardState) {
        updateAllItemStates(state)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewHierarchy()
        setupConstraints()
        updateCollectionLayoutIfNeeded()
        continueButton.setTitle(continueButtonTitle, for: .normal)
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

    private var items = BetaTestViewController.defaultItems()
    private var isProcessing = false
    private var retryingIndices = Set<Int>()

    private var lastCollectionWidth: CGFloat = 0

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = .zero
        layout.sectionInset = UIEdgeInsets(
            top: Layout.gridTopInset,
            left: Layout.gridHorizontalInset,
            bottom: Layout.gridBottomInset,
            right: Layout.gridHorizontalInset
        )
        layout.minimumInteritemSpacing = Layout.gridInterItemSpacing
        layout.minimumLineSpacing = Layout.gridLineSpacing
        return layout
    }()

    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = Layout.contentTopCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.accessibilityIdentifier = "BetaTestViewController.contentContainerView"
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.delaysContentTouches = false
        view.dataSource = self
        view.delegate = self
        view.accessibilityIdentifier = "BetaTestViewController.collectionView"
        view.register(BetaTestCollectionViewCell.self, forCellWithReuseIdentifier: BetaTestCollectionViewCell.reuseIdentifier)
        return view
    }()

    private lazy var bottomOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.clipsToBounds = false
        view.accessibilityIdentifier = "BetaTestViewController.bottomSectionView"
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
        button.layer.masksToBounds = true
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(handleContinueTap), for: .touchUpInside)
        button.accessibilityIdentifier = "BetaTestViewController.continueButton"
        return button
    }()

    private lazy var continueButtonShadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 9
        view.layer.shadowOffset = .zero
        view.accessibilityIdentifier = "BetaTestViewController.continueButtonShadowView"
        return view
    }()

    private func setupViewHierarchy() {
        view.backgroundColor = .fonezyHeaderGreen
        view.accessibilityIdentifier = "BetaTestViewController.view"

        view.addSubview(contentContainerView)
        contentContainerView.addSubview(collectionView)
        contentContainerView.addSubview(bottomOverlayView)

        bottomOverlayView.addSubview(continueButtonShadowView)
        continueButtonShadowView.addSubview(continueButton)
    }

    private func setupNavigationBar() {
        title = "Cek Fungsi"
        navigationItem.largeTitleDisplayMode = .never

        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.accessibilityIdentifier = "BetaTestViewController.navigationBar"
        navigationBar.prefersLargeTitles = false
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

            continueButtonShadowView.leadingAnchor.constraint(
                equalTo: bottomOverlayView.leadingAnchor,
                constant: Layout.buttonHorizontalInset
            ),
            continueButtonShadowView.trailingAnchor.constraint(
                equalTo: bottomOverlayView.trailingAnchor,
                constant: -Layout.buttonHorizontalInset
            ),
            continueButtonShadowView.topAnchor.constraint(equalTo: bottomOverlayView.topAnchor, constant: Layout.bottomSectionTopInset),
            continueButtonShadowView.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            continueButtonShadowView.bottomAnchor.constraint(
                equalTo: bottomOverlayView.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.bottomSectionBottomInset
            ),

            continueButton.leadingAnchor.constraint(equalTo: continueButtonShadowView.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: continueButtonShadowView.trailingAnchor),
            continueButton.topAnchor.constraint(equalTo: continueButtonShadowView.topAnchor),
            continueButton.bottomAnchor.constraint(equalTo: continueButtonShadowView.bottomAnchor),
        ])
    }

    private func updateCollectionLayoutIfNeeded() {
        let collectionWidth = collectionView.bounds.width
        guard collectionWidth > 0 else { return }
        guard abs(collectionWidth - lastCollectionWidth) > 0.5 else { return }
        lastCollectionWidth = collectionWidth

        collectionView.collectionViewLayout.invalidateLayout()
    }

    @objc
    private func handleContinueTap() {
        onContinueButtonTapped?()
        beginProcessing()
    }

    private func updateAllItemStates(_ state: BetaTestCardState) {
        for index in items.indices {
            items[index].state = state
        }
        collectionView.reloadData()
    }

    private func handleRetryTap(at index: Int) {
        guard items.indices.contains(index) else { return }
        guard items[index].state == .failed else { return }
        guard !retryingIndices.contains(index) else { return }

        let title = items[index].title
        onRetryButtonTapped?(index, title)

        retryingIndices.insert(index)
        items[index].state = .loading
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])

        DispatchQueue.main.asyncAfter(deadline: .now() + processDuration) { [weak self] in
            guard let self else { return }
            guard items.indices.contains(index) else { return }

            let resolvedState = stateResolver?(index, title) ?? defaultFinalState(for: index, title: title)
            items[index].state = resolvedState
            retryingIndices.remove(index)
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])

            onRetryCompleted?(ProcessResult(index: index, title: title, state: resolvedState))
        }
    }

    private func defaultFinalState(for index: Int, title: String) -> BetaTestCardState {
        if title == "Tombol Silent" {
            return .failed
        }
        return index == 6 ? .failed : .success
    }

    private static func defaultItems() -> [BetaTestItem] {
        [
            BetaTestItem(title: "CPU", icon: .cpu, state: .initial),
            BetaTestItem(title: "Hard Disk", icon: .hardDisk, state: .initial),
            BetaTestItem(title: "Kondisi Baterai", icon: .battery, state: .initial),
            BetaTestItem(title: "Tes Jailbreak", icon: .jailbreak, state: .initial),
            BetaTestItem(title: "Tes Biometric 1", icon: .biometricOne, state: .initial),
            BetaTestItem(title: "Tes Biometric 2", icon: .biometricTwo, state: .initial),
            BetaTestItem(title: "Tombol Silent", icon: .silent, state: .initial),
            BetaTestItem(title: "Tombol Volume", icon: .volume, state: .initial),
            BetaTestItem(title: "Tombol On/Off", icon: .power, state: .initial),
            BetaTestItem(title: "Tes Kamera", icon: .camera, state: .initial),
            BetaTestItem(title: "Tes Layar Sentuh", icon: .touch, state: .initial),
            BetaTestItem(title: "Tes Kartu SIM", icon: .sim, state: .initial),
        ]
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
            for: indexPath
        )

        guard let betaCell = cell as? BetaTestCollectionViewCell else {
            return cell
        }

        betaCell.configure(with: items[indexPath.item])
        betaCell.onRetryTapped = { [weak self, weak betaCell, weak collectionView] in
            guard let self, let betaCell, let collectionView else { return }
            guard let resolvedIndexPath = collectionView.indexPath(for: betaCell) else { return }
            self.handleRetryTap(at: resolvedIndexPath.item)
        }
        return betaCell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BetaTestViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        let sectionInsets = collectionLayout.sectionInset
        let horizontalInsets = sectionInsets.left + sectionInsets.right
        let totalSpacing = Layout.gridInterItemSpacing
        let availableWidth = collectionView.bounds.width - horizontalInsets - totalSpacing
        let itemWidth = floor(availableWidth / 2.0)
        let itemHeight = floor(itemWidth * Layout.cardAspectRatio)
        return CGSize(width: itemWidth, height: itemHeight)
    }
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
    var state: BetaTestCardState
}

// MARK: - BetaTestCardState

enum BetaTestCardState {
    case initial
    case loading
    case success
    case failed
}

// MARK: - BetaTestCollectionViewCell

private final class BetaTestCollectionViewCell: UICollectionViewCell {
    // MARK: Internal

    static let reuseIdentifier = "BetaTestCollectionViewCell"
    var onRetryTapped: (() -> Void)?

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
        loadingIndicator.stopAnimating()
        onRetryTapped = nil
    }

    func configure(with item: BetaTestItem) {
        let token = Self.accessibilityToken(for: item.title)
        accessibilityIdentifier = "BetaTestCell.\(token)"
        contentView.accessibilityIdentifier = "BetaTestCell.\(token).contentView"
        cardView.accessibilityIdentifier = "BetaTestCell.\(token).cardView"
        iconCircleView.accessibilityIdentifier = "BetaTestCell.\(token).iconCircleView"
        iconImageView.accessibilityIdentifier = "BetaTestCell.\(token).iconImageView"
        statusImageView.accessibilityIdentifier = "BetaTestCell.\(token).statusImageView"
        loadingIndicator.accessibilityIdentifier = "BetaTestCell.\(token).loadingIndicator"
        retryBadgeButton.accessibilityIdentifier = "BetaTestCell.\(token).retryButton"
        titleLabel.accessibilityIdentifier = "BetaTestCell.\(token).titleLabel"

        titleLabel.text = item.title

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

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.fonezyDisabledIcon
        return indicator
    }()

    private lazy var retryBadgeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Ulangi", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.92)
        button.layer.cornerRadius = Layout.retryHeight / 2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.fonezyDarkGray.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleRetryButtonTap), for: .touchUpInside)
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
                renderingMode: .alwaysOriginal
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
        cardView.addSubview(loadingIndicator)
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

            loadingIndicator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
            loadingIndicator.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: Layout.statusSize),
            loadingIndicator.heightAnchor.constraint(equalToConstant: Layout.statusSize),

            retryBadgeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
            retryBadgeButton.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
            retryBadgeButton.heightAnchor.constraint(equalToConstant: Layout.retryHeight),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Layout.contentInset),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Layout.contentInset),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: iconCircleView.bottomAnchor, constant: Layout.topRowSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
        ])
    }

    @objc
    private func handleRetryButtonTap() {
        onRetryTapped?()
    }

    private func applyState(_ state: BetaTestCardState) {
        retryBadgeButton.isHidden = true
        statusImageView.isHidden = true
        loadingIndicator.stopAnimating()
        titleLabel.textColor = .black

        switch state {
        case .initial:
            // Initial state is neutral grey (not success-green).
            cardView.backgroundColor = UIColor.fonezyInitialCard
            cardView.layer.borderWidth = 0
            iconCircleView.backgroundColor = UIColor.fonezyDisabledCircle

        case .loading:
            // Loading should keep initial styling while showing activity on status position.
            cardView.backgroundColor = UIColor.fonezyDisabledCard
            cardView.layer.borderWidth = 0
            iconCircleView.backgroundColor = UIColor.fonezyDisabledCircle
            loadingIndicator.color = UIColor.fonezyDisabledIcon
            loadingIndicator.startAnimating()

        case .success:
            cardView.backgroundColor = .white
            cardView.layer.borderColor = UIColor.fonezySapGreen.cgColor
            cardView.layer.borderWidth = 1
            iconCircleView.backgroundColor = UIColor.fonezySuccessCircle

            statusImageView.isHidden = false
            statusImageView.image = Self.successStatusImage()

        case .failed:
            cardView.backgroundColor = .white
            cardView.layer.borderColor = UIColor.fonezyErrorRed.cgColor
            cardView.layer.borderWidth = 1
            iconCircleView.backgroundColor = UIColor.fonezyErrorCircle

            retryBadgeButton.isHidden = false
        }
    }

    private func applyIcon(for icon: BetaTestItem.IconType, state: BetaTestCardState) {
        let tintColor =
            switch state {
            case .failed:
                UIColor.fonezyErrorRed
            case .initial, .loading:
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

    private static func accessibilityToken(for title: String) -> String {
        let normalized = String(title.lowercased().map { character in
            character.isLetter || character.isNumber ? character : "_"
        })
        let collapsed = normalized.replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
        return collapsed.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
}

private extension UIColor {
    static let fonezyHeaderGreen = UIColor(red: 54.0 / 255.0, green: 132.0 / 255.0, blue: 3.0 / 255.0, alpha: 1)
    static let fonezySapGreen = UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 28.0 / 255.0, alpha: 1)
    static let fonezyLabelGreen = UIColor(red: 54.0 / 255.0, green: 132.0 / 255.0, blue: 3.0 / 255.0, alpha: 1)
    static let fonezyStatusGreen = UIColor(red: 76.0 / 255.0, green: 153.0 / 255.0, blue: 31.0 / 255.0, alpha: 1)
    static let fonezyErrorRed = UIColor(red: 194.0 / 255.0, green: 50.0 / 255.0, blue: 0, alpha: 1)
    static let fonezyDarkGray = UIColor(red: 53.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1)
    static let fonezyLightGray = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
    static let fonezyInitialCard = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1) // #F4F4F4
    static let fonezyDisabledCard = UIColor(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 244.0 / 255.0, alpha: 1)
    static let fonezyDisabledCircle = UIColor(red: 214.0 / 255.0, green: 214.0 / 255.0, blue: 214.0 / 255.0, alpha: 1)
    static let fonezyDisabledIcon = UIColor(red: 80.0 / 255.0, green: 80.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
    static let fonezySuccessCircle = UIColor(red: 218.0 / 255.0, green: 229.0 / 255.0, blue: 212.0 / 255.0, alpha: 1)
    static let fonezyErrorCircle = UIColor(red: 234.0 / 255.0, green: 213.0 / 255.0, blue: 213.0 / 255.0, alpha: 1)
}
