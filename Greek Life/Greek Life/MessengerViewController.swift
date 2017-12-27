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
    static var miHandle = DatabaseHandle()
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
    var type = ""
    
    init(dialogueType:String) {
        type = dialogueType
    }
    
}

// --- Channel Dialogue --- //

class ChannelDialogue: Dialogue {
    
    // --- Channel Dialogue Attributes --- //
    var name = ""
    
    // --- Constructors ---//
    // For innitializing a channel from database
    init(id:String) {
        super.init(dialogueType: "ChannelDialogues")
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: "ChannelDialogues/"+id)
        self.id = id
        self.name = snapshot.childSnapshot(forPath: "Name").value as! String
        for messageSnapshot in snapshot.childSnapshot(forPath: "Messages").children {
            self.messages.append(Message(
                messageID: (messageSnapshot as! DataSnapshot).key,
                content: (messageSnapshot as! DataSnapshot).value as! String
            ))
        }
        let messengeesArrayOfIDs = (snapshot.childSnapshot(forPath: "Messengees").value as! String).components(separatedBy: ", ")
        for messengeeID in messengeesArrayOfIDs {
            messengees.append(Messengee(userID: messengeeID))
        }
    }
    
    // Send a message to the channel
    func sendMessage(message:Message) {
        Database.database().reference().child("ChannelDialogues/"+self.id+"/Messages/"+message.id).setValue(message.content)
    }
    
    // --- Static Functions --- //
    //Creation of a Channel
    static func createChannel(channelName:String, messengees:[Messengee], welcomeMessage:Message) -> Void {
        let dbChannelRef = Database.database().reference().child("ChannelDialogues/").childByAutoId()
        dbChannelRef.setValue(["Name": channelName])
        dbChannelRef.child("Messages").setValue([welcomeMessage.id: welcomeMessage.content])
        var listOfMessengees = ""
        for messengee in messengees {
            listOfMessengees.append(messengee.userID+", ")
        }
        listOfMessengees.removeLast(2)
        dbChannelRef.setValue(["Messengees": listOfMessengees])
    }
    
    
}

// --- Direct Dialogue --- //

class DirectDialogue: Dialogue {
    
    // --- Direct Messenger Dialogue Properties --- //
    
    // --- Constructors ---//
    
    init(id:String) {
        super.init(dialogueType: "DirectDialogues")
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
        super.init(dialogueType: "DirectDialogues")
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
    // --- Generic Initialization Common to Contstructors --- //
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
                        messageID: (messageSnapshot as! DataSnapshot).key,
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
    
    // --- Send Message to Dialogue --- //
    
    func sendMessage(message:Message) {
        Database.database().reference().child("DirectDialogues/"+self.id+"/Messages/"+message.id).setValue(message.content)
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
    var sentByName = ""
    var timeSent = ""
    
    // --- Constructors --- //
    //For pulling a message
    init(messageID:String, content:String) {
        self.id = messageID
        self.content = content
        let idComponents = messageID.components(separatedBy: ", ")
        self.timeSent = idComponents[0]
        self.sentBy = idComponents[1]
        self.sentByName = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: "Users/"+sentBy+"/First Name").value as? String ?? "Error: Couldn't find this user's first name."
    }
    //For sending a message
    init(senderID:String, content:String) {
        self.timeSent = String(Int(Date.init().timeIntervalSince1970))
        self.sentBy = senderID
        self.id = self.timeSent+", "+self.sentBy
        self.sentByName = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: "Users/"+sentBy+"/First Name").value as? String ?? "Error: Couldn't find this user's first name."
        self.content = content
    }
    
}


//-----------------------------------------------------------------------------------------------------------
//  Channels View
//-----------------------------------------------------------------------------------------------------------

//--- Channels Controller ---//

class ChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // --- Channel Dialogues Properties --- //
    var channelDialogues = [ChannelDialogue]()
    
    // --- IB Outlets --- //
    
    @IBOutlet weak var channelsTable: UITableView!
    
    
    // --- View Did Load --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // --- IB Actions --- //
    
    @IBAction func createChannelBTN(_ sender: UIBarButtonItem)
    {
        self.performSegue(withIdentifier: "ChannelSettingsSegue", sender: "")
    }
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
        performSegue(withIdentifier: "ChatViewSegue", sender: directDialogues[indexPath.row])
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: directDialogues[indexPath.row])
    }
    
    
    //-- Prepare for Segues --//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatViewSegue" {
            (segue.destination as! ChatViewController).dialogue = sender as! DirectDialogue
        }
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
    
    var dialogue = Dialogue(dialogueType: "")
    var numRowsInTable = 0
    var endOfTable = IndexPath(row: 0, section: 0)
    
    // --- IB Outlets --- //
    
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var messageInputField: UITextView!
    
    
    // --- View Did Load --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // --- Set up the table --- //
        //messagesTable.estimatedRowHeight = 85.0
        messagesTable.rowHeight = 100.0 //UITableViewAutomaticDimension
        messagesTable.reloadData()
        scrollToBottom()
        
        DatabaseHousekeeping.miHandle = Database.database().reference().observe(.value, with: { snapshot in
            DatabaseHousekeeping.dbSnapshot = snapshot
            let oldDialogueID = self.dialogue.id
            if self.dialogue.type == "DirectDialogues" {
                self.dialogue = DirectDialogue(id: oldDialogueID)
            }
            self.messagesTable.reloadData()
            self.scrollToBottom()
        })
        
        
        
    }
    
    // --- Function to scroll to end of the table --- //
    
    func scrollToBottom() -> Void {
        numRowsInTable = messagesTable.numberOfRows(inSection: 0)
        endOfTable.row = numRowsInTable-1
        messagesTable.scrollToRow(at: endOfTable, at: .bottom, animated: false)
    }
    
    //--- IB Actions ---//
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    @IBAction func sendMsgBTN(_ sender: UIButton) {
        if self.dialogue.type == "DirectDialogues" {
            let messageToSend = Message(senderID: (LoggedIn.User["UserID"] as! String), content: messageInputField.text)
            (self.dialogue as! DirectDialogue).sendMessage(message: messageToSend)
        }
        self.messageInputField.text = ""
    }
    
    //--- Table of Messages in Direct Message or Channel ---//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogue.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageCell = messagesTable.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        
        messageCell.messageSender.text = dialogue.messages[indexPath.row].sentByName
        messageCell.message.text = dialogue.messages[indexPath.row].content
        
        return messageCell
    }
    
    
    
}
//--- Cells for the Messaging Interface Table ---//

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageSender: UILabel!
    @IBOutlet weak var message: UILabel!
    
}


//-----------------------------------------------------------------------------------------------------------
//  Channel Creation/Editing View
//-----------------------------------------------------------------------------------------------------------

