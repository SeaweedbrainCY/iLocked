//
//  UIView.swift
//  iLocked
//
//  Created by Nathan on 21/10/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }

}
