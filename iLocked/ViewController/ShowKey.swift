//
//  ShowKey.swift
//  iLocked
//
//  Created by Nathan on 31/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit


class ShowKey: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    
    var nameKeyTitle = UILabel()
    var nameKey = UILabel()
    var keyTitle = UILabel()
    var key = UITextView()
    var encryptButton = UIButton()
    var shareButton = UIButton()
    var deleteButton = UIButton()
    var editButton = UIBarButtonItem()
    
    
    
    
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!
    
    static let notificationOfModificationName = Notification.Name("notificationOfModifcationFormEditKeyToShowKey")
    
    var name = ""
    var idKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("idKey = \(idKey)")
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.backgroundView.backgroundColor = .black
        self.scrollView.delegate = self
        constructView()
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Call when the user tap once or twice on the home button
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editKeyResult), name: ShowKey.notificationOfModificationName, object: nil)
                    
    }
        
        
    
    
    //
    // Views creation func
    //
    
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func constructView(){
        self.backgroundView.addSubview(self.nameKeyTitle)
        self.nameKeyTitle.translatesAutoresizingMaskIntoConstraints = false
        self.nameKeyTitle.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.leftAnchor, multiplier: 2).isActive = true
        self.nameKeyTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.scrollView.topAnchor, multiplier: 2).isActive = true
        self.nameKeyTitle.text = "Encryption key owner"
        self.nameKeyTitle.textColor = .white
        self.nameKeyTitle.font = UIFont(name: "Arial Rounded MT Bold", size: 25)
        
        self.backgroundView.addSubview(self.nameKey)
        self.nameKey.translatesAutoresizingMaskIntoConstraints = false
        self.nameKey.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.nameKey.topAnchor.constraint(equalToSystemSpacingBelow: self.nameKeyTitle.bottomAnchor, multiplier: 2).isActive = true
        self.nameKey.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 70).isActive = true
        self.nameKey.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.nameKey.layer.masksToBounds = true
        self.nameKey.layer.cornerRadius = 20
        self.nameKey.text = "  \(name)  "
        self.nameKey.font = UIFont(name: "American Typewriter", size: 19)
        self.nameKey.textColor = .systemOrange
        self.nameKey.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 0.5)
        self.nameKey.lineBreakMode = .byTruncatingTail
        
        
        
        self.backgroundView.addSubview(self.keyTitle)
        self.keyTitle.translatesAutoresizingMaskIntoConstraints = false
        self.keyTitle.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.leftAnchor, multiplier: 2).isActive = true
        self.keyTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.nameKey.bottomAnchor, multiplier: 5).isActive = true
        self.keyTitle.text = "Encryption key"
        self.keyTitle.textColor = .white
        self.keyTitle.font = UIFont(name: "Arial Rounded MT Bold", size: 25)
        
        self.backgroundView.addSubview(self.key)
        self.key.translatesAutoresizingMaskIntoConstraints = false
        self.key.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.key.topAnchor.constraint(equalToSystemSpacingBelow: self.keyTitle.bottomAnchor, multiplier: 2).isActive = true
        self.key.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 70).isActive = true
        self.key.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.key.isEditable = false
        self.key.isSelectable = false
        self.key.textColor = .systemOrange
        if let retrievedString: String = KeychainWrapper.standard.string(forKey: idKey){
            self.key.text = "\(retrievedString)"
        } else if self.name == "My encyrption key"{
            if let retrievedString: String = KeychainWrapper.standard.string(forKey: userPublicKeyId){
            self.key.text = "\(retrievedString)"
            } else {
                self.key.text = "Impossible to find this key. Please check you didn't make any mistake, install the last version of this application and be sure you have enough space on your iDevice."
                self.key.textColor = .systemRed
            }
        } else {
            self.key.text = "Impossible to find this key. Please check you didn't make any mistake, install the last version of this application and be sure you have enough space on your iDevice."
            self.key.textColor = .systemRed
        }
        
        self.key.font = UIFont(name: "American Typewriter", size: 17)
        
        self.key.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 0.5)
        self.key.layer.cornerRadius = 20
        
        
        self.backgroundView.addSubview(self.encryptButton)
        self.encryptButton.translatesAutoresizingMaskIntoConstraints = false
        self.encryptButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.encryptButton.topAnchor.constraint(equalToSystemSpacingBelow: self.key.bottomAnchor, multiplier: 5).isActive = true
        self.encryptButton.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 40).isActive = true
        self.encryptButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        if #available(iOS 13.0, *) {
            self.encryptButton.setImage(UIImage(systemName: "lock.fill") , for: .normal)
        } else {
            self.encryptButton.setImage(UIImage(named: "addKey"), for: .normal)
        }
        self.encryptButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.encryptButton.setTitleColor(.white, for: .normal)
        self.encryptButton.setTitle(" Use this key to encrypt a msg", for: .normal)
        self.encryptButton.tintColor = .systemOrange
        self.encryptButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        self.encryptButton.rondBorder()
        self.encryptButton.addTarget(self, action: #selector(self.encryptMessageSelected), for: .touchUpInside)
        
        self.backgroundView.addSubview(self.shareButton)
        self.shareButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.shareButton.topAnchor.constraint(equalToSystemSpacingBelow: self.encryptButton.bottomAnchor, multiplier: 4).isActive = true
        self.shareButton.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 40).isActive = true
        self.shareButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        if #available(iOS 13.0, *) {
            self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up") , for: .normal)
        }
        self.shareButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.shareButton.setTitleColor(.white, for: .normal)
        self.shareButton.setTitle(" Share this key", for: .normal)
        self.shareButton.tintColor = .systemOrange
        self.shareButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        self.shareButton.rondBorder()
        self.shareButton.addTarget(self, action: #selector(shareButtonSelected), for: .touchUpInside)
        
        self.backgroundView.addSubview(self.deleteButton)
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.deleteButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shareButton.bottomAnchor, multiplier: 4).isActive = true
        self.deleteButton.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 40).isActive = true
        self.deleteButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        if #available(iOS 13.0, *) {
            self.deleteButton.setImage(UIImage(systemName: "trash") , for: .normal)
        }
        self.deleteButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
        self.deleteButton.setTitleColor(.systemRed, for: .normal)
        self.deleteButton.setTitle(" Destroy this key", for: .normal)
        self.deleteButton.tintColor = .systemOrange
        self.deleteButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        self.deleteButton.rondBorder()
        self.deleteButton.addTarget(self, action: #selector(trashButtonSelected), for: .touchUpInside)
        
    }
    
    
    
    //
    // IBAction func
    //
    
    @IBAction private func shareBarButtonItemSelected(sender: UIBarButtonItem){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.key.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction private func trashBarButtonItemSelected(sender: UIBarButtonItem){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let A1 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let A2 = UIAlertAction(title: "Destroy this key", style: UIAlertAction.Style.destructive, handler: { (_) in
            self.destroyKey()
        })
        alert.addAction(A1)
        alert.addAction(A2)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func editBarButtonItemSelected(sender: UIBarButtonItem){
        performSegue(withIdentifier: "editKey", sender: self)
    }
    
    
    //
    // Obj C func
    //
    
    @objc private func shareButtonSelected(sender: UIButton){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.key.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @objc private func trashButtonSelected(sender: UIButton){
        sender.isEnabled = false
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let A1 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) in
            sender.isEnabled = true
        })
        let A2 = UIAlertAction(title: "Destroy this key", style: UIAlertAction.Style.destructive, handler: { (_) in
            self.destroyKey()
        })
        alert.addAction(A1)
        alert.addAction(A2)
        self.present(alert, animated: true, completion: nil)
    }
    
  
    
    /// When user click on 'Use this key to encrypt a message' button. We send data to EncryptHomePage with all field filled
    @objc private func encryptMessageSelected(sender: UIButton){
        performSegue(withIdentifier: "encryptMessage", sender: self)
    }
    
    @objc private func dismissView(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    @objc private func editKeyResult(notification: Notification){
        let notificationData = notification.userInfo
        self.name = notificationData?["name"] as! String
        self.nameKey.text = (notificationData?["name"] as! String)
        self.key.text = (notificationData?["key"] as! String)
        self.idKey = notificationData?["idKey"] as! String
    }
    
    //
    // Data gestion func
    //
    
    private func destroyKey(){
        //First in the dictionnary :
        let keyNameData = KeyId()
        var listeKeyName = keyNameData.getKeyIdArray()
        listeKeyName.removeValue(forKey: idKey)
        keyNameData.stockNewNameIdArray(listeKeyName)
        //then the keychain :
        KeychainWrapper.standard.removeObject(forKey: idKey)
        UIView.animate(withDuration: 1.5, animations: {
            self.key.alpha = 0
            self.nameKey.alpha = 0
            self.keyTitle.alpha = 0
            self.nameKeyTitle.alpha = 0
            self.deleteButton.alpha = 0
            self.shareButton.alpha = 0
            self.encryptButton.alpha = 0
        })
        self.perform(#selector(dismissView), with: nil, afterDelay: 1.6)
    }
    
    //
    // segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        } else if segue.identifier == "editKey"{
            let viewController = segue.destination as? UINavigationController
            let targetController = viewController?.topViewController as! AddKey
            targetController.oldName = self.name
            targetController.oldKey = self.key.text!
            targetController.viewOnBack = "ShowKey"
        } else if segue.identifier == "encryptMessage"{
            let viewController = segue.destination as? UINavigationController
            let targetController = viewController?.topViewController as! Encrypt
            targetController.keyNameTransmitted = self.name
        }
        
    }
}
