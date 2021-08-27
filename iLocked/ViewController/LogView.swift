//
//  LogView.swift
//  iLocked
//
//  Created by Stchepinsky Nathan on 26/08/2021.
//  Copyright © 2021 Nathan. All rights reserved.
//

import Foundation
import UIKit

class LogView : UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let log = LogFile(fileManager: FileManager())
        do {
            self.textView.text = try log.read()
        } catch {
            self.textView.text = "Impossible to read the logs. Error thrown : \(error.localizedDescription)"
            self.textView.textColor = .systemRed
        }
       

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let bottom = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(bottom)
    }
    
    @IBAction func shareButtonSelected(sender: UIBarButtonItem){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.textView.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
}

