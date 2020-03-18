//
//  ScoreProvider.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/5/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

enum Score: Int, CaseIterable {
    case None = 0
    case VeryBad = 1
    case Bad = 2
    case Ok = 3
    case Good = 4
    case VeryGood = 5
}

class ScoreProvider: NSObject, BaseService {
    var serviceProvider: ServiceProvider

    lazy var scores: [Score] = {
        return Score.allCases.filter({$0 != .None})
    }()

    func numericValue(for score: Score) -> Float? {
        switch score {
        case .VeryBad:
            return 0.5
        case .Bad:
            return 1.5
        case .Ok:
            return 2.5
        case .Good:
            return 3.5
        case .VeryGood:
            return 5.0
        case .None:
            return nil
        }
    }
    
    func maxNumericValue() -> Float {
        return numericValue(for: .VeryGood)!
    }
    func shortLabel(for score: Score) -> String {
        switch score {
        case .VeryBad:
            return "1"
        case .Bad:
            return "2"
        case .Ok:
            return "3"
        case .Good:
            return "4"
        case .VeryGood:
            return "5"
        case .None:
            return "-"
        }
    }

    func starLabel(for score: Score) -> String {
        switch score {
        case .VeryBad:
            return "★☆☆☆☆"
        case .Bad:
            return "★★☆☆☆"
        case .Ok:
            return "★★★☆☆"
        case .Good:
            return "★★★★☆"
        case .VeryGood:
            return "★★★★★"
        case .None:
            return "-"
        }
    }

    func label(for score: Score) -> String {
        switch score {
        case .VeryBad:
            return "1 - Very Bad"
        case .Bad:
            return "2 - Bad"
        case .Ok:
            return "3 - Ok"
        case .Good:
            return "4 - Good"
        case .VeryGood:
            return "5 - Very Good"
        case .None:
            return "-"
        }
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }
}
