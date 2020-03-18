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
    var selectedIndexChanged: ((Score?) -> Void)?

    private lazy var promptView: UILabel = {
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        return labelView
    }()


    private lazy var scoreEntryView: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        return segmentedControl
    }()

    private lazy var cardView: UIView = {

        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 8


        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true


        stackView.addArrangedSubview(promptView)
        stackView.addArrangedSubview(scoreEntryView)

        cardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        ])

        return cardView
    }()

    private var scores = [Score]()

    func setValues(for entry: DayViewModel.DayViewEntry) {
        promptView.text = entry.prompt
        scores = entry.scoreProvider.scores
        for score in scores {
            let label = entry.scoreProvider.shortLabel(for: score)
            scoreEntryView.insertSegment(withTitle: label, at: scoreEntryView.numberOfSegments, animated: false)
            if score == entry.score {
                scoreEntryView.selectedSegmentIndex = scoreEntryView.numberOfSegments - 1
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.scoreEntryView.removeAllSegments()
        self.promptView.text = nil
        self.selectedIndexChanged = nil
    }

    @objc private func valueChanged() {
        let score = scores[scoreEntryView.selectedSegmentIndex]
        self.selectedIndexChanged?(score)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
