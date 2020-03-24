//
//  AppFlowController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/23/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class AppFlowController: UIViewController {

    var cancelBag = CancelBag()

    lazy var serviceProvider: ServiceProvider = {
        let sp = ServiceProvider()
        return sp
    }()

    lazy var ownedNavigationController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.initialViewController)
        return nav
    }()

    lazy var initialViewController: UIViewController = {
        return self.tabController
    }()

    lazy var tabController: UITabBarController = {
        let tabController = UITabBarController()

        tabController.addChild(self.chartController)
        tabController.addChild(self.dayViewController)

        self.chartController.tabBarItem.title = "Charts"
        self.chartController.tabBarItem.image = UIImage(systemName: "chart.bar")

        self.dayViewController.tabBarItem.title = "Entries"
        self.dayViewController.tabBarItem.image = UIImage(systemName: "list.dash")

        tabController.navigationItem.setLeftBarButton(self.actionButtonItem, animated: true)

        tabController.selectedViewController = self.dayViewController

        return tabController
    }()

    lazy var chartController: ChartPageViewController = {
        let vc = ChartPageViewController()
        vc.service = serviceProvider.chartViewService
        return vc
    }()

    lazy var testController: UIViewController = {
        let testController = TestController()
        testController.title = "TESTING"
        return testController
    }()

    lazy var dayViewController: UIViewController = {
        let vc = DayViewPagingController()
        vc.serviceProvider = self.serviceProvider
        vc.flowController = self
        vc.title = "Day View"
        vc.navigationItem.setRightBarButton(self.actionButtonItem, animated: true)
        vc.navigationItem.setLeftBarButton(self.chartsButtonItem, animated: true)
        return vc
    }()

    lazy var actionButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsTapped(_:)))
        return button
    }()

    @objc func settingsTapped(_ sender: Any) {
        self.presentSettingsView()
    }

    @objc func actionsTapped(_ sender: Any) {
        self.presentPromptEditFlow()
    }

    func showActionSheet() {
        self.show(self.actionSheetController, sender: self)
    }

    lazy var chartsButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "chart.bar"), style: .plain, target: self, action: #selector(chartsTapped(_:)))
        return button
    }()

    @objc func chartsTapped(_ sender: Any) {
        self.presentChartsView()
    }

    func presentChartsView() {
        self.ownedNavigationController.pushViewController(self.chartController, animated: true)
    }

    lazy var actionSheetController: UIAlertController = {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(self.printDataAction)
        alertController.addAction(self.printPromptsAction)
        alertController.addAction(self.editPromptsAction)
        alertController.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }()

    lazy var printPromptsAction: UIAlertAction = {
        UIAlertAction(title: "Print Prompts", style: .default, handler: {_ in
            if let service = self.serviceProvider.promptStoreService as? InMemoryPromptStoreService {
                print(service.prompts)
            }
        })
    }()

    lazy var printDataAction: UIAlertAction = {
        UIAlertAction(title: "Print Data", style: .default, handler: {_ in
            if let service = self.serviceProvider.entryStoreService as? InMemoryEntryStoreService {
                print(service.entries)
            }
        })
    }()

    lazy var editPromptsAction: UIAlertAction = {
        UIAlertAction(title: "Edit Prompts", style: .default, handler: {_ in
            self.presentPromptEditFlow()
        })
    }()

    func presentSettingsView() {
        let vc = SettingsViewController()
        vc.serviceProvider = self.serviceProvider
        vc.modalPresentationStyle = .overCurrentContext
        self.ownedNavigationController.pushViewController(vc, animated: true)
    }

    func presentPromptEditFlow() {
        let vc = PromptEditFlowController()
        vc.serviceProvider = self.serviceProvider
        vc.modalPresentationStyle = .overCurrentContext
        self.ownedNavigationController.pushViewController(vc, animated: true)
    }

    override func loadView() {
        view = UIView()
        install(child: self.ownedNavigationController)
    }

    func install(child: UIViewController) {

        addChild(child)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        child.didMove(toParent: self)

    }
}
