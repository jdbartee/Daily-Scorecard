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
    var serviceProvider: ServiceProvider!
    var flowController: AppFlowController!

    lazy var pageController: UIPageViewController = {
        let dvc = nextDayViewController()
        dvc.date = initalDate()

        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self
        vc.delegate = self
        vc.setViewControllers([dvc], direction: .reverse, animated: true, completion: nil)

        vc.view.addSubview(self.dateView)

        NSLayoutConstraint.activate([
            dateView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -50),
            dateView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor, constant: 0)
        ])

        return vc
    }()

    func initalDate() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    lazy var dateLabel: UILabel = {
        var label = UILabel()
        label.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        //label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.sizeToFit()
        return label
    }()

    lazy var blurEffect = UIBlurEffect(style: .systemMaterialDark)

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

    lazy var reusableDayViewControllers = Set<DayViewController>()

    func nextDayViewController() -> DayViewController {
        if let vc = reusableDayViewControllers.filter({$0.parent == nil}).first {
            vc.prepareForReuse()
            return vc
        } else {
            let vc = self.newDayViewController()
            reusableDayViewControllers.insert(vc)
            return vc
        }
    }

    func newDayViewController() -> DayViewController {
        let vc = DayViewController.instantiate()
        vc.flowController = self.flowController
        vc.service = self.serviceProvider.dayViewService
        vc.scoreProvider = self.serviceProvider.scoreProvider
        return vc
    }

    override func loadView() {
        view = UIView()
        install(child: self.pageController)
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

extension DayViewPagingController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? DayViewController,
            let date = Calendar.current.prevDay(viewController.date) else {
            return nil
        }

        let vc = nextDayViewController()
        vc.date = date
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? DayViewController,
            let date = Calendar.current.nextDay(viewController.date),
            !Calendar.current.isDateInToday(viewController.date) else {
            return nil
        }

        let vc = nextDayViewController()
        vc.date = date
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers[0] as? DayViewController {
            self.dateLabel.text = DateFormatter.localizedString(from: viewController.date, dateStyle: .medium, timeStyle: .none)
            self.dateLabel.sizeToFit()
        }
    }
}
