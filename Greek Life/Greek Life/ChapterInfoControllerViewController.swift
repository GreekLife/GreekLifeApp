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
    let pdfTitle = "Docs/GL - Official Consitution (Amended Sept_04_2017)"
    
    @IBOutlet weak var MasterName: UILabel!
    @IBOutlet weak var ConstitutionButton: UIButton!
    
    @IBOutlet weak var FoundingFather: UIButton!

   //Jordan added this
    @IBOutlet weak var OpenConstitution: UIButton!
    @IBAction func OpenConsitution(_ sender: Any) {
        if let url = Bundle.main.url(forResource: pdfTitle, withExtension: "pdf")
    {
        let webview = UIWebView(frame: self.view.frame)
        let urlRequest = URLRequest(url: url)
        webview.loadRequest(urlRequest as URLRequest)
        self.view.addSubview(webview)
        }
    }
    @IBOutlet weak var aepiChapterDetails: UILabel!
    @IBOutlet weak var chapterName: UILabel!
    @IBOutlet weak var foundingDate: UILabel!
    @IBOutlet weak var activeMaster: UILabel!
    
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
        
        LoadConfiguration.loadConfig() //temporary - Jonah
        aepiChapterDetails.text = Configuration.Config!["Name"] as! String + " Chapter Details"
        chapterName.text = Configuration.Config!["ChapterName"] as! String + " Chapter"
        foundingDate.text = Configuration.Config!["FoundingDate"] as! String
        
        
        
        
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
