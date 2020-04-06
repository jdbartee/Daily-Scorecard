//
//  DayViewPagingModel.swift
//  DailyScorecard
//
//  Created by JD Bartee on 4/2/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

enum DayViewPagingState: Equatable {
    case today(DayViewPagingModel)
    case historic(DayViewPagingModel)
    case none
}

struct DayViewPagingModel: Equatable {
    var prevDate: Date?
    var nextDate: Date?
    var currentDate: Date
    var currentDateLabel: String
}
