//
//  PromptTableViewService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/19/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

protocol PromptTableViewService: BaseService{
    func promptTableViewModel() -> AnyPublisher<PromptTableViewModel,Never>
    func update(prompt: Prompt)
}

class InMemoryPromptTableViewService: PromptTableViewService {

    var serviceProvider: ServiceProvider

    lazy var storeService = {
        return self.serviceProvider.promptStoreService
    }()

    func promptTableViewModel() -> AnyPublisher<PromptTableViewModel, Never> {
        Future<PromptTableViewModel, Never>({ promise in
            let res = self.storeService.getAllPrompts()
            var model: PromptTableViewModel
            switch res {
            case .success(let prompts):
                model = PromptTableViewModel(
                    activePrompts: prompts
                        .filter({prompt in prompt.active})
                        .sorted(by: { (p1, p2) in p1.sortOrder < p2.sortOrder}),
                    inactivePrompts: prompts
                        .filter({prompt in !prompt.active})
                        .sorted(by: {(p1, p2) in p1.sortOrder < p2.sortOrder}))
            case .failure(_):
                model = PromptTableViewModel(activePrompts: [], inactivePrompts: [])
            }
            promise(.success(model))
        }).eraseToAnyPublisher()
    }

    func update(prompt: Prompt) {
        try? storeService.update(prompt: prompt).get()
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
