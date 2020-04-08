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
    func editPrompt(prompt: Prompt) -> AnyPublisher<PromptEditViewModel, Never>
    func savePrompt(prompt: PromptEditViewModel)
}

class InMemoryPromptEditViewService: PromptEditViewService {
    var serviceProvider: ServiceProvider

    var scoreProviderService: ScoreProviderService {
        self.serviceProvider.scoreProviderService
    }

    var storeService: PromptStoreService {
        self.serviceProvider.promptStoreService
    }

    var scoreProviderNames: [(String, String)] {
        self.scoreProviderService.scoreProviders.reduce(into: [(String, String)](), {$0.append(($1.key, $1.displayName))})
    }

    func newPrompt() -> AnyPublisher<PromptEditViewModel, Never> {
        Just(
            PromptEditViewModel(
                id: nil,
                prompt: "",
                active: true,
                sortOrder: 0,
                scoreProviderKey: self.scoreProviderService.defaultScoreProvider.key,
                scoreProviderKeysAndNames: self.scoreProviderNames)
        ).eraseToAnyPublisher()
    }

    func editPrompt(prompt: Prompt)  -> AnyPublisher<PromptEditViewModel, Never> {
        Just(
            PromptEditViewModel(
                id: prompt.id,
                prompt: prompt.prompt,
                active: prompt.active,
                sortOrder: prompt.sortOrder,
                scoreProviderKey: prompt.scoreProvider.key,
                scoreProviderKeysAndNames: self.scoreProviderNames)
        ).eraseToAnyPublisher()
    }

    func savePrompt(prompt: PromptEditViewModel) {
        if let id = prompt.id {
            let _ = storeService.update(prompt: Prompt(id: id, prompt: prompt.prompt, active: prompt.active, sortOrder: prompt.sortOrder, scoreProvider: ScoreFactory.scoreProvider(for: prompt.scoreProviderKey)))
        } else {
            let _ = storeService.insert(prompt: prompt.prompt, isActive: prompt.active, scoreProvider: ScoreFactory.scoreProvider(for: prompt.scoreProviderKey))
        }
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
