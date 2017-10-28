//
//  HomepageViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomepageViewController: UIViewController {
    
    @IBOutlet weak var CalendarContainer: UILabel!
    @IBOutlet weak var ForumContainer: UILabel!
    @IBOutlet weak var PollContainer: UILabel!
    @IBOutlet weak var BrothersContainer: UILabel!
    @IBOutlet weak var InfoContainer: UILabel!
    @IBOutlet weak var ProfileContainer: UILabel!
    @IBOutlet weak var MasterContainer: UILabel!
    @IBOutlet weak var imContainer: UILabel!
    @IBOutlet weak var imLabel: UILabel!
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var BackgroundPic: UIImageView!
    
    @IBOutlet weak var InstantMessaging: UIImageView!
    @IBOutlet weak var Forum: UIImageView!
    @IBOutlet weak var Brothers: UIImageView!
    @IBOutlet weak var Profile: UIImageView!
    @IBOutlet weak var Master: UIImageView!
    @IBOutlet weak var Info: UIImageView!
    @IBOutlet weak var Poll: UIImageView!
    @IBOutlet weak var Calendar: UIImageView!
    
    
    @IBAction func LogOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Signed out");
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Forum?.image = UIImage(named: "AEPiDocs/Icons/Forum.png")
        InstantMessaging?.image = UIImage(named: "AEPiDocs/Icons/InstantMessaging.png")
        Brothers?.image = UIImage(named: "AEPiDocs/Icons/Brothers.png")
        Profile?.image = UIImage(named: "AEPiDocs/Icons/Profile.png")
        Master?.image = UIImage(named: "AEPiDocs/Icons/Master.png")
        Info?.image = UIImage(named: "AEPiDocs/Icons/Info.png")
        Poll?.image = UIImage(named: "AEPiDocs/Icons/Poll.png")
        Calendar?.image = UIImage(named: "AEPiDocs/Icons/Calendar.png")
        BackgroundPic?.image = UIImage(named: "AEPiDocs/School.png");
        BackgroundPic?.alpha = 0.9
        Logo?.image = UIImage(named: "AEPiDocs/Logos/AEPi.png");
        
        imContainer.layer.cornerRadius = imContainer.frame.width/2;
        imContainer.layer.borderWidth = 0.5;
        CalendarContainer.layer.cornerRadius = CalendarContainer.frame.width/2;
        CalendarContainer.layer.borderWidth = 1;
        ForumContainer.layer.cornerRadius = ForumContainer.frame.width/2;
        ForumContainer.layer.borderWidth = 1;
        PollContainer.layer.cornerRadius = PollContainer.frame.width/2;
        PollContainer.layer.borderWidth = 1;
        BrothersContainer.layer.cornerRadius = BrothersContainer.frame.width/2;
        BrothersContainer.layer.borderWidth = 1;
        InfoContainer.layer.cornerRadius = InfoContainer.frame.width/2;
        InfoContainer.layer.borderWidth = 1;
        
        ProfileContainer.layer.cornerRadius = ProfileContainer.frame.width/2;
        ProfileContainer.layer.borderWidth = 1;
        MasterContainer.layer.cornerRadius = MasterContainer.frame.width/2;
        MasterContainer.layer.borderWidth = 1;
        
        let blue = UIColor.blue.withAlphaComponent(0.3)
        
        MasterContainer.layer.backgroundColor = blue.cgColor
        imContainer.layer.backgroundColor = blue.cgColor
        CalendarContainer.layer.backgroundColor = blue.cgColor
        ForumContainer.layer.backgroundColor = blue.cgColor
        PollContainer.layer.backgroundColor = blue.cgColor
        BrothersContainer.layer.backgroundColor = blue.cgColor
        InfoContainer.layer.backgroundColor = blue.cgColor
        ProfileContainer.layer.backgroundColor =  blue.cgColor
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        Info.isUserInteractionEnabled = true
        Info.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        print("hi");
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
