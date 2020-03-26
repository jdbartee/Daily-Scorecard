//
//  NotificationViewController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {
    var serviceProvider: ServiceProvider?
    var service: NotificationViewService? {
        return serviceProvider?.notificationViewService
    }

    var model: NotificationViewModel = .none
    var cancelBag = CancelBag()

    

    
}
