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
        self.Image = UIImage(named: "Icons/Placeholder.png")!
    }
    
    public init(pollId: String, PosterId: String, Epoch: Double, Poster: String, PollTitle: String, options: [String], upVotes: [[String]])
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
        self.Image = UIImage(named: "Icons/Placeholder.png")!
        self.UpVoteNames = [[]]
    }
    
    
}

class InnerPollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var OptionText: UITextView!
    @IBOutlet weak var PercentLbl: UILabel!
    @IBOutlet weak var Vote: UILabel!
    @IBOutlet weak var ExtraVotes: UILabel!
    
}

class PollTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    var rowHeight: CGFloat = 0
    var InnerPollRef: DatabaseReference!
    var Position = LoggedIn.User["Position"] as! String
    var UserId = LoggedIn.User["UserID"] as! String
    let first = LoggedIn.User["First Name"] as? String ?? "Unknown"
    let last = LoggedIn.User["Last Name"] as? String ?? "Unknown"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Polling.ListOfPolls[Polling.OuterIndex].Options.count > 10 {
            return 10
        }
        else {
            return Polling.ListOfPolls[Polling.OuterIndex].Options.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = InnerTable.dequeueReusableCell(withIdentifier: "InnerCell") as! InnerPollTableViewCell
        cell.OptionText.isEditable = false
        cell.OptionText.isScrollEnabled = false
        cell.OptionText.isSelectable = false
        cell.OptionText.textAlignment = .justified
        cell.OptionText.layer.cornerRadius = 5
        cell.OptionText.layer.borderWidth = 0.8
        cell.OptionText.layer.borderColor = UIColor(displayP3Red: 38/255, green: 38/255, blue: 38/255, alpha: 1).cgColor
        cell.OptionText.adjustsFontForContentSizeCategory = true

        cell.Vote.layer.borderWidth = 0.8
        cell.Vote.layer.cornerRadius = cell.Vote.frame.width/2
        cell.Vote.backgroundColor = .clear
        cell.Vote.textColor = .white
        cell.Vote.adjustsFontSizeToFitWidth = true
        
        var heightOfLbl:CGFloat = 0
        if Polling.ListOfPolls[Polling.OuterIndex].Options.count > 10 {
            if indexPath.row == 9 {
                cell.ExtraVotes.isHidden = false
                cell.ExtraVotes.frame.origin.y = cell.OptionText.frame.origin.y + cell.OptionText.frame.size.height
                heightOfLbl = cell.ExtraVotes.frame.size.height
            }
            else {
                cell.ExtraVotes.isHidden = true
                heightOfLbl = 0
            }

        }
        else {
            cell.ExtraVotes.isHidden = true
            heightOfLbl = 0
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
        cell.Vote.textColor = .white
        cell.OptionText.text = Polling.ListOfPolls[Polling.OuterIndex].Options[indexPath.row]
        GenericTools.FrameToFitTextView(View: cell.OptionText)
        cell.Vote.text = String(Polling.ListOfPolls[Polling.OuterIndex].UpVotes[indexPath.row].count)
        cell.PercentLbl.text = Polling.ListOfPolls[Polling.OuterIndex].Placing[indexPath.row]
        cell.PercentLbl.frame.origin.y = cell.Vote.frame.origin.y
        self.rowHeight = cell.OptionText.frame.origin.y + cell.OptionText.frame.size.height + heightOfLbl
        return cell
    }

    
    var PollRef: DatabaseReference!

    @IBOutlet weak var PollerPicture: UIImageView!
    @IBOutlet weak var Poster: UILabel!
    @IBOutlet weak var Poll: UITextView!
    @IBOutlet weak var PollDate: UILabel!
    @IBOutlet weak var InnerTable: UITableView!
    
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var Vote: UIButton!
    
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
    
    var Position = LoggedIn.User["Position"] as! String
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
    let filterColor = UIColor(displayP3Red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
    @IBAction func Newest(_ sender: Any) {
        thisMonthClicked = false
        thisWeekClicked = false
        if oldestClicked == true {
        Polling.ListOfPolls.reverse()
        }
        Newest.backgroundColor = .black
        Oldest.backgroundColor = filterColor
        ThisWeek.backgroundColor = filterColor
        ThisMonth.backgroundColor = filterColor
        oldestClicked = false
        newestClicked = true
        self.TableView.reloadData()

    }
    
    @IBAction func Oldest(_ sender: Any) {
        thisMonthClicked = false
        thisWeekClicked = false
        Polling.ListOfPolls.reverse()
        Oldest.backgroundColor = .black
        Newest.backgroundColor = filterColor
        ThisWeek.backgroundColor = filterColor
        ThisMonth.backgroundColor = filterColor
        newestClicked = false
        oldestClicked = true
        self.TableView.reloadData()
    }
    
    @IBAction func ThisWeek(_ sender: Any) {
        if oldestClicked == true {
            Polling.ListOfPolls.reverse()
        }
        ThisWeek.backgroundColor = .black
        Newest.backgroundColor = filterColor
        Oldest.backgroundColor = filterColor
        ThisMonth.backgroundColor = filterColor
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
        ThisMonth.backgroundColor = .black
        Newest.backgroundColor = filterColor
        Oldest.backgroundColor = filterColor
        ThisWeek.backgroundColor = filterColor
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
    
    @IBAction func Refresh(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            GetListOfPolls() {(success, error) in
                guard success else{
                    let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve polls.")
                    BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                    self.view.addSubview(BadPostRequest)
                    GenericTools.Logger(data: "\n Could not retrieve polls: \(error!)")
                    self.activityIndicator.stopAnimating();
                    UIApplication.shared.endIgnoringInteractionEvents();
                    return
                }
                Polling.ListOfPolls = mergeSorting.mergeSort(Polling.ListOfPolls)
                self.CalculateUpVotes(){(success, error) in
                    guard success else{
                        let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve votes.")
                        BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                        self.view.addSubview(BadPostRequest)
                        GenericTools.Logger(data: "\n Could not retrieve votes: \(error!)")
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
                    
                    Polling.fetched = true
                    self.TableView.reloadData()
                    self.activityIndicator.stopAnimating();
                    UIApplication.shared.endIgnoringInteractionEvents();
                    
                } // --
            }  // Finished Accumulating Data
        }
        else {
            let error = Banner.ErrorBanner(errorTitle: "No Internet Connection Available")
            error.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.view.addSubview(error)
            GenericTools.Logger(data: "\n No Internet Connection Available")
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        self.view.backgroundColor = UIColor.lightGray
        self.TableView.allowsSelection = false
        self.TableView.separatorColor =  .black
        self.TableView.separatorStyle = .singleLineEtched
        //Get poll info for each existing poll
        if Reachability.isConnectedToNetwork() {
        GetListOfPolls() {(success, error) in
            guard success else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve polls.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                GenericTools.Logger(data: "\n Could not retrieve polls: \(error!)")
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                return
            }
            Polling.ListOfPolls = mergeSorting.mergeSort(Polling.ListOfPolls)
                self.CalculateUpVotes(){(success, error) in
                    guard success else{
                        let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve votes.")
                        BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                        self.view.addSubview(BadPostRequest)
                        GenericTools.Logger(data: "\n Could not retrieve votes: \(error!)")
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
                    
                        Polling.fetched = true
                        self.TableView.reloadData()
                        self.activityIndicator.stopAnimating();
                        UIApplication.shared.endIgnoringInteractionEvents();

            } // --
        }  // Finished Accumulating Data
        }
        else {
           let error = Banner.ErrorBanner(errorTitle: "No Internet Connection Available")
            error.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.view.addSubview(error)
            GenericTools.Logger(data: "\n No Internet Connection Available")
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        }
    }
        func GetListOfPolls(completion: @escaping (Bool, Any?) -> Void) {
            PollRef = Database.database().reference()
            PollRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Polls").observeSingleEvent(of: .value, with: { (snapshot) in
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
                                                    
                                                            var retrievedPoll = Poll(pollId: Id, PosterId: PosterId, Epoch: Epoch, Poster: Poster, PollTitle: Title, options: Options, upVotes: [])
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
                completion(true, nil)
            }){ (error) in
                completion(false, error);
            }
        }
    
    func CalculateUpVotes(completion: @escaping (Bool, Any?) -> Void) {
        PollRef = Database.database().reference()
        PollRef.child((Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").observeSingleEvent(of: .value, with: { (snapshot) in
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
            completion(true, nil)
        }){ (error) in
            completion(false, error)
        }
    }
    
    func refreshPollUpvotes(){
        var refresh = 0
        for _ in Polling.ListOfPolls {
            var refresh2 = 0
            for _ in Polling.ListOfPolls[refresh].UpVotes{
                Polling.ListOfPolls[refresh].UpVotes[refresh2].removeAll()
                Polling.ListOfPolls[refresh].UpVoteNames[refresh2].removeAll()

                refresh2 += 1
            }
            refresh += 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Voting" {
            let clickedPoll = segue.destination as? PollVoting
            clickedPoll?.PollViewed = Polling.ListOfPolls[votingIndex]
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
            GenericTools.Logger(data: "\n No Internet Connection Available")
        }
        
    }
    
    var buttonIdentifier: String = ""
    func DeleteSelectedPollInternal(action: UIAlertAction) {
        if action.title == "Delete"{
            FirebaseDatabase.Database.database().reference(withPath: (Configuration.Config["DatabaseNode"] as! String)+"/Polls").child(self.buttonIdentifier).removeValue()
            FirebaseDatabase.Database.database().reference(withPath: (Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").child(self.buttonIdentifier).removeValue()
            self.deleteState = false
            self.DeleteBtn.tintColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
            self.TableView.reloadData()
        }
    }
    
    
    var votingIndex = 0
    @objc func VoteForPoll(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        votingIndex = (indexPath?.row)!
        performSegue(withIdentifier: "Voting", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Polling.fetched == false {
            return 0
        }
        else {
            return Polling.ListOfPolls.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         Polling.OuterIndex = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollTableViewCell
        cell.isHidden = false
        if deleteState == true {
            if UserId != Polling.ListOfPolls[indexPath.row].PosterId && self.Position != "Master" {
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
        cell.PollerPicture.layer.masksToBounds = true
        cell.InnerTable.separatorStyle = UITableViewCellSeparatorStyle.none
        cell.InnerTable.isScrollEnabled = false
        cell.InnerTable.allowsSelection = false

        cell.Poll.text = Polling.ListOfPolls[indexPath.row].PollTitle
        GenericTools.FrameToFitTextView(View: cell.Poll)
        
        cell.PollDate.text = date
        for mem in mMembers.MemberList {
            if Polling.ListOfPolls[indexPath.row].PosterId == mem.id {
                cell.PollerPicture.image = mem.picture
            }
        }
        cell.Poster.text = Polling.ListOfPolls[indexPath.row].Poster
        cell.setUpTable()
        cell.InnerTable.reloadData()
        
        //Get expected height of table
        var size: CGFloat = 0
        if Polling.ListOfPolls[indexPath.row].Options.count > 10 {
            for option in 0...9 {
                let newText = UITextView(frame: CGRect(x: 0, y: 0, width: 183, height: 0))
                newText.text = Polling.ListOfPolls[indexPath.row].Options[option]
                GenericTools.FrameToFitTextView(View: newText)
                size += newText.frame.size.height
            }
        }
        else {
            for option in Polling.ListOfPolls[indexPath.row].Options {
                let newText = UITextView(frame: CGRect(x: 0, y: 0, width: 183, height: 0))
                newText.text = option
                GenericTools.FrameToFitTextView(View: newText)
                size += newText.frame.size.height
            }
        }
        
        
        cell.InnerTable.frame.size.height = size + CGFloat(Polling.ListOfPolls[indexPath.row].Options.count * 3)
        if Polling.ListOfPolls[indexPath.row].Options.count > 10 {
            cell.InnerTable.frame.size.height = size + CGFloat(10 * 3) + 24
        }
        else {
            cell.InnerTable.frame.size.height = size + CGFloat(Polling.ListOfPolls[indexPath.row].Options.count * 3)
        }
        cell.InnerTable.frame.origin.y = cell.Poll.frame.origin.y + cell.Poll.frame.size.height + 10
        cell.Vote.frame.origin.y = cell.InnerTable.frame.origin.y + cell.InnerTable.frame.size.height
        cell.Vote.layer.cornerRadius = 10
        cell.DeleteButton.frame.origin.y = cell.Vote.frame.origin.y

        cell.PollDate.frame.origin.y = cell.Vote.frame.origin.y
        Polling.RowHeight = cell.Vote.frame.origin.y + cell.Vote.frame.size.height + 10
        
        if self.deleteState == true {
            if UserId == Polling.ListOfPolls[indexPath.row].PosterId || self.Position == "Master" {
        cell.DeleteButton.isHidden = false
        cell.DeleteButton.layer.cornerRadius = 5
        cell.DeleteButton.accessibilityLabel = Polling.ListOfPolls[indexPath.row].PollId
        cell.DeleteButton.addTarget(self, action: #selector(DeleteSelectedPoll(button:)), for: .touchUpInside)
        cell.DeleteButton.frame.origin.y = cell.Vote.frame.origin.y
        cell.PollDate.frame.origin.y = cell.Vote.frame.origin.y
        Polling.RowHeight = cell.Vote.frame.origin.y + cell.Vote.frame.size.height + 10
            }
        }
        else {
            cell.DeleteButton.isHidden = true
        }
        
        if cell.isHidden {
            Polling.RowHeight = 0
        }
        cell.Vote.addTarget(self, action: #selector(VoteForPoll(button:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Polling.RowHeight
    }

}

class PollVoting: UIViewController {
    
    @IBOutlet weak var PollQuestion: UITextView!
    @IBOutlet weak var Option: UIButton!
    @IBOutlet weak var Percent: UILabel!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var Votes: UIButton!

    
    let screensize: CGRect = UIScreen.main.bounds
    var scrollView: UIScrollView!
    var PollViewed: Poll!
    var Position = LoggedIn.User["Position"] as! String
    var UserId = LoggedIn.User["UserID"] as! String
    let first = LoggedIn.User["First Name"] as? String ?? "Unknown"
    let last = LoggedIn.User["Last Name"] as? String ?? "Unknown"
    
    
    @IBAction func Cancel(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Option.tag = 1
        Option.addTarget(self, action: #selector(UpVoteOption(button:)), for: .touchUpInside)
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        Votes.tag = 0
        Votes.addTarget(self, action: #selector(ViewResults(button:)), for: .touchUpInside)
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight))
        scrollView.addSubview(PollQuestion)
        scrollView.addSubview(Option)
        scrollView.addSubview(Percent)
        scrollView.addSubview(Votes)
        
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight)
        self.view.addSubview(scrollView)
        self.CalculateVotes(){(success, error) in
            guard success else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve votes.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                GenericTools.Logger(data: "\n Could not retreve polls: \(error!)")
                return
            }
            //Calculate Percentages --
                var VoteNumber = 0
                var totalVotes = 0
                for option in self.PollViewed.UpVoteNames {
                    totalVotes += option.count
                }
                for _ in self.PollViewed.UpVoteNames {
                    let votesForOption = self.PollViewed.UpVoteNames[VoteNumber].count
                    var voteResult: Float = 0
                    if totalVotes != 0 {
                        voteResult = (Float(votesForOption) / Float(totalVotes)) * Float(100)
                    }
                    self.PollViewed.Placing[VoteNumber] = String(String(Int(voteResult)) + "%")
                    VoteNumber += 1
                }
            self.ExistingOptions.removeAll()
            self.ExistingLabel.removeAll()
            self.DrawLayout()
        }
    }
   

    
    var ExistingOptions: [UIButton] = []
    var ExistingVotes: [UIButton] = []
    var ExistingLabel: [UILabel] = []
    func DrawLayout() {
        let name = "\(first) \(last)"
        PollQuestion.text = PollViewed.PollTitle
        GenericTools.FrameToFitTextView(View: PollQuestion)
        PollQuestion.frame.origin.y = toolbar.frame.origin.y + toolbar.frame.size.height + 30
        for option in (0...PollViewed.Options.count - 1) {
            let button = UIButton(frame: CGRect(x: Option.frame.origin.x, y: 0, width: screensize.width - 46, height: Option.frame.size.height))
            button.tag = option + 1
            button.addTarget(self, action: #selector(UpVoteOption(button:)), for: .touchUpInside)
            ExistingOptions.append(button)
            let label = UILabel(frame: CGRect(x: Percent.frame.origin.x, y: 0, width: Percent.frame.size.width, height: Option.frame.size.height))
            label.tag = option
            ExistingLabel.append(label)
            let vote = UIButton(frame: CGRect(x:Votes.frame.origin.x, y:0, width: Votes.frame.size.width, height: Option.frame.size.height))
            vote.tag = option
            vote.addTarget(self, action: #selector(ViewResults(button:)), for: .touchUpInside)
            ExistingVotes.append(vote)
            
        }
        for option in 0...(ExistingOptions.count - 1) {
            if option == 0 {
                Option.frame.origin.y = PollQuestion.frame.origin.y + PollQuestion.frame.size.height + 40
                Option.frame.size.width = screensize.width - 46
                let tempView = UITextView(frame: CGRect(x: 0, y: 0, width: screensize.width - ExistingVotes[option].frame.size.width, height: 0))
                tempView.text = PollViewed.Options[option]
                GenericTools.FrameToFitTextView(View: tempView)
                Option.frame.size.height = tempView.frame.size.height + 50
                Option.setTitle(PollViewed.Options[option], for: .normal)
                Option.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5.0, bottom: 5.0, right: 43)
                ExistingOptions[option].frame.size.height = Option.frame.size.height
                ExistingOptions[option].frame.origin.y = Option.frame.origin.y
                ExistingOptions[option].setTitle(PollViewed.Options[option], for: .normal)
                ExistingOptions[option].titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 43)
                
                Votes.frame.origin.x = Option.frame.origin.x + Option.frame.size.width
                Votes.frame.origin.y = Option.frame.origin.y
                Votes.frame.size.height = Option.frame.size.height
                ExistingVotes[option].frame = Votes.frame
                
                Percent.frame.origin.x = Option.frame.origin.x + (Option.frame.size.width - Percent.frame.size.width)
                Percent.frame.origin.y = Option.frame.origin.y
                Percent.frame.size.height = Option.frame.size.height
                ExistingLabel[option].frame.size.height = Percent.frame.size.height
                ExistingLabel[option].frame.origin.y = Percent.frame.origin.y
                ExistingLabel[option].frame.origin.x = Percent.frame.origin.x
                
                for names in PollViewed.UpVoteNames[option] {
                if names == name {
                    Option.backgroundColor = UIColor(displayP3Red: 255/255, green: 224/255, blue: 0/255, alpha: 1)
                    }
                }
                Percent.text = PollViewed.Placing[option]

            }
            else {
                let tempView = UITextView(frame: CGRect(x: 0, y: 0, width: screensize.width - ExistingVotes[option].frame.size.width, height: 0))
                tempView.text = PollViewed.Options[option]
                GenericTools.FrameToFitTextView(View: tempView)
                ExistingOptions[option].frame.size.height = tempView.frame.size.height + 50
                ExistingOptions[option].setTitle(PollViewed.Options[option], for: .normal)
                ExistingOptions[option].backgroundColor = UIColor(displayP3Red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
                ExistingOptions[option].frame.origin.y = ExistingOptions[option - 1].frame.origin.y + ExistingOptions[option - 1].frame.size.height + 20
                ExistingOptions[option].tintColor = .white
                ExistingOptions[option].contentHorizontalAlignment = .left
                ExistingOptions[option].titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 43)
                scrollView.addSubview(ExistingOptions[option])
                ExistingOptions[option].titleLabel?.font = UIFont(name: "System Font", size: 14)
                
                ExistingVotes[option].frame.size.height = ExistingOptions[option].frame.size.height
                ExistingVotes[option].frame.origin.y = ExistingOptions[option].frame.origin.y
                ExistingVotes[option].frame.origin.x = ExistingOptions[option].frame.origin.x + ExistingOptions[option].frame.size.width
                ExistingVotes[option].tintColor = .blue
                ExistingVotes[option].backgroundColor = UIColor(displayP3Red: 38/255, green: 38/255, blue: 38/255, alpha: 1)
                ExistingVotes[option].setTitleColor(UIColor(displayP3Red: 0/255, green: 122/255, blue: 255/255, alpha: 1), for: .normal)
                ExistingVotes[option].alpha = 0.5
                ExistingVotes[option].titleLabel?.font =  UIFont(name: (ExistingVotes[option].titleLabel?.font.fontName)!, size: 14)
                ExistingVotes[option].setTitle("Votes", for: .normal)
                scrollView.addSubview(ExistingVotes[option])
                
                ExistingLabel[option].frame.size.height = ExistingOptions[option].frame.size.height
                ExistingLabel[option].frame.origin.y = ExistingOptions[option].frame.origin.y
                ExistingLabel[option].frame.origin.x = ExistingOptions[option].frame.origin.x + (ExistingOptions[option].frame.size.width - ExistingLabel[option].frame.size.width)
                ExistingLabel[option].textColor = .black
                ExistingLabel[option].backgroundColor = .white
                ExistingLabel[option].alpha = 0.5
                ExistingLabel[option].text = PollViewed.Placing[option]
                ExistingLabel[option].textAlignment = .center
                ExistingLabel[option].font = UIFont.boldSystemFont(ofSize: 15.0)
                scrollView.addSubview(ExistingLabel[option])
                
                
                let maxHeight: CGFloat = screensize.height - ExistingOptions[option].frame.size.height - 60
                
                for names in PollViewed.UpVoteNames[option] {
                    if names == name {
                        ExistingOptions[option].backgroundColor = UIColor(displayP3Red: 255/255, green: 224/255, blue: 0/255, alpha: 1)
                    }
                }
                if ExistingOptions[option].frame.origin.y >= maxHeight {
                    let newScrollHeight = self.scrollView.contentSize.height + ExistingOptions[option].frame.size.height + 20
                    self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: newScrollHeight)
                }
            }
        }
    }
    
    func ViewResults(button: UIButton) {
        let index = button.tag
        let voters = self.PollViewed.UpVoteNames[index]
        let alert = UIAlertController(title: "Votes", message: "", preferredStyle: .alert)

        if voters.count == 0 {
            let action = UIAlertAction(title: "No one has voted yet", style: .default, handler: { (action) -> Void in
            })
            action.isEnabled = false
            alert.addAction(action)
        }
        else {
            for vote in voters {
                let action = UIAlertAction(title: vote, style: .default, handler: { (action) -> Void in
                })
                action.isEnabled = false
                alert.addAction(action)
            }
        }
        self.present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func UpVoteOption(button: UIButton) {
        
        self.upVotes(button: button) {(success, error) in
            if error != nil {
                GenericTools.Logger(data: "\n Error posting comment: \(error!)")
                let emptyError = UIAlertController(title: "Internal Server Error", message: "Error voting", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                emptyError.addAction(okAction)
                self.present(emptyError, animated: true, completion: nil)
            }
            else {
               
            }
        }
    }
    
    func upVotes(button: UIButton, completion: @escaping (Bool, Any?) -> Void) {
        if Reachability.isConnectedToNetwork() == true {
            let name = "\(self.first) \(self.last)"
            let ref = Database.database().reference()
            ref.child((Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").child(self.PollViewed.PollId).child("\"0\"/Names").updateChildValues([self.UserId : self.UserId]){ (error) in
                GenericTools.Logger(data: "\n Couldn't update vote: \(error)")
            }
            ref.child((Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").child(self.PollViewed.PollId).child("\"\(button.tag)\"").child("Names").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(self.UserId){
                    FirebaseDatabase.Database.database().reference(withPath: (Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").child(self.PollViewed.PollId).child("\"\(button.tag)\"").child("Names").child(self.UserId).removeValue()
                    button.backgroundColor = UIColor(displayP3Red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
                }
                else {
                    ref.child((Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").child(self.PollViewed.PollId).child("\"\(button.tag)\"").child("Names").updateChildValues([self.UserId : name])
                    button.backgroundColor = UIColor(displayP3Red: 255/255, green: 224/255, blue: 0/255, alpha: 1)
                }
                completion(true, nil)
            }){ (error) in
                GenericTools.Logger(data: "\n Couldnt update vote: \(error)")
                completion(false, error)
            }
            
        }
        else {
            //should help user handle error
            GenericTools.Logger(data: "\n Internet connection not available")
        }
    }
    
    func callCalculateVotes() {
        self.CalculateVotes(){(success, error) in
            guard success else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve votes.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                GenericTools.Logger(data: "\n Could not retreve polls: \(error!)")
                return
            }
            //Calculate Percentages --
            var VoteNumber = 0
            var totalVotes = 0
            for option in self.PollViewed.UpVoteNames {
                totalVotes += option.count
            }
            for _ in self.PollViewed.UpVoteNames {
                let votesForOption = self.PollViewed.UpVoteNames[VoteNumber].count
                var voteResult: Float = 0
                if totalVotes != 0 {
                    voteResult = (Float(votesForOption) / Float(totalVotes)) * Float(100)
                }
                self.PollViewed.Placing[VoteNumber] = String(String(Int(voteResult)) + "%")
                VoteNumber += 1
            }
            self.ExistingOptions.removeAll()
            self.ExistingLabel.removeAll()
            self.DrawLayout()
        }
    }
    
    func CalculateVotes(completion: @escaping (Bool, Any?) -> Void) {
        let ref = Database.database().reference()
        ref.child((Configuration.Config["DatabaseNode"] as! String)+"/PollOptions").child(self.PollViewed.PollId).observe( .value, with: { (snapshot) in
            self.refreshPollUpvotes()
            let snapshot = snapshot.children
            for snap in snapshot {
                if let childSnapshot = snap as? DataSnapshot
                {
                    let val = childSnapshot.key
                    let keys = val.replacingOccurrences(of: "\"", with: "")
                    let key = Int(keys)
                    if let Options = childSnapshot.value as? [String:AnyObject] , Options.count >= 0{
                        let votes = Options["Names"]! as! [String:AnyObject]
                            for person in votes {
                                let value = person.value as! String
                                if key != 0 {
                                    self.PollViewed.UpVoteNames[key! - 1].append(value)
                            }
                        }
                    }
                }
            }
            completion(true, nil)
        }){ (error) in
            GenericTools.Logger(data: "\n Could not get vote from database: \(error)")
            completion(false, error)
        }
    }
    var handled = false
    func refreshPollUpvotes(){
        var refresh = 0
        for _ in PollViewed.UpVoteNames {
                PollViewed.UpVoteNames[refresh].removeAll()
            refresh += 1
        }
        if !handled {
        PollViewed.UpVoteNames.removeLast()
            handled = true
        }
    }
    
    
    
    
    
    
}
