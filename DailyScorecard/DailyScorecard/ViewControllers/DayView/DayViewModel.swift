//
//  DayViewModel.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/16/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

enum DayViewViewModel {
    case none
    case error(error: String)
    case value(model: DayViewModel)
}

struct DayViewModel {
    struct DayViewEntry: Hashable {
        var entryId: UUID?
        var promptId: UUID
        
        var prompt: String
        var score: Score?
        var scoreProvider: ScoreProvider
    }

    var date: Date
    var entries: [DayViewEntry]
}

extension DayViewModel.DayViewEntry {
    init(withPrompt prompt: Prompt, andEntry entry: Entry? = nil, using scoreProvider: ScoreProvider) {
        self.entryId = entry?.id
        self.promptId = prompt.id

        self.score = entry?.score
        self.prompt = prompt.prompt
        self.scoreProvider = scoreProvider
    }
}
