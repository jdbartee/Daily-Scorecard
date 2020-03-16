//
//  EntryStoreService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/27/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

struct EntryDoesNotExist: Error {}

protocol EntryStoreService {
    func getEntry(id: Int) -> Result<Entry, Error>
    func getEntries(for date: Date) -> Result<[Entry], Error>
    func insert(promptId: Int, date: Date, score: Score) -> Result<Void, Error>
    func update(entry: Entry) -> Result<Void, Error>
    func delete(entry: Entry) -> Result<Void, Error>
}

class InMemoryEntryStoreService: EntryStoreService {

    var serviceProvider: ServiceProvider
    var entries: [Int:Entry] = [:]

    func getEntries(for date: Date) -> Result<[Entry], Error> {
        return .success(
            [Entry](
                self.entries.values.filter({ e in
                    Calendar.current.isDate(date, inSameDayAs: e.date)
                })
            )
        )
    }

    func getEntry(id: Int) -> Result<Entry, Error> {
        guard let entry = entries[id] else {
            return .failure(EntryDoesNotExist())
        }
        return .success(entry)
    }

    func insert(promptId: Int, date: Date, score: Score) -> Result<Void, Error> {
        let entry = Entry(id: newId(), promptId: promptId, date: date, score: score)
        entries[entry.id!] = entry
        return .success(())
    }

    func update(entry: Entry) -> Result<Void, Error> {
        guard let id = entry.id, entries.keys.contains(id) else {
            return .failure(EntryDoesNotExist())
        }
        entries[id] = entry

        return .success(())
    }

    func delete(entry: Entry) -> Result<Void, Error> {
        guard let id = entry.id, entries.keys.contains(id) else {
            return .failure(EntryDoesNotExist())
        }
        entries.removeValue(forKey: id)

        return .success(())
    }

    private func newId() -> Int {
        return ([Int](entries.keys).max() ?? 0) + 1
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
