//
//  Prompt.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation


struct Prompt {

    var id: UUID
    var prompt: String
    var active: Bool
    var sortOrder: Int
    var scoreProvider: ScoreProvider
}

extension Prompt: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(prompt)
        hasher.combine(active)
        hasher.combine(sortOrder)
        hasher.combine(scoreProvider.key)
    }

    static func == (lhs: Prompt, rhs: Prompt) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
