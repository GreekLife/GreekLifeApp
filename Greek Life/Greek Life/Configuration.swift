//
//  Configuration.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-01.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

//As of right now the config file is pretty useless but ill keep it incase we need it later

import Foundation



public class LoadConfiguration {
    
    class func loadConfig(){
        if let path = Bundle.main.path(forResource: "MainConfig", ofType: "plist"){
            //Configuration.Config = NSDictionary(contentsOfFile: path)
            }
    }
}
