//
//  CalendarViewController.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit


  //*******************//
 //  Calendar Struct  //
//*******************//
struct Calendar {
    //Calendar Fields
    var eventList:[String:[String:Any]]
    var settings:[String:Any]
    
    //General Gregorian Rules and Tools
    func isLeapYear(_ year:Int) -> Bool{
        if year % 4 == 0{
            if year % 100 == 0{
                if year % 400 == 0{
                    return true
                }else{
                    return false
                }
            }else{
                return true
            }
        }else{
            return false
        }
    }
    func daysIn(month:Int, year:Int) -> Int{
        if month == 2 {
            if isLeapYear(year){
                return 29
            }else{
                return 28
            }
        }else if month == 4 || month == 6 || month == 9 || month == 11{
            return 30
        }else{
            return 31
        }
    }
}


  //**********************************//
 //  Calendar View Controller Class  //
//**********************************//

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    //-------------------//
    //  Calendar Model   //
    //-------------------//

    //Database References
    let dataRef:DatabaseReference = Database.database().reference()
    //Handles for Database Sync
    var calendarDataHandle:DatabaseHandle?
    var calendarSettingsDataHandle:DatabaseHandle?
    //Current Snapshots of Database
    var calendarSnapshot:DataSnapshot?
    var calendarSettingsSnapshot:DataSnapshot?
    //Local Calendar Instace
    var calendar:Calendar = Calendar(eventList: [:], settings: [:])
    
    func initCalendar()
    {
        if Reachability.isConnectedToNetwork(){
            
            self.dataRef.child("Calendar").observeSingleEvent(of: .value, with: {(snapshot) in
                if let eventList = snapshot.value as? [String:[String:Any]]
                {
                    self.calendar.eventList = eventList
                    print("we got the calendar boyyz")
                    self.calendarTable.reloadData()
                }
                else{print("Can't find the calendar")}
            }){ (error) in
                print("Could not retrieve object from database");
            }
            self.dataRef.child("CalendarControls").observeSingleEvent(of: .value, with: {(snapshot) in
                if let settings = snapshot.value as? [String:Any]
                {
                    self.calendar.settings = settings
                    print("we got the settings boyyz")
                }
                else{print("Can't find the calendar")}
            }){ (error) in
                print("Could not retrieve object from database");
            }
        
        }
        else{print ("Not connected to network!")}
    }
    
    
    //-----------------------//
    //  Calendar Controller  //
    //-----------------------//
    
    
    @IBOutlet weak var calendarTable: UITableView!
    @IBAction func createEventBTN(_ sender: Any) {
    }
    @IBAction func backBTN(_ sender: Any)
    {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCalendar()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.eventList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        if let eventCell = eventCell as? EventCell
        {
            eventCell.eventTitle.text = Array(calendar.eventList.values)[indexPath.row]["title"] as? String
            eventCell.eventDateTime.text = CreateDate.getCurrentDate(epoch: Double(Array(calendar.eventList.keys)[indexPath.row])!)
        }
        return eventCell
    }
}
  //********************//
 //  Event Cell Class  //
//********************//

class EventCell: UITableViewCell
{
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDateTime: UILabel!
    @IBOutlet weak var eventLocation: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

















