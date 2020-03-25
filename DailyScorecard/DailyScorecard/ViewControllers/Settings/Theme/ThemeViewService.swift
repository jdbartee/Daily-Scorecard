//
//  ThemeViewService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine


class ThemeViewService: BaseService {
    var serviceProvider: ServiceProvider

    func model() -> AnyPublisher<ThemeViewModel, Never> {
        self.serviceProvider.themeService.themes()
            .map({ return ThemeViewModel.model(model: $0) })
            .eraseToAnyPublisher()
    }

    func setTheme(_ theme: Theme) {
        self.serviceProvider.themeService.setTheme(theme)
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
