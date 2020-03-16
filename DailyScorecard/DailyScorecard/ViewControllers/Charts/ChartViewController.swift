//
//  ChartViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/7/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class ChartViewController: UIViewController {
    var entries: [(Date, Float)] = [] {
        didSet {
            updateData()
        }
    }

    private var barViews: [BarView] = []

    private var barSpacing: CGFloat {
        10.0
    }

    private var animationDuration: TimeInterval {
        1
    }

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = self.barSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private func updateData() {
        while self.entries.count > self.barViews.count {
            let bar = BarView(frame: .zero)
            bar.formatter = formatter
            self.barViews.append(bar)
            self.stackView.addArrangedSubview(bar)

        }

        while self.entries.count < self.barViews.count {
            if let v = self.barViews.popLast() {
                v.removeFromSuperview()
            }
        }

        for (idx, (date, percentage)) in self.entries.enumerated() {
            let bar = barViews[idx]
            bar.date = date
            bar.layoutIfNeeded()

            UIView.animate(withDuration: animationDuration) {
                bar.percentage = percentage
            }
        }
    }

    override func viewDidLoad() {
        self.view.backgroundColor = .systemGroupedBackground
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
        self.view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

class BarView: UIView {

    var formatter: DateFormatter?
    var percentage: Float = 0.0 {
        didSet {
            updatePercentages()
        }
    }
    var date: Date = Date() {
        didSet {
            self.labelView.text = formatter?.string(from: date)
        }
    }
    private var spacing: Float {
        10.0
    }

    private var heightConstraint: NSLayoutConstraint?

    lazy var barView: UIView = {
        let barView = UIView()
        barView.backgroundColor = .systemBlue
        barView.layer.cornerRadius = 8
        barView.layer.masksToBounds = false
        barView.layer.shadowColor = UIColor.black.cgColor
        barView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0);
        barView.layer.shadowOpacity = 0.25;
        barView.translatesAutoresizingMaskIntoConstraints = false

        return barView
    }()

    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.addSubview(barView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            barView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            barView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            barView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            barView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor)
        ])

        return containerView
    }()

    lazy var labelView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        return label
    }()


    private func updatePercentages() {
        if let constraint = self.heightConstraint {
            NSLayoutConstraint.deactivate([constraint])
        }

        self.heightConstraint = self.barView.heightAnchor.constraint(
            equalTo: self.containerView.heightAnchor,
            multiplier: CGFloat(max(0.0, min(self.percentage, 1.0)))
        )
        NSLayoutConstraint.activate([self.heightConstraint!])
        self.layoutIfNeeded()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(labelView)
        addSubview(containerView)

        NSLayoutConstraint.activate([
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: trailingAnchor),

            containerView.bottomAnchor.constraint(equalTo: labelView.topAnchor, constant: CGFloat(-spacing)),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
        ])

        heightConstraint = barView.heightAnchor.constraint(equalToConstant: 0.0)
        NSLayoutConstraint.activate([heightConstraint!])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
