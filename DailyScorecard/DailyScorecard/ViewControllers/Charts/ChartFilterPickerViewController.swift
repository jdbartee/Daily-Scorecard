//
//  ChartFilterPickerViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/7/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

protocol ChartFilterPickerViewDelegate {
    func chartFilterPickerView( _ chartFilterPickerView: ChartFilterPickerViewController, didChangeFilterTo filter: ChartViewServiceFilter)
}
class ChartFilterPickerViewController: UIViewController {

    var delegate: ChartFilterPickerViewDelegate?
    var selectedFilter: ChartViewServiceFilter = .all
    var filters: [ChartViewServiceFilter] = [.all] {
        didSet {
            self.filtersChanged(oldValue)
        }
    }

    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChartFilterCell.self, forCellReuseIdentifier: "chart.filter")
        tableView.dataSource = self.tableViewDataSource
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.delegate = self.tableViewDelegate
        return tableView
    }()

    lazy var tableViewDataSource: UITableViewDataSource = {
        return self
    }()

    lazy var tableViewDelegate: UITableViewDelegate = {
        return self
    }()

    var selectionView: UIView {
        self.tableView
    }

    override func viewDidLoad() {
        view.addSubview(selectionView)

        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            selectionView.topAnchor.constraint(equalTo: view.topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ChartFilterPickerViewController: UITableViewDataSource {
    var tableFilters: [[ChartViewServiceFilter]] {
        return [self.filters.filter({$0 == .all}), self.filters.filter({$0 != .all})]
    }

    func filtersChanged(_ oldValue: [ChartViewServiceFilter]) {

        let oldFilters = oldValue.compactMap({ f -> UUID? in
            if case ChartViewServiceFilter.prompt(let prompt) = f {
                return prompt.id
            } else {
                return nil
            }
        })
        let newFilters = filters.compactMap({ f -> UUID? in
            if case ChartViewServiceFilter.prompt(let prompt) = f {
                return prompt.id
            } else {
                return nil
            }
        })

        let diff = newFilters.difference(from: oldFilters)

        if diff.count == 0 {
            return
        }

        tableView.beginUpdates()
        for d in diff {
            switch d {
            case .insert(let offset, _, _):
                tableView.insertRows(at: [IndexPath(row: offset, section: 1)], with: .automatic)
            case .remove(let offset, _, _):
                tableView.deleteRows(at: [IndexPath(row: offset, section: 1)], with: .automatic)
            }
        }

        if let visibleIndexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: visibleIndexPaths, with: .automatic)
        }
        tableView.endUpdates()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableFilters.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints =  false
        switch section {
        case 0:
            label.text = NSLocalizedString("Filters_Section_Header", comment: "")
        case 1:
            label.text = NSLocalizedString("Prompts_Section_Header", comment: "")
        default:
            break
        }
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .headline)
        label.sizeToFit()
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
        return view
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFilters[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chart.filter") as? ChartFilterCell else {
            fatalError()
        }
        cell.prepareForReuse()
        let filter = tableFilters[indexPath.section][indexPath.row]
        switch filter {
        case .all:
            cell.filterLabel.text = NSLocalizedString("All_Filter_Label", comment: "")
            cell.filterLabel.sizeToFit()
        case .prompt(let prompt):
            cell.filterLabel.text = prompt.prompt
        }
        if self.selectedFilter == filter {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension ChartFilterPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = tableFilters[indexPath.section][indexPath.row]
        self.selectedFilter = filter
        delegate?.chartFilterPickerView(self, didChangeFilterTo: filter)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ChartFilterCell: UITableViewCell {

    lazy var filterLabel: UILabel = {
        let filterLabel = UILabel()
        filterLabel.translatesAutoresizingMaskIntoConstraints = false
        filterLabel.adjustsFontForContentSizeCategory = true
        filterLabel.font = .preferredFont(forTextStyle: .body)
        return filterLabel
    }()

    private lazy var filterView: UIView = {
        let filterView = UIView()
        filterView.addSubview(self.filterLabel)
        filterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filterLabel.leadingAnchor.constraint(equalTo: filterView.leadingAnchor, constant: 8),
            filterLabel.trailingAnchor.constraint(equalTo: filterView.trailingAnchor,constant: -8),
            filterLabel.topAnchor.constraint(equalTo: filterView.topAnchor, constant: 8),
            filterLabel.bottomAnchor.constraint(equalTo: filterView.bottomAnchor, constant: -8)
        ])
        return filterView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(filterView)

        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterView.topAnchor.constraint(equalTo: topAnchor),
            filterView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
