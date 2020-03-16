//
//  Result.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/8/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

extension Result {
    func toOptional() -> Success? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
}
