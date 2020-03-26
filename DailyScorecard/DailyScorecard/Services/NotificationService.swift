//
//  NotificationService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService: NSObject, BaseService, UNUserNotificationCenterDelegate {
    var serviceProvider: ServiceProvider
    private var notificationId: String = "daily.reminder.notification"
    private var userDefaultScheduleKey = "user.default.schedule.key"
    private var userDefaultActiveKey = "user.default.active.key"

    private(set) var scheduledHour: Int? {
        get {
            UserDefaults().object(forKey: userDefaultScheduleKey) as? Int
        }
        set {
            if let value = newValue {
                UserDefaults().set(value, forKey: userDefaultScheduleKey)
            } else {
                UserDefaults().removeObject(forKey: userDefaultScheduleKey)
                self.isActive = false
            }
        }
    }

    private(set) var isActive: Bool {
        get {
            UserDefaults().bool(forKey: userDefaultActiveKey)
        }
        set {
            UserDefaults().set(newValue, forKey: userDefaultActiveKey)
        }
    }

    func updateSchedule() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        self.setSchedule(active: self.isActive, hour: self.scheduledHour)
    }

    func setSchedule(active: Bool, hour: Int?) {
        isActive = active
        scheduledHour = hour

        if isActive && scheduledHour != nil {
            UNUserNotificationCenter.current().getNotificationSettings() { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestPermission()
                case .authorized, .provisional:
                    self.scheduleNotifications()
                case .denied:
                    self.isActive = false
                @unknown default:
                    break
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    private func nextNotificationDateComponents() -> DateComponents? {
        let calendar = Calendar.current
        let now = Date()

        guard let scheduledHour = scheduledHour else {
            return nil
        }

        var notificationComponents = DateComponents()
        notificationComponents.calendar = calendar
        notificationComponents.hour = scheduledHour

        if serviceProvider.entryStoreService.getEntries(for: now).toOptional()?.reduce(true, { r,e in r && e.score != .None }) == true {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                notificationComponents.day = calendar.dateComponents([.day], from: tomorrow).day
            }
        }

        return notificationComponents

    }
    private func scheduleNotifications() {
        if let dateComponents = nextNotificationDateComponents() {
            let content = UNMutableNotificationContent()
            content.title = serviceProvider.appDetails.appName
            content.body = "Fill out your score card for the day."

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, error in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        })
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
