//
//  PromptTableViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/19/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine
import UIKit

class PromptTableViewController: UITableViewController, Storyboarded {
    enum PromptState: Hashable {
    case active
    case inactive
    }

    typealias SectionModel = PromptState
    typealias EntryCellModel = Prompt
    
    var flowController: PromptEditFlowController?

    @IBAction func addTapped(_ sender: Any) {
        self.flowController?.addNewPrompt()
    }

    lazy private var dataSource: some PromptTableViewDataSource = {
        let dataSource = PromptTableViewDataSource(tableView: self.tableView, cellProvider: self.cellProvider)
        dataSource.service = self.service
        dataSource.queryData = {self.queryData()}
        return dataSource
    }()

    var service: PromptTableViewService?

    var state: PromptTableViewModel = PromptTableViewModel(activePrompts: [], inactivePrompts: []) {
        didSet {
            self.reloadData()
        }
    }
    private var cancelBag = CancelBag()

    override func viewDidLoad() {
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.queryData()
        self.tableView.setEditing(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        cancelBag.cancelAll()
    }

    private func cellProvider(tableView: UITableView, indexPath: IndexPath, entry: EntryCellModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic")
        cell?.textLabel?.text = entry.prompt
        cell?.layoutIfNeeded()
        return cell
    }

    func queryData() {
        service?.promptTableViewModel()
        .receive(on: DispatchQueue.main)
        .assign(to: \Self.state, on: self)
        .store(in: &self.cancelBag)
    }

    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, EntryCellModel>()

        snapshot.deleteAllItems()
        snapshot.appendSections([.active])
        snapshot.appendItems(self.state.activePrompts)

        snapshot.appendSections([.inactive])
        snapshot.appendItems(self.state.inactivePrompts)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prompt = dataSource.itemIdentifier(for: indexPath) {
            self.flowController?.showDetail(prompt: prompt)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // The internet told me too.
        cell.textLabel?.text = nil
    }

    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            return sourceIndexPath
        }
        else {
            return proposedDestinationIndexPath
        }
    }

    private class PromptTableViewDataSource: UITableViewDiffableDataSource<SectionModel, EntryCellModel> {

        var queryData: (() -> Void)?
        var service: PromptTableViewService?
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            switch section {
            case 0:
                return "Active"
            case 1:
                return "Inactive"
            default:
                return nil
            }
        }

        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            guard sourceIndexPath.section == destinationIndexPath.section else {
                return
            }
            var currentIndexPath = sourceIndexPath

            while currentIndexPath != destinationIndexPath {
                let nextIndexPath = IndexPath(
                    row: currentIndexPath.row + (currentIndexPath.row < destinationIndexPath.row ? 1 : -1),
                    section: currentIndexPath.section)

                if let currentItem = self.itemIdentifier(for: currentIndexPath),
                    var nextItem = self.itemIdentifier(for: nextIndexPath) {
                    nextItem.sortOrder = currentItem.sortOrder
                    service?.update(prompt: nextItem)
                }
                currentIndexPath = nextIndexPath
            }

            if var sourceItem = self.itemIdentifier(for: sourceIndexPath),
                let destinationItem = self.itemIdentifier(for: destinationIndexPath) {
                sourceItem.sortOrder = destinationItem.sortOrder
                service?.update(prompt: sourceItem)
            }
            queryData?()
        }
    }
}

