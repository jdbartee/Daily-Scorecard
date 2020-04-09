//
//  PromptEditController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/20/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine
import UIKit

class PromptEditViewController: UITableViewController {
    var service: PromptEditViewService?
    var flowController: PromptEditFlowController?

    var promptModel: AnyPublisher<PromptEditViewModel, Never>?
    var state: PromptEditViewModel? {
        didSet {
            applyState()
        }
    }
    var cancelBag = CancelBag()

    var selectedProviderKey: String?
    var providerList: [(String, String)]?

    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:)))
        return button
    }()

    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped(_:)))
        return button
    }()

    lazy var promptTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.adjustsFontForContentSizeCategory = true
        textField.font = .preferredFont(forTextStyle: .body)
        return textField
    }()

    lazy var promptActiveSwitch: UISwitch = {
        let activeSwitch = UISwitch()
        activeSwitch.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return activeSwitch
    }()

    lazy var promptEditCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        let label = UILabel()
        label.text = NSLocalizedString("Prompt_Label", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)

        let stackView = UIStackView(arrangedSubviews: [label, self.promptTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill

        cell.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
        ])
        return cell
    }()

    lazy var promptActiveCell: UITableViewCell = {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        let label = UILabel()
        label.text = NSLocalizedString("Prompt_Active_Label", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)

        let stackView = UIStackView(arrangedSubviews: [label, self.promptActiveSwitch])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill

        cell.contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor),
        ])
        return cell
    }()

    lazy var staticCells: [UITableViewCell] = [
        self.promptEditCell,
        self.promptActiveCell
    ]

    @objc func cancelTapped(_ sender: Any) {
        flowController?.dismissDetail()
    }

    @objc func saveTapped(_ sender: Any) {
        if var state = self.state {
            state.prompt = self.promptTextField.text ?? ""
            state.active = promptActiveSwitch.isOn
            state.scoreProviderKey = self.selectedProviderKey ?? state.scoreProviderKey
            self.service?.savePrompt(prompt: state)
            flowController?.dismissDetail()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let promptModel = self.promptModel {
            promptModel
                .receive(on: DispatchQueue.main)
                .map({ $0 as PromptEditViewModel? })
                .assign(to: \PromptEditViewController.state, on: self)
                .store(in: &cancelBag)
        }
    }

    override func loadView() {
        super.loadView()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
        self.tableView.delegate = self
        self.navigationItem.setRightBarButton(self.saveButton, animated: false)
        self.navigationItem.setLeftBarButton(self.cancelButton, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        cancelBag.cancelAll()
    }

    func applyState() {
        self.promptTextField.text = self.state?.prompt
        self.promptActiveSwitch.setOn(self.state?.active ?? false, animated: true)
        self.selectedProviderKey = self.state?.scoreProviderKey
        self.providerList = self.state?.scoreProviderKeysAndNames

        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return staticCells.count
        } else if section == 1 {
            return self.providerList?.count ?? 0
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return staticCells[indexPath.row]
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "default") else { fatalError() }
            if let (k,  v) = self.providerList?[indexPath.row] {
                cell.accessoryType = k == self.selectedProviderKey ? .checkmark : .none
                cell.textLabel?.text = v
            }
            return cell
        } else {
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1, let (k,  _) = self.providerList?[indexPath.row] {
            self.selectedProviderKey = k
            tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 1 else { return nil }

        return NSLocalizedString("Score_Provider_Footer", comment: "")
    }
}
