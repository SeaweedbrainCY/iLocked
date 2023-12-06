//
//  SelectIcon.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 19/10/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class SelectIcon: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var backgroundLogo1:UIView!
    @IBOutlet weak var backgroundLogo2:UIView!
    @IBOutlet weak var backgroundLogo3:UIView!
    @IBOutlet weak var backgroundLogo4:UIView!
    @IBOutlet weak var backgroundLogo5:UIView!
    @IBOutlet weak var backgroundLogo6:UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructViews()
        
        self.scrollView.delegate = self
    }
    
    /*private func constructViews(){
        let allBackgroundViews: [UIView] = [self.backgroundLogo1, self.backgroundLogo2, self.backgroundLogo3, self.backgroundLogo4, self.backgroundLogo5, self.backgroundLogo6]
        
        for background in allBackgroundViews{
            background.frame = CGRect(x: background.frame.origin.x, y: background.frame.origin.y, width: self.view.frame.width / 3, height: self.view.frame.width / 3)
        }
    }*/
    
    private func constructViews(){
        let allBackgroundViews: [(UIView, UIView)] = [(self.backgroundLogo1, self.backgroundLogo2), (self.backgroundLogo3, self.backgroundLogo4), (self.backgroundLogo5, self.backgroundLogo6)]
        let background_width: CGFloat = self.view.frame.width / 3
       // let allBackgroundImage = [] // link to all icon's images
        
        // Stock the view above the one we are setting up. By default, the first views are set up below the top scroll view
        var topLeftView: NSLayoutYAxisAnchor = self.scrollView.topAnchor
        var topRightView: NSLayoutYAxisAnchor = self.scrollView.topAnchor
        
        for (left_view, right_view) in allBackgroundViews {
            
           
            
            // Left view
            
            left_view.translatesAutoresizingMaskIntoConstraints = false
            left_view.widthAnchor.constraint(equalToConstant: background_width).isActive = true
            left_view.heightAnchor.constraint(equalToConstant:background_width).isActive = true
            left_view.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 20).isActive = true
            left_view.topAnchor.constraint(equalToSystemSpacingBelow: topLeftView, multiplier: 2).isActive = true
            
            
            
            
            // right view
            right_view.translatesAutoresizingMaskIntoConstraints = false
            right_view.widthAnchor.constraint(equalToConstant: background_width).isActive = true
            right_view.heightAnchor.constraint(equalToConstant: background_width).isActive = true
            right_view.leftAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: -20).isActive = true
            right_view.topAnchor.constraint(equalToSystemSpacingBelow: topRightView, multiplier: 2).isActive = true
            
            // update the top view
           // topLeftView = left_view
            //topRightView = right_view
        }
    }
}
