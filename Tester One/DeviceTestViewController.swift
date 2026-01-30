//
//  DeviceTestViewController.swift
//  Tester One
//
//  Created by ENB Mac Mini on 30/01/26.
//

import UIKit

final class DeviceTestViewController: UIViewController {
    private let contentView = DeviceTestView()

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Device Test"
        contentView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

final class DeviceTestView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Device Test Screen"
        label.font = .preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        return label
    }()

    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back to Main", for: .normal)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, backButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
