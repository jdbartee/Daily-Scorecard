//
//  AboutViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {

    var serviceProvider: ServiceProvider?

    var appName: String {
        return serviceProvider?.appDetails.appName ?? ""
    }

    var appVersion: String {
        return serviceProvider?.appDetails.appVersion ?? ""
    }

    var copyright: String {
        return serviceProvider?.appDetails.copyright ?? ""
    }
    
    private lazy var cardView: UIView = {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        cardView.layer.cornerRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(self.layoutStack)
        self.layoutStack.translatesAutoresizingMaskIntoConstraints = false

        self.layoutStack.addArrangedSubview(self.titleFrame)
        self.layoutStack.addArrangedSubview(self.copyrightFrame)

        return cardView
    }()

    private lazy var layoutStack: UIStackView = {
        let layoutStack = UIStackView()
        layoutStack.axis = .vertical
        layoutStack.alignment = .fill
        layoutStack.distribution = .fillEqually
        return layoutStack
    }()

    private lazy var titleFrame: UIView = {
        let titleFrame = UIView()

        titleFrame.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false

        return titleFrame
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        return titleLabel
    }()

    private lazy var copyrightFrame: UIView = {
        let copyrightFrame = UIView()

        copyrightFrame.addSubview(self.copyrightLabel)
        self.copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        return copyrightFrame
    }()

    lazy var copyrightLabel: UILabel = {
        let copyrightLabel = UILabel()
        copyrightLabel.textAlignment = .center
        copyrightLabel.adjustsFontForContentSizeCategory = true
        copyrightLabel.font = .preferredFont(forTextStyle: .subheadline)
        return copyrightLabel
    }()

    lazy var layoutConstraints: [NSLayoutConstraint] = {
        return [
            self.cardView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            self.cardView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            self.cardView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            self.cardView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            self.layoutStack.topAnchor.constraint(equalTo: cardView.layoutMarginsGuide.topAnchor),
            self.layoutStack.bottomAnchor.constraint(equalTo: cardView.layoutMarginsGuide.bottomAnchor),
            self.layoutStack.leadingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.leadingAnchor),
            self.layoutStack.trailingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.trailingAnchor),

            self.titleLabel.centerYAnchor.constraint(equalTo: titleFrame.centerYAnchor),
            self.titleLabel.centerXAnchor.constraint(equalTo: titleFrame.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: titleFrame.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: titleFrame.trailingAnchor),

            self.copyrightLabel.bottomAnchor.constraint(equalTo: copyrightFrame.bottomAnchor),
            self.copyrightLabel.leadingAnchor.constraint(equalTo: copyrightFrame.leadingAnchor),
            self.copyrightLabel.trailingAnchor.constraint(equalTo: copyrightFrame.trailingAnchor),
        ]
    }()

    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = "\(appName) - \(appVersion)"
        self.copyrightLabel.text = copyright
    }

    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate(layoutConstraints)
    }

    override func loadView() {
        self.view = UIView()
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(cardView)
    }
}
