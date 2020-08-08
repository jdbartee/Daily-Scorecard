//
//  ScorePicker.swift
//  DailyScorecard
//
//  Created by jd on 8/7/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import SwiftUI

extension ScorePicker {
    private static let animation = Animation.spring(
        response: 0.55,
        dampingFraction: 0.525,
        blendDuration: 0)
    private static let bubbleSize = CGSize(width: 20, height: 20)
    private static let frameDimension: CGFloat = 40
    private static let paddingDimension: CGFloat = 20
}

struct ScorePicker: View {
    @Namespace private var namespace
    @Binding private var score: Score
    private let scoreProvider: ScoreProvider
    
    init(score: Binding<Score>, scoreProvider: ScoreProvider) {
        self._score = score.animation(Self.animation)
        self.scoreProvider = scoreProvider
    }

    var body: some View {
        HStack {
            ForEach(scoreProvider.scores(), id: \.self) { option in
                Button(action: {
                    score = option
                }) {
                    ZStack {
                        if (score == option) { bubbleView() }
                        textView(for: option)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(
                    minWidth: Self.frameDimension,
                    idealWidth: Self.frameDimension,
                    maxWidth: .infinity,
                    minHeight: Self.frameDimension,
                    idealHeight: Self.frameDimension,
                    maxHeight: Self.frameDimension,
                    alignment: .center)
            }
        }
    }
    
    private func textView(for option: Score) -> some View{
        let text = option.shortLabel(for: self.scoreProvider)
        return Text(text)
            .foregroundColor(.primary)
            .padding(.horizontal, Self.paddingDimension)
    }
    
    private func bubbleView() -> some View {
        RoundedRectangle(cornerSize: Self.bubbleSize, style: .continuous)
            .foregroundColor( .accentColor)
            .matchedGeometryEffect(id: 1, in: namespace)
    }

}
//
//struct ScorePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ScorePicker()
//    }
//}
