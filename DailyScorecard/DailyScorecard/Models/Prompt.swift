//
//  Prompt.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation


struct Prompt: Hashable {
    var id: UUID
    var prompt: String
    var active: Bool
    var sortOrder: Int
}
