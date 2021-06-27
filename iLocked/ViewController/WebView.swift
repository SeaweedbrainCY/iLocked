//
//  WebView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 13/06/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit
import WebKit


// class in charge of the web view. This feature will be implemented later
class WebView: UIViewController{
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var safariButton : UIBarButtonItem!
    @IBOutlet weak var shareButton : UIBarButtonItem!
    @IBOutlet weak var nextButton : UIBarButtonItem!
    @IBOutlet weak var prevButton : UIBarButtonItem!
    @IBOutlet weak var refreshButton : UIBarButtonItem!
    @IBOutlet weak var closeButton : UIBarButtonItem!
    @IBOutlet weak var titleButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
