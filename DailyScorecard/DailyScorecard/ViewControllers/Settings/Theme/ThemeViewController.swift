//
//  ThemeViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class ThemeViewController: UIViewController {
    var serviceProvider: ServiceProvider?
    private var model: ThemeViewModel = .none {
        didSet {
            tableView.reloadData()
        }
    }
    private var cancelBag = CancelBag()

    private var themes: [Theme] {
        switch model {
        case .none:
            return []
        case .model(let model):
            return model
        }
    }

    private var service: ThemeViewService? {
        serviceProvider?.themeViewService
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(ThemeTableViewCell.self, forCellReuseIdentifier: "theme")
        return tableView
    }()

    lazy var tableViewConstraints: [NSLayoutConstraint] = {
        return [
            self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
    }()

    override func viewWillAppear(_ animated: Bool) {
        service?
            .model()
            .receive(on: DispatchQueue.main).assign(to: \.model, on: self)
            .store(in: &cancelBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        cancelBag.cancelAll()
    }

    override func viewWillLayoutSubviews() {
        NSLayoutConstraint.activate(tableViewConstraints)
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .systemGroupedBackground
        self.title = NSLocalizedString("Themes_Title", comment: "")

        self.view.addSubview(tableView)
    }
}

extension ThemeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.themes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "theme") as? ThemeTableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        let theme = themes[indexPath.row]

        cell.colorView.backgroundColor = theme.tintColor
        cell.themeLabel.text = theme.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        service?.setTheme(theme)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}


class ThemeTableViewCell: UITableViewCell {

    lazy var themeLabel: UILabel = {
        let themeLabel = UILabel()
        themeLabel.translatesAutoresizingMaskIntoConstraints = false
        themeLabel.adjustsFontForContentSizeCategory = true
        themeLabel.font = .preferredFont(forTextStyle: .body)

        themeLabel.text = ""
        themeLabel.sizeToFit()
        return themeLabel
    }()

    lazy var colorView: UIView = {
        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 8
        colorView.backgroundColor = .red

        return colorView
    }()

    lazy var layoutConstraints: [NSLayoutConstraint] = {
        return [
            self.colorView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            self.colorView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            self.colorView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
            self.colorView.widthAnchor.constraint(equalTo: self.colorView.heightAnchor),

            self.themeLabel.leadingAnchor.constraint(equalTo: self.colorView.trailingAnchor, constant: 20),
            self.themeLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            self.themeLabel.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
            self.themeLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
        ]
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.layoutMargins = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        contentView.addSubview(colorView)
        contentView.addSubview(themeLabel)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }

    required init?(coder: NSCoder) {
        return nil
    }
}
