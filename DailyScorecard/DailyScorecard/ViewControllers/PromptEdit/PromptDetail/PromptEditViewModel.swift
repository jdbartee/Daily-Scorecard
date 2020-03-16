//
//  PromptEditViewModel.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/20/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

struct PromptEditViewModel: Hashable {
    var id: Int?
    var prompt: String
    var active: Bool
    var sortOrder: Int
}

extension PromptEditViewModel {
    init(prompt: Prompt) {
        self.id = prompt.id
        self.prompt = prompt.prompt
        self.active = prompt.active
        self.sortOrder = prompt.sortOrder
    }
}
