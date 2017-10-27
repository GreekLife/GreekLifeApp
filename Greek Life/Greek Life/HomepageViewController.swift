//
//  HomepageViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class HomepageViewController: UIViewController {
    
    @IBOutlet weak var CalendarContainer: UILabel!
    @IBOutlet weak var ForumContainer: UILabel!
    @IBOutlet weak var PollContainer: UILabel!
    @IBOutlet weak var BrothersContainer: UILabel!
    @IBOutlet weak var InfoContainer: UILabel!
    @IBOutlet weak var ProfileContainer: UILabel!
    @IBOutlet weak var MasterContainer: UILabel!
    @IBOutlet weak var Logo: UIImageView!
    
    @IBOutlet weak var BackgroundPic: UIImageView!
    
    @IBOutlet weak var instantMessaging: UIImageView!
    @IBOutlet weak var imContainer: UILabel!
    @IBOutlet weak var imLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        MasterContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        imContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        CalendarContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        ForumContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        PollContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        BrothersContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        InfoContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor
        ProfileContainer.layer.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 157, alpha: 0.2).cgColor

        let background = BackgroundPic;
        background?.image = UIImage(named: "AEPiDocs/School.png");
        background?.alpha = 0.9
        
        let logo = Logo;
        logo?.image = UIImage(named: "AEPiDocs/Logos/AEPi.png");
        
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
