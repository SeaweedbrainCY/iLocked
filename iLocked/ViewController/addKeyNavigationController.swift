//
//  addKeyNavigationController.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 27/12/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit


// This class is used to pass informations threw the navigation controller. Mostly to edit a saved key. Data is sent by ShowKey class and transmitted by this class to AddKey class
class AddKeyNavigationController: UINavigationController, UINavigationControllerDelegate{
    
    var name = ""
    var key = ""
    var viewOnBack = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addKeyView = segue.destination as! AddKey
        addKeyView.oldName = self.name
        addKeyView.oldKey = self.key
        addKeyView.viewOnBack = self.viewOnBack
    }
}
