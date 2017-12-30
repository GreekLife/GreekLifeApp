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
    static var chSettingsHandle = DatabaseHandle()
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
        DatabaseHousekeeping.chHandle = Database.database().reference().observe(.value, with: {snapshot in
            DatabaseHousekeeping.dbSnapshot = snapshot
            self.channelDialogues.removeAll()
            for channel in snapshot.childSnapshot(forPath: "ChannelDialogues").children {
                let listOfChannelMembers = ((channel as! DataSnapshot).childSnapshot(forPath: "Messengees").value as! String).components(separatedBy: ", ")
                if listOfChannelMembers.contains(LoggedIn.User["UserID"] as! String) ||
                    (LoggedIn.User["Position"] as! String == "Master" && LoggedIn.User["Validated"] as! Bool == true)
                {
                    self.channelDialogues.append(ChannelDialogue(id: (channel as! DataSnapshot).key ))
                }
            }
            
            self.channelsTable.reloadData()
        })
    }
    
    // --- IB Actions --- //
    
    @IBAction func createChannelBTN(_ sender: UIBarButtonItem)
    {
        self.performSegue(withIdentifier: "ChannelSettingsSegue", sender: "")
    }
    @IBAction func backBTN(_ sender: Any)
    {
        DatabaseHousekeeping.removeObservers()
        presentingViewController?.dismiss(animated: true)
    }
    
    
    //Table Stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.channelDialogues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let chCell = (tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ChannelDialogueCell)
        chCell.channelNameLabel.text = channelDialogues[indexPath.row].name
        chCell.lastMessageLabel.text? = ""
        chCell.lastMessageLabel.text?.append(Messengee(userID:(channelDialogues[indexPath.row].messages.last?.sentBy)!).firstName+" "+Messengee(userID: (channelDialogues[indexPath.row].messages.last?.sentBy)!).lastName+": \"")
        chCell.lastMessageLabel.text?.append((channelDialogues[indexPath.row].messages.last?.content)!+"\"")
        
        return chCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "ChatViewSegue", sender: channelDialogues[indexPath.row])
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChannelSettingsSegue", sender: channelDialogues[indexPath.row])
    }
    
    //-- Prepare for Segues --//
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatViewSegue" {
            (segue.destination as! ChatViewController).dialogue = (sender as! ChannelDialogue)
        }
        else if segue.identifier == "ChannelSettingsSegue" {
            (segue.destination as! ChannelSettingsViewController).channelID = (sender as! ChannelDialogue).id
        }
    }
    
}


// --- Channel Dialogue Cell --- //
class ChannelDialogueCell: UITableViewCell {
    
