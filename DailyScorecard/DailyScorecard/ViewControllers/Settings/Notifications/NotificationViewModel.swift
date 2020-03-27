//
//  NotificationViewModel.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

enum NotificationViewModel {
    case none
    case denied
    case off
    case on(hour: Int, minute: Int)
}
