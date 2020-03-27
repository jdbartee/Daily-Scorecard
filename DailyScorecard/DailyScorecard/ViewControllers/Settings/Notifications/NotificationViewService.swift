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

    private var defaultHour = 19
    private var defaultMinute = 0

    func model() -> AnyPublisher<NotificationViewModel, Never> {

        return Future<NotificationViewModel, Never> () { promise in
            self.serviceProvider.notificationService.checkSettings() {
                if self.serviceProvider.notificationService.denied {
                    promise(.success(.denied))
                }
                if self.serviceProvider.notificationService.isActive {
                    promise(.success(.on(hour: self.serviceProvider.notificationService.scheduledHour ?? self.defaultHour,
                                         minute: self.serviceProvider.notificationService.scheduledMinute ?? self.defaultMinute)))
                } else {
                    promise(.success((.off)))
                }
            }
        }.eraseToAnyPublisher()
    }

    func setActive(_ active: Bool) {
        self.serviceProvider.notificationService
            .setSchedule(active: active,
                         hour: self.serviceProvider.notificationService.scheduledHour ?? self.defaultHour,
                         minute: self.serviceProvider.notificationService.scheduledMinute ?? self.defaultMinute)
    }

    func setTime(hour: Int, minute: Int) {
        self.serviceProvider.notificationService
            .setSchedule(active: self.serviceProvider.notificationService.isActive,
                         hour: hour,
                         minute: minute)
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
