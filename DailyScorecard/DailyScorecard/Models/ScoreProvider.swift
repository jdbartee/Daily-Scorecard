//
//  ScoreProvider.swift
//  DailyScorecard
//
//  Created by JD Bartee on 4/7/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation


enum Score: Int, CaseIterable {
    case None = 0
    case Option1 = 1
    case Option2 = 2
    case Option3 = 3
    case Option4 = 4
    case Option5 = 5
    case Option6 = 6
    case Option7 = 7
    case Option8 = 8
    case Option9 = 9

    func numericValue(for scoreProvider: ScoreProvider)  -> Float? {
        return scoreProvider.numericValue(for: self)
    }

    func shortLabel(for scoreProvider: ScoreProvider) -> String {
        return scoreProvider.shortLabel(for: self)
    }
}


protocol ScoreProvider {
    static var key: String { get }
    static var displayName: String { get }
    func scores() -> [Score]
    func numericValue(for score: Score) -> Float?
    func shortLabel(for score: Score) -> String
}

extension ScoreProvider {
    var key: String {
        Self.key
    }
    var displayName: String {
        Self.displayName
    }
}
