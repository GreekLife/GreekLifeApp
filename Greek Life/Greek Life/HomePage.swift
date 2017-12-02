//
//  HomePage.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-12-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
