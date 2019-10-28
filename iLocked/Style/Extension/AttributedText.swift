//
//  AttributedText.swift
//  iLocked
//
//  Created by Nathan on 19/12/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
       
    }
    
}
