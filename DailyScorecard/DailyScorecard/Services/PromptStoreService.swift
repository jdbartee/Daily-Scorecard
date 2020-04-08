//
//  PromptStoreService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/24/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import CoreData

struct NotImplementedError: Error {}
struct PromptDoesNotExist: Error {}

protocol PromptStoreService {
    func getPrompt(for id: UUID) -> Result<Prompt, Error>
    func getAllPrompts() -> Result<[Prompt], Error>
    func getActivePrompts() -> Result<[Prompt], Error>
    func getPromptsForIdSet(ids: [UUID]) -> Result<[Prompt], Error>
    func insert(prompt: String, isActive active: Bool, scoreProvider: ScoreProvider) -> Result<Void, Error>
    func update(prompt: Prompt) -> Result<Void, Error>
    func delete(prompt: Prompt) -> Result<Void, Error>
}


class CoreDataPromptStoreService: PromptStoreService {
    var serviceProvider: ServiceProvider
    var persistentContainer: NSPersistentCloudKitContainer { self.serviceProvider.persistentContainer }
    
    func getPrompt(for id: UUID) -> Result<Prompt, Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedPrompt> = ManagedPrompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            guard let managedPrompt = try persistentContainer.viewContext.fetch(fetchRequest).first,
                  let prompt = Prompt(managedPrompt: managedPrompt) else {
                return .failure(QueryFailed())
            }
            return .success(prompt)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func getAllPrompts() -> Result<[Prompt], Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedPrompt> = ManagedPrompt.fetchRequest()
            let managedPrompts = try persistentContainer.viewContext.fetch(fetchRequest)
            let prompts = managedPrompts.compactMap({Prompt(managedPrompt: $0)})
            return .success(prompts)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func getActivePrompts() -> Result<[Prompt], Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedPrompt> = ManagedPrompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "active == %@", true)
            let managedPrompts = try persistentContainer.viewContext.fetch(fetchRequest)
            let prompts = managedPrompts.compactMap({Prompt(managedPrompt: $0)})
            return .success(prompts)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func getPromptsForIdSet(ids: [UUID]) -> Result<[Prompt], Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedPrompt> = ManagedPrompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "active == %@ OR id IN %@", argumentArray: [true, ids])
            let managedPrompts = try persistentContainer.viewContext.fetch(fetchRequest)
            let prompts = managedPrompts.compactMap({Prompt(managedPrompt: $0)})
            return .success(prompts)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func insert(prompt: String, isActive active: Bool, scoreProvider: ScoreProvider) -> Result<Void, Error> {
        do {
            let managedPrompt = ManagedPrompt(context: persistentContainer.viewContext)
            managedPrompt.id = UUID()
            managedPrompt.prompt = prompt
            managedPrompt.active = active
            managedPrompt.sortOrder = Int64(newSortOrder())
            managedPrompt.scoreProviderKey = scoreProvider.key

            try persistentContainer.viewContext.save()
            return .success(())
        } catch {
            return .failure(QueryFailed())
        }
    }

    func update(prompt: Prompt) -> Result<Void, Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedPrompt> = ManagedPrompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", prompt.id.uuidString)
            guard let managedPrompt = try persistentContainer.viewContext.fetch(fetchRequest).first else {
                return .failure(QueryFailed())
            }
            managedPrompt.id = prompt.id
            managedPrompt.active = prompt.active
            managedPrompt.prompt = prompt.prompt
            managedPrompt.sortOrder = Int64(prompt.sortOrder)
            managedPrompt.scoreProviderKey = prompt.scoreProvider.key

            try persistentContainer.viewContext.save()
            return .success(())
        } catch {
            return .failure(QueryFailed())
        }
    }

    func delete(prompt: Prompt) -> Result<Void, Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedPrompt> = ManagedPrompt.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", prompt.id.uuidString)
            guard let managedPrompt = try persistentContainer.viewContext.fetch(fetchRequest).first else {
                return .failure(QueryFailed())
            }
            persistentContainer.viewContext.delete(managedPrompt)

            try persistentContainer.viewContext.save()
            return .success(())
        } catch {
            return .failure(QueryFailed())
        }
    }

    private func newSortOrder() -> Int {
        return self.getAllPrompts().toOptional()?.reduce(0) { (r,v) in
            max(r, v.sortOrder) + 1
        } ?? 0
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}

private extension Prompt {
    init?(managedPrompt: ManagedPrompt) {
        if let id = managedPrompt.id,
            let prompt = managedPrompt.prompt,
            let sortOrder = Int(exactly: managedPrompt.sortOrder){
            let active = managedPrompt.active
            let scoreProvider = ScoreFactory.scoreProvider(for: managedPrompt.scoreProviderKey)
            self.init(id: id, prompt: prompt, active: active, sortOrder: sortOrder, scoreProvider: scoreProvider)
        } else {
            return nil
        }
    }
}
