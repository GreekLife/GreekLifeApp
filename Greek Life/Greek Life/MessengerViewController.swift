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
    
    static var handles = [DatabaseHandle]() //To be deleted
    
    static var dmHandle = DatabaseHandle()
    static var chHandle = DatabaseHandle()
    static var dbSnapshot = DataSnapshot()
    
    static func removeObservers () -> Void {
        Database.database().reference().removeObserver(withHandle: dmHandle)
        Database.database().reference().removeObserver(withHandle: chHandle)
        
    }
}

//-----------------------------------------------------------------------------------------------------------
//  Messenger Objects
//-----------------------------------------------------------------------------------------------------------

// --- Dialogue --- //

class Dialogue {
    
    // --- Dialogue Attributes --- //
    
    var id = ""
    var messages = [Message]()
    var messengees = [Messengee]()
    
}

// --- Channel Dialogue --- //

class ChannelDialogue: Dialogue {
    
    // --- Channel Dialogue Attributes --- //
    
    
}

// --- Direct Dialogue --- //

class DirectDialogue: Dialogue {
    
    // --- Direct Messenger Dialogue Properties --- //
    
    // --- Constructors ---//
    
    init(id:String) {
        super.init()
        //Assign the id to the object property
        //and populate the array of messengees
        //in case directDialogue doesn't exist
        self.id = id
        let messengeeIDsString = id
        let messengeeIDs = messengeeIDsString.components(separatedBy: ", ")
        for id in messengeeIDs {
            self.messengees.append(Messengee(userID: id))
        }
        //Then continue with initialization script
        initializeDirectDialogue()
    }
    init(messengeeIDs: [String]) {
        super.init()
        //Put together the proper DirectDialogue ID
        //and populate the array of messengees
        //in case directDialogue doesn't exist
        let sortedMessengeeIDs = messengeeIDs.sorted()
        for messengeeID in sortedMessengeeIDs {
            self.id.append(messengeeID+", ")
            self.messengees.append(Messengee(userID: messengeeID))
        }
        self.id = String(self.id.dropLast(2)) // to get rid of last ", "
        //Then continue with init script
        initializeDirectDialogue()
    }
    
    func initializeDirectDialogue () -> Void {
        // If the direct dialoue exists pull the data.
        // Otherwise there will be an error and so,
        // create a new one with a welcome message from both messengees.
        //let handle = Database.database().reference().child("DirectDialogues/"+id).observe(.value, with: { snapshot in
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: "DirectDialogues/"+id)
            if snapshot.hasChildren() {
                //Pulling Messages
                for messageSnapshot in snapshot.childSnapshot(forPath: "Messages").children {
                    self.messages.append(Message(
                        id: (messageSnapshot as! DataSnapshot).key,
                        content: (messageSnapshot as! DataSnapshot).value as! String
                    ))
                }
            }else{
                //Create a new Direct Dialogue with welcome messages from each messengee
                for messengee in self.messengees {
                    //make welcome message for the messengee
                    let timeStamp = Int(Date.init().timeIntervalSince1970)
                    let messengeeID = messengee.userID
                    let messageID = String(timeStamp)+", "+messengeeID
                    Database.database().reference().child("DirectDialogues/"+self.id+"/Messages/"+messageID).setValue("Hey, wassup?")
                }
            }
        //})
        /*{ error in
            //Create a new Direct Dialogue with welcome messages from each messengee
            for messengee in self.messengees {
                //make welcome message for the messengee
                let timeStamp = Date.init().timeIntervalSince1970
                let messengeeID = messengee.userID
                let messageID = String(timeStamp)+", "+messengeeID
                Database.database().reference().child("DirectDialogues/"+self.id+"Messages/"+messageID).setValue("Hey, wassup?")
            }
        }*/
        //DatabaseHousekeeping.handles.append(handle)
    }
    
}


// --- Messengee --- //

class Messengee {
    
    // --- Static Messengee Properties --- //
    
    static var messengees = [Messengee]()
    
    // --- Static Messengee Functions --- //
    
