//
//  CalendarViewController.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit




class EventEditor: UIViewController
{

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var localField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    var cal:Calendar = Calendar()
    
    @IBAction func submitBTN() {
        cal.createEvent(title: titleField.text!, startTime: startTimeField.text!, endTime: endTimeField.text!, date: dateField.text!, month: monthField.text!, year: yearField.text!, local: localField.text!, description: descriptionField.text!)
    }
    
}







class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dayList = ["day1", "day2", "day3"]
    let eventList = ["first event", "second event", "third event"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dayCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "dayCell")
        dayCell.textLabel?.text = eventList[indexPath.row]
        
        return dayCell
    }
    

    @IBOutlet weak var calendarTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
