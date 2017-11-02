//
//  Configuration.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-01.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import Foundation

struct Configuration{
    static var Config: NSDictionary?
}

public class LoadConfiguration {
    
    class func loadConfig(){

        if let path = Bundle.main.path(forResource: "MainConfig", ofType: "plist"){
            Configuration.Config = NSDictionary(contentsOfFile: path)
            }
    }
}
