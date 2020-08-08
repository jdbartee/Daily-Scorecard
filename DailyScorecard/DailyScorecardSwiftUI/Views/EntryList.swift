//
//  EntryList.swift
//  DailyScorecard
//
//  Created by jd on 8/8/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import SwiftUI

struct EntryList: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @State
    var date: Date
    
    var dayViewModel: DayViewModel!
    
    var entries: [Entry] {
        return appModel.entries(for: date)
    }
    
    var body: some View {
        List(self.entries, id: \.id) { entry in
            EntryCell(entry: entry)
        }
    }
}

struct EntryList_Previews: PreviewProvider {
    static var previews: some View {
        EntryList(date: Date())
            .environmentObject(AppModel(serviceProvider: ServiceProvider()))
    }
}
