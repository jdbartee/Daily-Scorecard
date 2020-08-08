//
//  EntryCell.swift
//  DailyScorecard
//
//  Created by jd on 8/7/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import SwiftUI

struct EntryCell: View {
    @EnvironmentObject
    var appModel: AppModel
    
    @State
    var entry: Entry

    private func promptText() -> String {
        appModel.promptText(for: entry)
    }
    
    private var binding: Binding<Score> {
        Binding(get: {
            return entry.score
        }, set: { score in
            appModel.setScore(to: score, for: entry)
        })
    }
    
    private var scoreProvider: ScoreProvider {
        appModel.scoreProvider(for: entry)
    }
    
    var body: some View {
        VStack(spacing: 5.0) {
            HStack {
                Text(promptText())
                    .font(.title2)
                    .fontWeight(.heavy)
                    .padding(.all, 5)
                Spacer()
            }
            HStack(alignment: .center, spacing: 50.0) {
                Spacer()
                ScorePicker(score: binding, scoreProvider: scoreProvider)
            }
            .padding(.horizontal, 5)
        }
    }
}

struct EntryCell_Previews: PreviewProvider {
    static var previews: some View {
        EntryCell(entry: Entry(id: UUID(), promptId: UUID(), date: Date(), score: Score.Option4))
            .environmentObject(ServiceProvider())
    }
}
