//
//  NotificationViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {
    var serviceProvider: ServiceProvider?
    var service: NotificationViewService? {
        return serviceProvider?.notificationViewService
    }

    var model: NotificationViewModel = .none {
        didSet {
            self.updateViewState()
        }
    }
    var cancelBag = CancelBag()


    private lazy var cardView: UIView = {
        let cardView = UIView()
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        if let insets = self.serviceProvider?.themeService.cardInsets {
            cardView.directionalLayoutMargins = insets
        }

        cardView.addSubview(self.layoutStack)

        return cardView
    }()

    private lazy var layoutStack: UIStackView = {
        let layoutStack = UIStackView()
        layoutStack.translatesAutoresizingMaskIntoConstraints = false
        layoutStack.axis = .vertical
        layoutStack.alignment = .fill
        layoutStack.distribution = .fillProportionally
        layoutStack.spacing = 8.0

        return layoutStack
    }()

    lazy var deniedPrompt: UILabel = {
        let deniedPrompt = UILabel()
        deniedPrompt.isHidden = true
        deniedPrompt.font = .preferredFont(forTextStyle: .body)
        deniedPrompt.translatesAutoresizingMaskIntoConstraints = false
        deniedPrompt.numberOfLines = 0
        deniedPrompt.textColor = .systemRed
        deniedPrompt.text = "You need to allow notifications in settings in order to set up reminders."
        return deniedPrompt
    }()

    lazy var mainPrompt: UILabel = {
        let mainPrompt = UILabel()
        mainPrompt.isHidden = true
        mainPrompt.font = .preferredFont(forTextStyle: .body)
        mainPrompt.translatesAutoresizingMaskIntoConstraints = false
        mainPrompt.numberOfLines = 0
        mainPrompt.text = "Would you like to recieve notifications daily to remind you to fill out your daily scorecard?"
        return mainPrompt
    }()

    lazy var toggleFrame: UIView = {
        let toggleFrame = UIView()
        toggleFrame.isHidden = true
        toggleFrame.translatesAutoresizingMaskIntoConstraints = false

        toggleFrame.addSubview(self.toggleSwitchLabel)
        toggleFrame.addSubview(self.toggleSwitch)

        NSLayoutConstraint.activate([
            self.toggleSwitchLabel.leadingAnchor.constraint(equalTo: toggleFrame.leadingAnchor),
            self.toggleSwitchLabel.topAnchor.constraint(equalTo: toggleFrame.topAnchor),
            self.toggleSwitchLabel.bottomAnchor.constraint(equalTo: toggleFrame.bottomAnchor),

            self.toggleSwitch.trailingAnchor.constraint(equalTo: toggleFrame.trailingAnchor),
            self.toggleSwitch.topAnchor.constraint(greaterThanOrEqualTo: toggleFrame.topAnchor),
            self.toggleSwitch.bottomAnchor.constraint(lessThanOrEqualTo: toggleFrame.bottomAnchor),

            self.toggleSwitchLabel.centerYAnchor.constraint(equalTo: self.toggleSwitch.centerYAnchor),
            self.toggleSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: self.toggleSwitchLabel.trailingAnchor),
        ])
        return toggleFrame
    }()

    lazy var toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addTarget(self, action: #selector(switchFlipped(_:)), for: .valueChanged)
        return toggleSwitch
    }()

    @objc private func switchFlipped(_ sender: Any?) {
        self.service?.setActive(self.toggleSwitch.isOn)
        self.queryModel()
    }

    lazy var toggleSwitchLabel: UILabel = {
        let toggleSwitchLabel = UILabel()
        toggleSwitchLabel.adjustsFontSizeToFitWidth = true
        toggleSwitchLabel.font = .preferredFont(forTextStyle: .body)
        toggleSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitchLabel.text = "Active"
        return toggleSwitchLabel
    }()

    lazy var timeFrame: UIView = {
        let timeFrame = UIView()
        timeFrame.isHidden = true
        timeFrame.translatesAutoresizingMaskIntoConstraints = false

        timeFrame.addSubview(self.timeLabel)
        timeFrame.addSubview(self.timePicker)

        NSLayoutConstraint.activate([
            self.timeLabel.topAnchor.constraint(equalTo: timeFrame.topAnchor),
            self.timeLabel.leadingAnchor.constraint(equalTo: timeFrame.leadingAnchor),
            self.timeLabel.trailingAnchor.constraint(equalTo: timeFrame.trailingAnchor),

            self.timePicker.bottomAnchor.constraint(equalTo: timeFrame.bottomAnchor),
            self.timePicker.leadingAnchor.constraint(equalTo: timeFrame.leadingAnchor),
            self.timePicker.trailingAnchor.constraint(equalTo: timeFrame.trailingAnchor),

            self.timePicker.topAnchor.constraint(greaterThanOrEqualTo: self.timeLabel.bottomAnchor)
        ])

        return timeFrame
    }()

    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.font = .preferredFont(forTextStyle: .body)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = "At what time:"
        return timeLabel
    }()

    lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.datePickerMode = .time
        timePicker.calendar = Calendar.current
        timePicker.minuteInterval = 15
        timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            timePicker.heightAnchor.constraint(lessThanOrEqualToConstant: timePicker.intrinsicContentSize.height)
        ])
        return timePicker
    }()

    @objc private func timeChanged(_ sender: Any) {
        let date = self.timePicker.date
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        if let hour = dateComponents.hour, let minute = dateComponents.minute {
            self.service?.setTime(hour: hour, minute: minute)
        }
        self.queryModel()
    }

    lazy var layoutConstraints: [NSLayoutConstraint] = {
        return [
            self.cardView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            self.cardView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            self.cardView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            self.cardView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            self.layoutStack.topAnchor.constraint(equalTo: self.cardView.layoutMarginsGuide.topAnchor),
            self.layoutStack.leadingAnchor.constraint(equalTo: self.cardView.layoutMarginsGuide.leadingAnchor),
            self.layoutStack.trailingAnchor.constraint(equalTo: self.cardView.layoutMarginsGuide.trailingAnchor),
            self.layoutStack.bottomAnchor.constraint(lessThanOrEqualTo: self.cardView.layoutMarginsGuide.bottomAnchor)
        ]
    }()

    func updateViewState() {
        UIView.animate(withDuration: 0.25, animations: {
            switch self.model {
            case .none:
                self.deniedPrompt.isHidden = true
                self.mainPrompt.isHidden = true
                self.toggleFrame.isHidden = true
                self.timeFrame.isHidden = true

            case .denied:
                self.deniedPrompt.isHidden = false
                self.mainPrompt.isHidden = false
                self.toggleFrame.isHidden = false
                self.timeFrame.isHidden = true

                self.toggleSwitch.setOn(false, animated: false)
                self.toggleSwitch.isEnabled = false

            case .off:
                self.deniedPrompt.isHidden = true
                self.mainPrompt.isHidden = false
                self.toggleFrame.isHidden = false
                self.timeFrame.isHidden = true

                self.toggleSwitch.isEnabled = true

            case .on(hour: let hour, minute: let minute):
                self.deniedPrompt.isHidden = true
                self.mainPrompt.isHidden = false
                self.toggleFrame.isHidden = false
                self.timeFrame.isHidden = false

                self.toggleSwitch.isOn = true
                self.toggleSwitch.isEnabled = true
                if let date = Calendar.current.date(from: DateComponents(calendar: Calendar.current, hour: hour, minute: minute)) {
                    self.timePicker.setDate(date, animated: false)
                }
            }
            self.layoutStack.layoutIfNeeded()
        }, completion: { _ in
        })
    }

    private func queryModel() {
        self.service?.model()
            .receive(on: DispatchQueue.main)
            .assign(to: \.model, on: self)
            .store(in: &self.cancelBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.queryModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.cancelBag.cancelAll()
    }

    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate(layoutConstraints)
    }

    override func loadView() {
        self.title = "Notifications"
        self.view = UIView()
        if let insets = self.serviceProvider?.themeService.viewInsets {
            view.directionalLayoutMargins = insets
            view.preservesSuperviewLayoutMargins = true
        }
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(cardView)

        self.layoutStack.addArrangedSubview(self.deniedPrompt)
        self.layoutStack.addArrangedSubview(self.mainPrompt)
        self.layoutStack.addArrangedSubview(self.toggleFrame)
        self.layoutStack.addArrangedSubview(self.timeFrame)
    }
}
