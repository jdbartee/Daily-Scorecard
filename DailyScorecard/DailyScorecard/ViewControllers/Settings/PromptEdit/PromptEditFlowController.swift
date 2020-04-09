//
//  PromptEditFlowController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class PromptEditFlowController: UIViewController {

    var serviceProvider: ServiceProvider?

    lazy var contentViewController: UIViewController = {
        let vc = PromptTableViewController.instantiate()
        vc.flowController = self
        vc.service = self.serviceProvider?.promptTableViewService
        return vc
    }()

    override func loadView() {
        view = UIView()
        install(child: self.contentViewController)

        self.navigationItem.title = self.contentViewController.navigationItem.title
        self.navigationItem.titleView = self.contentViewController.navigationItem.titleView
        self.navigationItem.setRightBarButtonItems(self.contentViewController.navigationItem.rightBarButtonItems, animated: true)
        self.navigationItem.setLeftBarButtonItems(self.contentViewController.navigationItem.leftBarButtonItems, animated: true)
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

    func addNewPrompt() {
        let vc = PromptEditViewController(style: .insetGrouped)
        vc.flowController = self
        vc.service = self.serviceProvider?.promptEditViewService
        vc.promptModel = self.serviceProvider?.promptEditViewService.newPrompt()
        vc.title = NSLocalizedString("New_Prompt_Title", comment: "")
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }

    func showDetail(prompt: Prompt) {
        let vc = PromptEditViewController(style: .insetGrouped)
        vc.flowController = self
        vc.service = self.serviceProvider?.promptEditViewService
        vc.promptModel = self.serviceProvider?.promptEditViewService.editPrompt(prompt: prompt)
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true)
    }

    @objc func dismissSelf() {
        self.parent?.dismiss(animated: true, completion: {})
    }

    func dismissDetail() {
        self.dismiss(animated: true, completion: {
            if let vc = self.contentViewController as? PromptTableViewController {
                vc.queryData()
            }
        })
    }
}
