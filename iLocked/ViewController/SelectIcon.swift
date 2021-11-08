//
//  SelectIcon.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 19/10/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class SelectIcon: UIViewController{
    
    @IBOutlet weak var backgroundLogo1:UIView!
    @IBOutlet weak var backgroundLogo2:UIView!
    @IBOutlet weak var backgroundLogo3:UIView!
    @IBOutlet weak var backgroundLogo4:UIView!
    @IBOutlet weak var backgroundLogo5:UIView!
    @IBOutlet weak var backgroundLogo6:UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructViews()
    }
    
    /*private func constructViews(){
        let allBackgroundViews: [UIView] = [self.backgroundLogo1, self.backgroundLogo2, self.backgroundLogo3, self.backgroundLogo4, self.backgroundLogo5, self.backgroundLogo6]
        
        for background in allBackgroundViews{
            background.frame = CGRect(x: background.frame.origin.x, y: background.frame.origin.y, width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        }
    }*/
    
    private construcViews(){
        
    }
}
