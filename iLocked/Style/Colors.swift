//
//  Colors.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 08/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

public enum Colors {
    case darkGray6
    case darkGray5
    case disabledBlueButton
    case disabledWhiteButton
    case disabledOrangeButton
    
    var color : UIColor {
        switch self {
        case .darkGray6:
            return UIColor(red: 28/255.0, green: 28/255.0, blue: 30/255.0, alpha: 1)
        case .darkGray5:
            return UIColor(red: 44/255.0, green: 44/255.0, blue: 46/255.0, alpha: 1)
        case .disabledBlueButton: // used for disabled blue button
            return UIColor(red: 4/255.0, green: 60/255.0, blue: 128/255.0, alpha: 1)
        case .disabledWhiteButton :// used for disabled white button
            return UIColor(red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1)
        case .disabledOrangeButton :// used for disabled orange button
                return UIColor(red: 128/255.0, green: 76/255.0, blue: 0, alpha: 1)
        }
    }
}
