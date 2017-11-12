//
//  CreatePollViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-11.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Poll: Comparable {
    
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
    }
    
    public init(pollId: String, Epoch: Double, Poster: String, PollTitle: String, option1: String, option2: String, option3: String, option4: String, option5: String, option6: String)
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
    }
    
    
}

class CreatePollViewController: UIViewController {

    @IBOutlet weak var Question: UITextField!
    @IBOutlet weak var AddNewOption: UIButton!
    @IBOutlet weak var CreatePoll: UIButton!
    @IBOutlet weak var Option1: UITextField!
    @IBOutlet weak var Option2: UITextField!
    @IBOutlet weak var Option3: UITextField!
    @IBOutlet weak var Option4: UITextField!
    @IBOutlet weak var Option5: UITextField!
    @IBOutlet weak var Option6: UITextField!
    @IBOutlet weak var number2: UILabel!
    @IBOutlet weak var Number3: UILabel!
    @IBOutlet weak var Number4: UILabel!
    @IBOutlet weak var Number5: UILabel!
    @IBOutlet weak var Number6: UILabel!
    
    
    
    @IBAction func AddButton(_ sender: Any) { //Function that controls adding an option
        if Option2.isHidden == true {
            Option2.isHidden = false
            number2.isHidden = false
        }
        else if Option3.isHidden == true {
            Option3.isHidden = false
            Number3.isHidden = false
        }
        else if Option4.isHidden == true {
            Option4.isHidden = false
            Number4.isHidden = false
        }
        else if Option5.isHidden == true {
            Option5.isHidden = false
            Number5.isHidden = false
        }
        else if Option6.isHidden == true {
            Option6.isHidden = false
            Number6.isHidden = false
        }
        else {
            let NoMore = UIAlertController(title: "Alert!", message: "You can only include up to 5 options in your poll", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            NoMore.addAction(okAction)
            self.present(NoMore, animated: true, completion: nil)
        }
    }
    @IBAction func CreateButton(_ sender: Any) { //function to initiate officially creating the poll
        if Question.text == "" {
            let emptyQ = UIAlertController(title: "Alert!", message: "Your question cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            emptyQ.addAction(okAction)
            self.present(emptyQ, animated: true, completion: nil)
        }
        else if Option1.text == "" {
            let AtLeastOne = UIAlertController(title: "Alert!", message: "You must have at least one option", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            AtLeastOne.addAction(okAction)
            self.present(AtLeastOne, animated: true, completion: nil)
        }
        else {
            CreateAPoll()
            }
            
        }
    
    
    func RetrievePollObject() {
        let Epoch = Date().timeIntervalSince1970
        let postId = UUID().uuidString
        let Poster = "Jonahelbaz"//LoggedIn.User["Username"] as! String
        let Title = Question.text
        let Option1 = self.Option1.text
        let Option2 = self.Option2.text
        let Option3 = self.Option3.text
        let Option4 = self.Option4.text
        let Option5 = self.Option5.text
        let Option6 = self.Option6.text
        
        newPoll = Poll(pollId: postId, Epoch: Epoch, Poster: Poster, PollTitle: Title!, option1: Option1!, option2: Option2!, option3: Option3!, option4: Option4!, option5: Option5!, option6: Option6!)
    }
    
    var newPoll: Poll = Poll()
    var ref: DatabaseReference!

    func CreateAPoll() {
        RetrievePollObject()
        let ThePoll: [String: Any] = [
            "Epoch" : newPoll.Epoch,
            "PostId" : newPoll.pollId,
            "Poster" : newPoll.poster,
            "Title" : newPoll.PollTitle,
            "Option1" : newPoll.option1,
            "Option2" : newPoll.option2,
            "Option3" : newPoll.option3,
            "Option4" : newPoll.option4,
            "Option5" : newPoll.option5,
            "Option6" : newPoll.option6
        ]
        let ThePollKey = [newPoll.pollId : ThePoll]
        ref = Database.database().reference()
        ref.child("Polls").updateChildValues(ThePollKey)
    }
    
    let op1 = true
    let op2 = false
    let op3 = false
    let op4 = false
    let op5 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Option1.isHidden = false
        Option2.isHidden = true
        Option3.isHidden = true
        Option4.isHidden = true
        Option5.isHidden = true
        Option6.isHidden = true
        
        number2.isHidden = true
        Number3.isHidden = true
        Number4.isHidden = true
        Number5.isHidden = true
        Number6.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
