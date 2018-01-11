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
import FirebaseStorage

class MasterControllsViewController: UIViewController {
    
    
    @IBOutlet weak var CurrentCode: UILabel!
    @IBOutlet weak var GenerateNewCode: UIButton!
    @IBOutlet weak var KickAMember: UIButton!
    @IBOutlet weak var SendNotif: UIButton!
    @IBOutlet weak var TempBan: UIButton!
    @IBOutlet weak var PostNews: UIButton!
    @IBOutlet weak var Validate: UIButton!
    @IBOutlet weak var InfoPage: UIButton!
    @IBOutlet weak var Code: UILabel!
    
    var ref: DatabaseReference!

    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        TempBan.layer.cornerRadius = 5
        Validate.layer.cornerRadius = 5
        Code.layer.cornerRadius = 5
        PostNews.layer.cornerRadius = 5
        CurrentCode.layer.cornerRadius = 5
        GenerateNewCode.layer.cornerRadius = 5
        KickAMember.layer.cornerRadius = 5
        SendNotif.layer.cornerRadius = 5
        CurrentCode.layer.cornerRadius = 5
        InfoPage.layer.cornerRadius = 5
        
        ref = Database.database().reference()
        ref.child((Configuration.Config["DatabaseNode"] as! String)+"/CreateAccount").child("GeneratedKey").observe(.value, with: { (snapshot) in
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
        ref.child((Configuration.Config["DatabaseNode"] as! String)+"/CreateAccount").child("GeneratedKey").setValue(newCode){ (error) in
            GenericTools.Logger(data: "\n Error generating key: \(error)")
        }
    }
    @IBAction func KickAMember(_ sender: Any) {
        ListType.kick = true
        performSegue(withIdentifier: "KickBrother", sender: self)
    }
    @IBAction func SendNotification(_ sender: Any) {
        performSegue(withIdentifier: "CustomNotif", sender: self)
    }
    
    @IBAction func PostNews(_ sender: Any) {
        performSegue(withIdentifier: "PostNews", sender: self)

    }
    
    @IBAction func ValidateUser(_ sender: Any) {
        ListType.kick = false
        performSegue(withIdentifier: "KickBrother", sender: self)
    }
    @IBAction func TempBan(_ sender: Any) {
        performSegue(withIdentifier: "TempBan", sender: self)

    }
    
    
}

class KickPrototypeCell: UITableViewCell {
    
    @IBOutlet weak var Name: UILabel!
}

struct ListType {
   static var kick = false
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
        self.CreatePostRef.child((Configuration.Config["DatabaseNode"] as! String)+"/News").child(pID).setValue(newPostData){ (error) in
            GenericTools.Logger(data: "\n Couldn't post news: \(error)")
        }
        completion(true, nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        News.text = ""
        News.layer.cornerRadius = 30
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
        self.dismiss(animated: true)
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .destructive, title: "Kick") { (rowAction, indexPath) in
            if ListType.kick == true {
                    let verify = UIAlertController(title: "Alert!", message: "Are you sure you want to permanantly kick this member?", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Kick", style: UIAlertActionStyle.default, handler: self.KickMember)
                    let destructorAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
                    verify.addAction(okAction)
                    verify.addAction(destructorAction)
                    self.present(verify, animated: true, completion: nil)
                    self.tempIndex = indexPath.row
            }
        }
        editAction.backgroundColor = .blue
        return [editAction]
    }
    
