//
//  DayViewModel.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/16/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

struct DayViewModel {
    struct DayViewEntry: Hashable {
        var entryId: Int?
        var promptId: Int
        
        var prompt: String
        var score: String
    }

    var date: Date
    var entries: [DayViewEntry]
}

extension DayViewModel.DayViewEntry {
    init(withPrompt prompt: Prompt, andEntry entry: Entry? = nil, using scoreProvider: ScoreProvider) {
        self.entryId = entry?.id
        self.promptId = prompt.id

        self.score = scoreProvider.shortLabel(for: entry?.score)
        self.prompt = prompt.prompt
    }
}
