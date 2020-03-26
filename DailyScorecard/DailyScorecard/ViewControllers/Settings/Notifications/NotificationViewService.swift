//
//  NotificationViewService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

class NotificationViewService: BaseService {
    var serviceProvider: ServiceProvider

    func model() -> AnyPublisher<NotificationViewModel, Never> {
        if serviceProvider.notificationService.isActive {
            return Just(.on(hour: serviceProvider.notificationService.scheduledHour!, minute: serviceProvider.notificationService.scheduledMinute!)).eraseToAnyPublisher()
        } else {
            return Just(.off).eraseToAnyPublisher()
        }
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
