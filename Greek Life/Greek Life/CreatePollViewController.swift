//
//  CreatePollViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-11.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreatePollViewController: UIViewController {

    @IBOutlet weak var Question: UITextField!
    @IBOutlet weak var AddNewOption: UIButton!
    @IBOutlet weak var CreatePoll: UIButton!
    @IBOutlet weak var Option1: UITextField!
    @IBOutlet weak var AddAnOptionLbl: UILabel!
    @IBOutlet weak var DefaultOptionLbl: UILabel!
    @IBOutlet weak var Toolbar: UIToolbar!
    @IBOutlet weak var DeleteOption: UIButton!
    
    let screensize: CGRect = UIScreen.main.bounds
    var scrollView: UIScrollView!

    var NumberOfOptons = 1
    var Options:[UITextField] = []
    var OptionsLbl: [UILabel] = []
    @IBAction func AddButton(_ sender: Any) { //Function that controls adding an option
        let newestOption = Options[NumberOfOptons-1]
        let newOriginY = newestOption.frame.origin.y + newestOption.frame.size.height + 10
        let newOption = UITextField(frame: CGRect(x: newestOption.frame.origin.x, y: newOriginY, width: newestOption.frame.size.width, height: newestOption.frame.size.height))
        newOption.textColor = UIColor.black
        newOption.backgroundColor = UIColor.clear
        newOption.font = UIFont(name: newOption.font!.fontName, size: 11)
        newOption.textAlignment = .justified
        newOption.borderStyle = .roundedRect
        NumberOfOptons += 1
        newOption.placeholder = " Option \(NumberOfOptons)"
        self.scrollView.addSubview(newOption)
        Options.append(newOption)
        let newCreatePollLocation = newOption.frame.origin.y + newOption.frame.size.height + 30
        CreatePoll.frame.origin.y = newCreatePollLocation
        let maxSize = CreatePoll.frame.origin.y + CreatePoll.frame.size.height + 74
        
        let newLabel = UILabel(frame: CGRect(x: DefaultOptionLbl.frame.origin.x, y: newOriginY, width: DefaultOptionLbl.frame.size.height, height: DefaultOptionLbl.frame.size.height))
        newLabel.text = "\(NumberOfOptons)."
        scrollView.addSubview(newLabel)
        OptionsLbl.append(newLabel)
        
        if self.scrollView.contentSize.height <= maxSize {
        let newScrollHeight = self.scrollView.contentSize.height + newOption.frame.size.height + 10
        self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: newScrollHeight)
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
            var isValid = false
            for option in Options {
                if let text = option.text {
                    if text == "" {
                        isValid = false
                        break
                    }
                    isValid = true
                }
            }
            if isValid == true {
            CreateAPoll()
            }
            else {
                let AtLeastOne = UIAlertController(title: "Alert!", message: "You cannot leave any empty options", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                AtLeastOne.addAction(okAction)
                self.present(AtLeastOne, animated: true, completion: nil)
            }
        }
            
        }
    
    @IBAction func DeleteOption(_ sender: Any) {
        if NumberOfOptons > 1 {
            let option = Options[NumberOfOptons - 1]
            Options[NumberOfOptons - 1].removeFromSuperview()
            Options.remove(at: (NumberOfOptons - 1))
            
            OptionsLbl[NumberOfOptons - 1].removeFromSuperview()
            OptionsLbl.remove(at: NumberOfOptons - 1)
            
            NumberOfOptons -= 1
            self.CreatePoll.frame.origin.y -= option.frame.size.height
            //-- should adjust scroll view in some cases as well --//
        }
    }
    
    var ArrayOfOptions: [String] = []
    func RetrievePollObject() -> Poll {
        let Epoch = Date().timeIntervalSince1970
        let postId = UUID().uuidString
        let first = LoggedIn.User["First Name"] as! String
        let last = LoggedIn.User["Last Name"] as! String
        let Poster =  "\(first) \(last)"
        let Title = Question.text
        for option in Options {
            ArrayOfOptions.append(option.text!)
        }

        let newPoll = Poll(pollId: postId, Epoch: Epoch, Poster: Poster, PollTitle: Title!, options: ArrayOfOptions, upVotes: [])
        return newPoll
    }
    
    var ref: DatabaseReference!
    func CreateAPoll() {
        let poll = RetrievePollObject()
        let ThePoll: [String: Any] = [
            "Epoch" : poll.Epoch,
            "PostId" : poll.pollId,
            "Poster" : poll.poster,
            "Title" : poll.PollTitle,
            "Options": poll.options
        ]
        let ThePollKey = [poll.pollId : ThePoll]
        ref = Database.database().reference()
        ref.child("Polls").updateChildValues(ThePollKey)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Option1.textColor = UIColor.black
        self.Option1.backgroundColor = UIColor.clear
        Options.append(self.Option1)
        OptionsLbl.append(self.DefaultOptionLbl)
        let screenWidth = screensize.width
        let screenHeight = screensize.height
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight))
        // constrain the scroll view to 8-pts on each side
        scrollView.addSubview(Question)
        scrollView.addSubview(AddNewOption)
        scrollView.addSubview(CreatePoll)
        scrollView.addSubview(Option1)
        scrollView.addSubview(AddAnOptionLbl)
        scrollView.addSubview(DefaultOptionLbl)
        scrollView.addSubview(DeleteOption)
        
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight)
        self.view.addSubview(scrollView)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
