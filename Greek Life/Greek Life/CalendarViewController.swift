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
    
    func editEvent (
        title:String,
        date:Date,
        duration:TimeInterval,
        local:String,
        description:String
        )
    {
        if Reachability.isConnectedToNetwork()
        {
            
            //Writing event data to database
            dataRef.child("Calendar").child(String(Int(date.timeIntervalSince1970.magnitude))).setValue([
                "title" : title,
                "duration" : duration.magnitude,
                "local" : local,
                "description" : description,
                "date" : date.timeIntervalSince1970
                ])
            
        }
    }
    
    
    //-----------------------//
    //  Calendar Controller  //
    //-----------------------//
    
    //IBOutlets and IBActions
    @IBOutlet weak var calendarTable: UITableView!
    @IBOutlet weak var createEventBTN: UIBarButtonItem!
    
    @IBAction func createEventBTN(_ sender: Any)
    {
        performSegue(withIdentifier: "eventEditorSegue", sender: "createEvent")
    }
    @IBAction func backBTN(_ sender: Any)
    {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
    //View Lifecycle Things
    override func viewDidLoad() {
        super.viewDidLoad()
        initCalendar()
        calendarDataHandle = dataRef.child("Calendar").observe(.value, with: {(calendarSnapshot) in
            self.calendar.eventList = (calendarSnapshot.value as? [String : [String : Any]])!
            self.calendarTable.reloadData()
        })
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //For Viewing an Event
        if segue.identifier == "displayEventViewSegue"
        {
            let displayEventView = segue.destination as? DisplayEventViewController
            let eventData:[String:Any] = Array(calendar.eventList.values)[(sender as! Int)]
            displayEventView?.eventData = eventData
        }
        //For Creating or Editing
        else if (sender as! String) == "createEvent"
        { 
            let eventEditorView = segue.destination as? EventEditorViewController
            eventEditorView?.isCreatingNew = true
        }else{
            print("didn't know what the fuck was happening")
        }
    }
    //Unwinding from presented views
    @IBAction func unwindCreateEvent(segue: UIStoryboardSegue)
    {
        
        let createEventInfo = segue.source as? EventEditorViewController
        editEvent(
            title:  (createEventInfo?.titleField.text!)!,
            date:  (createEventInfo?.datePicker.date)!,
            duration:  (createEventInfo?.durationPicker.countDownDuration)!,
            local:  (createEventInfo?.localField.text)!,
            description:  (createEventInfo?.descriptionField.text)!
        )
    }
    
    //Table View Controller Functions
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
    //To view an event in the DisplayEventViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "displayEventViewSegue", sender: indexPath.row)
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

  //***************************************//
 //  Display Event View Controller Class  //
//**************************************//

class DisplayEventViewController: UIViewController
{
    var eventData:[String:Any] = [:]
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionField: UITextView!
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        titleLabel.text = (eventData["title"] as! String)
    }
    
}

  //*********************************//
 //  Event Editor Controller Class  //
//*********************************//
class EventEditorViewController: UIViewController
{
    
    
    @IBAction func cancelBTN(_ sender: UIBarButtonItem)
    {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    var isCreatingNew:Bool = false //Is set by prepare function of Calendar Controller
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var localField: UITextField!
    @IBOutlet weak var durationPicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionField: UITextView!
    
    
    
    override func viewDidLoad() {
        
        if (isCreatingNew)
        {
            print("Making new event")
        }
        else
        {
            print("Editing previoulsy created event")
        }
    }
    
    // To prepare to close the event editor,
    // it calls the editEvent method from the model
    // in order to save the changes to database
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
}














