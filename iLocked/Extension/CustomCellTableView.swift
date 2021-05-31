//
//  CustomCellTableView.swift
//  iLocked
//
//  Created by Nathan on 09/01/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

//Custom qui permet d'ajouter un label au cellule des tableView



public class CustomTableViewCell: UITableViewCell {
    let textField = UITextField()
    
    public func configure(text: String?, placeholder :String?){
        self.addSubview(self.textField)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textField.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        self.textField.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        self.centerYAnchor.constraint(equalToSystemSpacingBelow: self.centerYAnchor, multiplier: 1).isActive = true
        self.centerXAnchor.constraint(equalToSystemSpacingAfter: self.centerXAnchor, multiplier: 1).isActive = true
        self.textField.backgroundColor = UIColor.systemGray5
        textField.text = text
        textField.placeholder = placeholder
        textField.accessibilityValue = text
        textField.accessibilityLabel = placeholder
    }
    
}
