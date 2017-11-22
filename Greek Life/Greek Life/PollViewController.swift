//
//  PollViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-13.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

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
    var PollTitle: String
    var Options: [String]
    var UpVotes: [[String]]
    var Placing: [String]
    var PercentLbl: [UILabel]
    var VoteBtn: [UIButton]
    var OptionTxt: [UITextView]
    var Drawn: Bool
    
    public init() {
        self.PollId = ""
        self.Epoch = 0
        self.Poster = ""
        self.PollTitle = ""
        self.Options = []
        self.UpVotes = [[]]
        self.Placing = []
        self.PercentLbl = []
        self.VoteBtn = []
        self.OptionTxt = []
        self.Drawn = false
    }
    
    public init(pollId: String, Epoch: Double, Poster: String, PollTitle: String, options: [String], upVotes: [[String]])
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
    }
    
    
}

class PollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var PollerPicture: UIImageView!
    @IBOutlet weak var Poster: UILabel!
    @IBOutlet weak var Poll: UITextView!
    @IBOutlet weak var PollDate: UILabel!
    @IBOutlet weak var PercentDefault: UILabel!

    
    @IBOutlet weak var PollOptionDefault: UITextView!
    @IBOutlet weak var PollVotesDefault: UIButton!
    
    @IBOutlet weak var PollResults: UIButton!
    @IBOutlet weak var SendReminder: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class PollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ListOfPolls:[Poll] = []
    var User = LoggedIn.User["Username"] as! String
    var PollRef: DatabaseReference!
    var RowHeight: CGFloat = 0
    var fetched = false
    
    @IBOutlet weak var TableView: UITableView!
    @IBAction func DeletePoll(_ sender: Any) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get poll info for each existing poll
        GetListOfPolls() {(success) in
            guard success else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve polls.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                print("Internet Connection not Available!")
                return
            }
            self.ListOfPolls = mergeSorting.mergeSort(self.ListOfPolls)
                self.CalculateUpVotes(){(success) in
                    guard success else{
                        let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve votes.")
                        BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                        self.view.addSubview(BadPostRequest)
                        print("Internet Connection not Available!")
                        return
                    }
                //Calculate Percentages --
                        var PollNumber = 0
                        for _ in self.ListOfPolls {
                            var VoteNumber = 0
                            var totalVotes = 0
                            for option in self.ListOfPolls[PollNumber].UpVotes {
                                totalVotes += option.count
                            }
                            for _ in self.ListOfPolls[PollNumber].UpVotes {
                                let votesForOption = self.ListOfPolls[PollNumber].UpVotes[VoteNumber].count
                                var voteResult: Float = 0
                                if totalVotes != 0 {
                                    voteResult = (Float(votesForOption) / Float(totalVotes)) * Float(100)
                                }
                                self.ListOfPolls[PollNumber].Placing[VoteNumber] = String(String(Int(voteResult)) + "%")
                                VoteNumber += 1
                            }
                            PollNumber += 1
                    }//--
                    //Create elements for options
                    self.CreateAvailableOptions()
                    self.fetched = true
                    self.TableView.reloadData()
            } // --
        }  // Finished Accumulating Data

    }
        func GetListOfPolls(completion: @escaping (Bool) -> Void) {
            PollRef = Database.database().reference()
            PollRef.child("Polls").observe(.value, with: { (snapshot) in
                self.ListOfPolls.removeAll()
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
                                                var retrievedPoll = Poll(pollId: Id, Epoch: Epoch, Poster: Poster, PollTitle: Title, options: Options, upVotes: [])
                                                for _ in retrievedPoll.Options {
                                                    retrievedPoll.UpVotes.append([])
                                                    retrievedPoll.Placing.append("0 %")
                                                }
                                                self.ListOfPolls.append(retrievedPoll)
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
        PollRef.child("PollOptions").observe(.value, with: { (snapshot) in
            let snapshot = snapshot.children
            for snap in snapshot {
                if let childSnapshot = snap as? DataSnapshot //Datasnapshot provides usable information
                {
                    var count = 0
                    if let pollArray = childSnapshot.value as? [String:AnyObject] , pollArray.count >= 0{
                        var keyArray:[String] = [] //array of options that have been voted on per poll
                        for(key,_) in pollArray {
                            let AKey = key
                            keyArray.append(AKey)
                        }
                        for upVotes in pollArray {
                            var value = upVotes.value as! [String:AnyObject]
                            let names = value["Names"] as! [String:String]
                            for name in names {
                                let num = Int(keyArray[count].replacingOccurrences(of: "\"", with: ""))
                                var pollCount = 0
                                for poll in self.ListOfPolls {
                                    if poll.PollId == childSnapshot.key {
                                        self.ListOfPolls[pollCount].UpVotes[num! - 1].append(name.value) //search for the poll id instead of using indexes on list of polls
                                    }
                                    pollCount += 1
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
    
    func CreateAvailableOptions() {
        var PollNumber = 0
        for poll in self.ListOfPolls {
            var option = 0
            for options in poll.Options {
                let NewTextOption = self.textView(x: 0, y: 0, width: 0, height: 0)
                NewTextOption.text = options
                self.ListOfPolls[PollNumber].OptionTxt.append(NewTextOption)
                
                let NewVoteButton = self.button(x: 0, y: 0, width: 0, height: 0)
                NewVoteButton.setTitle(String(poll.UpVotes[option].count), for: .normal)
                self.ListOfPolls[PollNumber].VoteBtn.append(NewVoteButton)
                
                let NewPlacingLabel = self.label(x: 0, y: 0, width: 0, height: 0)
                NewPlacingLabel.text = poll.Placing[option]
                self.ListOfPolls[PollNumber].PercentLbl.append(NewPlacingLabel)
                option += 1
            }
            PollNumber += 1
        }
    }
    
    
    //---------------------//
    //---Create elements---//
    //--------------------//
    
    func textView(x:CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)->UITextView {
        let textView = UITextView(frame: CGRect(x: x, y: y, width: width, height: height))
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.layer.borderWidth = 0.8
        textView.layer.borderColor = UIColor.black.cgColor
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }
    
    func button(x:CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)->UIButton {
        let button = UIButton(frame: CGRect(x: x, y: y, width: width, height: height))
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!, size: 15)
        return button
    }
    
    func label(x:CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)->UILabel {
        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        label.backgroundColor = UIColor.clear
        label.layer.borderColor = UIColor.black.cgColor
        label.font = UIFont(name: label.font.fontName, size: 12)
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListOfPolls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollTableViewCell
        let defaultOptionHeight: CGFloat = cell.PollOptionDefault.frame.size.height
        let defaultOptionWidth: CGFloat = cell.PollOptionDefault.frame.size.width
        let defaultOptionX: CGFloat = cell.PollOptionDefault.frame.origin.x
        let smallestPossibleTextArea: CGFloat = cell.PollOptionDefault.frame.size.height
        
        var CurrentOption = 0 //Defining what option number in the poll array
        var ExistingOptions:[UITextView] = []
        if fetched == true {
        if CurrentOption == 0 {
            //option 0 has an existing text view for the poll question and the first option plus a button to vote
            cell.Poll.text = self.ListOfPolls[indexPath.row].PollTitle
            GenericTools.FrameToFitTextView(View: cell.Poll)
            cell.Poll.textAlignment = .justified
            cell.PollOptionDefault.layer.cornerRadius = 5
            cell.PollOptionDefault.layer.borderWidth = 0.8
            cell.PollOptionDefault.layer.borderColor = UIColor.black.cgColor
            cell.PollOptionDefault.frame.origin.y = cell.Poll.frame.origin.y + cell.Poll.frame.size.height + 30
            cell.PollOptionDefault.text = self.ListOfPolls[indexPath.row].Options[CurrentOption]
            
            cell.PollerPicture.image = UIImage(named: "Docs/user_icon.png")
            cell.PollerPicture.layer.cornerRadius = cell.PollerPicture.frame.width/2
            
            cell.PollVotesDefault.setTitle(self.ListOfPolls[indexPath.row].VoteBtn[CurrentOption].titleLabel?.text, for: .normal)
            cell.PollVotesDefault.frame.size.height = smallestPossibleTextArea
            cell.PollVotesDefault.frame.size.width = smallestPossibleTextArea
            cell.PollVotesDefault.frame.origin.y = ((cell.PollOptionDefault.frame.origin.y) + ((cell.PollOptionDefault.frame.size.height - smallestPossibleTextArea)/2))
            cell.PollVotesDefault.frame.origin.x = cell.PollOptionDefault.frame.origin.x - 50
            cell.PollVotesDefault.layer.borderWidth = 0.8
            cell.PollVotesDefault.layer.cornerRadius = cell.PollVotesDefault.frame.width/2
            
            let date = CreateDate.getTimeSince(epoch: self.ListOfPolls[indexPath.row].Epoch)
            cell.PollDate.text = date
            cell.Poster.text = self.ListOfPolls[indexPath.row].Poster
            
            //Here we set the label value for the first option of every passing pole to its % value. I checked and i believe these are all set
            //correctly
            cell.PercentDefault.text = self.ListOfPolls[indexPath.row].Placing[CurrentOption]

            ExistingOptions.append(cell.PollOptionDefault)
            CurrentOption += 1
        }
        else {
//            for option in self.ListOfPolls[indexPath.row].Options {
//
//            }
        }
    }
    
        self.RowHeight = 500
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.RowHeight
    }
    
    

}
