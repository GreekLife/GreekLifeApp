//
//  FirstViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-20.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirstViewController: UIViewController {
    var User: [String: Any?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print(LoggedIn.User) //I can print it out just like this because the variable is stored in a structure rather than a class. I dont have to create a new instance of
        //it, I can just access the existing one
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

