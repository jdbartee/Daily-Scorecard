//
//  AppModel.swift
//  DailyScorecard
//
//  Created by jd on 8/8/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

class AppModel: ObservableObject {
    private var serviceProvider: ServiceProvider
    
    func promptText(for entry: Entry) -> String {
        switch serviceProvider.promptStoreService.getPrompt(for: entry.promptId) {
        case .success(let prompt):
            return prompt.prompt
        default:
            return ""
        }
    }
    
    func setScore(to newScore: Score, for entry: Entry) {
        print("Setting Score to: \(newScore)")
        let newEntry = Entry(id: entry.id, promptId: entry.promptId, date: entry.date, score: newScore)
        let _ = serviceProvider.entryStoreService.update(entry: newEntry)
    }
    
    func scoreProvider(for entry: Entry) -> ScoreProvider {
        switch serviceProvider.promptStoreService.getPrompt(for: entry.promptId) {
        case .success(let prompt):
            return prompt.scoreProvider
        default:
            return serviceProvider.scoreProviderService.defaultScoreProvider
        }
    }
    
    func entries(for date: Date) -> [Entry] {
        let entries = (try? self.serviceProvider.entryStoreService.getEntries(for: date).get()) ?? []
        let prompts = (try? self.serviceProvider.promptStoreService.getPromptsForIdSet(ids: entries.map({$0.promptId})).get()) ?? []
        var resEntries = [Entry]()
        for prompt in prompts.sorted(by: {(p1, p2) in p1.sortOrder < p2.sortOrder}) {
            if let entry = entries.first(where: {$0.promptId == prompt.id}) {
                if  (entry.score != .None || prompt.active ) {
                    resEntries.append(entry)
                }
            } else {
                if let entry = self.serviceProvider.entryStoreService.insert(promptId: prompt.id, date: date, score: .None).toOptional() {
                    resEntries.append(entry)
                }
            }
        }
        return resEntries
    }
    
    init(serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
