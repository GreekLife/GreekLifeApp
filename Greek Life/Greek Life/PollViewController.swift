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
    
    var pollId: String
    var Epoch: Double
    var poster: String
    var PollTitle: String
    var options: [String]
    var upVotes: [[String]]
    
    public init() {
        self.pollId = ""
        self.Epoch = 0
        self.poster = ""
        self.PollTitle = ""
        self.options = []
        self.upVotes = [[]]
    }
    
    public init(pollId: String, Epoch: Double, Poster: String, PollTitle: String, options: [String], upVotes: [[String]])
    {
        self.pollId = pollId
        self.Epoch = Epoch
        self.poster = Poster
        self.PollTitle = PollTitle
        self.options = options
        self.upVotes = upVotes
    }
    
    
}

class PollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var ListOfPolls:[Poll] = []
    var user = LoggedIn.User["Username"] as! String
    var PollRef: DatabaseReference!
    var rowHeight: CGFloat = 0
    var defaultHeight: CGFloat = 532 //532 matches the default for 6 options as set in the storyboard
    var CellState: [Bool] = []
    var DeleteCellState: [Bool] = []
    var deleteState = false
    var deleteHeight: CGFloat = 0
    var deleteButtons: [UIButton] = []
    var indexPath:IndexPath = IndexPath(item: 0, section: 0)

    @IBOutlet weak var TableView: UITableView!
    @IBAction func DeletePoll(_ sender: Any) {
        self.TableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.top, animated: true)
        DeleteCellState.removeAll()
        for _ in self.ListOfPolls {
            DeleteCellState.append(false)
        }
        
        if self.deleteState == true {
            self.deleteState = false
            deleteHeight = 0
            self.ListOfPolls = mergeSorting.mergeSort(self.ListOfPolls)
            var deleteCount = 0
            for _ in deleteButtons {
                deleteButtons[deleteCount].removeFromSuperview()
                deleteCount += 1
            }
            deleteButtons.removeAll()
        }
        else {
        self.deleteState = true
        }
        TableView.reloadData()
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
                                            let retrievedPoll = Poll(pollId: Id, Epoch: Epoch, Poster: Poster, PollTitle: Title, options: Options, upVotes: [[]])
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableView.allowsSelection = false

        GetListOfPolls() {(success) in
            guard success else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve polls.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                print("Internet Connection not Available!")
                return
            }
            var stateCount = 0
            for _ in self.ListOfPolls {
                self.CellState.append(false)
                stateCount += 1
            }
            self.ListOfPolls = mergeSorting.mergeSort(self.ListOfPolls)
            self.TableView.reloadData()
            
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    //------------------------//
    //-- Cell interactions --//
    //----------------------//
    
    //----Delete Post ----//
    var identifier:String = ""
    
    @objc func DeletePost(button: UIButton) {
        let verify = UIAlertController(title: "Alert!", message: "Are you sure you want to permanantly delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: DeletePostInternal)
        let destructor = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: DeletePostInternal)
        verify.addAction(okAction)
        verify.addAction(destructor)
        self.present(verify, animated: true, completion: nil)
        self.identifier = button.accessibilityIdentifier!
    }

    func DeletePostInternal(action: UIAlertAction) {
        if action.title == "Delete"{
            FirebaseDatabase.Database.database().reference(withPath: "Polls").child(self.identifier).removeValue()
            deleteState = false
            CellState.removeAll()
            var stateCount = 0
            for _ in self.ListOfPolls {
                self.CellState.append(false)
                stateCount += 1
            }
            DeleteCellState.removeAll()
            for _ in self.ListOfPolls {
                DeleteCellState.append(false)
            }
            deleteHeight = 0
            var deleteCount = 0
            for _ in deleteButtons {
                deleteButtons[deleteCount].removeFromSuperview()
                deleteCount += 1
            }
            deleteButtons.removeAll()
            
            var optionCount = 0
            for _ in self.options {
                options[optionCount].removeFromSuperview()
                optionCount += 1
            }
            
        }
    }


    //---Voted for an option ----//
    @objc func OptionSelected(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        let myData = ListOfPolls[indexPath!.row]
        PollRef = Database.database().reference()
        let tag = String(button.tag)
        PollRef.child("PollOptions").child(myData.pollId).child("\"\(tag)\"").child("Names").updateChildValues([user:user])
    }
    
    //----Process total votes for each option ----//
    func refreshPollUpvotes(){
        var refresh = 0
        for _ in self.ListOfPolls {
            var refresh2 = 0
            for _ in self.ListOfPolls[refresh].upVotes{
                self.ListOfPolls[refresh].upVotes[refresh2].removeAll()
                refresh2 += 1
            }
            refresh += 1
        }
    }
    
    func CalculateUpVotes(completion: @escaping (Bool) -> Void) {
        PollRef = Database.database().reference()
        PollRef.child("PollOptions").observe(.value, with: { (snapshot) in
            self.refreshPollUpvotes() //ideally we dont want to empty and reprocess everything but we're dealing with small numbers (<100)
            let snapshot = snapshot.children
            var pollVote = 0
            for snap in snapshot {
                if let childSnapshot = snap as? DataSnapshot //Datasnapshot provides usable information
                {
                    var count = 0
                    if let pollArray = childSnapshot.value as? [String:AnyObject] , pollArray.count >= 0{
                        var keyArray:[String] = []
                        for(key,_) in pollArray {
                            let AKey = key
                            keyArray.append(AKey)
                        }
                        for upVotes in pollArray {
                            var value = upVotes.value as! [String:AnyObject]
                            let names = value["Names"] as! [String:String]
                            for name in names {
                                let num = Int(keyArray[count].replacingOccurrences(of: "\"", with: ""))
                                self.ListOfPolls[pollVote].upVotes[num!].append(name.value)
                            }
                            count += 1
                    }
                        pollVote += 1
                  }
                }
            }
            completion(true)
        }){ (error) in
            print("Could not retrieve object from database");
            completion(false)
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
        button.layer.cornerRadius = button.frame.width/2
        return button
    }
    
    func label(x:CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)->UILabel {
    let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
    label.backgroundColor = UIColor.clear
    label.layer.borderColor = UIColor.black.cgColor
    label.font = UIFont(name: label.font.fontName, size: 12)
    return label
    }
    
    //--------------------//
    //---Table Views ----//
    //------------------//
    var options: [UITextView] = []
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollTableViewCell
        let defaultOptionHeight: CGFloat = 52
        let defaultOptionWidth: CGFloat = 257
        let defaultOptionX: CGFloat = 103
        let smallestPossibleTextArea: CGFloat = 30
        var existingOptions: Int = 0
        
        if deleteState == true {
            var filteredListOfPolls:[Poll] = []
            if self.user != "Master" {
                for poll in self.ListOfPolls {
                    if poll.poster == self.user {
                        filteredListOfPolls.append(poll)
                    }
                }
                self.ListOfPolls = filteredListOfPolls
                self.ListOfPolls = mergeSorting.mergeSort(self.ListOfPolls)
            }
        }
//        optionCount = 0
//        for _ in options {
//            options
//        } --> Options is cleared but actually needs to have them removed from super view in some cases.
         options = [] //--Included in cell height ---//
        if self.CellState[indexPath.row] == false {
            cell.Poll.text = self.ListOfPolls[indexPath.row].PollTitle
            GenericTools.FrameToFitTextView(View: cell.Poll)
            
            cell.PollerPicture.image = UIImage(named: "Docs/user_icon.png")
            cell.Poster.text = self.ListOfPolls[indexPath.row].poster
            let date = CreateDate.getTimeSince(epoch: self.ListOfPolls[indexPath.row].Epoch)
            cell.PollDate.text = date
            cell.Poll.textAlignment = .justified
        for option in self.ListOfPolls[indexPath.row].options {
            if existingOptions == 0 {
                cell.PollOptionDefault.layer.borderWidth = 0.8
                cell.PollOptionDefault.layer.borderColor = UIColor.black.cgColor
                cell.PollOptionDefault.text = option
                GenericTools.FrameToFitTextView(View: cell.PollOptionDefault )
                cell.PollOptionDefault.frame.origin.y = cell.Poll.frame.origin.y + cell.Poll.frame.size.height + 30
                options.append(cell.PollOptionDefault)
                existingOptions += 1
                cell.PollVotesDefault.frame.size.height = smallestPossibleTextArea
                cell.PollVotesDefault.frame.size.width = smallestPossibleTextArea
                cell.PollVotesDefault.frame.origin.y = ((cell.PollOptionDefault.frame.origin.y) + ((cell.PollOptionDefault.frame.size.height - smallestPossibleTextArea)/2))
                cell.PollVotesDefault.frame.origin.x = cell.PollOptionDefault.frame.origin.x - 50
                cell.PollVotesDefault.layer.borderWidth = 0.8
                cell.PollVotesDefault.layer.cornerRadius = cell.PollVotesDefault.frame.width/2
                cell.PollVotesDefault.setTitle("1", for: .normal)
                cell.PollOptionDefault.textAlignment = .justified

                let newLabelY = ((cell.PollOptionDefault.frame.origin.y) + ((cell.PollOptionDefault.frame.size.height - smallestPossibleTextArea)/2))
                let newLabelX: CGFloat =  cell.PollOptionDefault.frame.origin.x - 90
                let newLabel = label(x: newLabelX, y: newLabelY - 5, width: smallestPossibleTextArea + 10, height: smallestPossibleTextArea + 10)
                newLabel.text = "100%"
                cell.contentView.addSubview(newLabel)
                self.CellState[indexPath.row] = true
            }
            else {
                let lastOption = options[existingOptions - 1]
                let newOptionY: CGFloat = lastOption.frame.origin.y + lastOption.frame.height + 15
                let optionView = textView(x: defaultOptionX, y: newOptionY, width: defaultOptionWidth, height: defaultOptionHeight)
                optionView.text = option
                optionView.textAlignment = .justified
                GenericTools.FrameToFitTextView(View: optionView)
                cell.contentView.addSubview(optionView)
                options.append(optionView)
                existingOptions += 1
                let newButtonY: CGFloat = ((optionView.frame.origin.y) + ((optionView.frame.size.height - smallestPossibleTextArea)/2))
                let newButtonX: CGFloat = optionView.frame.origin.x - 50
                let newButton = button(x: newButtonX, y: newButtonY, width: smallestPossibleTextArea, height: smallestPossibleTextArea)
                newButton.setTitle("0", for: .normal) //--not working???
                newButton.tintColor = UIColor.blue
                cell.contentView.addSubview(newButton)
                let newLabelX: CGFloat = optionView.frame.origin.x - 90
                let newLabel = label(x: newLabelX, y: newButtonY - 5, width: smallestPossibleTextArea + 10, height: smallestPossibleTextArea + 10)
                newLabel.text = "100%"
                cell.contentView.addSubview(newLabel)
                self.CellState[indexPath.row] = true

            }
        }
            cell.PollResults.frame.origin.y = options[existingOptions-1].frame.origin.y + options[existingOptions-1].frame.height + 20
            cell.PollDate.frame.origin.y = options[existingOptions-1].frame.origin.y + options[existingOptions-1].frame.height + 20
            cell.SendReminder.frame.origin.y = options[existingOptions-1].frame.origin.y + options[existingOptions-1].frame.height + 20

        }
        if deleteState == true {
            let height = cell.PollResults.frame.origin.y + cell.PollResults.frame.height
            if DeleteCellState[indexPath.row] == false {
            let deleteButton = button(x: 0 , y: height, width: UIScreen.main.bounds.width, height: smallestPossibleTextArea)
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.backgroundColor = UIColor.red
            deleteButton.layer.borderColor = UIColor.clear.cgColor
            deleteButton.layer.cornerRadius = 0
            deleteHeight = smallestPossibleTextArea * 1.5
            deleteButton.accessibilityIdentifier = self.ListOfPolls[indexPath.row].pollId
            deleteButton.addTarget(self, action: #selector(DeletePost(button:)), for: .touchUpInside)
            cell.contentView.addSubview(deleteButton)
            deleteButtons.append(deleteButton)
            DeleteCellState[indexPath.row] = true
            }
        }
         self.rowHeight = cell.PollResults.frame.origin.y + cell.PollResults.frame.height + 15 + deleteHeight

        
        return cell
            }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ListOfPolls.count
    }

}
