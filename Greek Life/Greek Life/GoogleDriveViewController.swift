//
//  GoogleDriveViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2018-01-09.
//  Copyright © 2018 ConcordiaDev. All rights reserved.
//

import UIKit

class GoogleDriveViewController: UIViewController {

    @IBOutlet weak var WebView: UIWebView!
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let myUrl = URL (string: "https://www.google.com/drive/")!
        let request = URLRequest(url: myUrl);
        WebView.loadRequest(request);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
