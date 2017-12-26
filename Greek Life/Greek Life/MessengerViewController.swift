//
//  Messenger.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-23.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

/*Avi was here in this code. hahahahaha
 Enter block Jonah enter {
 {I am the best
 When you press enter your message sends
 When you type it types the message
 That is how a messenger works
 Thank you computer for doing
 The end
 Error be gone
 
 }*/


import UIKit
import FirebaseDatabase

//-----------------------------------------------------------------------------------------------------------
//  Database Objects
//-----------------------------------------------------------------------------------------------------------

struct DatabaseHousekeeping {
    
    static var handles = [DatabaseHandle]()
    
}

//-----------------------------------------------------------------------------------------------------------
//  Messenger Objects
//-----------------------------------------------------------------------------------------------------------

// --- Channel Dialiogue --- //

class ChannelDialogue {
    
    // --- Channel Dialogue Attributes --- //
    
    var messengees = [Messengee]()
    var messages = [Message]()
    
}

// --- Direct Dialogue --- //

class DirectDialogue {
    
    // --- Direct Messenger Dialogue Properties --- //
    
    var id = ""
    var messages = [Message]()
    var messengees = [Messengee]()
    
    // --- Constructor ---//
    
    init(id:String) {
        self.id = id
        // If the direct dialoue exists pull the data.
        // Otherwise, create a new one with a welcome message from both messengees
        let handle = Database.database().reference().child("DirectDialogues/"+id).observe(.value, with: { snapshot in
            let messengeeIDsString = snapshot.childSnapshot(forPath: "Messengees").value as! String
            let messengeeIDs = messengeeIDsString.components(separatedBy: ", ")
            //Pulling messengee data
            for id in messengeeIDs {
                self.messengees.append(Messengee(userID: id))
            }
        }){ error in
            Database.database().reference().child("DirectDialogues/"+id)
        }
        DatabaseHousekeeping.handles.append(handle)
    }
    init(ids: [String]) {
        //Put together a proper DirectDialogue ID
    }
    
}


// --- Messengee --- //

class Messengee {
    
    // --- Messengee Properties --- //
    
    var firstName = ""
    var lastName = ""
    var userID = ""
    var brotherName = ""
    var position = ""
    
    // --- Contstructor --- //
    
    init(userID:String) {
        self.userID = userID
        let handle = Database.database().reference().child("Users/"+userID).observe(.value, with: { (snapshot) in
            self.firstName = snapshot.value(forKey: "First Name") as! String;
            self.lastName = snapshot.value(forKey: "Last Name") as! String;
            self.brotherName = snapshot.value(forKey: "BrotherName") as! String;
            self.position = snapshot.value(forKey: "Position") as! String;
        }){ error in
            print("brother did not exist")
        }
        DatabaseHousekeeping.handles.append(handle)
    }
    
}

// --- Message --- //

class Message {
    
    // --- Message Properties --- //
    
    var id = ""
    var content = ""
    var sentBy = ""
    var timeSent = ""
    
    // --- Constructor --- //
    
    init(id:String, content:String) {
        self.id = id
        self.content = content
    }
    
}


//-----------------------------------------------------------------------------------------------------------
//  Channels View
//-----------------------------------------------------------------------------------------------------------

//--- Channels Controller ---//

class ChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
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



//-----------------------------------------------------------------------------------------------------------
//  Direct Messaging
//-----------------------------------------------------------------------------------------------------------

//--- Direct Messaging Controller ---//

class DMViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    //-- IB Outlets and Actions --//
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    //-- Table of Direct Messaging Conversations --//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "ChatViewSegue", sender: "")
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: "")
    }
    
    
    //-- Prepare for Segues --//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    //-- View Did Load  --//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}



//-----------------------------------------------------------------------------------------------------------
//  Messaging Interface
//-----------------------------------------------------------------------------------------------------------

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    
    //--- IB Outlets and Actions ---//
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    //--- Table of Messages in Direct Message or Channel ---//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    
}


//--- Cells for the Messaging Interface Table ---//

class ChatViewMessageCell: UITableViewCell {
    @IBOutlet weak var messageSender: UILabel!
    @IBOutlet weak var messageContent: UILabel!
    
}


//-----------------------------------------------------------------------------------------------------------
//  Messaging Interface Settings
//-----------------------------------------------------------------------------------------------------------

class ChatSettingsViewController:UIViewController
{
    @IBAction func doneBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
}











