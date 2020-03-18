//
//  EntryStoreService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/27/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import CoreData

struct EntryDoesNotExist: Error {}
struct QueryFailed: Error {}

protocol EntryStoreService {
    func getEntry(id: UUID) -> Result<Entry, Error>
    func getEntries(for date: Date) -> Result<[Entry], Error>
    func insert(promptId: UUID, date: Date, score: Score) -> Result<Entry, Error>
    func update(entry: Entry) -> Result<Entry, Error>
    func delete(entry: Entry) -> Result<Void, Error>
}

class InMemoryEntryStoreService: EntryStoreService {

    var serviceProvider: ServiceProvider
    var entries: [UUID:Entry] = [:]

    func getEntries(for date: Date) -> Result<[Entry], Error> {
        return .success(
            [Entry](
                self.entries.values.filter({ e in
                    Calendar.current.isDate(date, inSameDayAs: e.date)
                })
            )
        )
    }

    func getEntry(id: UUID) -> Result<Entry, Error> {
        guard let entry = entries[id] else {
            return .failure(EntryDoesNotExist())
        }
        return .success(entry)
    }

    func insert(promptId: UUID, date: Date, score: Score) -> Result<Entry, Error> {
        let entry = Entry(id: newId(), promptId: promptId, date: date, score: score)
        entries[entry.id] = entry
        return .success(entry)
    }

    func update(entry: Entry) -> Result<Entry, Error> {
        let id = entry.id
        guard entries.keys.contains(id) else {
            return .failure(EntryDoesNotExist())
        }
        entries[id] = entry

        return .success(entry)
    }

    func delete(entry: Entry) -> Result<Void, Error> {
        let id = entry.id
        guard entries.keys.contains(id) else {
            return .failure(EntryDoesNotExist())
        }
        entries.removeValue(forKey: id)

        return .success(())
    }

    private func newId() -> UUID {
        UUID()
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}

class CoreDataEntryStoreService: EntryStoreService {
    var serviceProvider: ServiceProvider
    var persistentContainer: NSPersistentCloudKitContainer { self.serviceProvider.persistentContainer }

    func getEntry(id: UUID) -> Result<Entry, Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedEntry> = ManagedEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            guard let managedEntry = try persistentContainer.viewContext.fetch(fetchRequest).first,
                  let entry = Entry(managedEntry: managedEntry) else {
                return .failure(QueryFailed())
            }
            return .success(entry)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func getEntries(for date: Date) -> Result<[Entry], Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedEntry> = ManagedEntry.fetchRequest()
            guard let tomorrow = Calendar.current.nextDay(date) else {
                return .failure(QueryFailed())
            }
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [date, tomorrow])
            let managedEntries = try persistentContainer.viewContext.fetch(fetchRequest)
            let entries = managedEntries.compactMap({Entry(managedEntry: $0)})
            return .success(entries)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func insert(promptId: UUID, date: Date, score: Score) -> Result<Entry, Error> {
        do {
            let managedEntry = ManagedEntry(context: persistentContainer.viewContext)
            managedEntry.id = UUID()
            managedEntry.promptId = promptId
            managedEntry.date = date
            managedEntry.score = Int64(score.rawValue)

            try persistentContainer.viewContext.save()
            guard let entry = Entry(managedEntry: managedEntry) else {
                return .failure(QueryFailed())
            }
            return .success(entry)
        } catch {
            return .failure(QueryFailed())
        }
    }

    func update(entry: Entry) -> Result<Entry, Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedEntry> = ManagedEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id.uuidString)
            guard let managedEntry = try persistentContainer.viewContext.fetch(fetchRequest).first else {
                return .failure(QueryFailed())
            }
            managedEntry.id = entry.id
            managedEntry.promptId = entry.promptId
            managedEntry.score = Int64(entry.score.rawValue)
            managedEntry.date = entry.date

            try persistentContainer.viewContext.save()
            guard let entry = Entry(managedEntry: managedEntry) else {
                return .failure(QueryFailed())
            }
            return .success(entry)
        } catch {
            return .failure(QueryFailed())
        }

    }

    func delete(entry: Entry) -> Result<Void, Error> {
        do {
            let fetchRequest: NSFetchRequest<ManagedEntry> = ManagedEntry.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", entry.id.uuidString)
            guard let managedEntry = try persistentContainer.viewContext.fetch(fetchRequest).first else {
                return .failure(QueryFailed())
            }

            persistentContainer.viewContext.delete(managedEntry)
            try persistentContainer.viewContext.save()
            return .success(())
        } catch {
            return .failure(QueryFailed())
        }
    }


    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}

fileprivate extension Entry {
    init?(managedEntry: ManagedEntry) {
        if let date = managedEntry.date,
            let id = managedEntry.id,
            let promptId = managedEntry.promptId,
            let score = Score(rawValue: Int(managedEntry.score)) {
            self.init(id: id, promptId: promptId, date: date, score: score)
        } else {
            return nil
        }
    }
}
