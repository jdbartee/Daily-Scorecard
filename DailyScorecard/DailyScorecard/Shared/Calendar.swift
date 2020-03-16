//
//  Calendar.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/1/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

extension Calendar {
    func today() -> Date {
        self.startOfDay(for: Date())
    }

    func prevDay(_ date: Date) -> Date? {
        return self.date(byAdding: .day, value: -1, to: date)
    }

    func nextDay(_ date: Date) -> Date? {
        return self.date(byAdding: .day, value: 1, to: date)
    }
}
