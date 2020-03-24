//
//  OptionSelectionView.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/21/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit


class OptionSelectionView: UIControl {


    var selectedOptionIndexDidChange: ((Int?)->Void)?
    private(set) var options = [String]()

    var selectedOptionIndex: Int? {
        didSet {
            animateChangeToSelectedOption(oldValue)
        }
    }

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
            UIView.animate(withDuration: 0.25) {
                if let oldIndex = oldValue {
                    let button = self.optionsStackView.arrangedSubviews[oldIndex] as? UIButton
                    button?.isSelected = false
                }
                if let index = self.selectedOptionIndex {
                    if let button = self.optionsStackView.arrangedSubviews[index] as? UIButton {
                        self.selector.isHidden = false
                        button.isSelected = true
                        self.selector.frame = button.frame
                        self.selector.layer.cornerRadius = button.frame.height / 2.0
                        }
                } else {
                    self.selector.isHidden = true
                }
            }
        }
    }

    private lazy var selector: UIView = {
        let selector = UIView(frame: .zero)
        selector.isHidden = true
        selector.backgroundColor = self.tintColor
        return selector
    }()

    private lazy var optionsStackView: UIStackView = {
        let optionsStackView = UIStackView()
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.distribution = .equalSpacing
        optionsStackView.axis = .horizontal

        return optionsStackView
    }()

    private func buttonView(for index: Int) -> UIButton {
        let option = options[index]

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        button.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.sizeToFit()

        button.setTitle(option, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.setTitleColor(self.tintColor.contrastColor(), for: .selected)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor),
        ])

        return button
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(selector)
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
        selector.backgroundColor = tintColor
        for button in optionsStackView.arrangedSubviews.compactMap({$0 as? UIButton}) {
            button.setTitleColor(tintColor.contrastColor(), for: .selected)
        }
        self.setNeedsDisplay()
    }

    @objc private func optionTapped(_ sender: Any) {
        if let sender = sender as? UIButton {
            if self.selectedOptionIndex != sender.tag {
                self.selectedOptionIndex = sender.tag
                self.selectedOptionIndexDidChange?(self.selectedOptionIndex)
            }
        }
    }

}
