//
//  ChapterInfoControllerViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-26.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ChapterInfoViewController: UIViewController {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var ChapterName: UILabel!
    @IBOutlet weak var FoundingDate: UILabel!
    @IBOutlet weak var ActiveMaster: UILabel!
    @IBOutlet weak var Constitution: UIButton!
    @IBOutlet weak var FoundingFather: UIButton!
    @IBOutlet weak var Home: UIButton!
    
    
    @IBAction func HomeBTN(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }

    var ref: DatabaseReference!

    func getInfo(completion: @escaping (Dictionary<String, Any>, Error?) -> Void){
        let ref = Database.database().reference()
        ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/Info").observeSingleEvent(of: .value, with: { (snapshot) in
            if let postDictionary = snapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                completion(postDictionary,nil )
            }
            else {
                completion([:], nil)
            }
        })
        
    }

    override func viewDidLoad() {
      super.viewDidLoad()
        getInfo()  {(dictionary ,error) in
            if let chapterName = dictionary["ChapterName"] as? String {
                if chapterName == "Empty" {
                    self.ChapterName.text = ""
                    return
                }
                self.ChapterName.text = chapterName
            }
            else {
                self.ChapterName.text = ""
            }
            if let foundingDate = dictionary["FoundingDate"] as? String {
                if foundingDate == "Empty" {
                    self.FoundingDate.text = ""
                    return
                }
                self.FoundingDate.text = foundingDate
            }
            else {
                self.FoundingDate.text = ""
            }
            if let activeMaster = dictionary["ActiveMaster"] as? String {
                if activeMaster == "Empty" {
                    self.ActiveMaster.text = ""
                    return
                }
                self.ActiveMaster.text = activeMaster
            }
            else {
                self.ActiveMaster.text = ""
            }
            if let url = dictionary["ChapterLogoURL"] as? String {
                if url == "Empty" {
                    return
                }
                Storage.storage().reference(forURL: url).getData(maxSize: 10000000) { (data, error) -> Void in
                    if error == nil {
                        if let pic = UIImage(data: data!) {
                            self.Image.image = pic
                        }
                        else {
                            GenericTools.Logger(data: "\n Error getting url data for info")
                        }
                    }
                    else {
                        GenericTools.Logger(data: "\n Error getting url data for info: \(error!)")
                    }
                }
            }
        }

        FoundingFather.layer.cornerRadius = 5
        Constitution.layer.cornerRadius = 5
        Home.layer.cornerRadius = 5

    }
}

