//
//  donationView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 07/06/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class Donation: UIViewController{
    
    @IBOutlet weak var donationButton: UIButton!
    @IBOutlet weak var donationScale: UISegmentedControl!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var developerStickerImage: UIImageView!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var infosLabel: UILabel!
    
    var initialViewsPosition: [UIView : CGRect] = [:] // Stock the initial position of each view before hiding them and show then with an animation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round button
        self.donationButton.layer.cornerRadius = 20
        hideViews()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showViews()
    }
    
    //
    // Construct view func
    //
    
    func hideViews(){ // Hide view below the content view
        let viewList: [UIView] = [donationScale,donationButton,developerLabel,closeButton,developerStickerImage,helloLabel,infosLabel]
        
        for i  in 0 ..< viewList.count {
            self.initialViewsPosition.updateValue(viewList[i].frame , forKey: viewList[i])
            viewList[i].translatesAutoresizingMaskIntoConstraints = true
            viewList[i].frame.origin.y = viewList[i].frame.origin.y + self.view.frame.height + 100*CGFloat((i+1))
        }
    }
    
    func showViews(){
        let viewList: [UIView] = [donationScale,donationButton,developerLabel,closeButton,developerStickerImage,helloLabel,infosLabel]
        let animation = UIViewPropertyAnimator(duration: 1, dampingRatio: 2, animations: {
            for i  in 0 ..< viewList.count {
                viewList[i].frame = self.initialViewsPosition[viewList[i]]!
            }
        })
        animation.startAnimation()
        stickView()
    }
    
    func stickView(){ // when the view is loaded, the views came with an animation, we fix with the determined constraints
        let viewList: [UIView] = [donationScale,donationButton,developerLabel,closeButton,developerStickerImage,helloLabel,infosLabel]
        
        for i  in 0 ..< viewList.count {
            viewList[i].translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    //
    // IBAction func
    //
    
    @IBAction func closeButtonSelected(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    // Objective C func
    //
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    //
    //segue
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        }
    }
    
}
