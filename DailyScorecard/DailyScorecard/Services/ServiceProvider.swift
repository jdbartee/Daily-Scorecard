//
//  ServiceProvider.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/17/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

protocol BaseService {
    var serviceProvider: ServiceProvider { get }
}

class ServiceProvider {
    lazy var cancelBag = CancelBag()
    lazy var dayViewService: DayViewService = InMemoryDayViewService(self)
    lazy var promptTableViewService: PromptTableViewService = InMemoryPromptTableViewService(self)
    lazy var promptEditViewService: PromptEditViewService = InMemoryPromptEditViewService(self)
    lazy var chartViewService: ChartViewService = CCHartViewService(self)

    lazy var promptStoreService: PromptStoreService = InMemoryPromptStoreService(self)
    lazy var entryStoreService: EntryStoreService = InMemoryEntryStoreService(self)
    lazy var scoreProvider: ScoreProvider = ScoreProvider(self)

    init() {
        self.loadSampleData()
    }

    private func loadSampleData() {
        let _ = self.promptStoreService.insert(prompt: "Eat Healthy", isActive: true)
        let _ = self.promptStoreService.insert(prompt: "Work on Personal Projects", isActive: true)
        let _ = self.promptStoreService.insert(prompt: "Relax", isActive: true)
        let _ = self.promptStoreService.insert(prompt: "Stay off Reddit", isActive: true)

        var day = Calendar.current.today()
        let threeWeeksAgo = Calendar.current.date(byAdding: .day, value: -7, to: day)!
        repeat {
            self.dayViewService.dayViewModel(for: day)
                .sink(receiveValue: { model in
                    for entry in model.entries {
                        self.dayViewService.setScore(for: entry, date: day, to: self.scoreProvider.scores.randomElement() ?? .Ok)
                    }
                })
                .store(in: &cancelBag)
            day = Calendar.current.prevDay(day)!
        } while day.compare(threeWeeksAgo) == .orderedDescending
    }
}
