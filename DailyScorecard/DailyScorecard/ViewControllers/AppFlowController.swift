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
        return self.pageController
    }()

    lazy var pageController: UIViewController = {
        let vc = DayViewPagingController()
        vc.serviceProvider = self.serviceProvider
        vc.flowController = self
        vc.title = "Day View"
        vc.navigationItem.setRightBarButton(self.actionButtonItem, animated: true)
        vc.navigationItem.setLeftBarButton(self.chartsButtonItem, animated: true)
        return vc
    }()

    lazy var actionButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(actionsTapped(_:)))
        return button
    }()

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
        let vc = ChartPageViewController()
        vc.service = serviceProvider.chartViewService
        self.ownedNavigationController.pushViewController(vc, animated: true)
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
