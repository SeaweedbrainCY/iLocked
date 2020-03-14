//
//  UIButton.swift
//  iLocked
//
//  Created by Nathan on 27/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    func rondBorder(){
        layer.cornerRadius = 10
    }
    
    func buttonInCircle(){
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 100
    }
}
