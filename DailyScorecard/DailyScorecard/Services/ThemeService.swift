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
    var defaultTheme = "Blue"

    var serviceProvider: ServiceProvider

    private var tintColors: [String:UIColor] = [
        "Orange": .systemOrange,
        "Purple": .systemPurple,
        "Blue": .systemBlue
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
