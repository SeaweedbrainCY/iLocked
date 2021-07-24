//
//  TabBarController.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 24/07/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("[* Tab Bar Controller Class *] prepare for segue")
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        }
    }
}
