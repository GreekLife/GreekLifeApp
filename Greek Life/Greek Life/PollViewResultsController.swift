//
//  ViewResultsController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-20.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct APoll {
    static var poll: Poll!
}

class ViewAllResults: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var poll: [String]!
    @IBOutlet weak var TableView: UITableView!

    @IBAction func Back(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if poll.count == 0 {
            poll.append("No one has voted for this option")
        }
        return poll.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollName", for: indexPath) as! ViewResultsControllerCell
        cell.Names.text = poll[indexPath.row]
        if cell.Names.text == "No one has voted for this option" {
            cell.Names.textColor = .lightGray
            cell.Names.font = UIFont(name: "ClearSans-Italic", size: 17 )
        }
        return cell
    }
    
}

class ViewResultsControllerCell: UITableViewCell {
    
    @IBOutlet weak var Option: UIButton!
    @IBOutlet weak var Names: UILabel!
    
}

class ViewResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var TableView: UITableView!
    var tempIndexPath = 0

    @IBAction func Back(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TableView.separatorStyle = UITableViewCellSeparatorStyle.none

    }
    
    @objc func DisplayResultsController(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        self.tempIndexPath = indexPath!.row
        performSegue(withIdentifier: "ViewOptionResults", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewOptionResults" {
            let AllResults = segue.destination as? ViewAllResults
            var names:[String] = []
            for name in APoll.poll.UpVoteNames[tempIndexPath] {
                names.append(name)
            }
            AllResults?.poll = names
       }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APoll.poll.Options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PollOption", for: indexPath) as! ViewResultsControllerCell
        cell.Option.setTitle("Option \(indexPath.row + 1)", for: .normal)
        cell.Option.setTitleColor(UIColor.blue, for: .normal)
        cell.Option.addTarget(self, action: #selector(DisplayResultsController(button:)), for: .touchUpInside)
        return cell
        }


}

