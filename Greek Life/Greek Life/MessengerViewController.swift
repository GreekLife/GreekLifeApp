//
//  Messenger.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-23.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Messenger: NSObject {

}
  //***********************************//
 //  Messenger View Controller Class  //
//***********************************//
class MessengerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    //Top toolbar
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let convoCell = tableView.dequeueReusableCell(withIdentifier: "convoCell", for: indexPath)
        return convoCell
    }
    
    //Gets called when user feels up a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        performSegue(withIdentifier: "MessagesViewSegue", sender: indexPath.row)
    }
    //Gets called when user feels up the accessory button of a cell
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "ChatSettingsSegue", sender: indexPath.row)
    }
    
}



  //***********************************//
 //   Settings View Controller Class  //
//***********************************//
class ChatSettingsViewController:UIViewController
{
    @IBAction func doneBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
}

  //*******************************//
 //   Chat View Controller Class  //
//*******************************//
class ChatViewController:UIViewController
{
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    //2676
}













