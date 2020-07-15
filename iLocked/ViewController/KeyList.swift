//
//  KeyList.swift
//  iLocked
//
//  Created by Nathan on 31/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit




class KeyList : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var selectCellButton : UIBarButtonItem!
    @IBOutlet weak var addKeyButton : UIBarButtonItem!
    
    
    var nameList: [String] = ["There is no key saved"]
    var nameSelected = "nil"
    var userKeySelected = false // We can inform ShowKey.swift, if the key selected, is the user key or not
    
    var selectModeIsActive = false // false = normal mode. False = user wants to select some cells.
    var selectedCellList : [Int] = [] // contains index.row of each selected cell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //On regarde les notifications :
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: Encrypt.notificationName, object: nil)
        
        //récupération des clés enregistrées :
        loadData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        
        if nameList == ["There is no key saved"] {
            self.selectCellButton.isEnabled = false //no cell to select
        }
         
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Call when the user tap once or twice on the home button
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                
    }
    
    func alert(_ title: String, message: String, quitMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: quitMessage, style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    //
    // tableView delegate func
    //
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{ // cellule par section
        if section == 0 {
            return nameList.count
        } else {
            if !selectModeIsActive { // user can't select this cell
                return 1
            } else {
                return 0
            }
            
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // titre
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        if indexPath.section == 0 {
            cell.textLabel!.text = self.nameList[indexPath.row]
        } else {
            if !selectModeIsActive { // only if user isn't selecting cells
                cell.textLabel!.text = "My public encryption key"
            } else {
                cell.textLabel!.text = ""
            }
        }
        return cell
    }
    
    //Sections name
       func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           switch section {
           case 0 : return "Saved public encryption keys"
           case 1 : if !selectModeIsActive { return "MY public encryption key"} else { return ""}
           default : return "ERROR"
           }
       }
    
    func numberOfSections(in tableView: UITableView) -> Int { // nbr de section
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //selected cell
        if !selectModeIsActive { // if user is not selecting cells
            if indexPath.section == 0 {
                self.userKeySelected = false
                 if nameList[0] != "There is no key saved" {
                     self.nameSelected = nameList[indexPath.row]
                     performSegue(withIdentifier: "showKey", sender: nil)
                 }
             } else {
                self.userKeySelected = true
                 self.nameSelected = "My encryption key"
                 performSegue(withIdentifier: "showKey", sender: nil)
             }
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else { // if user wants to select cells
            if indexPath.section == 0 {
                
                if selectedCellList.contains(indexPath.row){ // deselect this cell
                    selectedCellList.remove(at: self.selectedCellList.firstIndex(of: indexPath.row)!)
                    let cell : UITableViewCell = tableView.cellForRow(at: indexPath)!
                    cell.backgroundColor = .black
                } else { // select this cell
                    self.selectedCellList.append(indexPath.row)
                    let cell : UITableViewCell = tableView.cellForRow(at: indexPath)!
                    cell.backgroundColor = .systemBlue
                }
                
             } else {
                
                 self.nameSelected = "My encryption key"
                 performSegue(withIdentifier: "showKey", sender: nil)
             }
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    
    //
    // Data funct
    //
    
    public func loadData(){
        let keyId = KeyId()
        let listeNom : [String] = keyId.getKeyName()
        self.nameList = listeNom
        let sortedLists = keyId.sortByAlphabeticOrder(keys: nameList, value: nameList)
        self.nameList = sortedLists[0]
    }
    /*
     let keyNameData = KeyId()
     var listeKeyName = keyNameData.getKeyName()
     listeKeyName.remove(at: listeKeyName.firstIndex(of: name)!)
     keyNameData.stockNewNameIdArray(listeKeyName)
     //then the keychain :
     KeychainWrapper.standard.removeObject(forKey: name)
     */
    
    /// Delete keys selected
    private func destroyKey(){
        let keyNameData = KeyId()
        var listeKeyName = keyNameData.getKeyName()
        for row in selectedCellList { // We destroy key after key
            if let cell : UITableViewCell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) { // get selected cell
                if let cellTitle: String = cell.textLabel?.text{ // get title of the selected cell
                    if let index = nameList.firstIndex(of: cellTitle) { // get title corresponding to this name
                        //Delete in local array
                        listeKeyName.remove(at: listeKeyName.firstIndex(of: nameList[index])!)
                        keyNameData.stockNewNameIdArray(listeKeyName)
                        //then in the keychain :
                        KeychainWrapper.standard.removeObject(forKey: nameList[index])
                        // We display new changes
                        
                    } else { // No index
                        //
                        // ERROR #0004# : SERIOUS
                        //
                        alert("Data wrong saved", message: "Please re-start iLocked and try again. Error code : VC/KL.SWIFT#0004#", quitMessage: "Close")
                        break
                    }
                } else { // No title
                    //
                    // ERROR #0005# : SERIOUS
                    //
                    alert("Data wrong displayed", message: "Please re-start iLocked and try again. Error code : VC/KL.SWIFT#0005#", quitMessage: "Close")
                }
            } else { // No cell correponding to the selection
                //
                // ERROR #0006# : SERIOUS
                //
                alert("No link between selection and saved data", message: "Please re-start iLocked and try again. Error code : VC/KL.SWIFT#0006#", quitMessage: "Close")
            }
            
        }
        self.selectCellButtonSelected(sender: self.selectCellButton)
    }
    
    
    
    //
    // IBAction func
    //
    
    @IBAction public func refreshButtonSelected(sender: UIBarButtonItem){
        if selectModeIsActive {// button is a trash button
            sender.isEnabled = false
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let A1 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (_) in
                sender.isEnabled = true
            })
            let A2 = UIAlertAction(title: "Destroy \(self.selectedCellList.count) key(s)", style: UIAlertAction.Style.destructive, handler: { (_) in
                self.destroyKey()
            })
            alert.addAction(A1)
            alert.addAction(A2)
            self.present(alert, animated: true, completion: nil)
        } else { // is a refresh button
            //On supprime les anciennes infos
            nameList = ["There is no key saved"]
            //On load les nouvelles
            loadData()
            self.tableView.reloadData()
        }
    }
    
    @IBAction public func selectCellButtonSelected(sender: UIBarButtonItem){
        if selectModeIsActive { // User already click on select button and now, want to cancel his action
            self.addKeyButton.isEnabled = true
            self.refreshButton.image = UIImage(systemName: "arrow.clockwise.circle.fill")
            self.refreshButton.tintColor = .systemOrange
            sender.image =  UIImage(systemName: "ellipsis.circle")
            sender.title = ""
            
            // ... and other well unselectable
            nameList = ["There is no key saved"]
            //On load les nouvelles
            selectModeIsActive = false
            loadData()
            self.tableView.reloadData()
        } else { // want to select cell
            
            // We hide other button ...
            self.addKeyButton.isEnabled = false
            self.refreshButton.image =  UIImage(systemName: "trash.circle.fill")
            self.refreshButton.tintColor = .systemRed
            sender.image = nil
            sender.title = "Cancel"
            
            // ... and other well unselectable
            nameList = ["There is no key saved"]
            //On load les nouvelles
            selectModeIsActive = true
            loadData()
            self.tableView.reloadData()
        }
    }
    
    //
    // objc func
    //
    
    @objc private func notificationReceived(){
        refreshButtonSelected(sender: self.refreshButton)
    }
    
    /// Called by notification when the app is moves to background
    @objc private func appMovedToBackground(){
        performSegue(withIdentifier: "lockApp", sender: self)
    }
    
    ///Called by deleteOptionButton when user wants to delete selected key(s)
    @objc private func deleteKeys(){
        var message = "Destroy \(self.selectedCellList.count) key"
        if self.selectedCellList.count > 1 {
            message += "s"
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let A1 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:  {(_) in})
        let A2 = UIAlertAction(title: message, style: UIAlertAction.Style.destructive, handler: { (_) in
            self.destroyKey()
        })
        alert.addAction(A1)
        alert.addAction(A2)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //
    //segue func
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showKey"{
            let showKeyPage = segue.destination as? ShowKey
            showKeyPage!.name = self.nameSelected
            print("isUserKey from KeyList = \(self.userKeySelected)")
            showKeyPage!.isUserKey = self.userKeySelected
            
        }else if segue.identifier == "addKey"{
            let nv = segue.destination as? UINavigationController
            let addView = nv?.viewControllers.first as? AddKey
                addView!.viewOnBack = "KeyList"
        }else if segue.identifier == "lockApp"{
                let lockedView = segue.destination as! LockedView
                lockedView.activityInProgress = true
        }
    }
}
