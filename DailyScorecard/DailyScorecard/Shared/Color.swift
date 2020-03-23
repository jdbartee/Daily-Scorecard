//
//  Color.swift
//  DailyScorecard
//
//  Created by JD Bartee on 3/20/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var appHighlightColor: UIColor = UIColor.init(named: "PurpleHighlight")!
    func contrastColor() -> UIColor {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0

        self.getRed(&r, green: &g, blue: &b, alpha: nil)
        let luma = ((0.299 * r) + (0.587 * g) + (0.114 * b))
        return luma > 0.5 ? UIColor.darkText : UIColor.lightText
    }
}

