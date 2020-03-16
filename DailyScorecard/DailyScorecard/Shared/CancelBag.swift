//
//  CancelBag.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/23/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine

typealias CancelBag = Set<AnyCancellable>

extension CancelBag {
    mutating func cancelAll() {
        while let c = self.popFirst() { c.cancel() }
    }
}
