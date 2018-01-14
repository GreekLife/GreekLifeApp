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
import FirebaseStorage
import IQKeyboardManagerSwift

//-----------------------------------------------------------------------------------------------------------
//  Database Objects
//-----------------------------------------------------------------------------------------------------------
struct ConvoImages {
    
    static var imagesForConversation: [String: [UIImage]] = [:]
    
}

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

struct SelectedChannel {
    
    static var chatName = ""
    static var image: UIImage!
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
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/"+id)
        self.id = id
        self.name = snapshot.childSnapshot(forPath: "Name").value as? String ?? ""
        for messageSnapshot in snapshot.childSnapshot(forPath: "Messages").children {
            self.messages.append(Message(
                messageID: (messageSnapshot as! DataSnapshot).key,
                content: (messageSnapshot as! DataSnapshot).value as! String
            ))
        }
        let messengeesArrayOfIDs = (snapshot.childSnapshot(forPath: "Messengees").value as? String ?? "").components(separatedBy: ", ")
        if self.name != "" {
            for messengeeID in messengeesArrayOfIDs {
                messengees.append(Messengee(userID: messengeeID))
            }
        }
    }
    
    // Send a message to the channel
    func sendMessage(message:Message) {
        if message.content.isEmpty || message.content == "" {
            return
        }
        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/"+self.id+"/Messages/"+message.id).setValue(message.content)
    }
    
    // --- Static Functions --- //
    //Creation of a Channel
    static func createChannel(channelName:String, messengees:[Messengee], welcomeMessage:Message) -> Void {
        let dbChannelRef = Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/").childByAutoId()
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
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/DirectDialogues/"+id)
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
                Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/DirectDialogues/"+self.id+"/Messages/"+messageID).setValue("Hey, wassup?")
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
        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/DirectDialogues/"+self.id+"/Messages/"+message.id).setValue(message.content)
    }
    
}


// --- Messengee --- //

class Messengee {
    
    // --- Static Messengee Properties --- //
    
    static var messengees = [Messengee]()
    
    // --- Static Messengee Functions --- //
    
    static func getAllFromDB () -> Void {
        //let handle = Database.database().reference().child("Users").observe(.value, with: { snapshot in
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/Users")
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
        let snapshot = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/Users/"+userID)
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
        self.sentByName = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/Users/"+sentBy+"/First Name").value as? String ?? "Error"
    }
    //For sending a message
    init(senderID:String, content:String) {
        self.timeSent = String(Int(Date.init().timeIntervalSince1970))
        self.sentBy = senderID
        self.id = self.timeSent+", "+self.sentBy
        self.sentByName = DatabaseHousekeeping.dbSnapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/Users/"+sentBy+"/First Name").value as? String ?? "Error"
        self.content = content
    }
    
}


//-----------------------------------------------------------------------------------------------------------
//  Channels View
//-----------------------------------------------------------------------------------------------------------

//--- Channels Controller ---//

class ChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
   
    
    // --- Channel Dialogues Properties --- //
    var channelDialogues = [ChannelDialogue]()
    var filtered = [ChannelDialogue]()
    var searchActive : Bool = false
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    // --- IB Outlets --- //
    
    @IBOutlet weak var channelsTable: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var TableView: UITableView!
    @IBAction func RefreshChannels(_ sender: Any) {
        ActivityWheel.CreateActivityNotBlocked(activityIndicator: activityIndicator,view: self.view);
        self.SearchBar.isHidden = true
        Database.database().reference().observeSingleEvent(of: .value, with: {snapshot in
            DatabaseHousekeeping.dbSnapshot = snapshot
            self.channelDialogues.removeAll()
            for channel in snapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues").children {
                let listOfChannelMembers = ((channel as! DataSnapshot).childSnapshot(forPath: "Messengees").value as! String).components(separatedBy: ", ")
                if listOfChannelMembers.contains(LoggedIn.User["UserID"] as! String) ||
                    (LoggedIn.User["Position"] as! String == "Master" || LoggedIn.User["Contribution"] as! String == "Developer")
                {
                    self.channelDialogues.append(ChannelDialogue(id: (channel as! DataSnapshot).key ))
                }
            }
            self.channelDialogues = self.channelDialogues.sorted(by: { Double(($0.messages.last!.timeSent))! > Double(($1.messages.last!.timeSent))! })
            self.channelsTable.reloadData()
            self.activityIndicator.stopAnimating();
            self.SearchBar.isHidden = false

        })
    }
    
    
    
    // --- View Did Load --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchBar.delegate = self
        ActivityWheel.CreateActivityNotBlocked(activityIndicator: activityIndicator,view: self.view);
        SearchBar.isHidden = true
        TableView.keyboardDismissMode = .interactive
        TableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0);
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Database.database().reference().observeSingleEvent(of: .value, with: {snapshot in
            DatabaseHousekeeping.dbSnapshot = snapshot
            self.channelDialogues.removeAll()
            for channel in snapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues").children {
                let listOfChannelMembers = ((channel as! DataSnapshot).childSnapshot(forPath: "Messengees").value as! String).components(separatedBy: ", ")
                if listOfChannelMembers.contains(LoggedIn.User["UserID"] as! String) ||
                    (LoggedIn.User["Position"] as! String == "Master" || LoggedIn.User["Contribution"] as! String == "Developer")
                {
                    self.channelDialogues.append(ChannelDialogue(id: (channel as! DataSnapshot).key ))
                }
            }
            self.channelDialogues = self.channelDialogues.sorted(by: { Double(($0.messages.last!.timeSent))! > Double(($1.messages.last!.timeSent))! })
            self.channelsTable.reloadData()
            self.activityIndicator.stopAnimating();
            self.SearchBar.isHidden = false
        })
    }
    
    // --- IB Actions --- //
    
    @IBAction func createChannelBTN(_ sender: UIBarButtonItem)
    {
        self.performSegue(withIdentifier: "ChannelSettingsSegue", sender: nil)
    }
    @IBAction func backBTN(_ sender: Any)
    {
        DatabaseHousekeeping.removeObservers()
        presentingViewController?.dismiss(animated: true)
    }
    
    //Search bar stuff
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.SearchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.removeAll()
        
        let textSize = searchText.count

        for dialogue in channelDialogues {
            let name = dialogue.name.count
            if name > textSize {
                let newStr = (dialogue.name).substring(to: searchText.endIndex)
                if searchText.containsIgnoringCase(find: newStr) {
                    filtered.append(dialogue)
                }
            }
            if name < textSize {
                let newStr = searchText.substring(to: dialogue.name.endIndex)
                if newStr.containsIgnoringCase(find: dialogue.name) {
                    filtered.append(dialogue)
                }
            }
            if name == textSize {
                if (searchText).containsIgnoringCase(find: dialogue.name) {
                    filtered.append(dialogue)
                }
            }

        }
    
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.TableView.reloadData()
    }
    
    
    //Table Stuff
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchActive {
            return filtered.count
        }
        else {
            return self.channelDialogues.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let chCell = (tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath) as! ChannelDialogueCell)
        
        if searchActive {
            chCell.channelNameLabel.text = filtered[indexPath.row].name
            chCell.lastMessageLabel.text? = ""
            chCell.lastMessageLabel.text?.append(Messengee(userID:(filtered[indexPath.row].messages.last?.sentBy)!).firstName+" "+Messengee(userID: (filtered[indexPath.row].messages.last?.sentBy)!).lastName+": \"")
            
            var subString = ""
            if (((filtered[indexPath.row].messages.last?.content)!+"\"").count > 8) {
                let index = ((filtered[indexPath.row].messages.last?.content)!+"\"").index(((filtered[indexPath.row].messages.last?.content)!+"\"").startIndex, offsetBy: 8)
                let mySubstring = ((filtered[indexPath.row].messages.last?.content)!+"\"")[..<index]
                subString = String(mySubstring)
            }
            if subString == "https://" {
                chCell.lastMessageLabel.text?.append("Media\"")

            }
            else {
                chCell.lastMessageLabel.text?.append((filtered[indexPath.row].messages.last?.content)!+"\"")
            }
        }
        else {
            chCell.channelNameLabel.text = channelDialogues[indexPath.row].name
            chCell.lastMessageLabel.text? = ""
            chCell.lastMessageLabel.text?.append(Messengee(userID:(channelDialogues[indexPath.row].messages.last?.sentBy)!).firstName+" "+Messengee(userID: (channelDialogues[indexPath.row].messages.last?.sentBy)!).lastName+": \"")
            
            var subString = ""
            if (((channelDialogues[indexPath.row].messages.last?.content)!+"\"").count > 29) {
                let index = ((channelDialogues[indexPath.row].messages.last?.content)!+"\"").index(((channelDialogues[indexPath.row].messages.last?.content)!+"\"").startIndex, offsetBy: 29)
                let mySubstring = ((channelDialogues[indexPath.row].messages.last?.content)!+"\"")[..<index]
                subString = String(mySubstring)
            }
            if subString == "https://firebasestorage.googl" {
                chCell.lastMessageLabel.text?.append("Media\"")
            }
            else {
                chCell.lastMessageLabel.text?.append((channelDialogues[indexPath.row].messages.last?.content)!+"\"")
            }
        }
        if ChannelNotifications.UnreadIds.contains(self.channelDialogues[indexPath.row].id) {
            chCell.lastMessageLabel.textColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
            chCell.NewMessage.isHidden = false
        }
        else {
            chCell.lastMessageLabel.textColor = .white
            chCell.NewMessage.isHidden = true
        }
        
        
        return chCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SelectedChannel.chatName = channelDialogues[indexPath.row].name
        TableView.deselectRow(at: indexPath, animated: true)
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
            if sender != nil {
                (segue.destination as! ChannelSettingsViewController).channelID = (sender as! ChannelDialogue).id
                
            }
        }
    }
    
}


