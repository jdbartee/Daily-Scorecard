//
//  DayViewService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/17/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

protocol DayViewService: BaseService {
    func dayViewModel(for date: Date) -> AnyPublisher<DayViewModel, Never>
    func setScore(for entry: DayViewModel.DayViewEntry, date: Date, to score: Score)
}

class InMemoryDayViewService: DayViewService {
    var serviceProvider: ServiceProvider

    var entryStore: EntryStoreService {
        serviceProvider.entryStoreService
    }
    var promptStore: PromptStoreService {
        serviceProvider.promptStoreService
    }
    var notificationService: NotificationService {
        serviceProvider.notificationService
    }

    func dayViewModel(for date: Date) -> AnyPublisher<DayViewModel, Never> {
        return Future<DayViewModel, Never> { promise in
            let date = date
            let entries = (try? self.entryStore.getEntries(for: date).get()) ?? []
            let prompts = (try? self.promptStore.getPromptsForIdSet(ids: entries.map({$0.promptId})).get()) ?? []


            var dayViewEntries = [DayViewModel.DayViewEntry]()

            for prompt in prompts.sorted(by: {(p1, p2) in p1.sortOrder < p2.sortOrder}) {
                if let entry = entries.first(where: {$0.promptId == prompt.id}) {
                    if  (entry.score != .None || prompt.active ) {
                        dayViewEntries.append(DayViewModel.DayViewEntry(withPrompt: prompt, andEntry: entry, using: prompt.scoreProvider))
                    }
                } else {
                    if let entry = self.entryStore.insert(promptId: prompt.id, date: date, score: .None).toOptional() {
                        dayViewEntries.append(DayViewModel.DayViewEntry(withPrompt: prompt, andEntry: entry, using: prompt.scoreProvider))
                    }
                }
            }
            promise(.success(DayViewModel(date: date, entries: dayViewEntries)))
        }.eraseToAnyPublisher()
    }

    func setScore(for entry: DayViewModel.DayViewEntry, date: Date, to score: Score) {
        if let id = entry.entryId {
            if var e = try? entryStore.getEntry(id: id).get() {
                e.score = score
                let _ = entryStore.update(entry: e)
            }
        } else {
            let _ = entryStore.insert(promptId: entry.promptId, date: date, score: score)
        }
        
        notificationService.updateSchedule()
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
