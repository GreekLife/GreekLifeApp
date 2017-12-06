//
//  HomePage.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-12-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomePageCell: UITableViewCell {
    
    @IBOutlet weak var news: UITextView!
    
    
}

class HomePage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! HomePageCell
        cell.news.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    
    
    @IBOutlet weak var InstantMessaging: UIButton!
    @IBOutlet weak var Forum: UIButton!
    @IBOutlet weak var Calendar: UIButton!
    @IBOutlet weak var Poll: UIButton!
    @IBOutlet weak var Members: UIButton!
    @IBOutlet weak var Profile: UIButton!
    @IBOutlet weak var GoogleDrive: UIButton!
    @IBOutlet weak var Info: UIButton!
    
    let defaults:UserDefaults = UserDefaults.standard
    
    @IBAction func Signout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Signed out");
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        defaults.set(nil, forKey: "Password")
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func buttonClicked(sender: UIButton)
    {
        switch sender.tag {
        case 2:
          //  performSegue(withIdentifier: "InstantMessaging", sender: self)
            break;
        case 3:
            performSegue(withIdentifier: "Forum", sender: self)
            break;
        case 4:
            performSegue(withIdentifier: "Calendar", sender: self)
            break;
        case 5:
            performSegue(withIdentifier: "Poll", sender: self)
            break;
        case 6:
            performSegue(withIdentifier: "Members", sender: self)
            break;
        case 7:
          //  performSegue(withIdentifier: "Profile", sender: self)
            break;
        case 8:
           // performSegue(withIdentifier: "GoogleDrive", sender: self)
            break;
        case 9:
            performSegue(withIdentifier: "Info", sender: self)
            break;
        default: ()
            break;
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add targets
        InstantMessaging.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Forum.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Calendar.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Poll.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Members.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Profile.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        GoogleDrive.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Info.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)

        //Styles
        InstantMessaging.layer.borderColor = UIColor.white.cgColor
        InstantMessaging.layer.borderWidth = 1
        Forum.layer.borderColor = UIColor.white.cgColor
        Forum.layer.borderWidth = 1
        Calendar.layer.borderColor = UIColor.white.cgColor
        Calendar.layer.borderWidth = 1
        Poll.layer.borderColor = UIColor.white.cgColor
        Poll.layer.borderWidth = 1
        Members.layer.borderColor = UIColor.white.cgColor
        Members.layer.borderWidth = 1
        Profile.layer.borderColor = UIColor.white.cgColor
        Profile.layer.borderWidth = 1
        GoogleDrive.layer.borderColor = UIColor.white.cgColor
        GoogleDrive.layer.borderWidth = 1
        Info.layer.borderColor = UIColor.white.cgColor
        Info.layer.borderWidth = 1

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
