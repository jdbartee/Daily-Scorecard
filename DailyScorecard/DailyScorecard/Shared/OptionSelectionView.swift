//
//  OptionSelectionView.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/21/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit


class OptionSelectionView: UIView {

    private class OptionTapRecognizer: UITapGestureRecognizer {
        var optionIndex: Int? = nil
    }

    private(set) var options = [String]()
    var selectedOptionIndex: Int? {
        didSet {
            animateChangeToSelectedOption(oldValue)
        }
    }
    var selectedOptionIndexDidChange: ((Int?)->Void)?


    func setOptions(options: [String]) {
        self.selectedOptionIndex = nil
        self.options = options

        for view in self.optionsStackView.arrangedSubviews {
            self.optionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for (idx,_) in self.options.enumerated() {
            let button = buttonView(for: idx)
            self.optionsStackView.addArrangedSubview(button)
        }
    }

    private func animateChangeToSelectedOption(_ oldValue: Int?) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.5) {
                if let oldIndex = oldValue {
                    let button = self.optionsStackView.arrangedSubviews[oldIndex]
                    button.backgroundColor = .clear
                    (button.subviews[0] as? UILabel)?.textColor = .label
                }
                if let index = self.selectedOptionIndex {
                    let button = self.optionsStackView.arrangedSubviews[index]
                    button.backgroundColor = button.tintColor
                    (button.subviews[0] as? UILabel)?.textColor = .white
                }
            }
        }
    }

    private lazy var optionsStackView: UIStackView = {
        let optionsStackView = UIStackView()
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.distribution = .equalSpacing
        optionsStackView.axis = .horizontal

        return optionsStackView
    }()

    private lazy var selectionBubble: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.frame.size = CGSize(width: 50, height: 50)
        view.layer.cornerRadius = 25
        view.backgroundColor = self.tintColor
        return view
    }()

    private func buttonView(for index: Int) -> UIView {
        let option = options[index]
        let optionTap = OptionTapRecognizer(target: self, action: #selector(optionTapped(_:)))
        optionTap.optionIndex = index

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(optionTap)
        view.layer.cornerRadius = 8
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .title1)
        label.text = option
        label.textAlignment = .center
        label.sizeToFit()

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            view.widthAnchor.constraint(equalTo: view.heightAnchor),
        ])

        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(optionsStackView)
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: topAnchor),
            optionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.animateChangeToSelectedOption(self.selectedOptionIndex)
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.setNeedsDisplay()
    }

    @objc private func optionTapped(_ sender: Any) {
        if let sender = sender as? OptionTapRecognizer {
            if self.selectedOptionIndex != sender.optionIndex {
                self.selectedOptionIndex = sender.optionIndex
                self.selectedOptionIndexDidChange?(self.selectedOptionIndex)
            }
        }
    }

}
