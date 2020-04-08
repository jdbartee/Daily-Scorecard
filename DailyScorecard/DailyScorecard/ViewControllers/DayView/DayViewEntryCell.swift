//
//  DayViewEntryTableViewCell.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/16/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class DayViewEntryCell: UITableViewCell {

    private class ScoreTapRecognizer: UITapGestureRecognizer {
        var score: Score? = nil
    }

    private var scores = [Score]()
    private var score: Score? {
        return nil
    }
    var scoreValueChanged: ((Score?) -> Void)?

    private lazy var promptView: UILabel = {
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.adjustsFontForContentSizeCategory = true
        labelView.font = .preferredFont(forTextStyle: .body)
        return labelView
    }()

    private lazy var scoreFrame: UIView = {
        let scoreFrame = UIView()
        scoreFrame.translatesAutoresizingMaskIntoConstraints = false
        scoreFrame.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        scoreFrame.addSubview(self.scoreSelectionView)

        NSLayoutConstraint.activate([
            self.scoreSelectionView.topAnchor.constraint(equalTo: scoreFrame.layoutMarginsGuide.topAnchor),
            self.scoreSelectionView.bottomAnchor.constraint(equalTo: scoreFrame.layoutMarginsGuide.bottomAnchor),
            self.scoreSelectionView.leadingAnchor.constraint(greaterThanOrEqualTo: scoreFrame.layoutMarginsGuide.leadingAnchor),
            self.scoreSelectionView.trailingAnchor.constraint(equalTo: scoreFrame.layoutMarginsGuide.trailingAnchor),
        ])

        return scoreFrame
    }()

    private lazy var scoreSelectionView: OptionSelectionView = {
        let scoreStackView = OptionSelectionView()
        scoreStackView.translatesAutoresizingMaskIntoConstraints = false
        scoreStackView.selectedOptionIndexDidChange = self.scoreIndexChanged(idx:)
        scoreStackView.spacing = 12
        return scoreStackView
    }()

    private func scoreIndexChanged(idx: Int?) {
        if let idx = idx {
            let newScore = scores[idx]
            scoreValueChanged?(newScore)
        } else {
            scoreValueChanged?(nil)
        }
    }

    private lazy var cardView: UIView = {

        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        //cardView.layer.cornerRadius = 8
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

    func setValues(for entry: DayViewModel.DayViewEntry) {
        self.promptView.text = entry.prompt
        self.scores = entry.scoreProvider.scores()
        self.scoreSelectionView.setOptions(options: self.scores.map({ $0.shortLabel(for: entry.scoreProvider) }))
        if let score = entry.score {
            self.scoreSelectionView.selectedOptionIndex = self.scores.firstIndex(of: score)
        }
        promptView.textColor = entry.promptActive ? .label : .tertiaryLabel
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.scoreSelectionView.setOptions(options: [])
        self.promptView.text = nil
        self.scoreValueChanged = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
