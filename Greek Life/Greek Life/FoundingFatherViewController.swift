//
//  FoundingFatherViewController.swift
//  Greek Life
//
//  Created by Jordan Fefer on 2017-11-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class FoundingFatherPrototypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Name: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


class FoundingFatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foundingFatherList:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        readFoundingFathers()
    }
    
    func readFoundingFathers(){
        if let foundingfather =  Bundle.main.path(forResource: "Docs/Founding Fathers", ofType: "txt"){
            do{
                let contents = try String(contentsOfFile: foundingfather)
                let brother = contents.components(separatedBy: "\n")
                for line in brother {
                    let name = line.components(separatedBy: "\n")
                    foundingFatherList.append(name[0])
                    print(line)
                }
            }
            catch {
                GenericTools.Logger(data: "\n Error reading from file")
            }
        }
        else {
            print("fuck")
        }
        
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(foundingFatherList.count)
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FFCell", for:indexPath) as! FoundingFatherPrototypeTableViewCell
        cell.Name.text = foundingFatherList[indexPath.row]
        return(cell)
    }
    

}
