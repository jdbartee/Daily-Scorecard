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
    func insert(prompt: String, isActive active: Bool) -> Result<Void, Error>
    func update(prompt: Prompt) -> Result<Void, Error>
    func delete(prompt: Prompt) -> Result<Void, Error>
}

class InMemoryPromptStoreService: PromptStoreService {
    var serviceProvider: ServiceProvider
    var prompts: [UUID:Prompt] = [:]

    func getPrompt(for id: UUID) -> Result<Prompt, Error> {
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

    func getPromptsForIdSet(ids: [UUID]) -> Result<[Prompt], Error> {
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

    private func newId() -> UUID {
        return UUID()
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

    func insert(prompt: String, isActive active: Bool) -> Result<Void, Error> {
        do {
            let managedPrompt = ManagedPrompt(context: persistentContainer.viewContext)
            managedPrompt.id = UUID()
            managedPrompt.prompt = prompt
            managedPrompt.active = active
            managedPrompt.sortOrder = Int64(newSortOrder())

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
            self.init(id: id, prompt: prompt, active: active, sortOrder: sortOrder)
        } else {
            return nil
        }
    }
}
