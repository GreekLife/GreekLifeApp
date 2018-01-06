//
//  CreateAccountViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-29.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


struct NewUser {
    static var email = ""
    static var userID = ""
    static var edit = false
}

class AccountDetails: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var RePassword: UITextField!
    @IBOutlet weak var GoToProfile: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var ref: DatabaseReference!

    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func GoToProfile(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if Email.text! == "" || Password.text! == "" {
            let emptyError = UIAlertController(title: "Empty", message: "No fields can be left empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return
        }
        if Password.text! != RePassword.text! {
            let invalid = UIAlertController(title: "Does not match", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return
        }
        if Password.text!.count < 6 {
            let invalid = UIAlertController(title: "Too short", message: "Your password must be at least 6 characters long", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return
        }
        //Validate email
        Auth.auth().createUser(withEmail: Email.text!, password: Password.text!) { (user, Error) in
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
                if (Error == nil) {
                        if(user != nil){
                            print("Account created")
                            NewUser.email = self.Email.text!
                            NewUser.userID = (user?.uid)!
                            let newUserData = [
                                "BrotherName": "",
                                "Degree": "",
                                "First Name": "",
                                "Last Name": "",
                                "School": "",
                                "GraduationDate": "",
                                "Birthday": "",
                                "Position": "",
                                "Username": "",
                                "Email": NewUser.email,
                                "Image": "",
                                "UserID": NewUser.userID,
                                "NotificationId": "",
                                "Validated": false
                                ] as [String : Any]
                            
                            self.CreateProfile(newPostData: newUserData) {(success ,error) in
                                self.activityIndicator.stopAnimating();
                                UIApplication.shared.endIgnoringInteractionEvents();
                                if error != nil {
                                    GenericTools.Logger(data: "\n Error creating new user: \(error!)")
                                    let invalid = UIAlertController(title: "Internal Error", message: "Could not create your account", preferredStyle: UIAlertControllerStyle.alert)
                                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                                    invalid.addAction(okAction)
                                    self.present(invalid, animated: true, completion: nil)
                                }
                            }
                            let value = [
                                "Blocked": false,
                                "Delay": 0
                                ] as [String : Any]
                            Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Blocked/\(NewUser.userID)").setValue(value) { (error) in
                                GenericTools.Logger(data: "\n Error initializing block value: \(error)")
                            }
                            self.performSegue(withIdentifier: "Profile", sender: self);
                    }
                }
            else {
                if let myError = Error?.localizedDescription{
                    debugPrint(myError);
                    if myError == "The email address is already in use by another account." {
                        let invalid = UIAlertController(title: "Already Exists", message: myError, preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                        invalid.addAction(okAction)
                        self.present(invalid, animated: true, completion: nil)
                    }
                }
                else {
                    debugPrint("ERROR");
                    let invalid = UIAlertController(title: "Invalid", message: "Your email was not valid. Your account could not be created", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                    invalid.addAction(okAction)
                    self.present(invalid, animated: true, completion: nil)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func CreateProfile(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        ref = Database.database().reference()
        ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/Users").child(NewUser.userID).setValue(newPostData) { (error) in
            completion(false, error)
        }
        completion(true, nil)
        
    }
    
    
}

class CreateAccountViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var Position: UITextField!
    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var BrotherName: UITextField!
    @IBOutlet weak var School: UITextField!
    @IBOutlet weak var Degree: UITextField!
    @IBOutlet weak var GradDate: UITextField!
    @IBOutlet weak var Birthday: UITextField!
    @IBOutlet weak var ImageButton: UIButton!
    @IBOutlet weak var emailEdit: UITextField!
    
    @IBOutlet weak var Cancel: UIButton!
    var ref: DatabaseReference!
    let defaults:UserDefaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    
    let positionOptions = ["Brother", "Alumni", "Pledge", "LT Master", "Scribe", "Exchequer", "Pledge Master", "Rush Chair"]
    var existingBrotherNames: [String] = []
    var notifId = ""
    var defaultEmail = ""
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var Create: UIButton!
    @IBAction func CreateAccount(_ sender: Any) {
        if FirstName.text! == "" || LastName.text! == "" || BrotherName.text! == "" || School.text! == "" || Degree.text! == "" || GradDate.text! == "" || Birthday.text! == "" {
            let empty = UIAlertController(title: "Empty Field", message: "No Fields can be left empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            empty.addAction(okAction)
            self.present(empty, animated: true, completion: nil)
            return
        }
        if (LoggedIn.User["Username"] as? String) == nil || (LoggedIn.User["Position"] as? String) != "Master" {
            if FirstName.text! == "Master" || LastName.text! == "Master" || BrotherName.text! == "Master" || FirstName.text! == "master" || LastName.text! == "master" || BrotherName.text! == "master" {
                let masterNotAllowed = UIAlertController(title: "Warning!", message: "You can not use the name Master in your profile.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                masterNotAllowed.addAction(okAction)
                self.present(masterNotAllowed, animated: true, completion: nil)
                return
            }
        }
        
        //validate birthday --> Disable copy paste
        //validate grad date
        
        //avoid duplicate usernames
        if (LoggedIn.User["Username"] as? String) == nil { 
            if existingBrotherNames.index(of: BrotherName.text!) != nil {
                let invalid = UIAlertController(title: "Invalid", message: "This brother name already exists", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                invalid.addAction(okAction)
                self.present(invalid, animated: true, completion: nil)
                return
            }
        }
        
        if (LoggedIn.User["Position"] as? String) != "Master" {
            if positionOptions.index(of: Position.text!) == nil {
                let invalid = UIAlertController(title: "Invalid", message: "Invalid position", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                invalid.addAction(okAction)
                self.present(invalid, animated: true, completion: nil)
                return
            }
        }
        if self.pickedImage == nil {
            let invalid = UIAlertController(title: "Picture", message: "Please post a picture along with your profile details", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            return
        }
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator, view: self.view);
        var image = "Empty"
        if self.pickedImage != nil {
            if NewUser.edit == false {
            image = NewUser.userID
            }
            else {
                image = LoggedIn.User["UserID"] as! String
            }
            let storageRef = Storage.storage().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/ProfilePictures/\(image).jpg")
            if let uploadData = UIImageJPEGRepresentation(self.pickedImage!, 0.5){
                let newMetadata = StorageMetadata()
                newMetadata.contentType = "image/jpeg";

                storageRef.putData(uploadData, metadata: newMetadata, completion:{ (metadata, error) in
           
                    if error != nil {
                        GenericTools.Logger(data: "\n Error initializing block value: \(error!)")
                    }
                    if let imageURL = metadata?.downloadURL()?.absoluteString{
                        image = imageURL
                    }
                    var username = ""
                    if self.Position.text == "Master" {
                        username = "Master"
                    }
                    else {
                        username = self.BrotherName.text!
                    }
                    if NewUser.edit == false {
                    let newUserData = [
                        "BrotherName": self.BrotherName.text!,
                        "Degree": self.Degree.text!,
                        "First Name": self.FirstName.text!,
                        "Last Name": self.LastName.text!,
                        "School": self.School.text!,
                        "GraduationDate": self.GradDate.text!,
                        "Birthday": self.Birthday.text!,
                        "Position": self.Position.text!,
                        "Username": username,
                        "Email": NewUser.email,
                        "Image": image,
                        "UserID": NewUser.userID,
                        "NotificationId": self.notifId,
                        "Validated": false
                        ] as [String : Any]
                    
                        self.CreateProfile(newPostData: newUserData) {(success ,error) in
                            self.activityIndicator.stopAnimating();
                            UIApplication.shared.endIgnoringInteractionEvents();
                            if error != nil {
                                GenericTools.Logger(data: "\n Error updating user accound: \(error!)")
                                let invalid = UIAlertController(title: "Internal Error", message: "Could not succesfully update your account", preferredStyle: UIAlertControllerStyle.alert)
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                                invalid.addAction(okAction)
                                self.present(invalid, animated: true, completion: nil)
                                return
                            }
                        self.performSegue(withIdentifier: "ProfileCreated", sender: self)
                      }
                    }
                    else {
                        var changedUser = ""
                        var validated = false
                        if (LoggedIn.User["Position"] as! String) == "Master" {
                            changedUser = "Master"
                            validated = true
                        }
                        else {
                            changedUser = self.BrotherName.text!
                        }
                        
                        if let notifId = self.defaults.string(forKey: "NotificationId") {
                            self.notifId = notifId
                        }
                        else {
                            self.notifId = ""
                        }
                        let updatedData = [
                            "BrotherName": self.BrotherName.text!,
                            "Degree": self.Degree.text!,
                            "First Name": self.FirstName.text!,
                            "Last Name": self.LastName.text!,
                            "School": self.School.text!,
                            "GraduationDate": self.GradDate.text!,
                            "Birthday": self.Birthday.text!,
                            "Position": self.Position.text!,
                            "Username": changedUser,
                            "Email": self.emailEdit.text!,
                            "Image": image,
                            "UserID": LoggedIn.User["UserID"] as! String,
                            "NotificationId": self.notifId,
                            "Validated": validated
                            ] as [String : Any]
                        
                        if self.defaultEmail != self.emailEdit.text! {
                            Auth.auth().currentUser!.updateEmail(to: self.emailEdit.text!) { error in
                                if(error != nil) {
                                GenericTools.Logger(data: "Could not update email")
                                    self.activityIndicator.stopAnimating();
                                    UIApplication.shared.endIgnoringInteractionEvents();
                                    let invalid = UIAlertController(title: "Email", message: "Could not update email", preferredStyle: UIAlertControllerStyle.alert)
                                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                                    invalid.addAction(okAction)
                                    self.present(invalid, animated: true, completion: nil)
                                }
                            }
                        }
                        
                        self.CreateProfile(newPostData: updatedData) {(success ,error) in
                            self.activityIndicator.stopAnimating();
                            UIApplication.shared.endIgnoringInteractionEvents();
                            if error != nil {
                            GenericTools.Logger(data: "\n Could not update account \(error!)")
                            self.dismiss(animated: true, completion: nil)
                            let invalid = UIAlertController(title: "Error", message: "Could not update account", preferredStyle: UIAlertControllerStyle.alert)
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                            invalid.addAction(okAction)
                            self.present(invalid, animated: true, completion: nil)
                            }
                            else {
                                let valid = UIAlertController(title: "Success", message: "Updated account", preferredStyle: UIAlertControllerStyle.alert)
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                                valid.addAction(okAction)
                                self.present(valid, animated: true, completion: nil)
                            }
                        }
                    }
                
                })
                
            }
         }
    }
    
    func CreateProfile(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        var id = ""
        if LoggedIn.User["Username"] != nil {
            id = LoggedIn.User["UserID"] as! String
        }
        else {
            id = NewUser.userID
        }
        Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Users").child(id).setValue(newPostData)
        completion(true, nil)

    }
    
    @IBAction func GetImage(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            ImageButton.contentMode = .center //this aint right
            
            ImageButton.setBackgroundImage(editedImage, for: .normal)
            ImageButton.setTitle("", for: .normal)
            self.pickedImage = editedImage
        }
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ImageButton.contentMode = .center //this aint right
            ImageButton.setBackgroundImage(pickedImage, for: .normal)
            ImageButton.setTitle("", for: .normal)
            self.pickedImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func getBrotherNames() {
            ref = Database.database().reference()
            self.ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/Users").observe(.value, with: { (snapshot) in
                for snap in snapshot.children{
                    if let childSnapshot = snap as? DataSnapshot
                    {
                        if let postDictionary = childSnapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                            if let brotherName = postDictionary["BrotherName"] as? String {
                            self.existingBrotherNames.append(brotherName)
                            }
                        }
                    }
                }
            }){ (error) in
                GenericTools.Logger(data: "\n Error getting brother names: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getBrotherNames()
        Create.layer.cornerRadius = 5
        ImageButton.layer.borderColor = UIColor.black.cgColor
        ImageButton.layer.borderWidth = 1
        let pickerView = UIPickerView()
        emailEdit.layer.cornerRadius = 5
        
        if LoggedIn.User["Position"] as! String == "Master" {
            Position.isUserInteractionEnabled = false
            Position.isEnabled = false

        }
        
        pickerView.delegate = self
        imagePicker.delegate = self

        Position.inputView = pickerView
        
        if NewUser.edit == true {
            if LoggedIn.User["Position"] as? String == "Master" {
                Position.isUserInteractionEnabled = false
                Position.textColor = UIColor(displayP3Red: 255, green: 224, blue: 0, alpha: 1)
            }
            emailEdit.isHidden = false
            Cancel.isHidden = false
            emailEdit.text = LoggedIn.User["Email"] as? String
            FirstName.text = LoggedIn.User["First Name"] as? String
            LastName.text = LoggedIn.User["Last Name"] as? String
            BrotherName.text = LoggedIn.User["BrotherName"] as? String
            School.text = LoggedIn.User["School"] as? String
            Degree.text = LoggedIn.User["Degree"] as? String
            GradDate.text = LoggedIn.User["GraduationDate"] as? String
            Birthday.text = LoggedIn.User["Birthday"] as? String
            Position.text = LoggedIn.User["Position"] as? String
            for member in mMembers.MemberList {
                if member.id == (LoggedIn.User["UserID"] as? String) {
                    ImageButton.setBackgroundImage(member.picture, for: .normal)
                    ImageButton.setTitle("", for: .normal)
                    self.pickedImage = member.picture
                }
            }
            
            defaultEmail = emailEdit.text!
            Create.setTitle("Update Profile", for: .normal)
        }

        // Do any additional setup after loading the view.
    }

    
    @IBAction func ExpectedGrad(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChangedGrad), for: UIControlEvents.valueChanged)
    }


    
    @IBAction func Birthday(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChangedBirthday), for: UIControlEvents.valueChanged)
    }

    
    func datePickerValueChangedGrad(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        GradDate.text = dateFormatter.string(from: sender.date)
        
    }
    
    func datePickerValueChangedBirthday(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        Birthday.text = dateFormatter.string(from: sender.date)
        
    }

    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return positionOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return positionOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Position.text = positionOptions[row]
    }

}
