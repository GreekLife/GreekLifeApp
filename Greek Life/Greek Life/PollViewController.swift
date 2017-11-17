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
    var option1: String
    var option2: String
    var option3: String
    var option4: String
    var option5: String
    var option6: String
    var upVotes: [[String]]
    
    public init() {
        self.pollId = ""
        self.Epoch = 0
        self.poster = ""
        self.PollTitle = ""
        self.option1 = ""
        self.option2 = ""
        self.option3 = ""
        self.option4 = ""
        self.option5 = ""
        self.option6 = ""
        self.upVotes = [[],[],[],[],[],[],[]]
    }
    
    public init(pollId: String, Epoch: Double, Poster: String, PollTitle: String, option1: String, option2: String, option3: String, option4: String, option5: String, option6: String, upVotes: [[String]])
    {
        self.pollId = pollId
        self.Epoch = Epoch
        self.poster = Poster
        self.PollTitle = PollTitle
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.option4 = option4
        self.option5 = option5
        self.option6 = option6
        self.upVotes = upVotes
    }
    
    
}

class PollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var ListOfPolls:[Poll] = []
    var user = "Jonahelbaz"//LoggedIn.User["Username"] as! String
    var PollRef: DatabaseReference!
    var rowHeight: CGFloat = 0
    var defaultHeight: CGFloat = 532 //532 matches the default for 6 options as set in the storyboard

    @IBOutlet weak var TableView: UITableView!
    
    func GetListOfPolls(completion: @escaping (Bool) -> Void) {
        PollRef = Database.database().reference()
        PollRef.child("Polls").observe(.value, with: { (snapshot) in
            let snapshot = snapshot.children
            for snap in snapshot {
                if let childSnapshot = snap as? DataSnapshot //Datasnapshot provides usable information
                {
                    if let pollDictionary = childSnapshot.value as? [String:AnyObject] , pollDictionary.count > 0{ //test for at least one child and turn it into a dictionary of values.
                        if let Id = pollDictionary["PostId"] as? String {
                            if let Epoch = pollDictionary["Epoch"] as? Double {
                                if let Poster = pollDictionary["Poster"] as? String {
                                    if let Title = pollDictionary["Title"] as? String {
                                        let Option1 = pollDictionary["Option1"] as? String ?? ""
                                        let Option2 = pollDictionary["Option2"] as? String ?? ""
                                        let Option3 = pollDictionary["Option3"] as? String ?? ""
                                        let Option4 = pollDictionary["Option4"] as? String ?? ""
                                        let Option5 = pollDictionary["Option5"] as? String ?? ""
                                        let Option6 = pollDictionary["Option6"] as? String ?? ""
                                        
                                        let retrievedPoll = Poll(pollId: Id, Epoch: Epoch, Poster: Poster, PollTitle: Title, option1: Option1, option2: Option2, option3: Option3, option4: Option4, option5: Option5, option6: Option6, upVotes: [[],[],[],[],[],[],[]])
                                        self.ListOfPolls.append(retrievedPoll)
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
            self.CalculateUpVotes(){(success) in
                guard success else{
                    let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not retrieve polls.")
                    BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                    self.view.addSubview(BadPostRequest)
                    print("Internet Connection not Available!")
                    return
                }
                self.TableView.reloadData()
            }
            
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    @objc func OptionSelected(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        let myData = ListOfPolls[indexPath!.row]
        PollRef = Database.database().reference()
        let tag = String(button.tag)
        PollRef.child("PollOptions").child(myData.pollId).child("\"\(tag)\"").child("Names").updateChildValues([user:user])
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollCell", for: indexPath) as! PollTableViewCell
        cell.Poll.text = self.ListOfPolls[indexPath.row].PollTitle
        cell.PollerPicture.image = UIImage(named: "Docs/user_icon.png")
        cell.Poster.text = self.ListOfPolls[indexPath.row].poster
        let date = CreateDate.getTimeSince(epoch: self.ListOfPolls[indexPath.row].Epoch)
        cell.PollDate.text = date
        var count = 0
        if self.ListOfPolls[indexPath.row].option1 == "" {cell.PollOption1.isHidden = true; cell.PollNumbers1.isHidden = true; count += 1}
        else {cell.PollOption1.text = self.ListOfPolls[indexPath.row].option1}
        if self.ListOfPolls[indexPath.row].option2 == "" {cell.PollOption2.isHidden = true; cell.PollNumbers2.isHidden = true; count += 1}
        else {cell.PollOption2.text = self.ListOfPolls[indexPath.row].option2}
        if self.ListOfPolls[indexPath.row].option3 == "" {cell.PollOption3.isHidden = true; cell.PollNumbers3.isHidden = true; count += 1}
        else {cell.PollOption3.text = self.ListOfPolls[indexPath.row].option3}
        if self.ListOfPolls[indexPath.row].option4 == "" {cell.PollOption4.isHidden = true; cell.PollNumbers4.isHidden = true; count += 1}
        else {cell.PollOption4.text = self.ListOfPolls[indexPath.row].option4}
        if self.ListOfPolls[indexPath.row].option5 == "" {cell.PollOption5.isHidden = true; cell.PollNumbers5.isHidden = true; count += 1}
        else {cell.PollOption5.text = self.ListOfPolls[indexPath.row].option5}
        if self.ListOfPolls[indexPath.row].option6 == "" {cell.PollOption6.isHidden = true; cell.PollNumbers6.isHidden = true; count += 1}
        else {cell.PollOption6.text = self.ListOfPolls[indexPath.row].option6}
        
        //set style of cells
        cell.PollNumbers1.layer.cornerRadius = cell.PollNumbers1.frame.width/2
        cell.PollNumbers1.layer.borderWidth = 0.2
        cell.PollNumbers1.layer.backgroundColor = UIColor(red: 187/255, green: 220/255, blue: 255/255, alpha:0.2).cgColor
        cell.PollNumbers2.layer.cornerRadius = cell.PollNumbers2.frame.width/2
        cell.PollNumbers2.layer.borderWidth = 0.2
        cell.PollNumbers2.layer.backgroundColor = UIColor(red: 187/255, green: 220/255, blue: 255/255, alpha:0.2).cgColor
        cell.PollNumbers3.layer.cornerRadius = cell.PollNumbers3.frame.width/2
        cell.PollNumbers3.layer.borderWidth = 0.2
        cell.PollNumbers3.layer.backgroundColor = UIColor(red: 187/255, green: 220/255, blue: 255/255, alpha:0.2).cgColor
        cell.PollNumbers4.layer.cornerRadius = cell.PollNumbers4.frame.width/2
        cell.PollNumbers4.layer.borderWidth = 0.2
        cell.PollNumbers4.layer.backgroundColor = UIColor(red: 187/255, green: 220/255, blue: 255/255, alpha:0.2).cgColor
        cell.PollNumbers5.layer.cornerRadius = cell.PollNumbers5.frame.width/2
        cell.PollNumbers5.layer.borderWidth = 0.2
        cell.PollNumbers5.layer.backgroundColor = UIColor(red: 187/255, green: 220/255, blue: 255/255, alpha:0.2).cgColor
        cell.PollNumbers6.layer.cornerRadius = cell.PollNumbers6.frame.width/2
        cell.PollNumbers6.layer.borderWidth = 0.2
        cell.PollNumbers6.layer.backgroundColor = UIColor(red: 187/255, green: 220/255, blue: 255/255, alpha:0.2).cgColor
        
        //Percent vote for poll
        cell.PollOption1.layer.borderWidth = 0.5
        let width1 = Int(cell.PollOption1.frame.size.width)
        var totalVotes1 = 0
        var x = 1
        while x < 7 {
            totalVotes1 += self.ListOfPolls[indexPath.row].upVotes[x].count
            x += 1
        }
        let votesForOp1 = self.ListOfPolls[indexPath.row].upVotes[1].count
        let percentOp1 = votesForOp1/totalVotes1
        let percentFilledOp1 = width1 * percentOp1
        
        //Handle size of the cell
        let cgCount = CGFloat(count)
        cell.PollResults.frame.origin.y -=  ((cgCount * cell.PollOption1.frame.height) + cell.PollResults.frame.height)
        cell.PollDate.frame.origin.y -=  ((cgCount * cell.PollOption1.frame.height) + cell.PollDate.frame.height)
        cell.SendReminder.frame.origin.y -=  ((cgCount * cell.PollOption1.frame.height) + cell.SendReminder.frame.height)
        self.rowHeight = self.defaultHeight - (cgCount * cell.PollOption1.frame.height)
        
        //Cell button actions
        cell.PollNumbers1.tag = 1
        cell.PollNumbers1.addTarget(self, action: #selector(OptionSelected(button:)), for: .touchUpInside)
        cell.PollNumbers2.tag = 2
        cell.PollNumbers2.addTarget(self, action: #selector(OptionSelected(button:)), for: .touchUpInside)
        cell.PollNumbers3.tag = 3
        cell.PollNumbers3.addTarget(self, action: #selector(OptionSelected(button:)), for: .touchUpInside)
        cell.PollNumbers4.tag = 4
        cell.PollNumbers4.addTarget(self, action: #selector(OptionSelected(button:)), for: .touchUpInside)
        cell.PollNumbers5.tag = 5
        cell.PollNumbers5.addTarget(self, action: #selector(OptionSelected(button:)), for: .touchUpInside)
        cell.PollNumbers6.tag = 6
        cell.PollNumbers6.addTarget(self, action: #selector(OptionSelected(button:)), for: .touchUpInside)
        
        //set Poll upvotes
            cell.PollNumbers1.setTitle(String(self.ListOfPolls[indexPath.row].upVotes[1].count), for: .normal)
            cell.PollNumbers2.setTitle(String(self.ListOfPolls[indexPath.row].upVotes[2].count), for: .normal)
            cell.PollNumbers3.setTitle(String(self.ListOfPolls[indexPath.row].upVotes[3].count), for: .normal)
            cell.PollNumbers4.setTitle(String(self.ListOfPolls[indexPath.row].upVotes[4].count), for: .normal)
            cell.PollNumbers5.setTitle(String(self.ListOfPolls[indexPath.row].upVotes[5].count), for: .normal)
            cell.PollNumbers6.setTitle(String(self.ListOfPolls[indexPath.row].upVotes[6].count), for: .normal)
        
        return cell
            }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ListOfPolls.count
    }

}
