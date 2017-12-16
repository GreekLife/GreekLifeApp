//
//  Messenger.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-23.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

  //***********************************//
 //  Messenger Classes: Channels, DM //
//***********************************//
class Channel
{
    var title = ""
    var users = [String:Any]()
    var messages = [String:String]()
}

  //***********************************//
 //  Channel View Controller Class    //
//***********************************//
class ChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var dataRef = Database.database().reference()
    var dataRef2 = Database.database().reference()
    
    var channels = [Channel]()
    
    func initChannels () {
        //Getting Channel Users
        self.dataRef.child("Messenger").child("Channels").observeSingleEvent(of: .value, with: {(snapshot) in
            let dbChannels = snapshot.value as? NSDictionary
            for channel in dbChannels! {
                var currentChannel:Channel = Channel()
                currentChannel.title = channel.key as! String
                let dbMessages = snapshot.childSnapshot(forPath: "\(currentChannel.title)/Messages").value as? NSDictionary
                print(dbMessages)
            }
            
        })
        { (error) in
            print("Could not retrieve object from database");
        }
    }
    override func viewDidLoad() {
        initChannels()
    }
    
    
    
    
    //Top toolbar
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    //Table Stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let convoCell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath)
        return convoCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        performSegue(withIdentifier: "ChatViewSegue", sender: indexPath.row)
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: indexPath.row)
    }
    
    
    
}
  //******************************//
 //  DM View Controller Class    //
//******************************//
class DMViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    //Top toolbar
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
   
    
    
    //Table Stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let convoCell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath)
        return convoCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        performSegue(withIdentifier: "ChatViewSegue", sender: indexPath.row)
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: indexPath.row)
    }
    
}



  //***********************************//
 //   Settings View Controller Class  //
//***********************************//
class ChatSettingsViewController:UIViewController
{
    @IBAction func doneBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
}

  //*******************************//
 //   Chat View Controller Class  //
//*******************************//
class ChatViewController:
    UIViewController,UITableViewDataSource,UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        return messageCell
    }
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
}













