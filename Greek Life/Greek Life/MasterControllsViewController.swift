//
//  MasterControllsViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-12-01.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MasterControllsViewController: UIViewController {
    
    
    @IBOutlet weak var CurrentCode: UILabel!
    @IBOutlet weak var GenerateNewCode: UIButton!
    @IBOutlet weak var KickAMember: UIButton!
    @IBOutlet weak var SendNotif: UIButton!
    
    var ref: DatabaseReference!

    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrentCode.layer.cornerRadius = 5
        GenerateNewCode.layer.cornerRadius = 5
        KickAMember.layer.cornerRadius = 5
        SendNotif.layer.cornerRadius = 5
        
        ref = Database.database().reference()
        ref.child("CreateAccount").child("GeneratedKey").observe(.value, with: { (snapshot) in
            let code = snapshot.value as? String
            self.CurrentCode.text = code
            
        }) {(error) in
            GenericTools.Logger(data: "\n Could not read generated tree: \(error)")
        }
        
    }

    @IBAction func GenerateNewCode(_ sender: Any) {
        let val1 = arc4random_uniform(10)
        let val2 = arc4random_uniform(10)
        let val3 = arc4random_uniform(10)
        let val4 = arc4random_uniform(10)

        let newCode = "\(val1)\(val2)\(val3)\(val4)"
        ref = Database.database().reference()
        ref.child("CreateAccount").child("GeneratedKey").setValue(newCode){ (error) in
            GenericTools.Logger(data: "\n Error generating key: \(error)")
        }
    }
    @IBAction func KickAMember(_ sender: Any) {
        performSegue(withIdentifier: "KickBrother", sender: self)
        ListType.kick = true
        ListType.validate = false
    }
    @IBAction func SendNotification(_ sender: Any) {
        performSegue(withIdentifier: "CustomNotif", sender: self)
    }
    
    @IBAction func PostNews(_ sender: Any) {
        performSegue(withIdentifier: "PostNews", sender: self)

    }
    
    @IBAction func ValidateUser(_ sender: Any) {
        performSegue(withIdentifier: "KickBrother", sender: self)
        ListType.kick = false
        ListType.validate = true
    }
    
    
}

class KickPrototypeCell: UITableViewCell {
    
    @IBOutlet weak var Name: UILabel!
}

struct ListType {
   static var kick = false
   static var validate = false
}

class PostNews: UIViewController {
    
    @IBOutlet weak var News: UITextView!
    @IBOutlet weak var Post: UIButton!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    let user = LoggedIn.User["Username"] as! String
    let name = "\(LoggedIn.User["First Name"] as! String) \(LoggedIn.User["Last Name"] as! String)"
    var CreatePostRef: DatabaseReference!

    @IBAction func PostNews(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator, view: self.view);
        let components = News.text.components(separatedBy: .whitespacesAndNewlines)
        let PostWords = components.filter { !$0.isEmpty }
        
        let valid = validate(words: PostWords.count)
        
        if(valid == true)
        {
            UploadPost()
        }
        
    }
    @IBAction func Back(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
     func validate(words:Int)->Bool{
        if(words < 10) {
            let emptyError = UIAlertController(title: "Too Small", message: "Post must be at least 10 words", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
        else if(words > 400){
            let emptyError = UIAlertController(title: "Too Large", message: "Post must be no more than 400 words", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
    
        return true
    }
    
    func UploadPost(){
        let Epoch = Date().timeIntervalSince1970
        let Posting = News.text
        let postId = UUID().uuidString
        
        if(Posting != nil){
            let Post = [
                "Post": Posting!,
                "Epoch": Epoch,
                "PostId": postId,
                ] as [String : Any]
            PostData(newPostData: Post){(success, error) in
                guard success else{
                    let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not post.")
                    BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                    self.view.addSubview(BadPostRequest)
                    GenericTools.Logger(data: "\n Could not post \(String(describing: error))")
                    return
                }
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        CreatePostRef = Database.database().reference()
        let pID = newPostData["PostId"] as! String
        self.CreatePostRef.child("News").child(pID).setValue(newPostData){ (error) in
            GenericTools.Logger(data: "\n Couldn't post news: \(error)")
        }
        completion(true, nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        News.text = ""
        News.layer.cornerRadius = 10
        News.layer.borderWidth = 1
        Post.layer.cornerRadius = 5
    }
    
}

class KickMember: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: DatabaseReference!
    var memberList:[Member] = []
    var memberId:[String] = []


    @IBOutlet weak var TableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    @IBAction func Back(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KickCell", for: indexPath) as! KickPrototypeCell
        cell.Name.text = "\(memberList[indexPath.row].first) \(memberList[indexPath.row].last)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mMembers.memberObj = memberList[indexPath.row]
        performSegue(withIdentifier: "ValidateUser", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if ListType.kick == true {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let verify = UIAlertController(title: "Alert!", message: "Are you sure you want to permanantly kick this member?", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Kick", style: UIAlertActionStyle.default, handler: KickMember)
            let destructorAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            verify.addAction(okAction)
            verify.addAction(destructorAction)
            self.present(verify, animated: true, completion: nil)
            tempIndex = indexPath.row
            }
        }
    }
    var tempIndex = 0
    func KickMember(action: UIAlertAction) {
        FirebaseDatabase.Database.database().reference(withPath: "Users").child(self.memberId[tempIndex]).removeValue(){ (error) in
            GenericTools.Logger(data: "\n Could not kick user: \(error)")
        }
        GenericTools.Logger(data: "\n kicked user:")
        tempIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ListType.validate == true {
            for mem in mMembers.MemberList {
                if mem.status == false {
                    memberList.append(mem)
                }
            }
            self.TableView.reloadData()
        }
        else {
            for mem in mMembers.MemberList {
                    memberList.append(mem)
            }
            self.TableView.reloadData()
        }
    
    }
}

class CustomNotification: UIViewController {
    
    @IBOutlet weak var Notification: UITextField!
    @IBOutlet weak var SendNotification: UIButton!
    @IBAction func SendNotification(_ sender: Any) {
        if(Notification.text != "") {
            var old = ""
        Database.database().reference().child("GeneralMessage/Master").observe(.value, with: { (snapshot) in
            old = snapshot.value as! String
            if self.Notification.text! != old {
                Database.database().reference().child("GeneralMessage/Master").setValue(self.Notification.text!)
                let verify = UIAlertController(title: "Sent!", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                verify.addAction(okAction)
                self.present(verify, animated: true, completion: nil)
                self.Notification.text = ""
                return
            }
            else {
                let verify = UIAlertController(title: "Failed to send!", message: "Your message must be different than the last one.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                verify.addAction(okAction)
                self.present(verify, animated: true, completion: nil)
                return
            }
        }){ (error) in
            GenericTools.Logger(data: "\n Error sending custom notification: \(error)")
            }
        }
        else {
             let verify = UIAlertController(title: "Alert!", message: "You can't send an empty notification.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            verify.addAction(okAction)
            self.present(verify, animated: true, completion: nil)
            return
        }
        
    }
    @IBAction func Done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SendNotification.layer.cornerRadius = 10
    }
}
