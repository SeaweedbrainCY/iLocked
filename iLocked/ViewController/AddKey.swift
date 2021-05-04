//
//  AddKey.swift
//  iLocked
//
//  Created by Nathan on 30/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

class AddKey: UIViewController, UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var nameLabel = UILabel()
    var nameField = UITextField()
    var nameError = UIButton()
    var publicKeyLabel = UILabel()
    var publicKeyField = UITextView()
    var publicKeyError = UIButton()
    var nextButton = UIButton()
    var chargement = UIActivityIndicatorView()
    var tikImage = UIImageView()
    var currentColorButton = UIButton()
    var chooseColorControl = UISegmentedControl()
    
    var viewOnBack: String = ""
    var oldName:String = ""
    var oldKey : String = ""
    
    let keyTextViewPlaceholder = "If it's not ugly it can't be that ..."
    
    let forbiddenKeyName = [userPublicKeyId, userPrivateKeyId, "My encryption key"] // List of forbidden keyName
    
    //##################################################################################
    //##################################################################################
        //ATTENTION CE MORCEAU DE CODE EST STRICTEMENT SUPERFLU. IL CONCERNE UNE FONCTIONNALITÉ NON IMPLENTÉE ET TOUJOURS EN COURS DE DEVELOPPEMENT.
        //RÉINTEGRER CETTE PARTIE DE CODE EST INUTILE PUISQUE NON-UTILISÉ.
        /*local var
        let listeImageColor: [UIImage] = [UIImage(named: "blue")!, UIImage(named: "red")!, UIImage(named: "orange")!, UIImage(named: "green")!, UIImage(named: "pink")!, UIImage(named: "white")!, UIImage(named: "gray")!]*/
    //##################################################################################
    //##################################################################################
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View on back = \(self.viewOnBack)")
        self.scrollView.delegate = self
        self.scrollView.keyboardDismissMode = .onDrag
        self.backgroundView.layer.cornerRadius = 40
        addViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(true)
            //Call when the user tap once or twice on the home button
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
        }
    
    
    
    
    //
    // View constructions func
    //
    
    private func addViews(){
        backgroundView.addSubview(nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.leftAnchor, multiplier: 2).isActive = true
        self.nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.scrollView.topAnchor, multiplier: 2).isActive = true
        self.nameLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 30)
        self.nameLabel.textColor = .white
        self.nameLabel.text = "Name of this key :"
        
        backgroundView.addSubview(nameField)
        self.nameField.translatesAutoresizingMaskIntoConstraints = false
        self.nameField.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.nameField.topAnchor.constraint(equalToSystemSpacingBelow: self.nameLabel.bottomAnchor, multiplier: 2).isActive = true
        self.nameField.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width -  20).isActive = true
        self.nameField.font = UIFont(name: "Arial Rounded MT Bold", size: 20)
        self.nameField.textColor = .systemOrange
        self.nameField.placeholder = "Aa"
        self.nameField.keyboardAppearance = .dark
        self.nameField.textContentType = .name
        self.nameField.borderStyle = .roundedRect
        self.nameField.layer.cornerRadius = 15
        self.nameField.layer.borderWidth = 5
        self.nameField.layer.borderColor = .none
        self.nameField.backgroundColor = .black
        if self.oldName != ""{ // Name is given by ShowKey.swift in case of modification
            self.nameField.text = oldName
        }
        
        backgroundView.addSubview(nameError)
        self.nameError.translatesAutoresizingMaskIntoConstraints = false
        self.nameError.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.nameError.topAnchor.constraint(equalToSystemSpacingBelow: self.nameLabel.bottomAnchor, multiplier: 2).isActive = true
        self.nameError.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width -  20).isActive = true
        self.nameError.titleLabel!.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        self.nameError.setTitleColor(.systemRed, for: .normal)
        self.nameError.layer.cornerRadius = 15
        self.nameError.layer.borderWidth = 1
        self.nameError.layer.borderColor = UIColor.white.cgColor
        self.nameError.backgroundColor = .white
        self.nameError.isHidden = true
        self.nameError.addTarget(self, action: #selector(nameErrorSelected), for: .touchUpInside)
        
        backgroundView.addSubview(publicKeyLabel)
        self.publicKeyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.publicKeyLabel.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.leftAnchor, multiplier: 2).isActive = true
        self.publicKeyLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.nameField.topAnchor, multiplier: 5).isActive = true
        self.publicKeyLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 25)
        self.publicKeyLabel.textColor = .white
        self.publicKeyLabel.text = "Public (encryption) key :"
        
        backgroundView.addSubview(publicKeyField)
        self.publicKeyField.translatesAutoresizingMaskIntoConstraints = false
        self.publicKeyField.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.publicKeyField.topAnchor.constraint(equalToSystemSpacingBelow: self.publicKeyLabel.bottomAnchor, multiplier: 1.5).isActive = true
        self.publicKeyField.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 20).isActive = true
        self.publicKeyField.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.publicKeyField.font = UIFont(name: "American Typewriter", size: 20)
        self.publicKeyField.textColor = .lightGray
        self.publicKeyField.text = self.keyTextViewPlaceholder
        self.publicKeyField.keyboardAppearance = .dark
        self.publicKeyField.textContentType = .name
        self.publicKeyField.rondBorder()
        self.publicKeyField.layer.borderColor = UIColor.black.cgColor
        self.publicKeyField.backgroundColor = .black
        self.publicKeyField.delegate = self
        if self.oldKey != ""{ //Given by ShowKey.swift's class in case of modification
            self.publicKeyField.text = self.oldKey
            self.publicKeyField.textColor = .systemOrange
        }
        
        backgroundView.addSubview(publicKeyError)
        self.publicKeyError.translatesAutoresizingMaskIntoConstraints = false
        self.publicKeyError.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.publicKeyError.topAnchor.constraint(equalToSystemSpacingBelow: self.publicKeyLabel.bottomAnchor, multiplier: 1.5).isActive = true
        self.publicKeyError.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - 20).isActive = true
        self.publicKeyError.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.publicKeyError.titleLabel!.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        self.publicKeyError.setTitleColor(.systemRed, for: .normal)
        self.publicKeyError.layer.cornerRadius = 15
        self.publicKeyError.layer.borderWidth = 1
        self.publicKeyError.titleLabel?.numberOfLines = 20
        self.publicKeyError.layer.borderColor = UIColor.white.cgColor
        self.publicKeyError.backgroundColor = .white
        self.publicKeyError.isHidden = true
        self.publicKeyError.addTarget(self, action: #selector(publicKeyErrorSelected), for: .touchUpInside)
        
        //##################################################################################
        //##################################################################################
        //ATTENTION : CETTE PARTIE DE CODE EST NON OPTIMISÉE ET NON TERMINÉE.
        //CE CODE EST EN PRÉVSISION D'UNE FUTUR MISE À JOUR MAIS N'EST ABSOLUMENT PAS AU POINT
        //LE RÉTABLISSEMENT DE CE CODE SANS SÉRIEUX COMPLÉMENT MET EN PÉRIL LE CHARGEMENT DE LA VIEW
        /*self.backgroundView.addSubview(self.currentColorButton)
        self.currentColorButton.translatesAutoresizingMaskIntoConstraints = false
        self.currentColorButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.currentColorButton.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: self.publicKeyField.bottomAnchor, multiplier: 4).isActive = true
        self.currentColorButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.currentColorButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.currentColorButton.titleLabel?.backgroundColor = .blue
        self.currentColorButton.addTarget(self, action: #selector(colorButtonSelected), for: .touchUpInside)
        
        self.backgroundView.addSubview(self.chooseColorControl)
        self.chooseColorControl.translatesAutoresizingMaskIntoConstraints = false
        self.chooseColorControl.leftAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.rightAnchor, multiplier: 2).isActive = true
        self.chooseColorControl.topAnchor.constraint(equalToSystemSpacingBelow: self.publicKeyField.bottomAnchor, multiplier: 4).isActive = true
        self.chooseColorControl.widthAnchor.constraint(equalToConstant: self.scrollView.frame.size.width - self.currentColorButton.frame.size.width - 40).isActive = true
        for i in 0 ..< listeImageColor.count {
            self.chooseColorControl.setImage(listeImageColor[i], forSegmentAt: i)
        }
        self.chooseColorControl.isHidden = true*/
        //##################################################################################
        //##################################################################################
        
        self.backgroundView.addSubview(self.nextButton)
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.centerXAnchor.constraint(equalToSystemSpacingAfter: self.scrollView.centerXAnchor, multiplier: 1).isActive = true
        self.nextButton.topAnchor.constraint(equalToSystemSpacingBelow: self.publicKeyField.bottomAnchor, multiplier: 3).isActive = true
        self.nextButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.nextButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.nextButton.setImage(UIImage(named: "next"), for: .normal)
        self.nextButton.addTarget(self, action: #selector(nextButtonSelected), for: .touchUpInside)
        
        self.backgroundView.addSubview(self.chargement)
        self.chargement.translatesAutoresizingMaskIntoConstraints = false
        self.chargement.centerXAnchor.constraint(equalToSystemSpacingAfter: self.nextButton.centerXAnchor, multiplier: 1).isActive = true
        self.chargement.centerYAnchor.constraint(equalToSystemSpacingBelow: self.nextButton.centerYAnchor, multiplier: 1).isActive = true
        self.chargement.hidesWhenStopped = true
        
    }
    
    
    //
    // Objective C func
    //
    
    @objc private func nameErrorSelected(sender: UIButton){
        flip(firstView: self.nameError, secondView: self.nameField)
    }
    
    @objc private func publicKeyErrorSelected(sender: UIButton){
        flip(firstView: self.publicKeyError, secondView: self.publicKeyField)
    }
    
    //##################################################################################
    //##################################################################################
    //Bouton pour changer la couleur selectionné
    //ATTENTION CETTE FONCTION EST NON IMPLÉMENTÉE DANS LE CODE
    //CETTE FONCTION EST DANS LA PRÉVISION D'UNE AMÉRLIORATION À VENIR.
    //CETTE FONCTION PEUT ÉVENTUELLEMENT DISPARAITRE MOMENTANEMÉNT OU PASSER EN COMMENTAIRE
    /*@objc private func colorButtonSelected(sender:UIButton){
        let animation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut, animations: {
            self.currentColorButton.translatesAutoresizingMaskIntoConstraints = true
            self.chooseColorControl.translatesAutoresizingMaskIntoConstraints = true
            self.currentColorButton.frame.origin.x = 20
            self.chooseColorControl.frame.origin.x = 20 + self.currentColorButton.frame.size.width
        })
        animation.startAnimation()
    }*/
    //##################################################################################
    //##################################################################################
    
    @objc private func nextButtonSelected(sender: UIButton){
        //We can try to save data
        
        if self.verify(name : self.nameField.text,key: self.publicKeyField.text) {
            ///we save new data
            if oldName == "" {
                self.saveKeyWithName(nameString: self.nameField.text!)
            } else { /// we edit new data :
                let keyId = KeyId()
                let nameList = keyId.getKeyName()
                print("old name = \(self.oldName)")
                if !nameList.contains(oldName) { // Impossible to find the name. Fatal error
                    self.publicKeyError.setTitle("Impossible to identify this key. Please, try to save again this key. If you see this error several times please report the bug with the id : ##DATA/AK.SWIFT 0003 🛠", for: .normal)
                    self.flip(firstView: self.publicKeyField, secondView: self.publicKeyError)
                    self.flip(firstView: self.publicKeyField, secondView: self.publicKeyError)
                } else { // id found
                    self.saveKeyWithName(nameString: nameField.text!)
                }
            }
        }
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        //print("notification recived")
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    //
    // @IBOutlet func
    //
    
    @IBAction func cancelSelected(sender: UIBarButtonItem){
        print("cancel button selected")
        NotificationCenter.default.post(name: Encrypt.notificationOfNewKey, object: nil, userInfo:["addKey dismissed" : true])
        
        perform(#selector(dismissView), with: nil)
        
    }
    
    //
    // Design function
    //
    
    func flip(firstView : UIView, secondView: UIView) {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]

        UIView.transition(with: firstView , duration: 1.0, options: transitionOptions, animations: {
            firstView.isHidden = true
        })

        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
            secondView.isHidden = false
        })
    }
    
    
    //
    // segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lockApp"{
            let lockedView = segue.destination as! LockedView
            lockedView.activityInProgress = true
        }
    }
    
   

    //
    //Text view delegate
    //
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.keyTextViewPlaceholder{
            textView.text = ""
            textView.textColor = .systemOrange
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if textView.text == "" {
            textView.text = self.keyTextViewPlaceholder
            textView.textColor = .lightGray
        }
    }
    
    //
    // Data func
    //
    
    ///Save a key with an Id
    /// - id : String which correspond to an int
    public func saveKeyWithName(nameString name: String){
        let keyArray = KeyId()
        var nameList = keyArray.getKeyName()
        if nameList.contains(oldName){ // If old name where in the array, we replace it
           nameList.remove(at: nameList.firstIndex(of: oldName)!)
        }
        nameList.append(name)
        keyArray.stockNewNameIdArray(nameList)
        //enregsitrement dans la keyChain:
        let successfulSave:Bool = KeychainWrapper.standard.set("\(self.publicKeyField.text!)", forKey: name)
        if successfulSave {
                //
                //SUCCÈS ::
                //
                print("button = \(self.nextButton.state)")
                NotificationCenter.default.post(name: Encrypt.notificationOfNewKey, object: nil, userInfo:["addKey success" : true])
                //get date
            let formatter:DateFormatter = DateFormatter()
                formatter.dateFormat = "DD/MM/YYY"
            //let todayDate:NSDate = formatter.date(from: Date().description(with: .current))! as NSDate
                if self.viewOnBack == "ShowKey"{
                    NotificationCenter.default.post(name: ShowKey.notificationOfModificationName, object: nil, userInfo: ["name": self.nameField.text!, "key": self.publicKeyField.text!])
                }
                dismissView()
        }
    }
    
    public func verify(name:String?,key:String?) -> Bool{
        let keyArray = KeyId()
        if name == ""{
            self.nameError.setTitle("This key needs a little name 🥺", for: .normal)
            flip(firstView: self.nameField, secondView: self.nameError)
            return false
        } else if key == "" || key == self.keyTextViewPlaceholder{
            self.publicKeyError.setTitle("Without key, no encryption 🤷‍♂️", for: .normal)
            self.flip(firstView: publicKeyField, secondView: self.publicKeyError)
            return false
        } else {
            // Check if the key is valid :
            if !KeyId().checkKeyValidity(key!){
                self.publicKeyError.setTitle("Key isn't valid 🚧\nIt must be generated by the iLocked app and must not be modified", for: .normal)
                self.flip(firstView: publicKeyField, secondView: self.publicKeyError)
                return false
            }
        }
        let nameList = keyArray.getKeyName()
        print("nameList in addKey = \(nameList)")
        if nameList.count != 0{
            if nameList.contains("##ERROR##"){
                self.publicKeyError.setTitle(nameList[0], for: .normal)
                flip(firstView: self.publicKeyField, secondView: self.publicKeyError)
                return false
            } else if oldName == "" { // we don't have any error
                for forbiddenName in self.forbiddenKeyName{
                    if key == forbiddenName{ // Forbidden name
                        self.nameError.setTitle("This name are forbidden 🔏", for: .normal)
                        flip(firstView: self.nameField, secondView: self.nameError)
                        return false
                    }
                }
                print("nameList in addKey = \(nameList)")
                for name in nameList { // we verify if the name already exist
                    print("name already stored = \(name)\n")
                    if name == name {
                        self.nameError.setTitle("This name is already taken 💩", for: .normal)
                        flip(firstView: self.nameField, secondView: self.nameError)
                        return false
                    }
                }
            }
        }
        return true // If we haven't already returned false, it must be true
    }
}

