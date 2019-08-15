
//
//  KeyList.swift
//  Trust
//
//  Created by Nathan on 31/07/2019.
//  Copyright © 2019 Nathan. All rights reserved.
//

import Foundation
import UIKit

class KeyList : UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameList: [String] = ["There is no key saved"]
    var idKeyList: [String] = ["1"]
    var nameSelected = "nil"
    var idKeySelected = "nil"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //récupération des clés enregistrées :
        var dicoEncoded: String = "nil"
        do {
            dicoEncoded = try String(contentsOf: URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(arrayNameIdPath), encoding: .utf8)
        } catch {
            print("Fichier introuvable. ERREUR GRAVE Mais pas trop")
        }
        print("decoded = \(dicoEncoded)")
        if dicoEncoded != "nil"{
            let dicoDecoded = dicoEncoded.convertToDictionary(text: dicoEncoded)
            if let listeNom: [String: String] = dicoDecoded {
                print(listeNom)
                for (id, nom) in listeNom {
                    if nameList[0] == "There is no key saved"{
                        nameList[0] = nom
                        idKeyList[0] = id
                    } else {
                        nameList.append(nom)
                        idKeyList.append(id)
                    }
                }
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell") 
    }
    
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
            return 1
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // titre
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.textLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17)
        if indexPath.section == 0 {
            cell.textLabel!.text = self.nameList[indexPath.row]
        } else {
            cell.textLabel!.text = "Ma propre clé de chiffrement"
        }
        cell.imageAtEnd.image = UIImage(named: "flecheDroite")
        return cell
    }
    
    //Nom des sections
       func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           switch section {
           case 0 : return "Clés de chiffrement enregistrées"
           case 1 : return "MA clé de chiffrement"
           default : return "ERROR"
           }
       }
    
    func numberOfSections(in tableView: UITableView) -> Int { // nbr de section
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //cellule selectionné
        if indexPath.section == 0 {
            if nameList[0] == "There is no key saved" {
                self.nameSelected = nameList[indexPath.row]
                self.idKeySelected = idKeyList[indexPath.row]
                performSegue(withIdentifier: "showKey", sender: nil)
            }
        } else {
            self.nameSelected = "Ma clé de chiffrement"
            self.idKeySelected = "0"
            performSegue(withIdentifier: "showKey", sender: nil)
        }
       tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showKey"{
            let showKeyPage = segue.destination as? ShowKey
            showKeyPage!.name = self.nameSelected
            showKeyPage!.idKey = self.idKeySelected
        }
        
    }
}
