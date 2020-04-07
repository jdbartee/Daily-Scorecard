//
//  DayViewPagingController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/4/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class DayViewPagingController: UIViewController {
    var serviceProvider: ServiceProvider?
    var dataSource = DayViewPagingDataSource()

    var service: DayViewPagingService? {
        self.serviceProvider?.dayViewPagingService
    }

    var state: DayViewPagingState = .none {
        didSet {
            self.updateState(oldValue)
        }
    }

    var prevDate: Date? {
        switch state {
        case .historic(let model), .today(let model):
            return model.prevDate
        default:
            return nil
        }
    }
    var nextDate: Date? {
        switch state {
        case .historic(let model), .today(let model):
            return model.nextDate
        default:
            return nil
        }
    }

    var cancelBag = CancelBag()

    lazy var pageController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self.dataSource
        vc.delegate = self

        vc.view.addSubview(self.dateView)

        NSLayoutConstraint.activate([
            dateView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -10),
            dateView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor, constant: 0),
            dateView.widthAnchor.constraint(equalTo: vc.view.widthAnchor, multiplier: 0.80)
        ])

        return vc
    }()


    lazy var dateLabel: UILabel = {
        var label = UILabel()
        label.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()

    lazy var blurEffect = UIBlurEffect(style: .systemMaterial)

    lazy var vibrancyView: UIVisualEffectView = {
        let vibrancyView = UIVisualEffectView()
        vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: .label)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        return vibrancyView
    }()

    lazy var dateView: UIView = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateViewTapped(_:)))

        let view = UIVisualEffectView()
        view.effect = blurEffect
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(tapGesture)


        vibrancyView.contentView.addSubview(self.dateLabel)
        view.contentView.addSubview(vibrancyView)

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 5.0);
        view.layer.shadowOpacity = 0.25;

        NSLayoutConstraint.activate([
            vibrancyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            vibrancyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            vibrancyView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            vibrancyView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            self.dateLabel.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor),
            self.dateLabel.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor),
            self.dateLabel.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor),
            self.dateLabel.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor)
        ])

        return view
    }()

    @objc func dateViewTapped(_ sender: Any) {
        switch state {
        case .today(_):
            break
        default:
            let dvc = self.getReusableDayViewTableController()
            dvc.queryData(for: Calendar.current.today())
            self.pageController.setViewControllers([dvc], direction: .forward, animated: true) { _ in
                self.queryData()
            }
        }
    }

    lazy var reusableDayViewControllers = Set<DayViewTableController>()

    func getReusableDayViewTableController() -> DayViewTableController {
        if let vc = reusableDayViewControllers.filter({ vc in
            vc != self.pageController.viewControllers?.first &&
                vc != self.dataSource.previousViewController &&
                vc != self.dataSource.nextViewController
        }).first {
            vc.prepareForReuse()
            return vc
        } else {
            let vc = self.newDayViewController()
            reusableDayViewControllers.insert(vc)
            return vc
        }
    }

    func newDayViewController() -> DayViewTableController {
        let vc = DayViewTableController()
        vc.service = self.serviceProvider?.dayViewService
        return vc
    }

    func queryData() {
        self.service?.model()
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancelBag)
    }

    func queryData(for date: Date) {
        self.service?.model(for: date)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &cancelBag)
    }

    private func updateState(_ oldValue: DayViewPagingState) {
        DispatchQueue.main.async {
            self.pageController.dataSource = nil

            switch self.state {
            case .historic(let model), .today(let model):
                self.dateLabel.text = model.currentDateLabel

                if let dvc = self.pageController.viewControllers?.first as? DayViewTableController {
                    dvc.queryData(for: model.currentDate)
                } else {
                    let dvc = self.getReusableDayViewTableController()
                    dvc.queryData(for: model.currentDate)
                    self.pageController.setViewControllers([dvc], direction: .forward, animated: false, completion: nil)
                }

                if let prevDate = model.prevDate {
                    let vc = self.getReusableDayViewTableController()
                    vc.queryData(for: prevDate)
                    self.dataSource.previousViewController = vc
                } else {
                    self.dataSource.previousViewController = nil
                }

                if let nextDate = model.nextDate {
                    let vc = self.getReusableDayViewTableController()
                    vc.queryData(for: nextDate)
                    self.dataSource.nextViewController = vc
                } else {
                    self.dataSource.nextViewController = nil
                }

            case .none:
                self.pageController.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
                self.dataSource.nextViewController = nil
                self.dataSource.previousViewController = nil
                self.dateLabel.text = nil
            }


            self.pageController.dataSource = self.dataSource
        }
    }

    private func reloadCurrentState() {
        switch state {
        case .historic(let model):
            self.queryData(for: model.currentDate)
        case .today(_):
            self.queryData()
        case .none:
            self.queryData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.reloadCurrentState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.cancelBag.cancelAll()
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemGroupedBackground
        install(child: self.pageController)
    }

    func install(child: UIViewController) {

        addChild(child)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        child.didMove(toParent: self)

    }
}

class DayViewPagingDataSource: NSObject, UIPageViewControllerDataSource {

    var previousViewController: UIViewController?
    var nextViewController: UIViewController?


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard viewController != self.previousViewController else { return nil }
        return self.previousViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard viewController != self.nextViewController else { return nil }
        return self.nextViewController
    }
}

extension DayViewPagingController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers?.first {
                if vc == self.dataSource.previousViewController, let date = self.prevDate {
                    self.queryData(for: date)
                } else if vc == self.dataSource.nextViewController, let date = self.nextDate {
                    self.queryData(for: date)
                } else {
                    print("A Major error occured")
                    self.reloadCurrentState()
                }
            }
        }
    }
}
