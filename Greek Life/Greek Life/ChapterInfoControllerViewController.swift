//
//  ChapterInfoControllerViewController.swift
//  Greek Life
//
//  Created by Jordan Fefer on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChapterInfoControllerViewController: UIViewController {
    //Jordan added this    
    @IBOutlet weak var MasterName: UILabel!
    @IBOutlet weak var ConstitutionButton: UIButton!
    
    @IBOutlet weak var FoundingFather: UIButton!

   //Jordan added this
    @IBOutlet weak var OpenConstitution: UIButton!
    @IBOutlet weak var chapterName: UILabel!
    @IBOutlet weak var foundingDate: UILabel!
    @IBOutlet weak var activeMaster: UILabel!
    @IBOutlet weak var Logo: UIImageView!
    
    var ref: DatabaseReference!
    
    func ReadMaster() {
        
        ref =  Database.database().reference()
        ref.child("Users").child("Master").observeSingleEvent(of: .value, with:{(snapshot) in
            let snap = snapshot.value as? NSDictionary
            let firstName = snap?["First Name"] as? String
            let lastName = snap?["Last Name"] as? String
            
            let fullName = firstName! + " " + lastName!
            self.MasterName.text = fullName;
        })
    
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        ReadMaster()
        Logo.image = UIImage(named: "Docs/Logos/Letters1.png")
        LoadConfiguration.loadConfig() //temporary - Jonah
        chapterName.text = Configuration.Config!["ChapterName"] as? String ?? "" + " Chapter"
        foundingDate.text = Configuration.Config!["FoundingDate"] as? String ?? ""
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
