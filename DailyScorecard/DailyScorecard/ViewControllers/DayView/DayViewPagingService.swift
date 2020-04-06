//
//  DayViewPagingService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 4/2/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

class DayViewPagingService: BaseService {
    var serviceProvider: ServiceProvider

    func model() -> AnyPublisher<DayViewPagingState, Never> {
        return Future<DayViewPagingState, Never> { promise in
            let date = Calendar.current.today()
            let model = DayViewPagingModel(
                prevDate: Calendar.current.prevDay(date),
                nextDate: nil,
                currentDate: date,
                currentDateLabel: "Today")

            promise(.success(.today(model)))
        }.eraseToAnyPublisher()
    }

    func model(for date: Date) -> AnyPublisher<DayViewPagingState, Never> {

        if Calendar.current.isDateInToday(date) {
            return Future<DayViewPagingState, Never> { promise in
                let date = Calendar.current.today()
                let model = DayViewPagingModel(
                    prevDate: Calendar.current.prevDay(date),
                    nextDate: nil,
                    currentDate: date,
                    currentDateLabel: "Today")

                promise(.success(.historic(model)))
            }.eraseToAnyPublisher()
        } else {
            return Future<DayViewPagingState, Never> { promise in
                let model = DayViewPagingModel(
                    prevDate: Calendar.current.prevDay(date),
                    nextDate: Calendar.current.nextDay(date),
                    currentDate: date,
                    currentDateLabel: self.label(for: date))
                promise(.success(.historic(model)))
            }.eraseToAnyPublisher()
        }
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }

    private func label(for date: Date) -> String {
         DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
}
