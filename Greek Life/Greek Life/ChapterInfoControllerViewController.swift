//
//  ChapterInfoControllerViewController.swift
//  Greek Life
//
//  Created by Jordan Fefer on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class ChapterInfoControllerViewController: UIViewController {
    //Jordan added this
    let pdfTitle = "Docs/GL - Official Consitution (Amended Sept_04_2017)"
    
    @IBOutlet weak var MasterName: UILabel!
    @IBOutlet weak var ConstitutionButton: UIButton!
    
    @IBOutlet weak var FoundingFather: UIButton!

   //Jordan added this
    @IBOutlet weak var OpenConstitution: UIButton!
    @IBAction func OpenConsitution(_ sender: Any) {
        if let url = Bundle.main.url(forResource: pdfTitle, withExtension: "pdf")
    {
        let webview = UIWebView(frame: self.view.frame)
        let urlRequest = URLRequest(url: url)
        webview.loadRequest(urlRequest as URLRequest)
        self.view.addSubview(webview)
        }
    }
    
    func ReadMaster() {
        
        let fullName = "";
        self.MasterName.text = fullName;
    
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
        ReadMaster()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
