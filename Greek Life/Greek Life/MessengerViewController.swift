//
//  Messenger.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-23.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

  //*****************************************//
 //  Messenger Model Objects: Channels, DM  //
//********************************888888***//
struct Channel
{
    var title = ""
    var users = [String:Any]()
    var messages = [String:String]()
}
struct DMessenger {
    static var dmList = [DM]()
    static var dmListOfLoggedIn = [DM]()
    
    static func initUser(for dmTable:UITableView) -> Void {
    //Check to make sure user has a dm with every other user.
    //If not, create dm in db and put welcome message.
        var dataRef = Database.database().reference()
        let LoggedInUserID = LoggedIn.User["UserID"] as! String
        var userIDList:[String] = []
        var dmIDList:[String] = []
        dmList.removeAll()
        dmListOfLoggedIn.removeAll()
        //Load up the dm's from db
        Database.database().reference().child("Messenger/DMs").observe(.value, with: {(snapshot) in
            for dmSnap in snapshot.children {
                let dmSnapshot = dmSnap as! DataSnapshot
                let messageDict = dmSnapshot.childSnapshot(forPath: "Messages").value as! [String:String]
                let dmID = dmSnapshot.key// childSnapshot(forPath: "dmID").value as! String
                let dmEntry = DM(id: dmID, messages: messageDict)
                self.dmList.append(dmEntry)
            }
        
        //Get list of userID's
        Database.database().reference().child("Users").observe(.value, with: { (snapshot) in
            
            userIDList = (snapshot.value as! [String:Any]).keys.reversed()
            //Replace Master key with his actual userID
            userIDList[userIDList.index(of: "Master")!] = snapshot.childSnapshot(forPath: "Master/UserID").value as! String
            
            //Get list of dmID's
            for dm in DMessenger.dmList {
                dmIDList.append(dm.dmID)
            }
            //Check to see if logged in user has a dm with every other user
        
            for userID in userIDList {
                if (userID != LoggedInUserID)
                {
                    var dmWithUserExists = false
                    for dmID in dmIDList{
                        if (dmID.contains(LoggedInUserID) && dmID.contains(userID)){
                            dmWithUserExists = true
                        }
                    }
                    //If dm between logged in user and userID doesn't exist then make one
                    //and display welcome message
                    if !dmWithUserExists {
                        dataRef = Database.database().reference()
                        let timeStamp = String(Int(Date.init().timeIntervalSince1970))
                        dataRef.child("Messenger/DMs/"+userID+LoggedInUserID+"/Messages/"+timeStamp+","+LoggedInUserID).setValue("Hey, it's brother "+(LoggedIn.User["BrotherName"] as! String))
                    }
                }
            }
            for dm in dmList {
                if dm.dmID.contains(LoggedIn.User["UserID"] as! String) && dm.dmID != dm.dmID+dm.dmID {
                    dmListOfLoggedIn.append(dm)
                }
            }
            dmTable.reloadData()
            })
        })
    }
}
class DM {
    var dmID:String
    var messages:[String:String]
    init(id dmID:String, messages:[String:String]) {
        self.dmID = dmID
        self.messages = messages
    }
    func sendMessage(senderUserID:String, message:String, sendingView:UIViewController) -> Void {
        let dataRef = Database.database().reference()
        let messageID = String(Date.init().timeIntervalSince1970) + "," + senderUserID
        dataRef.child("Messenger/DMs/"+dmID+"/"+messageID).setValue(message){ error in
            let alert = UIAlertController(title: "Cannot send...", message: "We were unable to send you message, please check your internet connection.", preferredStyle: UIAlertControllerStyle.alert )
            alert.addAction(UIAlertAction(title: "Lemme try again", style: UIAlertActionStyle.cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
        }
    }
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
        let dmCell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath)
        return dmCell
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
    //DataBaseStuff
    let dataRef = Database.database().reference()
    var otherUsersFirstLast = [String:String]()
    
    //Top toolbar
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
   
    
    
    //Table Stuff
    @IBOutlet weak var dmTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return DMessenger.dmListOfLoggedIn.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let dmCell = UITableViewCell()
        var otherBrotherID = ""
        if let userIDRange = DMessenger.dmListOfLoggedIn[indexPath.row].dmID.range(of: LoggedIn.User["UserID"] as! String){
            otherBrotherID = DMessenger.dmListOfLoggedIn[indexPath.row].dmID
            otherBrotherID.removeSubrange(userIDRange)
        }
        
        dmCell.textLabel?.text = self.otherUsersFirstLast[otherBrotherID]
        return dmCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        performSegue(withIdentifier: "ChatViewSegue", sender: indexPath.row)
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: indexPath.row)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("Users").observe(.value, with: { (snapshot) in
            for userSnap in snapshot.children {
                let userID = (userSnap as! DataSnapshot).childSnapshot(forPath: "UserID").value as! String
                let firstName = (userSnap as! DataSnapshot).childSnapshot(forPath: "First Name").value as! String
                let lastName = (userSnap as! DataSnapshot).childSnapshot(forPath: "Last Name").value as! String
                self.otherUsersFirstLast[userID] = firstName+", "+lastName
            }
            DMessenger.initUser(for: self.dmTableView)
        })
        
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













