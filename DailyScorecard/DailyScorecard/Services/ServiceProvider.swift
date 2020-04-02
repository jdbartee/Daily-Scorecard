//
//  ServiceProvider.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/17/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import CoreData

protocol BaseService {
    var serviceProvider: ServiceProvider { get }
}

class ServiceProvider {
    lazy var cancelBag = CancelBag()
    lazy var appDetails: AppDetailService = AppDetailService(self)
    lazy var dayViewPagingService: DayViewPagingService = DayViewPagingService(self)
    lazy var dayViewService: DayViewService = InMemoryDayViewService(self)
    lazy var promptTableViewService: PromptTableViewService = InMemoryPromptTableViewService(self)
    lazy var promptEditViewService: PromptEditViewService = InMemoryPromptEditViewService(self)
    lazy var chartViewService: ChartViewService = CCHartViewService(self)

    lazy var themeViewService: ThemeViewService = ThemeViewService(self)
    lazy var notificationViewService: NotificationViewService = NotificationViewService(self)

    lazy var promptStoreService: PromptStoreService = CoreDataPromptStoreService(self)
    lazy var entryStoreService: EntryStoreService = CoreDataEntryStoreService(self)

    lazy var themeService: ThemeService = ThemeService(self)
    lazy var notificationService: NotificationService = NotificationService(self)

    lazy var scoreProvider: ScoreProvider = ScoreProvider(self)
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "DailyScorecard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    init() {
    }
}
