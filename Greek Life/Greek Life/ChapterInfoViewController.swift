//
//  ChapterInfoControllerViewController.swift
//  Greek Life
//
//  Created by Jordan Fefer on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChapterInfoViewController: UIViewController {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var ChapterName: UILabel!
    @IBOutlet weak var FoundingDate: UILabel!
    @IBOutlet weak var ActiveMaster: UILabel!
    @IBOutlet weak var Constitution: UIButton!
    @IBOutlet weak var FoundingFather: UIButton!
    @IBOutlet weak var Home: UIButton!
    @IBAction func HomeBTN(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)

    }

    var ref: DatabaseReference!

    func ReadMaster() {

        ref =  Database.database().reference()
        ref.child("Users").child("Master").observeSingleEvent(of: .value, with:{(snapshot) in
            let snap = snapshot.value as? NSDictionary
            let firstName = snap?["First Name"] as? String
            let lastName = snap?["Last Name"] as? String

            let fullName = firstName! + " " + lastName!
            self.ActiveMaster.text = fullName;
        })

    }

    override func viewDidLoad() {
      super.viewDidLoad()
        ReadMaster()
        Image.image = UIImage(named: "Docs/Logos/Logo4.png")
        LoadConfiguration.loadConfig()
        ChapterName.text = Configuration.Config!["ChapterName"] as? String ?? "" + " Chapter"
        FoundingDate.text = Configuration.Config!["FoundingDate"] as? String ?? ""

        FoundingFather.layer.cornerRadius = 5
        Constitution.layer.cornerRadius = 5
        Home.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

