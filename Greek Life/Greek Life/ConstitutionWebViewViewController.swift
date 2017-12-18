//
//  ConstitutionWebViewViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-10.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class ConstitutionWebViewViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pdf = "Docs/Consitution"
        if let url = Bundle.main.url(forResource: pdf, withExtension: "pdf")
        {
            let webview = UIWebView(frame: self.view.frame)
            let urlRequest = URLRequest(url: url)
            webview.loadRequest(urlRequest as URLRequest)
            self.view.addSubview(webview)
        }
        else {
            GenericTools.Logger(data: "\n Error retreving and displaying constitution")
        }
         // Do any additional setup after loading the view.
    }
}
