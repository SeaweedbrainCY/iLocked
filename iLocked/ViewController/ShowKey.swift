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
    
    //var nameKeyTitle = UILabel()
    //var nameKey = UILabel()
    
    var keyTitle = UILabel()
    var key = UILabel()
    var encryptButton = UIButton()
    var shareButton = UIButton()
    var deleteButton = UIButton()
    var editButton = UIBarButtonItem()
    var copyButton = UIButton(type: .custom)
    var notificationView = UIButton()
    var date = UILabel()
    var tips = UILabel()
    var QRCodeButton = UIButton()
    let shareModeItems: [String] = ["Shortcut".localized(), "Plain text".localized()]
    var shareModeButton = UISegmentedControl()
    var shareModeTitle = UILabel()
    var shareModeInfoButton = UIButton()
    
    
    
    
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!
    
    static let notificationOfModificationName = Notification.Name("notificationOfModifcationFormEditKeyToShowKey")
    
    
    
    var name = ""
    var isUserKey = false // if true, you cannot delete this key
    let background = DispatchQueue.global(qos: .background)
    let log = LogFile(fileManager: FileManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.backgroundView.backgroundColor = Colors.darkGray6.color
        self.scrollView.delegate = self
        constructView()
        print("isUser key = \(isUserKey)")
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyButtonSelected))
            tap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
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
        //self.navigationItem.title = "\(name)'s key"
        
        // Useless. Old design. Can be deleted in next code version
        /*self.backgroundView.addSubview(self.nameKeyTitle)
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
        self.nameKey.lineBreakMode = .byTruncatingTail*/
        
        
        
        self.backgroundView.addSubview(self.keyTitle)
        self.keyTitle.translatesAutoresizingMaskIntoConstraints = false
        self.keyTitle.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor, constant: 1).isActive = true
        self.keyTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.backgroundView.topAnchor, multiplier: 2).isActive = true
        self.keyTitle.text = "\(name)"
        self.keyTitle.textColor = .white
        self.keyTitle.font = UIFont(name: "American Typewriter Bold", size: 20)
        
        self.backgroundView.addSubview(self.key)
        if let retrievedString: String = KeychainWrapper.standard.string(forKey: name){
            self.key.text = "\(retrievedString)"
        } else if isUserKey{
            if let retrievedString: String = KeychainWrapper.standard.string(forKey: UserKeys.publicKey.tag){
            self.key.text = "\(retrievedString)"
            } else {
                self.key.text = "Impossible to find this key. Please check you have installed the last version of this application and be sure you have enough space on your iDevice.".localized(withKey: "ImpossibleFindKey")
                self.key.textColor = .systemRed
            }
        } else {
            self.key.text = "Impossible to find this key. Please check you have installed the last version of this application and be sure you have enough space on your iDevice.".localized(withKey: "ImpossibleFindKey")
            self.key.textColor = .systemRed
        }
        self.key.numberOfLines = 0
        self.key.translatesAutoresizingMaskIntoConstraints = false
        self.key.widthAnchor.constraint(equalToConstant: self.view.frame.size.width - 5).isActive = true
        let size = key.sizeThatFits(key.bounds.size)
        print("[*]  Size = \(size)")
        //self.key.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        //self.key.heightAnchor.constraint(equalToConstant: 2*self.scrollView.frame.size.height / 3).isActive = true
        self.key.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.key.topAnchor.constraint(equalToSystemSpacingBelow: self.keyTitle.bottomAnchor , multiplier: 2).isActive = true
        print("view width = \(self.view.frame.width)")
        print("scroll view width = \(self.scrollView.frame.width)")
        self.key.textColor = .white
        
        
        self.key.font = UIFont(name: "American Typewriter", size: 15)
        
        self.key.backgroundColor = Colors.darkGray6.color
        //self.key.layer.borderWidth = 0.5
        //self.key.layer.borderColor = UIColor.white.cgColor
       // self.key.layer.cornerRadius = 20
        
        
        self.backgroundView.addSubview(self.shareModeInfoButton)
        self.shareModeInfoButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareModeInfoButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        self.shareModeInfoButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.shareModeInfoButton.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.leftAnchor, multiplier: 1.5).isActive = true
        self.shareModeInfoButton.topAnchor.constraint(equalToSystemSpacingBelow: self.key.bottomAnchor, multiplier: 3).isActive = true
        self.shareModeInfoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        self.shareModeInfoButton.tintColor = .lightGray
        
        self.backgroundView.addSubview(self.shareModeTitle)
        self.shareModeTitle.translatesAutoresizingMaskIntoConstraints = false
        self.shareModeTitle.widthAnchor.constraint(equalToConstant: 130).isActive = true
        self.shareModeTitle.heightAnchor.constraint(equalToConstant: 25).isActive = true
        self.shareModeTitle.topAnchor.constraint(equalToSystemSpacingBelow: self.key.bottomAnchor, multiplier: 3).isActive = true
        self.shareModeTitle.leftAnchor.constraint(equalToSystemSpacingAfter: self.shareModeInfoButton.rightAnchor, multiplier: 1).isActive = true
        self.shareModeTitle.text = "Share as :".localized()
        self.shareModeTitle.font = UIFont(name: "Avenir Next Demibold", size: 10)
        self.shareModeTitle.textColor = .white
       
        
        
        
        self.shareModeButton = UISegmentedControl(items: self.shareModeItems)
        self.backgroundView.addSubview(self.shareModeButton)
        self.shareModeButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareModeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        self.shareModeButton.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: -20).isActive = true
        self.shareModeButton.leftAnchor.constraint(equalToSystemSpacingAfter: self.shareModeTitle.rightAnchor, multiplier: 1).isActive = true
        
        self.shareModeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.key.bottomAnchor, multiplier: 3).isActive = true
        self.shareModeButton.selectedSegmentIndex = 0
        self.shareModeButton.tintColor = .white
        self.shareModeButton.backgroundColor = Colors.darkGray5.color
        self.shareModeButton.selectedSegmentTintColor = .systemBlue
        self.shareModeButton.addTarget(self, action: #selector(shareModeValueChanged), for: .valueChanged)
        
        let viewWidthUsable: CGFloat = self.view.frame.width - 60
        let buttonDistance: CGFloat = 10
        let buttonWidth: CGFloat = (viewWidthUsable - buttonDistance * 3) / 4
        
        self.backgroundView.addSubview(self.encryptButton)
        self.encryptButton.translatesAutoresizingMaskIntoConstraints = false
        self.encryptButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.encryptButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.encryptButton.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 30).isActive = true
        self.encryptButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shareModeButton.bottomAnchor, multiplier: 2).isActive = true
        let image = UIImage(systemName: "lock.doc")!
        
        
        self.encryptButton.setImage(image, for: .normal)
        self.encryptButton.backgroundColor = Colors.darkGray5.color
        self.encryptButton.setTitleColor(.white, for: .normal)
        self.encryptButton.tintColor = .systemOrange
        self.encryptButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        self.encryptButton.rondBorder()
        self.encryptButton.addTarget(self, action: #selector(self.encryptMessageSelected), for: .touchUpInside)
        
        
        self.backgroundView.addSubview(self.shareButton)
        self.shareButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.shareButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.shareButton.leftAnchor.constraint(equalTo: self.encryptButton.rightAnchor, constant: buttonDistance).isActive = true
        self.shareButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shareModeButton.bottomAnchor, multiplier: 2).isActive = true
        
        self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up") , for: .normal)
        self.shareButton.tintColor = .systemOrange
        self.shareButton.backgroundColor = Colors.darkGray5.color
        self.shareButton.rondBorder()
        self.shareButton.addTarget(self, action: #selector(shareButtonSelected), for: .touchUpInside)
        
        self.backgroundView.addSubview(self.QRCodeButton)
        self.QRCodeButton.translatesAutoresizingMaskIntoConstraints = false
        self.QRCodeButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.QRCodeButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.QRCodeButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shareModeButton.bottomAnchor, multiplier: 2).isActive = true
        self.QRCodeButton.leftAnchor.constraint(equalTo: self.shareButton.rightAnchor, constant: buttonDistance).isActive = true
        self.QRCodeButton.setImage(UIImage(systemName: "qrcode") , for: .normal)
        self.QRCodeButton.tintColor = .systemOrange
        self.QRCodeButton.backgroundColor = Colors.darkGray5.color
        self.QRCodeButton.rondBorder()
        self.QRCodeButton.addTarget(self, action: #selector(QRCodeButtonSelected), for: .touchUpInside)
        
        
        self.backgroundView.addSubview(self.deleteButton)
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.deleteButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        self.deleteButton.topAnchor.constraint(equalToSystemSpacingBelow: self.shareModeButton.bottomAnchor, multiplier: 2).isActive = true
        self.deleteButton.leftAnchor.constraint(equalTo: self.QRCodeButton.rightAnchor, constant: buttonDistance).isActive = true
        if #available(iOS 13.0, *) {
            self.deleteButton.setImage(UIImage(systemName: "trash") , for: .normal)
        }
        self.deleteButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        self.deleteButton.setTitleColor(.systemRed, for: .normal)
        self.deleteButton.tintColor = .systemOrange
        self.deleteButton.rondBorder()
        self.deleteButton.addTarget(self, action: #selector(trashButtonSelected), for: .touchUpInside)
        if isUserKey{ // Cannot delete user own key
            deleteButton.backgroundColor = UIColor(red: 0.121, green: 0.13, blue: 0.142, alpha: 1)
            deleteButton.tintColor = .lightGray
            self.trashBarButtonItem.tintColor = .lightGray
            self.editBarButtonItem.tintColor = .lightGray
        }
        
        /*self.backgroundView.addSubview(self.copyButton)
        self.copyButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(scale: UIImage.SymbolScale.large)
        self.copyButton.setImage(UIImage(systemName: "doc.circle", withConfiguration: config), for: .normal)
        self.copyButton.rightAnchor.constraint(equalTo: self.encryptButton.leftAnchor, constant: -10).isActive = true 
        self.copyButton.centerYAnchor.constraint(equalToSystemSpacingBelow: self.key.centerYAnchor, multiplier: 1).isActive = true
        self.copyButton.clipsToBounds = true
        self.copyButton.tintColor = .systemOrange
        self.copyButton.addTarget(self, action: #selector(copyButtonSelected), for: .touchUpInside)
       */
        self.backgroundView.addSubview(self.notificationView)
        self.notificationView.translatesAutoresizingMaskIntoConstraints = false
        self.notificationView.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1).isActive = true
        self.notificationView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.notificationView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.notificationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        self.notificationView.layer.borderWidth = 2
        self.notificationView.layer.cornerRadius = 20
        self.notificationView.backgroundColor = .white
        self.notificationView.setTitleColor(.black, for: .normal)
        self.notificationView.alpha = 0
        self.notificationView.setTitle("Copied".localized(), for: .normal)
        self.notificationView.addTarget(self, action: #selector(notificationViewSelected), for: .touchUpInside)
        
        /*self.backgroundView.addSubview(self.date)
        self.date.translatesAutoresizingMaskIntoConstraints = false
        self.date.centerXAnchor.constraint(equalToSystemSpacingAfter: self.view.centerXAnchor, multiplier: 1).isActive = true
        self.date.topAnchor.constraint(equalToSystemSpacingBelow: self.shareButton.bottomAnchor, multiplier: 2).isActive = true
        self.date.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.date.textColor = .lightGray
        self.date.font = UIFont(name: "Baskerville Bold", size: 15)
        self.date.text = "Added on "*/
        
        self.backgroundView.addSubview(self.tips)
        self.tips.translatesAutoresizingMaskIntoConstraints = false
        self.tips.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        self.tips.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 10).isActive = true
        self.tips.topAnchor.constraint(equalToSystemSpacingBelow: self.deleteButton.bottomAnchor, multiplier: 2).isActive = true
        self.tips.numberOfLines = 1
        self.tips.textColor = .darkGray
        self.tips.font = UIFont(name: "Arial Rounded MT Bold", size: 13)
        self.tips.text = "Tips : double tap on the key-text to copy it !".localized()
    }
    
    
    
    //
    // IBAction func
    //
    
    @IBAction private func shareBarButtonItemSelected(sender: UIBarButtonItem){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.key.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction private func trashBarButtonItemSelected(sender: UIBarButtonItem){
        if  isUserKey{ // cannot delete user key
            alert("That's your own public key !".localized() , message: "You cannot delete your own public key. To revoke your keys, go to settings.".localized(withKey: "ownKeyErrorMessage"))
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let A1 = UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.cancel, handler: nil)
            let A2 = UIAlertAction(title: "Destroy this key".localized(), style: UIAlertAction.Style.destructive, handler: { (_) in
                self.destroyKey()
            })
            alert.addAction(A1)
            alert.addAction(A2)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func editBarButtonItemSelected(sender: UIBarButtonItem){
        if isUserKey { //cannot edit user key
            alert("That's your own public key !".localized() , message: "You cannot edit your own public key. To revoke your keys, go to settings".localized(withKey: "ownKeyErrorEdit"))
        } else {
            performSegue(withIdentifier: "editKey", sender: self)
        }
       
    }
    
    @IBAction private func QRCodeButtonItemSelected(sender: UIBarButtonItem){
        performSegue(withIdentifier: "QRCODE", sender: self)
    }
    
    
    //
    // Obj C func
    //
    
    @objc private func shareButtonSelected(sender: UIButton){
        let activityViewController = UIActivityViewController(activityItems: ["\(self.key.text!)" as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @objc private func trashButtonSelected(sender: UIButton){
        if  isUserKey{ // cannot delete user key
            alert("That's your own public key !".localized() , message: "You cannot delete your own public key. To revoke your keys, go to settings".localized(withKey: "ownKeyErrorMessage"))
        } else {
            sender.isEnabled = false
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let A1 = UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.cancel, handler: { (_) in
            sender.isEnabled = true
            })
            let A2 = UIAlertAction(title: "Destroy this key".localized(), style: UIAlertAction.Style.destructive, handler: { (_) in
            self.destroyKey()
            })
            alert.addAction(A1)
            alert.addAction(A2)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func QRCodeButtonSelected(sender: UIButton){
        performSegue(withIdentifier: "QRCODE", sender: self)
    }
  
    
    /// When user click on 'Use this key to encrypt a message' button. We send data to EncryptHomePage with all field filled
    @objc private func encryptMessageSelected(sender: UIButton){
        performSegue(withIdentifier: "encryptMessage", sender: self)
    }
    
    @objc private func dismissView(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc private func editKeyResult(notification: Notification){
        let notificationData = notification.userInfo
        self.name = notificationData?["name"] as! String
        self.keyTitle.text = (notificationData?["name"] as! String)
        self.key.text = (notificationData?["key"] as! String)
    }
    
    @objc private func backToNormal(){ // reset the button
        let animation = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.7, animations: {
            self.notificationView.alpha = 0
       })
       animation.startAnimation()
       
    }
    @objc private func copyButtonSelected(sender: UIButton){
        UIPasteboard.general.string = self.key.text
        let animation = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5, animations: {
            self.notificationView.alpha = 1
       })
       animation.startAnimation()
        perform(#selector(backToNormal), with: nil, afterDelay: 1.5)
        
        //self.copyButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        //self.copyButton.tintColor = .systemGreen
        
    }
    
    @objc private func notificationViewSelected(sender: UIButton){// If the notification is touched, we hide it
        backToNormal()
    }
    
    @objc func shareModeValueChanged(){
        
    }
    
    
    
    //
    // Data gestion func
    //
    
    private func destroyKey(){
        //First in the dictionnary :
        let keyNameData = KeyId()
        var listeKeyName = keyNameData.getKeyName()
        listeKeyName.remove(at: listeKeyName.firstIndex(of: name)!)
        keyNameData.stockNewNameIdArray(listeKeyName)
        //then the keychain :
        KeychainWrapper.standard.removeObject(forKey: name)
        UIView.animate(withDuration: 1.5, animations: {
            self.key.alpha = 0
            self.keyTitle.alpha = 0
            self.deleteButton.alpha = 0
            self.shareButton.alpha = 0
            self.encryptButton.alpha = 0
            self.date.alpha = 0
            self.tips.alpha = 0
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
        } else if segue.identifier == "QRCODE"{
            let qrCodeView = segue.destination as? QRCodeViewController
            let qrCodeData = QRCodeData()
            let data = qrCodeData.getQRCodeTextFromPublicKey(self.key.text!)
            if data != nil {
                qrCodeView?.text = data!
                qrCodeView?.titleStr = self.keyTitle.text!
            }else {
                qrCodeView?.text = ""
                qrCodeView?.titleStr = "Error 🚧. Please try again.".localized()
            }
        } 
        
    }
}
