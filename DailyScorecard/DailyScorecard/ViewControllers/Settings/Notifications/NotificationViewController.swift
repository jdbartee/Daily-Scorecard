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

    var staticCells: [UITableViewCell] = []

    private lazy var tableView: UITableView = {
        let tableview = UITableView(frame: .zero, style: .insetGrouped)
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.allowsSelection = false
        return tableview
    }()

    lazy var deniedPrompt: UILabel = {
        let deniedPrompt = UILabel()
        deniedPrompt.font = .preferredFont(forTextStyle: .body)
        deniedPrompt.translatesAutoresizingMaskIntoConstraints = false
        deniedPrompt.numberOfLines = 0
        deniedPrompt.textColor = .systemRed
        deniedPrompt.text = NSLocalizedString("Allow_Notifications_Error_Prompt", comment: "")
        return deniedPrompt
    }()

    lazy var deniedPromptCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.contentView.addSubview(self.deniedPrompt)

        NSLayoutConstraint.activate([
            self.deniedPrompt.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            self.deniedPrompt.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
            self.deniedPrompt.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            self.deniedPrompt.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        ])
        return cell
    }()

    lazy var mainPrompt: UILabel = {
        let mainPrompt = UILabel()
        mainPrompt.font = .preferredFont(forTextStyle: .body)
        mainPrompt.translatesAutoresizingMaskIntoConstraints = false
        mainPrompt.numberOfLines = 0
        mainPrompt.text = NSLocalizedString("Notification_Prompt", comment: "")
        return mainPrompt
    }()

    lazy var mainPrompCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.contentView.addSubview(self.mainPrompt)

        NSLayoutConstraint.activate([
            self.mainPrompt.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            self.mainPrompt.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
            self.mainPrompt.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            self.mainPrompt.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        ])
        return cell
    }()

    lazy var toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = true
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
        toggleSwitchLabel.text = NSLocalizedString("Notification_Active_Label", comment: "")
        return toggleSwitchLabel
    }()

    lazy var toggleCell: UITableViewCell = {
        let cell = UITableViewCell(frame: .zero)
        cell.contentView.addSubview(self.toggleSwitchLabel)
        cell.accessoryView = self.toggleSwitch

        NSLayoutConstraint.activate([
            self.toggleSwitchLabel.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            self.toggleSwitchLabel.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
            self.toggleSwitchLabel.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            self.toggleSwitchLabel.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
        ])
        return cell
    }()

    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.font = .preferredFont(forTextStyle: .body)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = NSLocalizedString("Notification_Time_Label", comment: "")
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

    lazy var timePickerCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.contentView.addSubview(self.timeLabel)
        cell.contentView.addSubview(self.timePicker)

        NSLayoutConstraint.activate([
            self.timeLabel.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            self.timeLabel.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            self.timeLabel.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),

            self.timePicker.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
            self.timePicker.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            self.timePicker.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),

            self.timePicker.topAnchor.constraint(greaterThanOrEqualTo: self.timeLabel.bottomAnchor)
        ])

        return cell
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
            self.tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ]
    }()

    func updateViewState() {
        let newCells: [UITableViewCell]
        switch self.model {
        case .none:
            newCells = []

        case .denied:
            newCells = [self.deniedPromptCell, self.mainPrompCell, self.toggleCell]
            self.toggleSwitch.setOn(false, animated: false)
            self.toggleSwitch.isEnabled = false

        case .off:
            newCells = [self.mainPrompCell, self.toggleCell]
            self.toggleSwitch.isEnabled = true

        case .on(hour: let hour, minute: let minute):
            newCells = [self.mainPrompCell, self.toggleCell, self.timePickerCell]
            self.toggleSwitch.isOn = true
            self.toggleSwitch.isEnabled = true
            if let date = Calendar.current.date(from: DateComponents(calendar: Calendar.current, hour: hour, minute: minute)) {
                self.timePicker.setDate(date, animated: false)
            }
        }

        self.tableView.beginUpdates()

        let diff = newCells.difference(from: self.staticCells)
        self.staticCells = newCells
        for d in diff {
            switch d {
            case .insert(let offset, _, _):
                tableView.insertRows(at: [IndexPath(row: offset, section: 0)], with: .automatic)
            case .remove(let offset, _, _):
                tableView.deleteRows(at: [IndexPath(row: offset, section: 0)], with: .automatic)
            }
        }
        self.tableView.endUpdates()
    }

    private func queryModel() {
        self.service?.model()
            .receive(on: DispatchQueue.main)
            .assign(to: \.model, on: self)
            .store(in: &self.cancelBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.queryModel()

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification, object: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
            self.queryModel()
            })
            .store(in: &self.cancelBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cancelBag.cancelAll()
    }

    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate(layoutConstraints)
    }

    override func loadView() {
        self.title = NSLocalizedString("Notifications_Title", comment: "")
        self.view = UIView()

        view.backgroundColor = .systemGroupedBackground

        view.addSubview(tableView)
    }
}

extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.staticCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return staticCells[indexPath.row]
    }
}
