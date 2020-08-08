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
    private var userDefaultScheduleHourKey = "user.default.schedule.hour.key"
    private var userDefaultScheduleMinuteKey = "user.default.schedule.minute.key"
    private var userDefaultActiveKey = "user.default.active.key"

    private(set) var scheduledHour: Int? {
        get {
            UserDefaults().object(forKey: userDefaultScheduleHourKey) as? Int
        }
        set {
            if let value = newValue {
                UserDefaults().set(value, forKey: userDefaultScheduleHourKey)
            } else {
                UserDefaults().removeObject(forKey: userDefaultScheduleHourKey)
                self.isActive = false
            }
        }
    }
    
    private(set) var scheduledMinute: Int? {
        get {
            UserDefaults().object(forKey: userDefaultScheduleMinuteKey) as? Int
        }
        set {
            if let value = newValue {
                UserDefaults().set(value, forKey: userDefaultScheduleMinuteKey)
            } else {
                UserDefaults().removeObject(forKey: userDefaultScheduleMinuteKey)
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

    private(set) var denied: Bool = false

    func updateSchedule() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        self.setSchedule(active: self.isActive, hour: self.scheduledHour, minute: self.scheduledMinute)
    }

    func setSchedule(active: Bool, hour: Int?, minute: Int?) {

        if active && hour != nil && minute != nil {

            isActive = active
            scheduledHour = hour
            scheduledMinute = minute

            UNUserNotificationCenter.current().getNotificationSettings() { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestPermission()
                case .authorized, .provisional:
                    self.scheduleNotifications()
                case .denied:
                    self.isActive = false
                    self.denied = true
                case .ephemeral:
                    self.scheduleNotifications()
                @unknown default:
                    break
                }
            }
        } else {
            isActive = false
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    private func nextNotificationDateComponents() -> DateComponents? {
        let calendar = Calendar.current
        let now = calendar.today()

        guard let scheduledHour = scheduledHour, let scheduledMinute = scheduledMinute  else {
            return nil
        }

        var notificationComponents = DateComponents()
        notificationComponents.calendar = calendar
        notificationComponents.hour = scheduledHour
        notificationComponents.minute = scheduledMinute

        if serviceProvider.entryStoreService.getEntries(for: now).toOptional()?.reduce(true, { r,e in r && e.score != .None }) == true {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) {
                notificationComponents.day = calendar.dateComponents([.day], from: tomorrow).day
            }
        }

        return notificationComponents

    }
    private func scheduleNotifications() {
        self.denied = false
        if let dateComponents = nextNotificationDateComponents() {
            let content = UNMutableNotificationContent()
            content.title = serviceProvider.appDetails.appName
            content.body = NSLocalizedString("Notification_Text", comment: "")

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, error in
            if granted == true && error == nil {
                self.scheduleNotifications()
            } else {
                self.isActive = false
            }
        })
    }

    func checkSettings(_ completion: (() -> Void)?) {
        UNUserNotificationCenter.current().getNotificationSettings() { settings in
            self.denied = settings.authorizationStatus == .denied
            completion?()
        }
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
        super.init()
    }
}
