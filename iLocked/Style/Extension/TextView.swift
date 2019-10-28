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
}
