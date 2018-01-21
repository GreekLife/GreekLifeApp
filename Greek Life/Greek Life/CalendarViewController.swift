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
struct theCalendar {
    let userCalendar = Calendar.current
    //UI Stuff
    var monthViewing:Int
    var yearViewing:Int
    mutating func initUI(){
        self.monthViewing = userCalendar.component(.month, from: Date.init())
        self.yearViewing = userCalendar.component(.year, from: Date.init())
    }
    //Calendar Fields
    var eventList:[String:[String:Any]] = ["":["":""]]
    var settings:[String:Any]
    var sectionedEventList:[Int:[Int:[Int:[String:[String:Any]]]]]
    ////////////////////////YY///MM///DD///epoch///Detail:Val///
    
    
    mutating func organizeEvents ()
    {
        sectionedEventList.removeAll()
        for event in eventList
        {
            let dateDate = Date.init(timeIntervalSince1970: Double(event.key)!)
            let year:Int = userCalendar.component(.year, from: dateDate)
            let month:Int = userCalendar.component(.month, from: dateDate)
            let day:Int = userCalendar.component(.day, from: dateDate)
            if sectionedEventList[year]?[month]?[day] != nil {
                sectionedEventList[year]![month]![day]![event.key] = event.value
            }
            else if sectionedEventList[year]?[month] != nil{
                sectionedEventList[year]![month]![day] = [event.key:event.value]
            }
            else if sectionedEventList[year] != nil{
                sectionedEventList[year]![month] = [day:[event.key:event.value]]
            }
            else {
                sectionedEventList[year] = [month:[day:[event.key:event.value]]]
            }
        }
    }
    
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
    func monthToString(_ month:Int) -> String
    {
        switch month {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return "That's not a month"
        }
    }
    func weekdayToString(_ day:Int) -> String{
        switch day {
            case 1: return "Sunday"
            case 2: return "Monday"
            case 3: return "Tuesday"
            case 4: return "Wednesday"
            case 5: return "Thursday"
            case 6: return "Friday"
            case 7: return "Saturday"
            default: return "Not a day"
        }
    }
    func stndrdth (_ day:Int) -> String {
        if(day == 1 || day == 21 || day == 31){
            return "st"
        }else if(day == 2 || day == 22){
            return "nd"
        }else if(day == 3 || day == 23){
            return "rd"
        }else{
            return "th"
        }
    }
    
}


  //**********************************//
 //  Calendar View Controller Class  //
