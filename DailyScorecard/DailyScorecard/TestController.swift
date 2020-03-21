//
//  TestController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/21/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class TestController: UIViewController {

    lazy var optionView: OptionSelectionView = {
        let optionView = OptionSelectionView()
        optionView.translatesAutoresizingMaskIntoConstraints = false
        optionView.setOptions(options: ["A", "B", "CC", "D", "E", "F", "g"])
        optionView.selectedOptionIndex = 0

        return optionView
    }()

    private lazy var promptView: UIView = {
        let prompt = UILabel()
        prompt.text = "This is a testing view"
        prompt.translatesAutoresizingMaskIntoConstraints = false
        return prompt
    }()

    private lazy var scoreFrame: UIView = {
        let view = UIView()
        view.addSubview(optionView)

        NSLayoutConstraint.activate([
            optionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            optionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            optionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            optionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        return view
    }()

    private lazy var cardView: UIView = {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 8
        cardView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)


        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8


        stackView.addArrangedSubview(promptView)
        stackView.addArrangedSubview(scoreFrame)

        cardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cardView.layoutMarginsGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cardView.layoutMarginsGuide.trailingAnchor),
        ])
        return cardView
    }()

    override func viewDidLoad() {

        self.view.addSubview(self.cardView)
        self.view.backgroundColor = .systemBackground

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 500)
        ])
    }
}
