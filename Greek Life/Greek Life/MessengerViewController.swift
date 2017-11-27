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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 10
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
//  Messenger View Controller Class  //
//***********************************//
class ChatSettingsViewController:UIViewController
{
    
}














