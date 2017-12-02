//
//  MasterControllsViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-12-01.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MasterControllsViewController: UIViewController {
    
    
    @IBOutlet weak var CurrentCode: UILabel!
    @IBOutlet weak var GenerateNewCode: UIButton!
    @IBOutlet weak var KickAMember: UIButton!
    @IBOutlet weak var SendNotif: UIButton!
    
    var ref: DatabaseReference!

    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrentCode.layer.cornerRadius = 5
        GenerateNewCode.layer.cornerRadius = 5
        KickAMember.layer.cornerRadius = 5
        SendNotif.layer.cornerRadius = 5
        
        ref = Database.database().reference()
        ref.child("CreateAccount").child("GeneratedKey").observe(.value, with: { (snapshot) in
            let code = snapshot.value as? String
            self.CurrentCode.text = code
            
        }) {(error) in
            print(error.localizedDescription)
            print("Could not read code from database")
        }
        
    }

    @IBAction func GenerateNewCode(_ sender: Any) {
        let val1 = arc4random_uniform(10)
        let val2 = arc4random_uniform(10)
        let val3 = arc4random_uniform(10)
        let val4 = arc4random_uniform(10)

        let newCode = "\(val1)\(val2)\(val3)\(val4)"
        ref = Database.database().reference()
        ref.child("CreateAccount").child("GeneratedKey").setValue(newCode)
    }
    @IBAction func KickAMember(_ sender: Any) {
        performSegue(withIdentifier: "KickBrother", sender: self)
    }
    @IBAction func SendNotification(_ sender: Any) {
    }
    
}

class KickPrototypeCell: UITableViewCell {
    
    @IBOutlet weak var Name: UILabel!
}

class KickMember: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var memberList:[String] = []

    @IBOutlet weak var TableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KickCell", for: indexPath) as! KickPrototypeCell
        cell.Name.text = memberList[indexPath.row]
         cell.isSelected = false
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            //code to delete member id
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        //Code that executes if another child is added in as a User in the Firebase Database
        ref.child("Users").observe(.value, with: { (snapshot) in
            for snap in snapshot.children {
                if let childsnap = snap as? DataSnapshot
                {
                    if let dictionary = childsnap.value as? [String:AnyObject], dictionary.count > 0 {
                        let first = dictionary["First Name"] as? String ?? ""
                        let last = dictionary["Last Name"] as? String ?? ""
                        let name = "\(first) \(last)"

                        self.memberList.append(name)
                    }
                    self.TableView.reloadData()

                }
            }
        })
    
    
    }
}
