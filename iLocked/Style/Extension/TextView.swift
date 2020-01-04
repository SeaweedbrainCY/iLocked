//
//  TextView.swift
//  iLocked
//
//  Created by Nathan on 27/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    func rondBorder() {
        layer.cornerRadius = 15
        layer.borderWidth = 5
        layer.borderColor = UIColor.init(red: 0.022, green: 0.276, blue: 0.371, alpha: 1).cgColor
    }

    
    ///Center vertically a text in a UITexteView
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(0, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
