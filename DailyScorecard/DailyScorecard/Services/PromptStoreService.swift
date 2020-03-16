//
//  PromptStoreService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

struct NotImplementedError: Error {}
struct PromptDoesNotExist: Error {}

protocol PromptStoreService {
    func getPrompt(for id: Int) -> Result<Prompt, Error>
    func getAllPrompts() -> Result<[Prompt], Error>
    func getActivePrompts() -> Result<[Prompt], Error>
    func getPromptsForIdSet(ids: [Int]) -> Result<[Prompt], Error>
    func insert(prompt: String, isActive active: Bool) -> Result<Void, Error>
    func update(prompt: Prompt) -> Result<Void, Error>
    func delete(prompt: Prompt) -> Result<Void, Error>
}

class InMemoryPromptStoreService: PromptStoreService {
    var serviceProvider: ServiceProvider
    var prompts: [Int:Prompt] = [:]

    func getPrompt(for id: Int) -> Result<Prompt, Error> {
        guard let prompt = prompts[id] else {
            return .failure(PromptDoesNotExist())
        }
        return.success(prompt)
    }
    
    func getAllPrompts() -> Result<[Prompt], Error> {
        return .success([Prompt](self.prompts.values))
    }
    
    func getActivePrompts() -> Result<[Prompt], Error> {
        return .success([Prompt](self.prompts.values.filter({p in p.active})))
    }

    func getPromptsForIdSet(ids: [Int]) -> Result<[Prompt], Error> {
        return .success([Prompt](
            self.prompts.values.filter({ p in
                p.active || ids.contains(p.id)
            })
        ))
    }

    func insert(prompt: String, isActive active: Bool) -> Result<Void, Error> {
        let p = Prompt(id: newId(), prompt: prompt, active: active, sortOrder: newSortOrder())
        prompts[p.id] = p
        return .success(())
    }

    func update(prompt: Prompt) -> Result<Void, Error> {
        let id = prompt.id
        if !prompts.keys.contains(id) {
            return .failure(PromptDoesNotExist())
        }
        prompts[id] = prompt

        return .success(())
    }

    func delete(prompt: Prompt) -> Result<Void, Error> {
        if !prompts.keys.contains(prompt.id) {
            return .failure(PromptDoesNotExist())
        }
        prompts.removeValue(forKey: prompt.id)
        return .success(())
    }

    private func newId() -> Int {
        return ([Int](prompts.keys).max() ?? 0) + 1
    }

    private func newSortOrder() -> Int {
        return prompts.values.reduce(0) { (r,v) in
            max(r, v.sortOrder) + 1
        }
    }
    
    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
