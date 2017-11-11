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
        }        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
