//
//  PollViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-13.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

struct Poll: Comparable {
    
    static func ==(lhs: Poll, rhs: Poll) -> Bool {
        return lhs.Epoch == rhs.Epoch
    }
    static func < (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.Epoch > rhs.Epoch
    }
    
    var PollId: String
    var Epoch: Double
    var Poster: String
    var PosterId: String
    var PollTitle: String
    var Options: [String]
    var UpVotes: [[String]]
    var Placing: [String]
    var PercentLbl: [UILabel]
    var VoteBtn: [UIButton]
    var OptionTxt: [UITextView]
    var Drawn: Bool
    var ImageURL: String
    var Image: UIImage
    var UpVoteNames: [[String]]
    
    public init() {
        self.PollId = ""
        self.Epoch = 0
        self.Poster = ""
        self.PollTitle = ""
        self.Options = []
        self.UpVoteNames = [[]]
        self.UpVotes = [[]]
        self.Placing = []
        self.PercentLbl = []
        self.VoteBtn = []
        self.OptionTxt = []
        self.Drawn = false
        self.PosterId = ""
        self.ImageURL = "Empty"
        self.Image = UIImage(named: "Icons/Profile.png")!
    }
    
    public init(pollId: String, ImageURL: String, PosterId: String, Epoch: Double, Poster: String, PollTitle: String, options: [String], upVotes: [[String]])
    {
        self.PollId = pollId
        self.Epoch = Epoch
        self.Poster = Poster
        self.PollTitle = PollTitle
        self.Options = options
        self.UpVotes = upVotes
        self.Placing = []
        self.PercentLbl = []
        self.VoteBtn = []
        self.OptionTxt = []
        self.Drawn = false
        self.PosterId = PosterId
        self.ImageURL = ImageURL
        self.Image = UIImage(named: "Icons/Profile.png")!
        self.UpVoteNames = [[]]
    }
    
    
}

class InnerPollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var OptionText: UITextView!
    @IBOutlet weak var VoteBtn: UIButton!
    @IBOutlet weak var PercentLbl: UILabel!
    
}

class PollTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    var rowHeight: CGFloat = 0
    var InnerPollRef: DatabaseReference!
    var User = LoggedIn.User["Username"] as! String
    var UserId = LoggedIn.User["UserID"] as! String
    let first = LoggedIn.User["First Name"] as? String ?? "Unknown"
    let last = LoggedIn.User["Last Name"] as? String ?? "Unknown"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Polling.ListOfPolls[Polling.OuterIndex].Options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = InnerTable.dequeueReusableCell(withIdentifier: "InnerCell") as! InnerPollTableViewCell
        cell.OptionText.isEditable = false
        cell.OptionText.isScrollEnabled = false
        cell.OptionText.isSelectable = false
        cell.OptionText.textAlignment = .justified
        cell.OptionText.layer.cornerRadius = 5
        cell.OptionText.layer.borderWidth = 0.8
        cell.OptionText.layer.borderColor = UIColor(displayP3Red: 20/255, green: 26/255, blue: 110/255, alpha: 1).cgColor
        cell.VoteBtn.layer.borderWidth = 0.8
        cell.VoteBtn.layer.cornerRadius = cell.VoteBtn.frame.width/2
        cell.VoteBtn.layer.borderColor = UIColor(displayP3Red: 212/255, green: 175/255, blue: 55/255, alpha: 1).cgColor
        cell.VoteBtn.backgroundColor = .clear

        for voter in Polling.ListOfPolls[Polling.OuterIndex].UpVotes[indexPath.row] {
            if voter == UserId {
                cell.VoteBtn.backgroundColor = .lightGray
            }
        }
        var placings:[Int] = []
        if Polling.fetched == true {
        for votes in Polling.ListOfPolls[Polling.OuterIndex].Placing {
            let percentIndex = votes.index(of: "%")
            let strVal = votes.prefix(upTo: percentIndex!)
            let val = Int(strVal)
            placings.append(val!)
            
            }
        }
        cell.VoteBtn.tag = (indexPath.row + 1)
        cell.VoteBtn.accessibilityLabel = Polling.ListOfPolls[Polling.OuterIndex].PollId
        cell.VoteBtn.addTarget(self, action: #selector(UpVoteOption(button:)), for: .touchUpInside)
        
        cell.OptionText.text = Polling.ListOfPolls[Polling.OuterIndex].Options[indexPath.row]
        GenericTools.FrameToFitTextView(View: cell.OptionText)
        cell.VoteBtn.setTitle(String(Polling.ListOfPolls[Polling.OuterIndex].UpVotes[indexPath.row].count), for: .normal)
        cell.PercentLbl.text = Polling.ListOfPolls[Polling.OuterIndex].Placing[indexPath.row]
        cell.PercentLbl.frame.origin.y = cell.VoteBtn.frame.origin.y
        if Polling.fetched == true {
        let percentIndex = cell.PercentLbl.text?.index(of: "%")
        let strVal = (cell.PercentLbl.text!).prefix(upTo: percentIndex!)
        let value = Int(strVal)
    }
        self.rowHeight = cell.OptionText.frame.origin.y + cell.OptionText.frame.size.height
        return cell
    }
    
    func UpVoteOption(button: UIButton) {
        if Reachability.isConnectedToNetwork() == true {
        self.InnerPollRef = Database.database().reference()
        InnerPollRef.child("PollOptions").child(button.accessibilityLabel!).child("\"\(button.tag)\"").child("Names").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.UserId){
                FirebaseDatabase.Database.database().reference(withPath: "PollOptions").child(button.accessibilityLabel!).child("\"\(button.tag)\"").child("Names").child(self.UserId).removeValue()
            }
            else {
                let name = "\(self.first) \(self.last)"
                self.InnerPollRef.child("PollOptions").child(button.accessibilityLabel!).child("\"\(button.tag)\"").child("Names").updateChildValues([self.UserId : name])
            }
        })
        }
        else {
            //should help user handle error
            print("Internet Connection not Available!")
        }
    }

    
    var PollRef: DatabaseReference!

    @IBOutlet weak var PollerPicture: UIImageView!
    @IBOutlet weak var Poster: UILabel!
    @IBOutlet weak var Poll: UITextView!
    @IBOutlet weak var PollDate: UILabel!
    @IBOutlet weak var InnerTable: UITableView!
    
    @IBOutlet weak var PollResults: UIButton!
    @IBOutlet weak var SendReminder: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpTable()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpTable(){
        InnerTable?.delegate = self
        InnerTable?.dataSource = self
        
  }
}

