//
//  ChartViewService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/5/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

protocol ChartViewService {
    var filter: ChartViewServiceFilter { get set }
    func chartModel(for filter: ChartViewServiceFilter) -> AnyPublisher<ChartViewModel, Never>
    func dateRange() -> DateInterval
}

enum ChartViewServiceFilter: Hashable {
    case all
    case prompt(Prompt)
}
class CCHartViewService: ChartViewService, BaseService {
    var serviceProvider: ServiceProvider

    var entryStore: EntryStoreService {
        serviceProvider.entryStoreService
    }
    var promptStore: PromptStoreService {
        serviceProvider.promptStoreService
    }
    var scoreProvider: ScoreProvider {
        serviceProvider.scoreProvider
    }

    func dateRange() -> DateInterval {
        let today = Calendar.current.today()
        let start = Calendar.current.date(byAdding: .day, value: -6, to: today)
        return DateInterval(start: start!, end: today)
    }

    var filter: ChartViewServiceFilter = .all

    func chartModel(for filter: ChartViewServiceFilter) -> AnyPublisher<ChartViewModel, Never> {
        return Future<ChartViewModel, Never>({ promise in
            let dateRange = self.dateRange()
            var percentages = [Float]()
            var dates = [Date]()
            var filters = [ChartViewServiceFilter]()
            filters.append(.all)
            for prompt in self.promptStore.getAllPrompts().toOptional()?.sorted(by: {(p1,p2) in p1.sortOrder < p2.sortOrder}) ?? [] {
                filters.append(.prompt(prompt))
            }
            var date = dateRange.start

            while dateRange.contains(date) {
                let entries = (try? self.entryStore.getEntries(for: date).get()) ?? []
                let scores = entries.filter { entry in
                    switch filter {
                    case .all:
                        return true
                    case .prompt(let prompt):
                        return prompt.id == entry.promptId
                    }
                }.map { entry in
                    self.scoreProvider.numericValue(for: entry.score)
                }.filter({ score in
                    score != nil
                }).map( { score in
                    return (score!) / self.scoreProvider.maxNumericValue()
                })

                let percentage = scores.reduce(Float(0.0), {(r,v) in r + v}) / Float(scores.count)
                percentages.append(percentage)
                dates.append(date)

                date = Calendar.current.nextDay(date)!
            }
            let model = ChartViewModel(percentages: percentages, dates: dates, activeFilter: filter, filters: filters)
            promise(.success(model))
        }).delay(for: .seconds(0.5), scheduler: DispatchQueue.main).eraseToAnyPublisher()
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
