//
//  DayViewTableController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/15/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit
import Combine

class DayViewTableController: UIViewController {

    private var entries = [DayViewModel.DayViewEntry]()

    var service: DayViewService?
    var cancelBag = CancelBag()

    var state: DayViewViewModel = .none {
        didSet {
            self.updateState()
        }
    }

    var date: Date? {
        switch state {
        case .value(let model):
            return model.date
        default:
            return nil
        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DayViewEntryCell.self, forCellReuseIdentifier: "entry")
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        return tableView
    }()

    lazy var dataSource: UITableViewDataSource = {
        let dataSource = self
        return dataSource
    }()

    override func viewWillAppear(_ animated: Bool) {
        if let date = date {
            self.queryData(for: date)
        }
    }

    override func viewDidLoad() {
        self.view.addSubview(self.tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func queryData(for date: Date) {
        self.service?.dayViewModel(for: date)
            .receive(on: DispatchQueue.main)
            .map({ v in DayViewViewModel.value(model: v) })
            .assign(to: \.state, on: self)
            .store(in: &self.cancelBag)
    }

    func prepareForReuse() {
        self.state = .none
    }

    fileprivate func updateState() {
        DispatchQueue.main.async {
            switch self.state {
            case .value(let model):
                self.setEntries(model.entries, for: self.tableView)
            default:
                self.setEntries([], for: self.tableView)
                break
            }
        }
    }

}

extension DayViewTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}


extension DayViewTableController: UITableViewDataSource {

    func setEntries(_ newEntries: [DayViewModel.DayViewEntry], for tableView: UITableView) {
        tableView.beginUpdates()
        let diff = newEntries.map({$0.entryId}).difference(from: entries.map({$0.entryId}))
        entries = newEntries
        for d in diff {
            switch d {
            case .insert(let offset, _, _):
                tableView.insertRows(at: [IndexPath(row: offset, section: 0)], with: .automatic)
            case .remove(let offset, _, _):
                tableView.deleteRows(at: [IndexPath(row: offset, section: 0)], with: .automatic)
            }
        }
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = self.entries[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "entry") as? DayViewEntryCell else {
            fatalError()
        }
        cell.setValues(for: entry)
        cell.scoreValueChanged = { score in
            if let date = self.date, let score = score {
                self.service?.setScore(for: entry, date: date, to: score)
                self.queryData(for: date)
            }
        }

        return cell
    }
}
