//
//  FoundingFatherViewController.swift
//  Greek Life
//
//  Created by Jordan Fefer on 2017-11-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class FoundingFatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(Founding.foundingFatherList.count-1)
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FFCell", for:indexPath) as! FoundingFatherPrototypeTableViewCell
        cell.Name.text = Founding.foundingFatherList[indexPath.row]
        return(cell)
    }
    

}
