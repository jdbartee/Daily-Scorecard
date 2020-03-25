//
//  AddDetailService.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/25/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation

class AppDetailService: BaseService {
    var serviceProvider: ServiceProvider
    var appName: String
    var appVersion: String
    var copyright: String

    init(_ serviceProvider: ServiceProvider) {
        self.appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Application"
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        self.copyright = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "Copyright"

        self.serviceProvider = serviceProvider
    }
}
