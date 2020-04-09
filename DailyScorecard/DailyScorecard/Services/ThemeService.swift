//
//  ThemeService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ThemeService: BaseService {
    var userDefaultsThemeKey = "user.selected.theme"
    var defaultTheme = NSLocalizedString("Blue", comment: "")

    lazy var cardInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    lazy var viewInsets = NSDirectionalEdgeInsets(top: 35, leading: 8, bottom: 35, trailing: 8)

    var serviceProvider: ServiceProvider

    private var tintColors: [String:UIColor] = [
        NSLocalizedString("Orange", comment: ""): .systemOrange,
        NSLocalizedString("Purple", comment: ""): .systemPurple,
        NSLocalizedString("Blue", comment: ""): .systemBlue,
        NSLocalizedString("Green", comment: ""): .systemGreen,
        NSLocalizedString("Cyan", comment: ""): .cyan,
        NSLocalizedString("Red", comment: ""): .systemRed,
    ]

    func themes() -> AnyPublisher<[Theme], Never> {
        return Future<[Theme], Never>({ promise in
            let themes = self.tintColors.map({key, value in Theme(name: key, tintColor: value)})
            promise(.success(themes))
        }).eraseToAnyPublisher()
    }

    func setTheme(_ theme: Theme) {
        DispatchQueue.main.async {
            UserDefaults().set(theme.name, forKey: self.userDefaultsThemeKey)
            self.applyDefaultTheme()
        }
    }

    func applyDefaultTheme() {
        let themeKey = UserDefaults().string(forKey: userDefaultsThemeKey) ?? defaultTheme

        UIView.appearance().tintColor = tintColors[themeKey]
        
        let windows = UIApplication.shared.windows
        for window in windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }

    init(_ serviceProvide: ServiceProvider) {
        self.serviceProvider = serviceProvide
    }
}