//**********************************//

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    //------------------//
    //  Database Stuff  //
    //------------------//
    
    //Database References
    let dataRef:DatabaseReference = Database.database().reference()
    //Handles for Database Sync
    var calendarDataHandle:DatabaseHandle?
    var calendarSettingsDataHandle:DatabaseHandle?
    //Current Snapshots of Database
    var calendarSnapshot:DataSnapshot?
    var calendarSettingsSnapshot:DataSnapshot?
    
    //-------------------//
    //  Calendar Model   //
    //-------------------//
    
    var canDeleteEvents = false;
    
    //theCalendar Struct Instance
    var calendar:theCalendar = theCalendar(monthViewing: 0, yearViewing: 0, eventList: [:], settings: [:], sectionedEventList: [:])
    
    //Calendar Initialization (Fetching data from DB)
    func initCalendar()
    {
        if Reachability.isConnectedToNetwork(){
            
            self.dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar").observeSingleEvent(of: .value, with: {(snapshot) in
                if let eventList = snapshot.value as? [String:[String:Any]]
                {
                    self.calendar.eventList = eventList
                    self.reloadCalendar()
                }
                else{print("Can't find the calendar")}
            }){ (error) in
                print("Could not retrieve object from database");
            }
            self.dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/CalendarControls").observeSingleEvent(of: .value, with: {(snapshot) in
                if let settings = snapshot.value as? [String:Any]
                {
                    self.calendar.settings = settings
                }
                else{print("Can't find the calendar")}
            }){ (error) in
                print("Could not retrieve object from database");
            }
        
        }
        else{print ("Not connected to network!")}
    }
    //General function to edit events in the DB
    func editEvent (
        title:String,
        date:Date,
        duration:TimeInterval,
        location:String,
        description:String
        )
    {
        if Reachability.isConnectedToNetwork()
        {
            
            //Writing event data to database
            dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar").child(String(Int(date.timeIntervalSince1970.magnitude))).setValue([
                "title" : title,
                "duration" : duration.magnitude,
                "location" : location,
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
    @IBOutlet weak var editBTN: UIBarButtonItem!
    @IBAction func editBTN(_ sender: Any)
    {
        if self.canDeleteEvents == true {
            self.canDeleteEvents = false
        }
        else {
            self.canDeleteEvents = true
        }
        self.reloadCalendar()
    }
    //Action called to delete event
    @objc func DeleteEventBTN(button: UIButton){
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        let eventKey = String(Array(Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.values)[(indexPath?.section)!])[(indexPath?.row)!].key)
        let confirmDeleteEvent = UIAlertController(title: "Delete Event", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.alert)
        confirmDeleteEvent.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in confirmDeleteEvent.dismiss(animated: true)}))
        confirmDeleteEvent.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            self.dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar/"+eventKey!).removeValue(){ (error) in
                
            }
            confirmDeleteEvent.dismiss(animated: true)
            self.calendar.eventList.removeValue(forKey: eventKey!)
            self.reloadCalendar()
        }))
        self.present(confirmDeleteEvent, animated: true, completion: nil)
    }
    
    @IBAction func createEventBTN(_ sender: Any){
        performSegue(withIdentifier: "eventEditorSegue", sender: "createEvent")
    }
    @IBAction func backBTN(_ sender: Any){
        dataRef.removeObserver(withHandle: calendarDataHandle!)
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBOutlet weak var monthYearField: UITextField!
    @IBAction func monthYearField(_ sender: UITextField) {
        let monthPickerView:MonthYearPickerView = MonthYearPickerView();
        
        monthPickerView.onDateSelected = { (month: Int, year: Int) in
            self.calendar.monthViewing = month
            self.calendar.yearViewing = year
            self.reloadCalendar()
        }
        sender.inputView = monthPickerView
        monthPickerView.selectRow(calendar.monthViewing - 1, inComponent: 0, animated: false)
        monthPickerView.selectRow(calendar.yearViewing - 1913, inComponent: 1, animated: false)
    }
    
    
    
    //View Lifecycle Things
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEboard.member.contains(LoggedIn.User["Position"] as! String){
            self.editBTN.isEnabled = true
            self.createEventBTN.isEnabled = true
        }else{
            self.editBTN.isEnabled = false
            self.createEventBTN.isEnabled = false
        }
        self.calendar.initUI()
        initCalendar()
        self.reloadCalendar()
        self.calendar.initUI()
        initCalendar()
        self.reloadCalendar()
        calendarDataHandle = dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar").observe(.value, with: {(calendarSnapshot) in
            self.calendar.eventList = (calendarSnapshot.value as? [String : [String : Any]])!
            self.reloadCalendar()
        })
        
    }
    //To and From other Views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //For Viewing an Event
        if segue.identifier == "displayEventViewSegue"
        {
            var senderDict = sender as! [String:Int]
            self.reloadCalendar()
            let displayEventView = segue.destination as? DisplayEventViewController
            let eventData:[String:Any] =
                Array(Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.values)[senderDict["section"]!])[senderDict["row"]!].value
            displayEventView?.eventData = eventData
            displayEventView?.calendar = self.calendar
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
            location:  (createEventInfo?.locationField.text)!,
            description:  (createEventInfo?.descriptionField.text)!
        )
    }
    
    //Table View Controller Functions
    func reloadCalendar(){
        self.calendar.organizeEvents()
        self.calendarTable.reloadData()
        self.monthYearField.text = "\(calendar.monthToString(calendar.monthViewing)), \(calendar.yearViewing)"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if calendar.sectionedEventList[calendar.yearViewing]?[calendar.monthViewing] != nil {
            return calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.count
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if calendar.sectionedEventList[calendar.yearViewing]?[calendar.monthViewing] != nil {
            let sortedDayKeys = Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.keys).sorted(by: <)
            let keyForCurrentDay =  sortedDayKeys[section]
            let weekday = Calendar.current.component(.weekday, from: Date(timeIntervalSince1970:Double(Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]![keyForCurrentDay]!)[0].key)!))
            let date = keyForCurrentDay
            return "\(calendar.weekdayToString(weekday)) the \(date)\(calendar.stndrdth(date))"
        }
        else{
            return "Nothing happening this month"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if calendar.sectionedEventList[calendar.yearViewing]?[calendar.monthViewing] != nil {
            return Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!)[section].value.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        if let eventCell = eventCell as? EventCell
        {
            eventCell.eventTitle.text =
                Array(Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.values)[indexPath.section])[indexPath.row].value["title"] as? String
            eventCell.eventDateTime.text =
                CreateDate.getCurrentDate(epoch: Double(Array(Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.values)[indexPath.section])[indexPath.row].value["date"] as! Double))
            eventCell.deleteBTN.addTarget(self, action: #selector(DeleteEventBTN(button:)), for: .touchUpInside )
            if self.canDeleteEvents {
                eventCell.deleteBTN.alpha = 1
                eventCell.deleteBTN.isEnabled = true
                eventCell.deleteBTN.setTitle("Delete", for: .normal)
            }else{
                if let isCancelled =  Array(Array(calendar.sectionedEventList[calendar.yearViewing]![calendar.monthViewing]!.values)[indexPath.section])[indexPath.row].value["Cancelled"] as? Bool {
                    if isCancelled {
                        eventCell.deleteBTN.alpha = 1
                        eventCell.deleteBTN.setTitle("Cancelled", for: .normal)
                        eventCell.deleteBTN.isEnabled = false

                    }
                    else {
                        eventCell.deleteBTN.alpha = 0
                        eventCell.deleteBTN.isEnabled = false
                    }
                }
                else {
                    eventCell.deleteBTN.alpha = 0
                    eventCell.deleteBTN.isEnabled = false
                }
                
            }
            
        }
        return eventCell
    }
    
    //To view an event in the DisplayEventViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "displayEventViewSegue", sender: ["section":indexPath.section, "row":indexPath.row])
    }
    
    
}
  //********************//
 //  Event Cell Class  //