class ChannelSettingsViewController:UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // --- Channel Settings Properties --- //
    var channelID = ""
    var channelName = ""
    var oldWelcomeMessage = ""
    var welcomeMessage = ""
    var allMessengees = [Messengee]()
    var messengeesInChannel = [Messengee]()
    var messengeesNotInChannel = [Messengee]()
    
    // --- IB Outlets --- //
    @IBOutlet weak var channelNameField: UITextField!
    @IBOutlet weak var welcomeMessageField: UITextField!
    @IBOutlet weak var tableOfMessengeesInChannel: UITableView!
    
    
    // --- View Did Load --- //
    override func viewDidLoad() {
        super.viewDidLoad()
        let snapshot = DatabaseHousekeeping.dbSnapshot
        // Get all potential messengees
        for messengeeSnap in snapshot.childSnapshot(forPath: "Users").children
        {
            allMessengees.append(Messengee(userID: (messengeeSnap as! DataSnapshot).key))
        }
        // Get all channel data if channel exists and shove it into the fields
        if snapshot.childSnapshot(forPath: "ChannelDialogue/"+channelID).exists() {
            let channelSnap = snapshot.childSnapshot(forPath: "ChannelDialogue/"+channelID)
            // Get channelID
            self.channelID = channelSnap.key
            // Get channelName
            self.channelName = channelSnap.childSnapshot(forPath: "Name").value as! String
            // Get the original Welcome Message
            self.oldWelcomeMessage = (Array(channelSnap.childSnapshot(forPath: "Messages").children)[0] as! DataSnapshot).value as! String
            self.welcomeMessage = self.oldWelcomeMessage
            // Get messengeesInChannel
            for messengeeID in (channelSnap.childSnapshot(forPath: "Messengees").value as! String).components(separatedBy: ", ")
            {
                messengeesInChannel.append(Messengee(userID: messengeeID))
            }
            //Check populate the messengeesNotInChannel
            var messengeeIsInChannel = false
            for messengeeA in allMessengees {
                for messengeeB in messengeesInChannel {
                    if messengeeA.userID == messengeeB.userID {
                        messengeeIsInChannel = true
                    }
                }
                if !messengeeIsInChannel {
                    messengeesNotInChannel.append(messengeeA)
                }
            }
            // Shove data into the fields
            self.channelNameField.text = self.channelName
            self.welcomeMessageField.text = self.welcomeMessage
            self.tableOfMessengeesInChannel.reloadData()
        }
    }
    
    // --- IB Actions --- //
    @IBAction func cancelBTN(_ sender: UIBarButtonItem)
    {
        presentingViewController?.dismiss(animated: true)
    }
    // Submit the changes to database then dismiss view
    @IBAction func doneBTN(_ sender: Any)
    {
        // Get or set referece/id for channelDialogue
        var channelDBReference = DatabaseReference()
        if self.channelID == "" {
            channelDBReference = Database.database().reference().child("ChannelDialogues").childByAutoId()
        }
        else {
            channelDBReference = Database.database().reference().child("ChannelDialogues/"+self.channelID)
        }
        // --- Update the messengees --- //
        // Remove messengees that were turned off
        var messengeeIndexesToRemoveFromChannel = [Int]()
        for cellRow in 0...(tableOfMessengeesInChannel.numberOfRows(inSection: 0)-1) {
            let messengeeCell = tableOfMessengeesInChannel.cellForRow(at: IndexPath(row: cellRow, section: 0)) as! ChannelSettingsMessengeeCell
            if messengeeCell.channelMemberSwitch.isOn == false {
                messengeeIndexesToRemoveFromChannel.append(cellRow)
            }
        }
        var removalCount = 0
        for index in messengeeIndexesToRemoveFromChannel {
            let indexToRemove = index - removalCount
            messengeesInChannel.remove(at: indexToRemove)
            removalCount += 1
        }
        // Add messengees that were turned on
        for cellRow in 0...(tableOfMessengeesInChannel.numberOfRows(inSection: 1)-1) {
            let messengeeCell = tableOfMessengeesInChannel.cellForRow(at: IndexPath(row: cellRow, section: 1)) as! ChannelSettingsMessengeeCell
            if messengeeCell.channelMemberSwitch.isOn == true{
                messengeesInChannel.append(messengeesNotInChannel[cellRow])
            }
        }
        // Make the string of IDs for the database
        var stringOfIDsForDB = ""
        for messengee in messengeesInChannel {
            stringOfIDsForDB.append(messengee.userID+", ")
        }
        stringOfIDsForDB = String(stringOfIDsForDB.dropLast(2))
        channelDBReference.setValue(["Messengees":stringOfIDsForDB])
        
        // --- Update the Welcome Messages if new --- //
        welcomeMessage = welcomeMessageField.text!
        if welcomeMessage != oldWelcomeMessage {
            let timeRN = Date.init().timeIntervalSince1970
            let messageID = String(timeRN)+", "+(LoggedIn.User["UserID"] as! String)
            channelDBReference.child("Messages/"+messageID).setValue(welcomeMessage)
        }
        
        // --- Update Channel Name --- //
        channelName = channelNameField.text!
        channelDBReference.child("Name").setValue(channelName)
        
        presentingViewController?.dismiss(animated: true)
    }
    
    // --- Table O' Messengees --- //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Current Channel Members:"
        }else{
            return "Rest of Users:"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return messengeesInChannel.count
        } else {
            return messengeesNotInChannel.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messengeeCell = tableOfMessengeesInChannel.dequeueReusableCell(withIdentifier: "ChannelMessengeeCell")! as! ChannelSettingsMessengeeCell
        
        if indexPath.section == 0 {
            messengeeCell.messengeeNameLabel.text = messengeesInChannel[indexPath.row].firstName+" "+messengeesInChannel[indexPath.row].lastName
            messengeeCell.channelMemberSwitch.isOn = true
        }
        else {
            messengeeCell.messengeeNameLabel.text = messengeesNotInChannel[indexPath.row].firstName+" "+messengeesNotInChannel[indexPath.row].lastName
            messengeeCell.channelMemberSwitch.isOn = false
        }
        return messengeeCell
    }
}

class ChannelSettingsMessengeeCell: UITableViewCell {
    
    // --- IB Outlets --- //
    @IBOutlet weak var messengeeNameLabel: UILabel!
    @IBOutlet weak var channelMemberSwitch: UISwitch!
    
    
    
}









