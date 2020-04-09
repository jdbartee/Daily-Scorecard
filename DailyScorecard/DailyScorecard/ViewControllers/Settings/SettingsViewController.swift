//
//  SettingsViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/23/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {

    var serviceProvider: ServiceProvider?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")

        return tableView
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(self.tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Settings_Title", comment: "")
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    var editPromptController: PromptEditFlowController {
        let editPromptController = PromptEditFlowController()
        editPromptController.serviceProvider = self.serviceProvider

        return editPromptController
    }

    var themeController: UIViewController {
        let themeController = ThemeViewController()
        themeController.serviceProvider = serviceProvider
        return themeController
    }

    var notificationsController: UIViewController {
        let notificationsController = NotificationViewController()
        notificationsController.serviceProvider = self.serviceProvider
        return notificationsController
    }

    var aboutController: UIViewController {
        let aboutController = AboutViewController()
        aboutController.serviceProvider = self.serviceProvider
        return aboutController
    }

    var titles: [String] {
        return [
            NSLocalizedString("Edit_Prompts_Title", comment: ""),
            NSLocalizedString("Themes_Title", comment: ""),
            NSLocalizedString("Notifications_Title", comment: ""),
            NSLocalizedString("About_Title", comment: ""),
        ]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        cell.textLabel?.text = titles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let viewController: UIViewController
        switch indexPath.row {
        case 0:
            viewController = editPromptController
        case 1:
            viewController = themeController
        case 2:
            viewController = notificationsController
        case 3:
            viewController = aboutController
        default:
            return
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }


}