//********************//

class EventCell: UITableViewCell
{
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDateTime: UILabel!
    @IBOutlet weak var deleteBTN: UIButton!
    
    
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

class DisplayEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let calView = (presentingViewController as! CalendarViewController)
        if (calView.calendar.eventList[String(Int(((eventData["date"] as! Double))))]!["attendees"] as? [String:String])?.keys != nil {
            let attendees = calView.calendar.eventList[String(Int((eventData["date"] as? Double)!))]!["attendees"] as! [String:String]
            return attendees.count
        }else{
            return 0
        }
        
    }
    func getNameById(id: String) -> String {
        var name = ""
        for user in mMembers.MemberList {
            if user.id == id {
                name = user.first + " " + user.last
            }
        }
        return name
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calView = (presentingViewController as! CalendarViewController)
        let attendees = calView.calendar.eventList[String(Int((eventData["date"] as? Double)!))]!["attendees"] as! [String:String]
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "attendeeCell")
        let name = getNameById(id: Array(attendees)[indexPath.row].value)
        cell.textLabel?.text = name
        return cell
    }
    
    var eventData:[String:Any] = [:]
    var calendar:theCalendar = theCalendar(monthViewing: 0, yearViewing: 0, eventList: [:], settings: [:], sectionedEventList: [:])
    
    @IBOutlet weak var CancelEvent: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var attendingSwitch: UISwitch!
    @IBAction func attendingSwitch(_ sender: UISwitch)
    {
        let calView = (presentingViewController as! CalendarViewController)
        let dataRef = calView.dataRef
        if sender.isOn{
            dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar/"+String(Int((eventData["date"] as? Double)!))+"/attendees/"+(LoggedIn.User["UserID"] as? String)!).setValue(LoggedIn.User["UserID"])
        }else{
            //if calView.calendar.eventList[String(Int((eventData["date"] as? Double)!))]?["attendees"].contains(where: (LoggedIn.User["UserID"] as? String)
            dataRef.child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar/"+String(Int((eventData["date"] as? Double)!))+"/attendees/"+(LoggedIn.User["UserID"] as? String)!).removeValue(){error in
                print("user wasn't attending in the first place")
            }
        }
    }
    
    @IBAction func CancelEvent(_ sender: Any) {
        if let cancelled = eventData["Cancelled"] as? Bool {
            if cancelled {
                Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar/" + String(Int((eventData["date"] as? Double)!)) + "/Cancelled").setValue(false) {
                    error in
                    print("Couldnt uncancel event")
                }
                let alert = UIAlertController(title: "Uncancelled", message: "Your event has been uncancelled", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            else {
                Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar/" + String(Int((eventData["date"] as? Double)!)) + "/Cancelled").setValue(true){ error in
                    print("Couldnt cancel event")
                }
                let alert = UIAlertController(title: "Cancelled", message: "Your event has been cancelled", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/Calendar/" + String(Int((eventData["date"] as? Double)!)) + "/Cancelled").setValue(true){ error in
                print("Couldnt cancel event")
            }
            let alert = UIAlertController(title: "Cancelled", message: "Your event has been cancelled", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func backBTN(_ sender: Any)
    {
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        titleLabel.text = (eventData["title"] as! String)
        if let dictOfAttendees = calendar.eventList[String(Int(((eventData["date"] as! Double))))]!["attendees"] as? [String:String]? {
            if dictOfAttendees?.keys != nil {
            let listOfAttendees = dictOfAttendees!.keys
            if (listOfAttendees.contains(LoggedIn.User["UserID"] as! String)){
                attendingSwitch.isOn = true
            }
            }
        }
         if let cancelled = eventData["Cancelled"] as? Bool {
            if cancelled {
                CancelEvent.setTitle("Uncancel this event?", for: .normal)
            }
            else {
                CancelEvent.setTitle("Cancel this event?", for: .normal)
            }
        }
        if !(isEboard.member.contains(LoggedIn.User["Position"] as! String)) {
            CancelEvent.isHidden = true
        }
        
        let date = Date.init(timeIntervalSince1970: eventData["date"] as! TimeInterval)
        dateLabel.text = theFormatter.dateStringFromDate(date)
        let endDate:Date = date.addingTimeInterval(eventData["duration"] as! TimeInterval)
        timeLabel.text = "\(theFormatter.timeStringFromDate(date)) to \(theFormatter.timeStringFromDate(endDate))"
        locationLabel.text = eventData["location"] as? String
        descriptionField.text = eventData["description"] as! String
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
    @IBOutlet weak var locationField: UITextField!
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














