//
//  CreatePollViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-11.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class CreatePollViewController: UIViewController {

    @IBOutlet weak var Question: UITextField!
    @IBOutlet weak var AddNewOption: UIButton!
    @IBOutlet weak var CreatePoll: UIButton!
    @IBOutlet weak var Option1: UITextField!
    @IBOutlet weak var Option2: UITextField!
    @IBOutlet weak var Option3: UITextField!
    @IBOutlet weak var Option4: UITextField!
    @IBOutlet weak var Option5: UITextField!
    @IBOutlet weak var number2: UILabel!
    @IBOutlet weak var Number3: UILabel!
    @IBOutlet weak var Number4: UILabel!
    @IBOutlet weak var Number5: UILabel!
    
    
    
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
            //Create post
        }
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
        
        number2.isHidden = true
        Number3.isHidden = true
        Number4.isHidden = true
        Number5.isHidden = true
        
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