// --- Channel Dialogue Cell --- //
class ChannelDialogueCell: UITableViewCell {
    
    // --- IB Outlets --- //
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var NewMessage: UIButton!
    
    
}


//-----------------------------------------------------------------------------------------------------------
//  Direct Messaging
//-----------------------------------------------------------------------------------------------------------

//--- Direct Messaging Controller ---//

class DMViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    
    // --- Direct Messaging Properties --- //
    
    var directDialogues = [DirectDialogue]()
    var filtered = [DirectDialogue]()
    var searchActive = false
    
    
    // --- IB Outlets --- //
    
    @IBOutlet weak var directDialogueTable: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var TableView: UITableView!
    
    
    // --- View Did Load  --- //
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityWheel.CreateActivityNotBlocked(activityIndicator: activityIndicator,view: self.view);
        SearchBar.isHidden = true
        SearchBar.delegate = self
        
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
                self.directDialogues = self.directDialogues.sorted(by: { Double(($0.messages.last!.timeSent))! > Double(($1.messages.last!.timeSent))! })
                self.directDialogueTable.reloadData()
                self.activityIndicator.stopAnimating();
                self.SearchBar.isHidden = false
            })
            
        })
        
        TableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0);
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
    
    //Search bar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.SearchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered.removeAll()
        
        let textSize = searchText.count
        
        for dialogue in directDialogues {
            var name = ""
            var id = ""
            let idTokens = dialogue.id.components(separatedBy: ",")
            if LoggedIn.User["UserID"] as! String == idTokens[0] {
                id = idTokens[1]
                let space = id.index(id.startIndex, offsetBy: 1)..<id.endIndex
                id = id[space]
            }
            else {
                id = idTokens[0]
            }
            for user in mMembers.MemberList {
                if user.id == id {
                    name = (user.first + " " + user.last)
                }
            }
            let nameCount = name.count
            if nameCount > textSize {
                let newStr = name.substring(to: searchText.endIndex)
                if searchText.containsIgnoringCase(find: newStr) {
                    filtered.append(dialogue)
                }
            }
            if nameCount < textSize {
                let newStr = searchText.substring(to: name.endIndex)
                if newStr.containsIgnoringCase(find: name) {
                    filtered.append(dialogue)
                }
            }
            if nameCount == textSize {
                if (searchText).containsIgnoringCase(find: name) {
                    filtered.append(dialogue)
                }
            }
            
        }
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.TableView.reloadData()
    }
    
    //-- Table of Direct Messaging Conversations --//
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchActive {
            return filtered.count
        }
        else {
        return directDialogues.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let directDialogueCell = directDialogueTable.dequeueReusableCell(withIdentifier: "directDialogueCell") as! DirectDialogueCell
        
        directDialogueCell.accessoryType = .disclosureIndicator

        if searchActive {
            let directDialogue = self.filtered[indexPath.row]
            // Get the names of the other messengees and put them in a string
            var otherMessengees = ""
            for messengee in directDialogue.messengees {
                if messengee.userID != (LoggedIn.User["UserID"] as! String) {
                    otherMessengees.append(messengee.firstName+" "+messengee.lastName+", ")
                }
            }
            directDialogueCell.messengeeOtherLabel.text? = String(otherMessengees.dropLast(2))
            directDialogueCell.lastMessageLabel.text? = ""
            directDialogueCell.lastMessageLabel.text?.append(Messengee(userID:(filtered[indexPath.row].messages.last?.sentBy)!).firstName+" "+Messengee(userID: (filtered[indexPath.row].messages.last?.sentBy)!).lastName+": \"")
            
            var subString = ""
            if (((filtered[indexPath.row].messages.last?.content)!+"\"").count > 8) {
                let index = ((filtered[indexPath.row].messages.last?.content)!+"\"").index(((filtered[indexPath.row].messages.last?.content)!+"\"").startIndex, offsetBy: 8)
                let mySubstring = ((filtered[indexPath.row].messages.last?.content)!+"\"")[..<index]
                subString = String(mySubstring)
            }
            if subString == "https://" {
                 directDialogueCell.lastMessageLabel.text?.append("Media\"")
            }
            else {
                directDialogueCell.lastMessageLabel.text?.append((filtered[indexPath.row].messages.last?.content)!+"\"")
            }
            
        }
        else {
            let directDialogue = self.directDialogues[indexPath.row]
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
            
            var subString = ""
            if (((directDialogues[indexPath.row].messages.last?.content)!+"\"").count > 29) {
                let index = ((directDialogues[indexPath.row].messages.last?.content)!+"\"").index(((directDialogues[indexPath.row].messages.last?.content)!+"\"").startIndex, offsetBy: 29)
                let mySubstring = ((directDialogues[indexPath.row].messages.last?.content)!+"\"")[..<index]
                subString = String(mySubstring)
            }
            if subString == "https://firebasestorage.googl" {
                directDialogueCell.lastMessageLabel.text?.append("Media\"")
            }
            else {
                directDialogueCell.lastMessageLabel.text?.append((directDialogues[indexPath.row].messages.last?.content)!+"\"")
            }
        }
        
        var unreadMessageExists = false
        for messengee in directDialogues[indexPath.row].messengees {
            if DMNotifications.UnreadIds.contains(messengee.userID) {
                unreadMessageExists = true
            }
        }
        if unreadMessageExists {
            directDialogueCell.NewMessage.isHidden = false
            directDialogueCell.lastMessageLabel.textColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
        }
        else {
            directDialogueCell.NewMessage.isHidden = true
            directDialogueCell.lastMessageLabel.textColor = .white
        }
        
        return directDialogueCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let directDialogue = self.directDialogues[indexPath.row]
        // Get the names of the other messengees and put them in a string
        var otherMessengees = ""
        for messengee in directDialogue.messengees {
            if messengee.userID != (LoggedIn.User["UserID"] as! String) {
                otherMessengees.append(messengee.firstName+" "+messengee.lastName+", ")
            }
        }
        SelectedChannel.chatName = String(otherMessengees.dropLast(2))
        TableView.deselectRow(at: indexPath, animated: true)
        removeNotifications(dialogue: directDialogues[indexPath.row])
        performSegue(withIdentifier: "ChatViewSegue", sender: directDialogues[indexPath.row])
    }
    
    func removeNotifications(dialogue: DirectDialogue ) {
        let users = dialogue.id.components(separatedBy: ", ")
        var sender = ""
        if LoggedIn.User["UserID"] as? String == users[0] {
            sender = users[1]
        }
        else if LoggedIn.User["UserID"] as? String == users[1] {
            sender = users[0]
        }
        
        if DMNotifications.UnreadIds.contains(sender) {
            let index = DMNotifications.UnreadIds.index(of: sender)
            DMNotifications.UnreadIds.remove(at: index!)
        }
        
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
    @IBOutlet weak var NewMessage: UIButton!
    
    
}


