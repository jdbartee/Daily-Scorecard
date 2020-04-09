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

    var serviceProvider: ServiceProvider?

    lazy var ownedNavigationController: UINavigationController = {
        let nav = UINavigationController(rootViewController: self.initialViewController)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }()

    lazy var initialViewController: UIViewController = {
        return self.tabController
    }()

    lazy var tabController: UITabBarController = {
        let tabController = UITabBarController()

        tabController.addChild(self.chartController)
        tabController.addChild(self.dayViewController)

        self.chartController.tabBarItem.title = NSLocalizedString("Charts_Tab_Button", comment: "")
        self.chartController.tabBarItem.image = UIImage(systemName: "chart.bar")

        self.dayViewController.tabBarItem.title = NSLocalizedString("Entries_Tab_Button", comment: "")
        self.dayViewController.tabBarItem.image = UIImage(systemName: "list.dash")

        tabController.navigationItem.setLeftBarButton(self.actionButtonItem, animated: true)
        tabController.selectedViewController = self.dayViewController

        tabController.title = self.serviceProvider?.appDetails.appName
        return tabController
    }()

    lazy var chartController: ChartPageViewController = {
        let vc = ChartPageViewController()
        vc.serviceProvider = serviceProvider
        return vc
    }()

    lazy var dayViewController: UIViewController = {
        let vc = DayViewPagingController()
        vc.serviceProvider = self.serviceProvider
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

    func presentSettingsView() {
        let vc = SettingsViewController()
        vc.serviceProvider = self.serviceProvider
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
