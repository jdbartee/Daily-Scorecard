//
//  DailyScorecardApp.swift
//  DailyScorecard
//
//  Created by jd on 8/7/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import SwiftUI

@main
struct DailyScorecardApp: App {
    @State var appModel = AppModel(serviceProvider:
        ServiceProvider())
    
    var body: some Scene {
        WindowGroup {
            EntryList(date: Date())
                .environmentObject(appModel)
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello")
            .font(.title)
            .padding()
    }
}
