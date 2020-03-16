//
//  PromptEditViewService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/20/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

protocol PromptEditViewService {
    func newPrompt() -> AnyPublisher<PromptEditViewModel, Never>
    func editPrompt(prompt: PromptEditViewModel) -> AnyPublisher<PromptEditViewModel, Never>
    func savePrompt(prompt: PromptEditViewModel)
}

class InMemoryPromptEditViewService: PromptEditViewService {
    var serviceProvider: ServiceProvider

    lazy var storeService: PromptStoreService = {
        self.serviceProvider.promptStoreService
    }()


    func newPrompt() -> AnyPublisher<PromptEditViewModel, Never> {
        Just(PromptEditViewModel(prompt: "", active: true, sortOrder: 0)).eraseToAnyPublisher()
    }

    func editPrompt(prompt: PromptEditViewModel)  -> AnyPublisher<PromptEditViewModel, Never> {
        Just(prompt).eraseToAnyPublisher()
    }

    func savePrompt(prompt: PromptEditViewModel) {
        if let id = prompt.id {
            let _ = storeService.update(prompt: Prompt(id: id, prompt: prompt.prompt, active: prompt.active, sortOrder: prompt.sortOrder))
        } else {
            let _ = storeService.insert(prompt: prompt.prompt, isActive: prompt.active)
        }
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
