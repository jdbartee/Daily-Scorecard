//
//  Entry.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/27/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

struct Entry: Hashable {
    var id: UUID
    var promptId: UUID
    var date: Date
    var score: Score
}
