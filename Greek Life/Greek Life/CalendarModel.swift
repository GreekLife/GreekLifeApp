//
//  CalendarModel.swift
//  Greek Life
//
//  Created by Jon Zlotnik on 2017-11-05.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Event
{
    var time:Int
    var day:Int
    var month:Int
    var year:Int
}

class Calendar {
    
    init() {
        
    }
    
    let calRef = Database.database().reference().child("Calendar")
    
    func createEvent (
        title:String,
        startTime:String,
        endTime:String,
        date:String,
        month:String,
        year:String,
        local:String,
        description:String
        )
    {
        if Reachability.isConnectedToNetwork()
        {
            calRef.child("\(year)/\(month)/\(date)/\(title)").setValue([
                "startTime" : startTime,
                "endTime" : endTime,
                "local" : local,
                "description" : description
                ])
        }else
        {
            //put alert on screen
        }
    }
    
    /*func pullEvents ()
    {
        var cal: Calendar = Calendar(calRef)
        
        return cal
    }*/
}