//-----------------------------------------------------------------------------------------------------------
//  Messaging Interface
//-----------------------------------------------------------------------------------------------------------

class ChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // --- Chat View Controller Properties --- //
    
    var dialogue = Dialogue(dialogueType: "")
    var numRowsInTable = 0
    var endOfTable = IndexPath(row: 0, section: 0)
    
    // --- IB Outlets --- //
    
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var Layout: UIStackView!
    @IBOutlet weak var Toolbar: UIToolbar!
    @IBOutlet weak var TextHeader: UIBarButtonItem!
    
    // --- View Did Load --- //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        self.view.addGestureRecognizer(longPressRecognizer)
        IQKeyboardManager.sharedManager().enable = false
        messagesTable.allowsSelection = false
        messagesTable.keyboardDismissMode = .interactive
        messagesTable.separatorStyle = .none
        messageInputField.frame = CGRect(x: 48, y: 5 , width: (self.view.frame.width - 128), height:30)
        messageInputField.backgroundColor = UIColor(displayP3Red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        messageInputField.layer.borderWidth = 0.5
        messageInputField.delegate = self
        messageInputField.layer.cornerRadius = 10
        self.messageInputField.textColor = .white

        // --- Set up the table --- //
        //messagesTable.estimatedRowHeight = 85.0
        messagesTable.rowHeight = 100.0 //UITableViewAutomaticDimension
        messagesTable.reloadData()

        DatabaseHousekeeping.miHandle = Database.database().reference().observe(.value, with: { snapshot in
            DatabaseHousekeeping.dbSnapshot = snapshot
            let oldDialogueID = self.dialogue.id
            if self.dialogue.type == "DirectDialogues" {
                self.dialogue = DirectDialogue(id: oldDialogueID)
                let users = self.dialogue.id.components(separatedBy: ", ")
                var sender = ""
                if LoggedIn.User["UserID"] as? String == users[0] {
                    sender = users[1]
                }
                else if LoggedIn.User["UserID"] as? String == users[1] {
                    sender = users[0]
                }

                if DMNotifications.UnreadIds.contains(sender) {
                    let index = DMNotifications.UnreadIds.index(of: sender)
                    DMNotifications.UnreadIds.remove(at: index!)
                }
            }else if self.dialogue.type == "ChannelDialogues" {
                self.dialogue = ChannelDialogue(id:oldDialogueID)
            
                if ChannelNotifications.UnreadIds.contains(self.dialogue.id) {
                    let index = ChannelNotifications.UnreadIds.index(of: self.dialogue.id)
                    ChannelNotifications.UnreadIds.remove(at: index!)
                }
            }
            self.messagesTable.reloadData()
            self.scrollToBottom()

        })
        TextHeader.title = SelectedChannel.chatName
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // --- Function to scroll to end of the table --- //
    
    func scrollToBottom() -> Void {
      DispatchQueue.main.async {
        if self.dialogue.messages.count > 0 {
            let indexPath = IndexPath(row: self.dialogue.messages.count-1, section: 0)
            self.messagesTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            messagesTable.contentInset = UIEdgeInsets.zero
        } else {
            messagesTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        messagesTable.scrollIndicatorInsets = messagesTable.contentInset
        
        scrollToBottom()
    }
    

    
    
    //----Create chat box ----/ --> NOt fucking working fucking shit
    
    
    let messageInputField = UITextView()
    let containerView = UIView()
    
    lazy var inputContainerView: UIView = {
        self.containerView.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: 40)
        self.containerView.backgroundColor = UIColor(displayP3Red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        self.containerView.layer.borderWidth = 0.5
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "Icons/upload_image.png")
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        self.containerView.addSubview(uploadImageView)
        
        uploadImageView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true


        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Post", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMsgBTN), for: .touchUpInside)
        self.containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: self.containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: self.containerView.heightAnchor).isActive = true
        
        self.containerView.addSubview(self.messageInputField)
        
        self.messageInputField.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 8).isActive = true
        self.messageInputField.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        self.messageInputField.rightAnchor.constraint(equalTo: sendButton.rightAnchor).isActive = true
        self.messageInputField.heightAnchor.constraint(equalTo: self.containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        let color = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 8).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.view.bringSubview(toFront: self.containerView);
        return self.containerView
    }()
    
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        if let selectedImageFromPicker = selectedImage {
            uploadSelectedImageToFirebase(image: selectedImageFromPicker)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func uploadSelectedImageToFirebase(image: UIImage) {
        self.messageInputField.becomeFirstResponder()
        let randomId = UUID().uuidString
        let userId = LoggedIn.User["UserID"] as! String
        let refId = userId + "," + randomId
        let storageRef = Storage.storage().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/ConvoPictures/" + refId)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.5){
            let newMetadata = StorageMetadata()
            newMetadata.contentType = "image/jpeg";
            
            storageRef.putData(uploadData, metadata: newMetadata, completion:{ (metadata, error) in
                
                if error != nil {
                    GenericTools.Logger(data: "\n Error initializing block value: \(error!)")
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString{
                    self.sendImagegBTN(imageURL: imageURL)
                }
            })
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let originalHeight = textView.frame.size.height
        if originalHeight < 100 {
            GenericTools.FrameToFitTextView(View: textView)
            let newHeight = textView.frame.size.height
            let diff = newHeight - originalHeight
            self.containerView.frame.origin.y -= diff
            self.containerView.frame.size.height += diff
        }
        print(self.containerView.frame.origin.y)

        //self.TableView.contentInset = UIEdgeInsetsMake(0, 0, self.containerView.frame.origin.y, 0)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.containerView.frame.size.height = 40
        textView.frame.size.height = 30

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print(self.containerView.frame.origin.y)
    }
    
    //--- IB Actions ---//
    
    @IBAction func backBTN(_ sender: Any)
    {
        self.messageInputField.endEditing(true)
        self.messageInputField.resignFirstResponder()
        self.containerView.isHidden = true
        presentingViewController?.dismiss(animated: true)
    }
    func sendMsgBTN(button: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if messageInputField.text == "" || messageInputField.text.isEmpty {
                return
            }
        let messageToSend = Message(senderID: (LoggedIn.User["UserID"] as! String), content: messageInputField.text)
        if self.dialogue.type == "DirectDialogues" {
            (self.dialogue as! DirectDialogue).sendMessage(message: messageToSend)
        }
        else if self.dialogue.type == "ChannelDialogues" {
            (self.dialogue as! ChannelDialogue).sendMessage(message: messageToSend)
        }
        self.messageInputField.text = ""
            let originalHeight = messageInputField.frame.size.height
        GenericTools.FrameToFitTextView(View: self.messageInputField)
            let newHeight = messageInputField.frame.size.height
            let diff = newHeight - originalHeight
            self.containerView.frame.origin.y -= diff
            self.containerView.frame.size.height += diff

        }
        else {
            let error = Banner.ErrorBanner(errorTitle: "Internet Connection not available")
            self.view.addSubview(error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                error.isHidden = true
            }
        }
    }
    
    func sendImagegBTN(imageURL: String) {
        if Reachability.isConnectedToNetwork() {
            if imageURL == "" || imageURL.isEmpty {
                return
            }
            let messageToSend = Message(senderID: (LoggedIn.User["UserID"] as! String), content: imageURL)
            if self.dialogue.type == "DirectDialogues" {
                (self.dialogue as! DirectDialogue).sendMessage(message: messageToSend)
            }
            else if self.dialogue.type == "ChannelDialogues" {
                (self.dialogue as! ChannelDialogue).sendMessage(message: messageToSend)
            }
        }
        else {
            let error = Banner.ErrorBanner(errorTitle: "Internet Connection not available")
            self.view.addSubview(error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                error.isHidden = true
            }
        }
    }
    
    //--- Table of Messages in Direct Message or Channel ---//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogue.messages.count
    }
    var rowHeight: CGFloat = 0
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func DeleteMessage(Alert: UIAlertAction) {
        let indexStr = Alert.accessibilityLabel
        let index = Int(indexStr!)
        let message = dialogue.messages[index!]
        // DB call to delete the message
        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/"+dialogue.type+"/"+dialogue.id+"/Messages/"+message.id).setValue("Deleted Message*");
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.messagesTable)
            if let indexPath = self.messagesTable.indexPathForRow(at: touchPoint) {
                let alert = UIAlertController(title: dialogue.messages[indexPath.row].sentByName, message:"", preferredStyle: UIAlertControllerStyle.alert)
                let timeSince = CreateDate.getTimeSince(epoch: Double(dialogue.messages[indexPath.row].timeSent)!)
                alert.addAction(UIAlertAction(title: "Sent " + timeSince + " ago", style: UIAlertActionStyle.default, handler: nil))
                
                if (LoggedIn.User["UserID"] as! String) == dialogue.messages[indexPath.row].sentBy || (LoggedIn.User["Position"] as! String) == "Master"{
                    let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: DeleteMessage)
                    deleteAction.accessibilityLabel = String(describing: indexPath.row)
                    alert.addAction(deleteAction)
                }
                
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        for view in sender.view!.subviews {
            if let imageView = view as? UIImageView {
                self.messageInputField.resignFirstResponder()
                let newImageView = UIImageView(image: imageView.image)
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = .black
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                self.view.addSubview(newImageView)
                self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.messageInputField.becomeFirstResponder()
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func getImage(index: Int, url: String, completion: @escaping (Bool, UIImage) -> Void) {
        Storage.storage().reference(forURL: url).getData(maxSize: 10000000) { (data, error) -> Void in
            if error == nil {
                if let pic = UIImage(data: data!) {
                    pic.accessibilityIdentifier = String(index)
                    if var array = ConvoImages.imagesForConversation[SelectedChannel.chatName] {
                        array.append(pic)
                        ConvoImages.imagesForConversation[SelectedChannel.chatName] = array
                    }
                    else {
                        ConvoImages.imagesForConversation[SelectedChannel.chatName] = [pic]
                    }
                    completion(true, pic)
                }
            }
            else {
                let image = UIImage(named: "Icons/no_image.png")
                completion(false, image!)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell = messagesTable.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
        messageCell.message.becomeFirstResponder() //biggest patch in existance - done at 7:21am post all nighter -- should fix
        
        if (LoggedIn.User["UserID"] as! String) == dialogue.messages[indexPath.row].sentBy {
            messageCell.messageSender.textAlignment = .right
            messageCell.message.textAlignment = .right
            messageCell.message.textContainerInset = UIEdgeInsets(top: 10, left: 0.0, bottom: 10, right: 10)
            
            messageCell.textbubble.layer.backgroundColor = UIColor(displayP3Red: 36/255, green: 91/255, blue: 155/255, alpha: 1).cgColor
            messageCell.message.backgroundColor = UIColor.clear
            messageCell.messageSender.isHidden = true
        }
        else {
            messageCell.messageSender.isHidden = false
            messageCell.messageSender.textAlignment = .left
            messageCell.messageSender.textColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
            messageCell.message.textAlignment = .left
            messageCell.message.backgroundColor = UIColor.clear
            messageCell.message.textContainerInset = UIEdgeInsets(top: 2, left: 5.0, bottom: 10, right: 5)
            messageCell.textbubble.layer.backgroundColor = UIColor(displayP3Red: 90/255, green: 90/255, blue: 90/255, alpha: 1).cgColor
        }
        messageCell.messageSender.text = dialogue.messages[indexPath.row].sentByName
        messageCell.message.text = dialogue.messages[indexPath.row].content
        
        var subString = ""
        if (messageCell.message.text.count > 38) {
            let index = messageCell.message.text.index(messageCell.message.text.startIndex, offsetBy: 38)
            let mySubstring = messageCell.message.text[..<index]
            subString = String(mySubstring)
        }
//        else if (messageCell.message.text.count > 7) {
//            let index = messageCell.message.text.index(messageCell.message.text.startIndex, offsetBy: 7)
//            let mySubstring = messageCell.message.text[..<index]
//            subString = String(mySubstring)
//        }
        if subString == "https://firebasestorage.googleapis.com" {
            messageCell.addSubview(messageCell.textbubble)
            messageCell.textbubble.frame.size.width = 175
            messageCell.textbubble.frame.size.height = 250
            messageCell.textbubble.addSubview(messageCell.imageSentView)

            messageCell.imageSentView.leftAnchor.constraint(equalTo: messageCell.textbubble.leftAnchor).isActive = true
            messageCell.imageSentView.topAnchor.constraint(equalTo: messageCell.textbubble.topAnchor).isActive = true
            messageCell.imageSentView.widthAnchor.constraint(equalTo: messageCell.textbubble.widthAnchor).isActive = true
            messageCell.imageSentView.heightAnchor.constraint(equalTo: messageCell.textbubble.heightAnchor).isActive = true
            
            if (LoggedIn.User["UserID"] as! String) == dialogue.messages[indexPath.row].sentBy {
                messageCell.message.textAlignment = .left
                messageCell.message.frame.origin.y = messageCell.messageSender.frame.origin.y
                messageCell.textbubble.frame = CGRect(x: UIScreen.main.bounds.width - 180, y: 0, width: 175, height: 250)
                self.rowHeight = messageCell.textbubble.frame.size.height + 6
            }
            else {
                messageCell.message.frame.origin.y = messageCell.messageSender.frame.origin.y + messageCell.messageSender.frame.size.height + 1
                messageCell.textbubble.addSubview(messageCell.messageSender)
                messageCell.textbubble.frame = CGRect(x: 10, y: 0, width: 175, height: 250)
                self.rowHeight = messageCell.textbubble.frame.size.height + 6
                messageCell.messageSender.backgroundColor = .clear

            }
            var found = false
            if let array = ConvoImages.imagesForConversation[SelectedChannel.chatName] {
                for pic in array {
                    let accessInt = Int(pic.accessibilityIdentifier!)
                    if accessInt == indexPath.row {
                        messageCell.imageSentView.image = pic
                        found = true
                    }
                }
            }
            if(!found) {
                getImage(index: indexPath.row, url: messageCell.message.text!){ response,pic in
                    if response == true {
                        messageCell.imageSentView.image = pic
                    }
                    else {

                    }
                }
            }
            messageCell.message.text = ""
            messageCell.removeFromSuperview()
            messageCell.textbubble.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:))))
            
        }
//        else if subString == "https:/" || subString == "http://" {
//            let linkAttributes = [
//                NSLinkAttributeName: NSURL(string: messageCell.message.text!)!,
//                NSForegroundColorAttributeName: UIColor.green
//                ] as [String : Any]
//            let attributedString = NSMutableAttributedString(string: messageCell.message.text!)
//             attributedString.setAttributes(linkAttributes, range: NSMakeRange(0, messageCell.message.text.count))
//            messageCell.message.delegate = self
//            messageCell.message.attributedText = attributedString
//        }
        else {
            messageCell.message.textColor = .white
            messageCell.backgroundColor = UIColor(displayP3Red: 90, green: 90, blue: 90, alpha: 1)
            messageCell.imageSentView.removeFromSuperview()
            if messageCell.message.text == "Deleted Message*" {
                messageCell.message.text = "This message has been removed"
                messageCell.message.textColor = .red
            }
        else {
            messageCell.message.textColor = .white
            messageCell.message.text = messageCell.message.text
        }
        
         GenericTools.FrameToFitTextView(View: messageCell.message)
         var newSize = messageCell.message.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        
        if newSize.width > 250 {
            let remainder = 250 - newSize.width
            newSize.width += remainder
        }
        
        let newFrame = CGSize(width: newSize.width, height: newSize.height)
        messageCell.message.frame.size = newFrame
        GenericTools.FrameToFitTextView(View: messageCell.message)

        self.rowHeight = (messageCell.message.frame.size.height + messageCell.messageSender.frame.size.height + 12)
        messageCell.addSubview(messageCell.textbubble)
        messageCell.textbubble.addSubview(messageCell.message)
        
        if (LoggedIn.User["UserID"] as! String) == dialogue.messages[indexPath.row].sentBy {
            messageCell.message.textAlignment = .left
            messageCell.message.frame.origin.y = messageCell.messageSender.frame.origin.y
            messageCell.textbubble.frame = CGRect(x: UIScreen.main.bounds.width - (messageCell.message.frame.size.width + 20), y: messageCell.message.frame.origin.y, width: messageCell.message.frame.size.width + 20, height: messageCell.message.frame.size.height + 3)
            self.rowHeight = messageCell.textbubble.frame.size.height + 6
        }
        else {
            messageCell.message.frame.origin.y = messageCell.messageSender.frame.origin.y + messageCell.messageSender.frame.size.height + 1
            messageCell.textbubble.addSubview(messageCell.messageSender)
            messageCell.textbubble.frame = CGRect(x: 10, y: 0, width: messageCell.message.frame.size.width + 20, height: messageCell.message.frame.size.height + messageCell.messageSender.frame.size.height + 3)
            
            if(100 > messageCell.message.frame.size.width) {
                //Should be wrapping content of name and then accomodating that. but for now ill leave it as a maximum of 60
                messageCell.textbubble.frame.size.width = 100
            }

        }
        }
        return messageCell
    }
    
    
    
}
//--- Cells for the Messaging Interface Table ---//

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageSender: UILabel!
    @IBOutlet weak var message: UITextView!
    
    let imageSentView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
        
    }()
    let textbubble: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 90/255, green: 90/255, blue: 90/255, alpha: 1)
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
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
    
    @IBOutlet weak var DeleteChannelBTN: UIButton!
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
            for messengeeSnap in snapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/Users").children
            {
                self.allMessengees.append(Messengee(userID: (messengeeSnap as! DataSnapshot).key))
            }
            // Get all channel data if channel exists and shove it into the fields
            if self.channelID != "" && snapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/"+self.channelID).exists() {
                let channelSnap = snapshot.childSnapshot(forPath: (Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/"+self.channelID)
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
                self.DeleteChannelBTN.isHidden = true
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
    
    @IBAction func DeleteChannel(_ sender: Any) {
        let delete = UIAlertController(title: "Delete", message: "Are you sure you would like to delete this channel?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: DeleteChannel)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        delete.addAction(cancelAction)
        delete.addAction(okAction)
        self.present(delete, animated: true, completion: nil)
        
    }
    
    func DeleteChannel(alert: UIAlertAction) {
        let currentChannelId = self.channelID
        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/" + currentChannelId).removeValue();
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // --- IB Actions --- //
    @IBAction func cancelBTN(_ sender: UIBarButtonItem)
    {
        presentingViewController?.dismiss(animated: true)
    }
    // Submit the changes to database then dismiss view
    @IBAction func doneBTN(_ sender: Any)
    {
        if welcomeMessageField.text! == "" || channelNameField.text! == "" {
            let verify = UIAlertController(title: "Alert!", message: "You cannot leave any fields empty.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            verify.addAction(okAction)
            self.present(verify, animated: true, completion: nil)
            return
        }
        
        
        
        // Get or set referece/id for channelDialogue
        var channelDBReference = DatabaseReference()
        if self.channelID == "" {
            channelDBReference = Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues").childByAutoId()
        }
        else {
            channelDBReference = Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/ChannelDialogues/"+self.channelID)
        }
        // --- Update the messengees --- //
        // Make the string of IDs for the database
        var stringOfIDsForDB = ""
        var numberOfMembersInChannel = 0
        for messengee in isMessengeeInChannel {
            if messengee.value {
                stringOfIDsForDB.append(messengee.key+", ")
                numberOfMembersInChannel += 1
            }
        }
        if numberOfMembersInChannel < 3 {
            let verify = UIAlertController(title: "Alert!", message: "You cannot make a channel with less than 3 members.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            verify.addAction(okAction)
            self.present(verify, animated: true, completion: nil)
            return
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
extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}









