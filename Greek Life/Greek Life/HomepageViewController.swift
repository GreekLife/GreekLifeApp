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
    
    @IBOutlet weak var ForumContainer: UIButton!
    @IBOutlet weak var CalendarContainer: UIButton!
    @IBOutlet weak var PollContainer: UIButton!
    @IBOutlet weak var BrothersContainer: UIButton!
    @IBOutlet weak var MasterContainer: UIButton!
    @IBOutlet weak var ProfileContainer: UIButton!
    @IBOutlet weak var imContainer: UIButton!
    @IBOutlet weak var InfoContainer: UIButton!
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var BackgroundPic: UIImageView!
    
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
       // let blue = UIColor.blue.withAlphaComponent(0.3)
        
        BackgroundPic?.image = UIImage(named: "AEPiDocs/School.png")
        BackgroundPic?.alpha = 0.9
        Logo?.image = UIImage(named: "AEPiDocs/Logos/AEPi.png");
        
        imContainer.layer.cornerRadius = imContainer.frame.width/2;
        imContainer.layer.borderWidth = 0.5;
        imContainer.setImage(UIImage(named: "AEPiDocs/Icons/InstantMessaging.png"), for: UIControlState.normal)
        imContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
        //imContainer.layer.backgroundColor = blue.cgColor
        
        CalendarContainer.layer.cornerRadius = CalendarContainer.frame.width/2;
        CalendarContainer.layer.borderWidth = 1;
        CalendarContainer.setImage(UIImage(named: "AEPiDocs/Icons/Calendar.png"), for: UIControlState.normal)
        CalendarContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
        //CalendarContainer.layer.backgroundColor = blue.cgColor

        ForumContainer.layer.cornerRadius = ForumContainer.frame.width/2;
        ForumContainer.layer.borderWidth = 1;
        ForumContainer.setImage(UIImage(named: "AEPiDocs/Icons/Forum.png"), for: UIControlState.normal)
        ForumContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
        //ForumContainer.layer.backgroundColor = blue.cgColor

        PollContainer.layer.cornerRadius = PollContainer.frame.width/2;
        PollContainer.layer.borderWidth = 1;
        PollContainer.setImage(UIImage(named: "AEPiDocs/Icons/Poll.png"), for: UIControlState.normal)
        PollContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
       // PollContainer.layer.backgroundColor = blue.cgColor

        BrothersContainer.layer.cornerRadius = BrothersContainer.frame.width/2;
        BrothersContainer.layer.borderWidth = 1;
        BrothersContainer.setImage(UIImage(named: "AEPiDocs/Icons/Brothers.png"), for: UIControlState.normal)
        BrothersContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)

        InfoContainer.layer.cornerRadius = InfoContainer.frame.width/2;
        InfoContainer.layer.borderWidth = 1;
        InfoContainer.setImage(UIImage(named: "AEPiDocs/Icons/Info.png"), for: UIControlState.normal)
        InfoContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
       // InfoContainer.layer.backgroundColor = blue.cgColor

        ProfileContainer.layer.cornerRadius = ProfileContainer.frame.width/2;
        ProfileContainer.layer.borderWidth = 1;
        ProfileContainer.setImage(UIImage(named: "AEPiDocs/Icons/Profile.png"), for: UIControlState.normal)
        ProfileContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
        //ProfileContainer.layer.backgroundColor =  blue.cgColor
        
        MasterContainer.layer.cornerRadius = MasterContainer.frame.width/2;
        MasterContainer.layer.borderWidth = 1;
        MasterContainer.setImage(UIImage(named: "AEPiDocs/Icons/Master.png"), for: UIControlState.normal)
        MasterContainer.imageEdgeInsets = UIEdgeInsetsMake(55,55,55,55)
       // MasterContainer.layer.backgroundColor = blue.cgColor
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
