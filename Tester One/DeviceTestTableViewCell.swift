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
        selectionStyle = .none
        clipsToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        applyColors()
        configureShadow()
        setupViewHierarchy()
        setupConstraints()
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
        cellContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: cellContainerView.bounds,
            cornerRadius: cellContainerView.layer.cornerRadius
        ).cgPath
        firstStackView.layer.cornerRadius = max(cellContainerView.layer.cornerRadius - Layout.labelPadding, 0)
    }

    // MARK: Private

    private enum Constants {
        static let defaultTitle = "Alpha"
    }

    private enum Layout {
        static let outerPadding: CGFloat = 8
        static let innerPadding: CGFloat = 12
        static let labelPadding: CGFloat = 8
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
        view.layer.cornerRadius = 8
        view.clipsToBounds = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.defaultTitle
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var firstStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        stack.clipsToBounds = true
        return stack
    }()

    private func setupViewHierarchy() {
        contentView.addSubview(baseContainerView)
        baseContainerView.addSubview(cellContainerView)
        cellContainerView.addSubview(firstStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            baseContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.outerPadding),
            baseContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.outerPadding),
            baseContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.outerPadding),
            baseContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.outerPadding),

            cellContainerView.leadingAnchor.constraint(equalTo: baseContainerView.leadingAnchor),
            cellContainerView.trailingAnchor.constraint(equalTo: baseContainerView.trailingAnchor),
            cellContainerView.topAnchor.constraint(equalTo: baseContainerView.topAnchor),
            cellContainerView.bottomAnchor.constraint(equalTo: baseContainerView.bottomAnchor),

            firstStackView.leadingAnchor.constraint(equalTo: cellContainerView.leadingAnchor, constant: Layout.labelPadding),
            firstStackView.trailingAnchor.constraint(equalTo: cellContainerView.trailingAnchor, constant: -Layout.labelPadding),
            firstStackView.topAnchor.constraint(equalTo: cellContainerView.topAnchor, constant: Layout.labelPadding),
            firstStackView.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -Layout.labelPadding),
        ])
    }

    private func applyColors() {
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
}