    var tempIndex = 0
    func KickMember(action: UIAlertAction) {
        FirebaseDatabase.Database.database().reference(withPath: (Configuration.Config["DatabaseNode"] as! String)+"/Users").child(self.memberId[tempIndex]).removeValue()
        
        GenericTools.Logger(data: "\n kicked user:")
        tempIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberList = []
        memberId = []
        if ListType.kick == false {
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
        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/GeneralMessage/Master").observe(.value, with: { (snapshot) in
            old = snapshot.value as! String
            if self.Notification.text! != old {
                Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/GeneralMessage/Master").setValue(self.Notification.text!)
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

class BanCell: UITableViewCell {
    @IBOutlet weak var Name: UILabel!
    
}

class Ban: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableView: UITableView!
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BanCell", for: indexPath) as! BanCell
        cell.Name.text = "\(mMembers.MemberList[indexPath.row].first) \(mMembers.MemberList[indexPath.row].last)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Ban") { (rowAction, indexPath) in
            self.selectedIndex = indexPath.row
            let verify = UIAlertController(title: "Ban", message: "How long would you like to temporarily ban this person from the app? All access will be revoked.", preferredStyle: UIAlertControllerStyle.alert)
            let Five = UIAlertAction(title: "5 minutes", style: UIAlertActionStyle.default, handler: self.BanMember)
            let Thirty = UIAlertAction(title: "30 minutes", style: UIAlertActionStyle.default, handler: self.BanMember)
            let OneTwenty = UIAlertAction(title: "2 hours", style: UIAlertActionStyle.default, handler: self.BanMember)
            let day = UIAlertAction(title: "1 Day", style: UIAlertActionStyle.default, handler: self.BanMember)
            let destructorAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            
            verify.addAction(Five)
            verify.addAction(Thirty)
            verify.addAction(OneTwenty)
            verify.addAction(day)
            verify.addAction(destructorAction)
            self.present(verify, animated: true, completion: nil)
        }
        editAction.backgroundColor = .blue
        return [editAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mMembers.MemberList.count
    }
    
    var selectedIndex = 0
    func BanMember(alert: UIAlertAction) {
        var time = 0
        switch alert.title {
        case "5 minutes"?:
            time = 5
            break
        case "30 minutes"?:
            time = 30
            break
        case "2 hours"?:
            time = 120
            break
        case "1 Day"?:
            time = 1440
            break
        default:
            time = 0
            break
        }
        let value = [
            "Blocked": true,
            "Delay": time
            ] as [String : Any]
        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/Blocked/\(mMembers.MemberList[selectedIndex].id)").setValue(value) { (error) in
            GenericTools.Logger(data: "\n Error editing time for desired block: \(error)")
        }
    }
}

class DefineInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBAction func BackBTN(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Save(_ sender: Any) {
        
        if ChapterName.text! == "" || FoundingDate.text! == "" || ActiveMaster.text! == "" {
            let invalid = UIAlertController(title: "Empty", message: "Please do not leave any info empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            return
        }
        
        if self.pickedImage == nil {
            let invalid = UIAlertController(title: "Picture", message: "Please upload a logo with your info", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            return
        }
        
        
        if self.pickedImage != nil {
            let storageRef = Storage.storage().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/Info/\(imageName).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.pickedImage!, 0.5){
                let newMetadata = StorageMetadata()
                newMetadata.contentType = "image/jpeg";
                
                storageRef.putData(uploadData, metadata: newMetadata, completion:{ (metadata, error) in
                    if error == nil {
                        let infoObject = [
                            "ChapterName": self.ChapterName.text!,
                            "FoundingDate": self.FoundingDate.text!,
                            "ActiveMaster": self.ActiveMaster.text!,
                            "ChapterLogoURL": metadata!.downloadURL()!.description
                            ] as [String: Any]
                        
                        Database.database().reference().child((Configuration.Config["DatabaseNode"] as! String)+"/Info").setValue(infoObject){ error in
                                let invalid = UIAlertController(title: "Error", message: "There was an error saving your data", preferredStyle: UIAlertControllerStyle.alert)
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                                invalid.addAction(okAction)
                                self.present(invalid, animated: true, completion: nil)
                                return
                        }
                        let saved = UIAlertController(title: "Saved", message: "Info has been updated", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                        saved.addAction(okAction)
                        self.present(saved, animated: true, completion: nil)
                        return
                    }
                    else {
                        let invalid = UIAlertController(title: "Error", message: "There was an error handling your picture", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                        invalid.addAction(okAction)
                        self.present(invalid, animated: true, completion: nil)
                        return
                    }
                })
            }
            
        }
    }
    
    @IBAction func GetImage(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            LogoImage.contentMode = .center //this aint right
            
            LogoImage.setImage(editedImage, for: .normal)
            LogoImage.setTitle("", for: .normal)
            self.pickedImage = editedImage
        }
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            LogoImage.contentMode = .center //this aint right
            LogoImage.setBackgroundImage(pickedImage, for: .normal)
            LogoImage.setTitle("", for: .normal)
            self.pickedImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var ChapterName: UITextField!
    @IBOutlet weak var FoundingDate: UITextField!
    @IBOutlet weak var ActiveMaster: UITextField!
    @IBOutlet weak var LogoImage: UIButton!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    var pickedImage: UIImage!
    let imagePicker = UIImagePickerController()
    let imageName = "InfoLogoImage"
    
    
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
                            self.LogoImage.setImage(pic, for: .normal)
                            self.pickedImage = self.LogoImage.currentImage

                        }
                        else {
                            self.LogoImage.setTitle("Could not load the current image", for: .normal)
                            GenericTools.Logger(data: "\n Error getting url data for info")
                        }
                    }
                    else {
                        GenericTools.Logger(data: "\n Error getting url data for info: \(error!)")
                    }
                }
            }
        }
        imagePicker.delegate = self
        
    }
    
    func getInfo(completion: @escaping (Dictionary<String, Any>, Error?) -> Void){
        let ref = Database.database().reference()
        ref.child((Configuration.Config["DatabaseNode"] as! String)+"/Info").observeSingleEvent(of: .value, with: { (snapshot) in
           if let postDictionary = snapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                 completion(postDictionary,nil )
            }
           else {
                completion([:], nil)
            }
        })
   
    }
    
    
}