    // --- IB Outlets --- //
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    
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
        directDialogueCell.lastMessageLabel.text? = ""
        directDialogueCell.lastMessageLabel.text?.append(Messengee(userID:(directDialogues[indexPath.row].messages.last?.sentBy)!).firstName+" "+Messengee(userID: (directDialogues[indexPath.row].messages.last?.sentBy)!).lastName+": \"")
        directDialogueCell.lastMessageLabel.text?.append((directDialogues[indexPath.row].messages.last?.content)!+"\"")
        return directDialogueCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "ChatViewSegue", sender: directDialogues[indexPath.row])
    }
    /*func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: directDialogues[indexPath.row])
    }*/
    
    
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
            }else if self.dialogue.type == "ChannelDialogues" {
                self.dialogue = ChannelDialogue(id:oldDialogueID)
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
        let messageToSend = Message(senderID: (LoggedIn.User["UserID"] as! String), content: messageInputField.text)
        if self.dialogue.type == "DirectDialogues" {
            (self.dialogue as! DirectDialogue).sendMessage(message: messageToSend)
        }
        else if self.dialogue.type == "ChannelDialogues" {
            (self.dialogue as! ChannelDialogue).sendMessage(message: messageToSend)
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
    var isMessengeeInChannel = [String:Bool]()
    
    var didUpdateSnapshot = false
    
    // --- IB Outlets --- //
    @IBOutlet weak var channelNameField: UITextField!
    @IBOutlet weak var welcomeMessageField: UITextField!
    @IBOutlet weak var tableOfMessengeesInChannel: UITableView!
    
    
    // --- View Did Load --- //
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseHousekeeping.chSettingsHandle = Database.database().reference().observe(.value, with: { snapshot in DatabaseHousekeeping.dbSnapshot = snapshot
        let snapshot = DatabaseHousekeeping.dbSnapshot
        // Get all potential messengees
        for messengeeSnap in snapshot.childSnapshot(forPath: "Users").children
        {
            self.allMessengees.append(Messengee(userID: (messengeeSnap as! DataSnapshot).key))
        }
        // Get all channel data if channel exists and shove it into the fields
        if snapshot.childSnapshot(forPath: "ChannelDialogues/"+self.channelID).exists() {
            let channelSnap = snapshot.childSnapshot(forPath: "ChannelDialogues/"+self.channelID)
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
                self.isMessengeeInChannel[messengeeID] = true
            }
            //Check populate the messengeesNotInChannel
            let messengeeIDIsInChannel = self.isMessengeeInChannel.keys
            for messengee in self.allMessengees {
                if !messengeeIDIsInChannel.contains(messengee.userID) {
                    self.isMessengeeInChannel[messengee.userID] = false
                }
            }
            // Shove data into the fields
            self.channelNameField.text = self.channelName
            self.welcomeMessageField.text = self.welcomeMessage
        } else {
            // If it doesn't exist, put all the messengees into the messengeesNotInChannel and put the logged in user into the messengeesInChannel
            for messengee in self.allMessengees {
                if messengee.userID == (LoggedIn.User["UserID"] as! String) {
                    self.isMessengeeInChannel[messengee.userID] = true
                }
                else {
                    self.isMessengeeInChannel[messengee.userID] = false
                }
            }
        }
        //Reload the table of messengees
            self.tableOfMessengeesInChannel.reloadData()
        
        })
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
        // Make the string of IDs for the database
        var stringOfIDsForDB = ""
        for messengee in isMessengeeInChannel {
            if messengee.value {
                stringOfIDsForDB.append(messengee.key+", ")
            }
        }
        stringOfIDsForDB = String(stringOfIDsForDB.dropLast(2))
        channelDBReference.child("Messengees").setValue(stringOfIDsForDB)
        
        // --- Update the Welcome Messages if new --- //
        welcomeMessage = welcomeMessageField.text!
        if welcomeMessage != oldWelcomeMessage {
            let timeRN = Int(Date.init().timeIntervalSince1970)
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
        var rowCounter = 0;
        if section == 0 {
            for messengee in isMessengeeInChannel {
                if messengee.value == true {rowCounter += 1}
            }
            return rowCounter
        } else {
            for messengee in isMessengeeInChannel {
                if messengee.value == false {rowCounter += 1}
            }
            return rowCounter
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messengeeCell = tableOfMessengeesInChannel.dequeueReusableCell(withIdentifier: "ChannelMessengeeCell")! as! ChannelSettingsMessengeeCell
        messengeeCell.indexOfMessengeeToRemoveFromList = indexPath.row
        messengeeCell.containingView = self
        var arrayOfMessengeesInQuestion = [Messengee]()
        if indexPath.section == 0 {
            
            for messengee in isMessengeeInChannel {
                if messengee.value == true {
                    arrayOfMessengeesInQuestion.append(Messengee(userID: messengee.key))
                }
            }
            messengeeCell.messengeeNameLabel.text = arrayOfMessengeesInQuestion[indexPath.row].firstName+" "+arrayOfMessengeesInQuestion[indexPath.row].lastName
            messengeeCell.messengeeInCellID = arrayOfMessengeesInQuestion[indexPath.row].userID
            messengeeCell.channelMemberSwitch.isOn = true
        }
        else {
            for messengee in isMessengeeInChannel {
                if !messengee.value {
                    arrayOfMessengeesInQuestion.append(Messengee(userID: messengee.key))
                }
            }
            messengeeCell.messengeeNameLabel.text = arrayOfMessengeesInQuestion[indexPath.row].firstName+" "+arrayOfMessengeesInQuestion[indexPath.row].lastName
            messengeeCell.messengeeInCellID = arrayOfMessengeesInQuestion[indexPath.row].userID
            messengeeCell.channelMemberSwitch.isOn = false
        }
        return messengeeCell
    }
}

class ChannelSettingsMessengeeCell: UITableViewCell {
    
    var containingView:ChannelSettingsViewController = ChannelSettingsViewController()
    var messengeeInCellID = ""
    var indexOfMessengeeToRemoveFromList  = 0
    
    // --- IB Outlets --- //
    @IBOutlet weak var messengeeNameLabel: UILabel!
    @IBOutlet weak var channelMemberSwitch: UISwitch!
    
    // --- IB Actions --- //
    @IBAction func channelMemberSwitch(_ sender: UISwitch)
    {
        if sender.isOn {
            containingView.isMessengeeInChannel[messengeeInCellID] = true
        }else{
            containingView.isMessengeeInChannel[messengeeInCellID] = false
        }
        containingView.tableOfMessengeesInChannel.reloadData()
    }
}