struct Polling {
    static var ListOfPolls:[Poll] = []
    static var OuterIndex = 0
    static var RowHeight: CGFloat = 0
    static var fetched = false
}

class PollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var User = LoggedIn.User["Username"] as! String
    var UserId = LoggedIn.User["UserID"] as! String
    let first = LoggedIn.User["First Name"] as! String
    let last = LoggedIn.User["Last Name"] as! String
    var PollRef: DatabaseReference!
    var RowHeight: CGFloat = 0
    var deleteState = false
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var indexPath:IndexPath = IndexPath(item: 0, section: 0) //used for scrolling to the top
    var newestClicked = true
    var oldestClicked = false
    var thisWeekClicked = false
    var thisMonthClicked = false
    
    @IBOutlet weak var Newest: UIButton!
    @IBOutlet weak var Oldest: UIButton!
    @IBOutlet weak var ThisWeek: UIButton!
    @IBOutlet weak var ThisMonth: UIButton!
    
    
    @IBAction func BackHome(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func Newest(_ sender: Any) {
        thisMonthClicked = false
        thisWeekClicked = false
        if oldestClicked == true {
        Polling.ListOfPolls.reverse()
        }
       Newest.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
        Oldest.backgroundColor = UIColor.clear
        ThisWeek.backgroundColor = UIColor.clear
        ThisMonth.backgroundColor = UIColor.clear
        oldestClicked = false
        newestClicked = true
        self.TableView.reloadData()

    }
    
    @IBAction func Oldest(_ sender: Any) {
        thisMonthClicked = false
        thisWeekClicked = false
        Polling.ListOfPolls.reverse()
        Oldest.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
        Newest.backgroundColor = UIColor.clear
        ThisWeek.backgroundColor = UIColor.clear
        ThisMonth.backgroundColor = UIColor.clear
        newestClicked = false
        oldestClicked = true
        self.TableView.reloadData()
    }
    
    @IBAction func ThisWeek(_ sender: Any) {
        if oldestClicked == true {
            Polling.ListOfPolls.reverse()
        }
        ThisWeek.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
        Newest.backgroundColor = UIColor.clear
        Oldest.backgroundColor = UIColor.clear
        ThisMonth.backgroundColor = UIColor.clear
        thisMonthClicked = false
        newestClicked = false
        oldestClicked = false
        thisWeekClicked = true
        self.TableView.reloadData()
    }
    @IBAction func ThisMonth(_ sender: Any) {
        if oldestClicked == true {
            Polling.ListOfPolls.reverse()
        }
        ThisMonth.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
        Newest.backgroundColor = UIColor.clear
        Oldest.backgroundColor = UIColor.clear
        ThisWeek.backgroundColor = UIColor.clear
        thisMonthClicked = true
        newestClicked = false
        oldestClicked = false
        thisWeekClicked = false
        self.TableView.reloadData()
        
    }
    
    @IBOutlet weak var DeleteBtn: UIBarButtonItem!
    @IBOutlet weak var TableView: UITableView!
    @IBAction func DeletePoll(_ sender: Any) {
        if deleteState == true {
            deleteState = false
            self.DeleteBtn.tintColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
        }
        else {
            deleteState = true
            self.DeleteBtn.tintColor = .red
        }
        self.TableView.reloadData()
        self.TableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.top, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        self.view.backgroundColor = UIColor.lightGray
        self.TableView.allowsSelection = false
        
        //Get poll info for each existing poll
        if Reachability.isConnectedToNetwork() {
        GetListOfPolls() {(success) in
            guard success else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve polls.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                print("Internet Connection not Available!")
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                return
            }
            Polling.ListOfPolls = mergeSorting.mergeSort(Polling.ListOfPolls)
                self.CalculateUpVotes(){(success) in
                    guard success else{
                        let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve votes.")
                        BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                        self.view.addSubview(BadPostRequest)
                        print("Internet Connection not Available!")
                        self.activityIndicator.stopAnimating();
                        UIApplication.shared.endIgnoringInteractionEvents();
                        return
                    }
                //Calculate Percentages --
                        var PollNumber = 0
                        for _ in Polling.ListOfPolls {
                            var VoteNumber = 0
                            var totalVotes = 0
                            for option in Polling.ListOfPolls[PollNumber].UpVotes {
                                totalVotes += option.count
                            }
                            for _ in Polling.ListOfPolls[PollNumber].UpVotes {
                                var votesForOption = 0
                                if VoteNumber == 0 {
                                     votesForOption = Polling.ListOfPolls[PollNumber].UpVotes[VoteNumber].count
                                }
                                else {
                                  votesForOption = Polling.ListOfPolls[PollNumber].UpVotes[VoteNumber].count
                                }
                                var voteResult: Float = 0
                                if totalVotes != 0 {
                                    voteResult = (Float(votesForOption) / Float(totalVotes)) * Float(100)
                                }
                                Polling.ListOfPolls[PollNumber].Placing[VoteNumber] = String(String(Int(voteResult)) + "%")
                                VoteNumber += 1
                            }
                            PollNumber += 1
                    }//--
                    //Create elements for options
                    self.ReadImages() {(response) in
                        Polling.fetched = true
                        self.TableView.reloadData()
                        self.activityIndicator.stopAnimating();
                        UIApplication.shared.endIgnoringInteractionEvents();
                    }

                    

            } // --
        }  // Finished Accumulating Data
        }
        else {
           let error = Banner.ErrorBanner(errorTitle: "No Internet Connection Available")
            error.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.view.addSubview(error)
            print("Internet Connection not Available!")
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        }
    }
        func GetListOfPolls(completion: @escaping (Bool) -> Void) {
            PollRef = Database.database().reference()
            PollRef.child("Polls").observe(.value, with: { (snapshot) in
                Polling.ListOfPolls.removeAll()
                let snapshot = snapshot.children
                for snap in snapshot {
                    if let childSnapshot = snap as? DataSnapshot //Datasnapshot provides usable information
                    {
                        if let pollDictionary = childSnapshot.value as? [String:AnyObject] , pollDictionary.count > 0{ //test for at least one child and turn it into a dictionary of values.
                            if let Id = pollDictionary["PostId"] as? String {
                                if let Epoch = pollDictionary["Epoch"] as? Double {
                                    if let Poster = pollDictionary["Poster"] as? String {
                                        if let Title = pollDictionary["Title"] as? String {
                                            if let Options = pollDictionary["Options"] as? [String] {
                                                if let PosterId = pollDictionary["PosterId"] as? String {
                                                    if let imageURL = pollDictionary["ImageURL"] as? String {
                                                    
                                                            var retrievedPoll = Poll(pollId: Id, ImageURL: imageURL, PosterId: PosterId, Epoch: Epoch, Poster: Poster, PollTitle: Title, options: Options, upVotes: [])
                                                for _ in retrievedPoll.Options {
                                                    retrievedPoll.UpVotes.append([])
                                                    retrievedPoll.UpVoteNames.append([])
                                                    retrievedPoll.Placing.append("0%")
                                                }
                                                Polling.ListOfPolls.append(retrievedPoll)
                                                    
                                                }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                completion(true)
            }){ (error) in
                print("Could not retrieve object from database");
                completion(false);
            }
        }
    
    func CalculateUpVotes(completion: @escaping (Bool) -> Void) {
        PollRef = Database.database().reference()
        PollRef.child("PollOptions").observe( .value, with: { (snapshot) in
            self.refreshPollUpvotes()
            let snapshot = snapshot.children
            for snap in snapshot {
                if let childSnapshot = snap as? DataSnapshot //Datasnapshot provides usable information
                {
                    var count = 0
                    if let Options = childSnapshot.value as? [String:AnyObject] , Options.count >= 0{
                        var keyArray:[String] = [] //array of options that have been voted on per poll
                        for(key,_) in Options {
                            let AKey = key
                            keyArray.append(AKey)
                        }
                        for option in Options {
                            var value = option.value as! [String:AnyObject]
                            let names = value["Names"] as! [String:String]
                            for name in names {
                                let num = Int(keyArray[count].replacingOccurrences(of: "\"", with: ""))
                                if num != 0 {
                                var pollCount = 0
                                for poll in Polling.ListOfPolls {
                                    if poll.PollId == childSnapshot.key {
                                        Polling.ListOfPolls[pollCount].UpVotes[num! - 1].append(name.key) //search for the poll id instead of using indexes on list of polls
                                        Polling.ListOfPolls[pollCount].UpVoteNames[num! - 1].append(name.value)
                                    }
                                    pollCount += 1
                                  }
                                }
                            }
                            count += 1
                        }
                    }
                }
            }
            completion(true)
        }){ (error) in
            print("Could not retrieve object from database");
            completion(false)
        }
    }
    
    func refreshPollUpvotes(){
        var refresh = 0
        for _ in Polling.ListOfPolls {
            var refresh2 = 0
            for _ in Polling.ListOfPolls[refresh].UpVotes{
                Polling.ListOfPolls[refresh].UpVotes[refresh2].removeAll()
                refresh2 += 1
            }
            refresh += 1
        }
    }
    
    func ReadImages(completion: @escaping (Bool) -> Void) {
        for count in 0...(Polling.ListOfPolls.count - 1) {
            if Polling.ListOfPolls[count].ImageURL != "Empty" {
                let storageRef = Storage.storage().reference(forURL: Polling.ListOfPolls[count].ImageURL)
                storageRef.getData(maxSize: 10000000) { (data, error) -> Void in
                    if error == nil {
                        if let pic = UIImage(data: data!) {
                            Polling.ListOfPolls[count].Image = pic
                            completion(true)
                        }
                        else {
                            Polling.ListOfPolls[count].Image = UIImage(named: "Icons/Profile.png")!
                            completion(true)
                        }
                    }
                    else {
                        print("Error Loading picture")
                        print(error!)
                        completion(false)
                    }
                }
            }
            else {
                Polling.ListOfPolls[count].Image = UIImage(named: "Icons/Profile.png")!
            }
        }
    }
        
    
    func DeleteSelectedPoll(button: UIButton) {
        if Reachability.isConnectedToNetwork() == true {
        let verify = UIAlertController(title: "Alert!", message: "Are you sure you want to permanantly delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: DeleteSelectedPollInternal)
        let destructorAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        verify.addAction(okAction)
        verify.addAction(destructorAction)
        self.present(verify, animated: true, completion: nil)
        self.buttonIdentifier = button.accessibilityLabel!
        }
        else {
            let error = Banner.ErrorBanner(errorTitle: "No Internet Connection Available")
            error.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.view.addSubview(error)
            print("Internet Connection not Available!")
        }
        
    }
    
    var buttonIdentifier: String = ""
    func DeleteSelectedPollInternal(action: UIAlertAction) {
        if action.title == "Delete"{
            FirebaseDatabase.Database.database().reference(withPath: "Polls").child(self.buttonIdentifier).removeValue()
            FirebaseDatabase.Database.database().reference(withPath: "PollOptions").child(self.buttonIdentifier).removeValue()
            self.deleteState = false
            self.DeleteBtn.tintColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
            self.TableView.reloadData()
        }
    }
    
    var tempIndexPath = 0
    @objc func ViewResults(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        self.tempIndexPath = indexPath!.row
        performSegue(withIdentifier: "ViewResults", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewResults" {
            APoll.poll = Polling.ListOfPolls[tempIndexPath]
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Polling.fetched == false {
            return 0
        }
        return Polling.ListOfPolls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         Polling.OuterIndex = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollTableViewCell
        cell.isHidden = false
        if deleteState == true {
            if UserId != Polling.ListOfPolls[indexPath.row].PosterId && self.User != "Master" {
                cell.isHidden = true
            }
        }
        let epoch = Date().timeIntervalSince1970
        let month = 2678400
        let week = 604800
        if deleteState != true && self.thisWeekClicked {
            let timeSince = Int(epoch - Polling.ListOfPolls[indexPath.row].Epoch)
            if timeSince > week {
                cell.isHidden = true
            }
        }
        
        if deleteState != true && self.thisMonthClicked {
            let timeSince = Int(epoch - Polling.ListOfPolls[indexPath.row].Epoch)
            if timeSince > month {
                cell.isHidden = true
            }
        }
        Polling.OuterIndex = indexPath.row
        let date = CreateDate.getTimeSince(epoch: Polling.ListOfPolls[indexPath.row].Epoch)
        cell.PollerPicture.layer.cornerRadius = cell.PollerPicture.frame.size.width/2
        cell.InnerTable.separatorStyle = UITableViewCellSeparatorStyle.none
        cell.InnerTable.isScrollEnabled = false
        cell.InnerTable.allowsSelection = false

        cell.Poll.text = Polling.ListOfPolls[indexPath.row].PollTitle
        GenericTools.FrameToFitTextView(View: cell.Poll)
        
        cell.PollDate.text = date
        cell.PollerPicture.image = Polling.ListOfPolls[indexPath.row].Image
        cell.Poster.text = Polling.ListOfPolls[indexPath.row].Poster
        cell.InnerTable.reloadData()
        //Get expected height of table
        var size: CGFloat = 0
        for option in Polling.ListOfPolls[indexPath.row].Options {
            let newText = UITextView(frame: CGRect(x: 0, y: 0, width: 238, height: 0))
            newText.text = option
            GenericTools.FrameToFitTextView(View: newText)
            size += newText.frame.size.height
        }
        
        cell.InnerTable.frame.size.height = size + CGFloat(Polling.ListOfPolls[indexPath.row].Options.count * 3)
        cell.InnerTable.frame.origin.y = cell.Poll.frame.origin.y + cell.Poll.frame.size.height + 10
        cell.DeleteButton.frame.origin.y = cell.InnerTable.frame.origin.y + cell.InnerTable.frame.size.height
        cell.PollResults.frame.origin.y = cell.InnerTable.frame.origin.y + cell.InnerTable.frame.size.height
        cell.SendReminder.frame.origin.y = cell.PollResults.frame.origin.y
        cell.PollDate.frame.origin.y = cell.PollResults.frame.origin.y
        Polling.RowHeight = cell.PollResults.frame.origin.y + cell.PollResults.frame.size.height
        cell.SendReminder.isHidden = true
        
        if UserId == Polling.ListOfPolls[indexPath.row].PosterId || self.User == "Master" {
            cell.SendReminder.isHidden = false
        }
        
        if self.deleteState == true {
            if UserId == Polling.ListOfPolls[indexPath.row].PosterId || self.User == "Master" {
        cell.DeleteButton.isHidden = false
        cell.DeleteButton.layer.cornerRadius = 5
        cell.DeleteButton.accessibilityLabel = Polling.ListOfPolls[indexPath.row].PollId
        cell.DeleteButton.addTarget(self, action: #selector(DeleteSelectedPoll(button:)), for: .touchUpInside)
        cell.DeleteButton.frame.origin.y = cell.InnerTable.frame.origin.y + cell.InnerTable.frame.size.height + 10
        cell.PollResults.frame.origin.y = cell.DeleteButton.frame.origin.y + cell.DeleteButton.frame.size.height + 10
        cell.SendReminder.frame.origin.y = cell.PollResults.frame.origin.y
        cell.PollDate.frame.origin.y = cell.PollResults.frame.origin.y
        Polling.RowHeight = cell.PollResults.frame.origin.y + cell.PollResults.frame.size.height
            }
        }
        else {
            cell.DeleteButton.isHidden = true
        }
        
        cell.PollResults.addTarget(self, action: #selector(ViewResults(button:)), for: .touchUpInside)

        if cell.isHidden {
            Polling.RowHeight = 0
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Polling.RowHeight
    }

}