    static func getAllFromDB () -> Void {
        //let handle = Database.database().reference().child("Users").observe(.value, with: { snapshot in
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: "Users")
        self.messengees.removeAll()
            for user in snapshot.children {
                self.messengees.append(Messengee(userID: (user as! DataSnapshot).key))
            }
        //})
        /*{ error in
            print("Error: There seems to be no users in the database.")
        }*/
        //DatabaseHousekeeping.handles.append(handle)
    }
    
    // --- Messengee Properties --- //
    
    var firstName = ""
    var lastName = ""
    var userID = ""
    var brotherName = ""
    var position = ""
    
    // --- Contstructor --- //
    
    init(userID:String) {
        self.userID = userID
        //let handle = Database.database().reference().child("Users/"+userID).observe(.value, with: { (snapshot) in
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: "Users/"+userID)
            self.firstName = snapshot.childSnapshot(forPath: "First Name").value as? String ?? " ";
            self.lastName = snapshot.childSnapshot(forPath: "Last Name").value as? String ?? " ";
            self.brotherName = snapshot.childSnapshot(forPath: "BrotherName").value as? String ?? " ";
            self.position = snapshot.childSnapshot(forPath: "Position").value as? String ?? " ";
        //})
    /*{ error in
            print("Error: This brother does not exist.")
        }
        DatabaseHousekeeping.handles.append(handle)*/
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
        let idComponents = id.components(separatedBy: ", ")
        self.timeSent = idComponents[0]
        self.sentBy = idComponents[1]
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
        DatabaseHousekeeping.removeObservers()
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
    
    // --- Direct Messaging Properties --- //
    
    var directDialogues = [DirectDialogue]()
    
    
    // --- IB Outlets --- //
    
    @IBOutlet weak var directDialogueTable: UITableView!
    
    
    // --- View Did Load  --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().observeSingleEvent(of:.value, with: {snapshot in
            //Store Database in housekeeping struct
            DatabaseHousekeeping.dbSnapshot = snapshot
            //Get all the Messengees/Users from database
            Messengee.getAllFromDB()
            self.initDirectDialogues()
            
            //Begin Sync
            DatabaseHousekeeping.dmHandle = Database.database().reference().observe(.value, with: { snapshot in
                DatabaseHousekeeping.dbSnapshot = snapshot
                Messengee.getAllFromDB()
                self.initDirectDialogues()
                self.directDialogueTable.reloadData()
            })
            
        })
    }
    
    // --- Initialize directDialogues --- //
    func initDirectDialogues () -> Void {
        // Initialize directDialogues of LoggedIn user
        self.directDialogues.removeAll()
        let messengeeLoggedIn = LoggedIn.User["UserID"] as! String
        for messengeeOther in Messengee.messengees {
            if messengeeLoggedIn != messengeeOther.userID {
                self.directDialogues.append(DirectDialogue(messengeeIDs: [messengeeLoggedIn, messengeeOther.userID]))
            }
        }
    }
   
    //-- IB Actions --//
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
        DatabaseHousekeeping.removeObservers()
    }
    
    //-- Table of Direct Messaging Conversations --//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return directDialogues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let directDialogue = self.directDialogues[indexPath.row]
        let directDialogueCell = directDialogueTable.dequeueReusableCell(withIdentifier: "directDialogueCell") as! DirectDialogueCell
        // Get the names of the other messengees and put them in a string
        var otherMessengees = ""
        for messengee in directDialogue.messengees {
            if messengee.userID != (LoggedIn.User["UserID"] as! String) {
                otherMessengees.append(messengee.firstName+" "+messengee.lastName+", ")
            }
        }
        directDialogueCell.messengeeOtherLabel.text? = String(otherMessengees.dropLast(2))
        return directDialogueCell
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
}


// --- Direct Dialogue Reusable Cell Class --- //

class DirectDialogueCell: UITableViewCell {
    @IBOutlet weak var messengeeOtherLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    
}


//-----------------------------------------------------------------------------------------------------------
//  Messaging Interface
//-----------------------------------------------------------------------------------------------------------

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    // --- Chat View Controller Properties --- //
    
    var dialogue = Dialogue()
    
    // --- IB Outlets --- //
    
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var messageInputField: UITextView!
    
    
    // --- View Did Load --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //--- IB Actions ---//
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    @IBAction func sendMsgBTN(_ sender: UIButton) {
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











