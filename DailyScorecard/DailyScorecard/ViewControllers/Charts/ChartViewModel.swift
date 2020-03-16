//
//  ChartViewModel.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/5/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

struct ChartViewModel {
    
    var percentages: [Float]
    var dates: [Date]
    var activeFilter: ChartViewServiceFilter
    var filters: [ChartViewServiceFilter]
}
