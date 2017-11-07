//
//  CalendarViewController.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

  //*******************//
 //  Calendar Struct  //
//*******************//
struct Calendar {
    //Calendar Fields
    var eventList:Dictionary<Double, Dictionary<String,Any>>
    var settings:Dictionary<String, Any>
    
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
    let calendarRef:DatabaseReference = Database.database().reference().child("Calendar")
    let calendarSettingsRef:DatabaseReference = Database.database().reference().child("CalendarControls")
    //Handles for Database Sync
    var calendarDataHandle:DatabaseHandle?
    var calendarSettingsDataHandle:DatabaseHandle?
    //Current Snapshots of Database
    var calendarSnapshot:DataSnapshot?
    var calendarSettingsSnapshot:DataSnapshot?
    //Local Calendar Instace
    var calendar:Calendar = Calendar(eventList: <#Dictionary<String, Any>#>, settings: <#Dictionary<String, Any>#>)
    
    func initDBSnapshots()
    {
        calendarRef.observeSingleEvent(of: .value, with: {(snapshot) in
            self.calendarSnapshot = snapshot
        })
        calendarDataHandle = calendarRef.observe(.value, with: {(snapshot) in
            self.calendarSnapshot = snapshot
        })
        calendarSettingsRef.observeSingleEvent(of: .value, with: {(snapshot) in
            self.calendarSettingsSnapshot = snapshot
        })
        calendarSettingsDataHandle = calendarSettingsRef.observe(.value, with: {(snapshot) in
            self.calendarSettingsSnapshot = snapshot
        })
    }
    func openCalendar()
    {
        calendar.settings = (calendarSettingsSnapshot?.dictionaryWithValues(forKeys: [
            "start", "end"
            ]))!
        calendar.eventList = calendarSnapshot?.value as! Dictionary<Double,Dictionary<String,Any>>
    }
    func closeCalendar()
    {
        
    }
    
    
    //-----------------------//
    //  Calendar Controller  //
    //-----------------------//
    
    override func viewDidLoad() {
        initDBSnapshots()
        openCalendar()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return calendar.eventList.enumerated(). [indexPath.row]. ["title"]
    }
    
    
    
}
