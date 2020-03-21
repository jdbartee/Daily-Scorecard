//
//  ChartViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/5/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class ChartPageViewController: UIViewController {
    var service: ChartViewService?
    var state: ChartViewModel = ChartViewModel(percentages: [], dates: [], activeFilter: .all, filters: [.all]) {
        didSet {
            barChartController.entries = Array(zip(state.dates, state.percentages))
            filterController.filters = self.state.filters
        }
    }

    var cancelBag = CancelBag()

    override func viewWillAppear(_ animated: Bool) {
        self.title = "Weekly Trends"
        self.queryData(for: state.activeFilter)
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.cancelBag.cancelAll()
    }

    lazy var graphContainerView: UIView = {
        let graphContainerView = UIView()
        graphContainerView.translatesAutoresizingMaskIntoConstraints = false
        return graphContainerView
    }()

    lazy var filterContainerView: UIView = {
        let filterContainerView = UIView()
        filterContainerView.translatesAutoresizingMaskIntoConstraints = false
        return filterContainerView
    }()

    lazy var barChartController: ChartViewController = {
        let barChartController = ChartViewController()
        return barChartController
    }()

    lazy var filterController: ChartFilterPickerViewController = {
        let filterController = ChartFilterPickerViewController()
        filterController.delegate = self
        filterController.filters = [.all]
        return filterController
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(graphContainerView)
        view.addSubview(filterContainerView)

        install(child: barChartController, into: graphContainerView)
        install(child: filterController, into: filterContainerView)

        NSLayoutConstraint.activate([
            graphContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            graphContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            graphContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            graphContainerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),


            filterContainerView.topAnchor.constraint(equalTo: graphContainerView.bottomAnchor, constant: 20),
            filterContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            filterContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            filterContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func queryData(for filter: ChartViewServiceFilter) {
        service?.chartModel(for: filter)
            .receive(on: DispatchQueue.main)
            .assign(to: \Self.state, on: self)
            .store(in: &self.cancelBag)
    }

    func install(child: UIViewController, into container: UIView) {

        addChild(child)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: container.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        child.didMove(toParent: self)

    }
}

extension ChartPageViewController: ChartFilterPickerViewDelegate {
    func chartFilterPickerView(_ chartFilterPickerView: ChartFilterPickerViewController, didChangeFilterTo filter: ChartViewServiceFilter) {
        self.queryData(for: filter)
    }
}
