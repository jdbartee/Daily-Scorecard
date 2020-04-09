//
//  ScoreProvider.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/5/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

class ScoreProviderService: BaseService {

    var serviceProvider: ServiceProvider

    var scoreFactory = ScoreFactory.self

    var scoreProviders: [ScoreProvider] = [
        FiveValueScoreProvider(),
        TwoValueScoreProvider(),
    ]

    var defaultScoreProvider: ScoreProvider {
        return scoreFactory.defaultScoreProvider
    }

    init(_ serviceProvider: ServiceProvider) {
        self.serviceProvider = serviceProvider
    }

}

class ScoreFactory {
    static var defaultScoreProvider = FiveValueScoreProvider()
    static func scoreProvider(for key: String?) -> ScoreProvider {
        switch key {
        case FiveValueScoreProvider.key:
            return FiveValueScoreProvider()
        case TwoValueScoreProvider.key:
            return TwoValueScoreProvider()
        default:
            return defaultScoreProvider
        }
    }
}

struct TwoValueScoreProvider: ScoreProvider {
    static var key: String = "TwoValue"
    static var displayName: String = NSLocalizedString("TwoValue_Provider_Name", comment: "")

    func scores() -> [Score] {
        return [.Option1, .Option2]
    }

    func numericValue(for score: Score) -> Float? {
        switch score {
        case .Option1: return 0.5 / 5.0
        case .Option2: return 5.0 / 5.0
        case .None: return nil
        default: return nil
        }
    }

    func shortLabel(for score: Score) -> String {
        switch score {
        case .Option1: return NSLocalizedString("TwoValue_Fail_Label", comment: "")
        case .Option2: return NSLocalizedString("TwoValue_Pass_Label", comment: "")
            case .None: return ""
            default: return ""
        }
    }
}

struct FiveValueScoreProvider: ScoreProvider {
    static var key: String = "FiveValue"
    static var displayName: String = NSLocalizedString("FiveValue_Provider_Name", comment: "")

    func scores() -> [Score] {
        return [.Option3, .Option4, .Option5, .Option6, .Option7]
    }

    func numericValue(for score: Score) -> Float? {
        switch score {
        case .Option3: return 0.5 / 5.0
        case .Option4: return 1.5 / 5.0
        case .Option5: return 2.5 / 5.0
        case .Option6: return 3.5 / 5.0
        case .Option7: return 5.0 / 5.0
        case .None: return nil
        default: return nil
        }
    }

    func shortLabel(for score: Score) -> String {
        switch score {
        case .Option3: return String(1)
        case .Option4: return String(2)
        case .Option5: return String(3)
        case .Option6: return String(4)
        case .Option7: return String(5)
        case .None: return ""
        default: return ""
        }
    }
}
