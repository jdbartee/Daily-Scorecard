//
//  DayViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/16/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit
import Combine

class DayViewController: UITableViewController, Storyboarded {
    typealias SectionModel = Int
    typealias EntryCellModel = DayViewModel.DayViewEntry

    var service: DayViewService?
    var scoreProvider: ScoreProvider?
    var lastSelectedIndex: IndexPath?
    var date: Date = Date() {
        didSet {
            self.queryData()
        }
    }

    lazy var dataSource: UITableViewDiffableDataSource<SectionModel, EntryCellModel> = {
        var dataSource = UITableViewDiffableDataSource<SectionModel, EntryCellModel>(tableView: self.tableView, cellProvider: self.cellProvider)
        return dataSource
    }()

    lazy var pickerView: UIPickerView = {
        var pickerView = UIPickerView()
        pickerView.delegate = self.scoreProvider
        pickerView.dataSource = self.scoreProvider
        return pickerView
    }()

    lazy var pickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(textFieldDone(_:)))
        ]
        toolbar.setItems(items, animated: true)
        toolbar.sizeToFit()
        return toolbar
    }()

    lazy var proxyTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.inputView = self.pickerView
        textField.inputAccessoryView = self.pickerToolbar
        return textField
    }()

    lazy var globalTapRecognizer: UITapGestureRecognizer = {
        var tr = UITapGestureRecognizer(target: self, action: #selector(globalTap(_:)))
        tr.cancelsTouchesInView = false
        return tr
    }()

    var state: DayViewModel = DayViewModel(date: Calendar.current.today(), entries: []) {
        didSet {
            reloadData()
        }
    }
    var cancelBag = CancelBag()

    var flowController: AppFlowController?

    @objc func globalTap(_ sender: Any?) {
        lastSelectedIndex = nil
        self.view.endEditing(false)
    }

    @objc func textFieldDone(_ sender: Any) {
        let row = self.pickerView.selectedRow(inComponent: 0)

        if let score = self.scoreProvider?.scores[row],
           let index = lastSelectedIndex,
           let entry = dataSource.itemIdentifier(for: index) {
            service?.setScore(for: entry, date: self.state.date, to: score)
            self.queryData()

            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems([dataSource.itemIdentifier(for: index)!])
            self.dataSource.apply(snapshot)
        }

        lastSelectedIndex = nil
        self.view.endEditing(false)
    }
        

    override func viewDidLoad() {
        self.tableView.dataSource = self.dataSource
        self.view.addGestureRecognizer(self.globalTapRecognizer)
        self.view.addSubview(self.proxyTextField)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.queryData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        cancelBag.cancelAll()
    }

    func prepareForReuse() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, EntryCellModel>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    private func queryData() {
        service?.dayViewModel(for: self.date)
            .receive(on: DispatchQueue.main)
            .assign(to: \Self.state, on: self)
            .store(in: &self.cancelBag)
    }

    private func cellProvider(tableView: UITableView, indexPath: IndexPath, entry: EntryCellModel) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entry") as? DayViewEntryTableViewCell
        cell?.promptLabel.text = entry.prompt
        cell?.scoreLabel.text = entry.score
        cell?.scoreLabel.textColor = .systemBlue
        cell?.layoutIfNeeded()
        
        return cell
    }

    private func reloadData() {
        let data = self.state.entries
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, EntryCellModel>()

        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.proxyTextField.isEditing {
            return nil
        } else {
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndex = indexPath
        self.proxyTextField.becomeFirstResponder()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? DayViewEntryTableViewCell {
            cell.promptLabel.text = nil
            cell.scoreLabel.text = nil
        }
    }
}

extension ScoreProvider: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.scores.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = self.label(for: self.scores[row])
        label.textAlignment = .center
        return label
    }
}
