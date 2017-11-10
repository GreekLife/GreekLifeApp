//
//  ChapterInfoControllerViewController.swift
//  Greek Life
//
//  Created by Jordan Fefer on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

struct Founding {
    static var foundingFatherList = [String]()
}

class ChapterInfoControllerViewController: UIViewController {
    //Jordan added this
    let pdfTitle = "AEPiDocs/GL - Official Consitution (Amended Sept_04_2017)"
    
    @IBOutlet weak var MasterName: UILabel!
    @IBAction func FoundingFather(_ sender: Any) {
        readFoundingFathers();
    }
    @IBOutlet weak var FoundingFather: UIButton!
    @IBOutlet weak var Constitution: UIButton!
    @IBAction func ConstitutionAction(_ sender: Any) {
        
    }
   //Jordan added this
    @IBAction func openConstitutionAction(_ sender: Any) {
    
        if let url = Bundle.main.url(forResource: pdfTitle, withExtension: "pdf")
        {
            let webview = UIWebView(frame: self.view.frame)
            let urlRequest = URLRequest(url: url)
            webview.loadRequest(urlRequest as URLRequest)
            self.view.addSubview(webview)
            }
    
    }
    func readFoundingFathers(){
        if let foundingfather =  Bundle.main.path(forResource: "AEPiDocs/Founding_Fathers", ofType: "txt"){
            do{
                let contents = try String(contentsOfFile: foundingfather)
                let brother = contents.components(separatedBy: "\n")
                for line in brother {
                    let name = line.components(separatedBy: "\n")
                    Founding.foundingFatherList.append(name[0])
                    print(line)
                }
            }
            catch {
                print("Could not read from file!")
            }
        }
        else {
            print("fuck")
        }
    
    }
    
    func ReadMaster() {
        
        let fullName = "";
        self.MasterName.text = fullName;
    
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
        for father in Founding.foundingFatherList {
            print(father)
        }
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
