//
//  CreateAccountViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-29.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var BrotherName: UITextField!
    @IBOutlet weak var School: UITextField!
    @IBOutlet weak var Degree: UITextField!
    @IBOutlet weak var ProfEmail: UITextField!
    @IBOutlet weak var GradDate: UITextField!
    @IBOutlet weak var Birthday: UITextField!
    
    @IBOutlet weak var Create: UIButton!
    @IBAction func CreateAccount(_ sender: Any) {
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Create.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
