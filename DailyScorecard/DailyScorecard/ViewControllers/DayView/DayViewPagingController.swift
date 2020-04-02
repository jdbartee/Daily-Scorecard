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

    private var prevHash: Int = 0
    private var nextHash: Int = 0

    var service: DayViewPagingService? {
        self.serviceProvider?.dayViewPagingService
    }

    var state: DayViewPagingState = .none {
        didSet {
            self.updateState(oldValue)
        }
    }
    var cancelBag = CancelBag()
    
    lazy var pageController: UIPageViewController = {
        let dvc = getReusableDayViewTableController()
        dvc.queryData(for: initalDate())

        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self
        vc.delegate = self
        vc.setViewControllers([dvc], direction: .reverse, animated: true, completion: nil)

        vc.view.addSubview(self.dateView)

        NSLayoutConstraint.activate([
            dateView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -10),
            dateView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor, constant: 0),
            dateView.widthAnchor.constraint(equalTo: vc.view.widthAnchor, multiplier: 0.80)
        ])

        return vc
    }()

    func initalDate() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

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
        let view = UIVisualEffectView()
        view.effect = blurEffect
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false


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

    lazy var reusableDayViewControllers = Set<DayViewTableController>()

    func getReusableDayViewTableController() -> DayViewTableController {
        if let vc = reusableDayViewControllers.filter({$0.parent == nil}).first {
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
        pageController.dataSource = nil
        switch state {
        case .historic(let model), .today(let model):
            dateLabel.text = model.currentDateLabel
            if let dvc = pageController.viewControllers?[0] as? DayViewTableController {
                dvc.queryData(for: model.currentDate)
            }

        default:
            dateLabel.text = nil
        }

        dateLabel.sizeToFit()
        pageController.dataSource = self
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
        reloadCurrentState()
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink() { _ in
                self.reloadCurrentState()
            }.store(in: &cancelBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.cancelBag.cancelAll()
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemGroupedBackground
        install(child: self.pageController)
        self.queryData()
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

extension DayViewPagingController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

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

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let _ = prevDate else {
            return nil
        }

        let vc = getReusableDayViewTableController()
        prevHash = vc.hash
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let _ = nextDate else {
            return nil
        }

        let vc = getReusableDayViewTableController()
        nextHash = vc.hash
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        switch state {
        case .historic(let model), .today(let model):
            if let vc = pendingViewControllers[0] as? DayViewTableController {
                if vc.hash == prevHash, let date = model.prevDate {
                    vc.queryData(for: date)
                } else if vc.hash == nextHash, let date = model.nextDate {
                    vc.queryData(for: date)
                }
            }
        default:
            break
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
        switch state {
        case .historic(let model), .today(let model):
            if let vc = pageViewController.viewControllers?[0] as? DayViewTableController {
                if vc.hash == prevHash, let date = model.prevDate {
                    self.queryData(for: date)
                } else if vc.hash == nextHash, let date = model.nextDate {
                    self.queryData(for: date)
                }
            }
        default:
            break
        }
        }
    }
}
