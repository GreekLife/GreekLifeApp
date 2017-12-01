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
}

class AccountDetails: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var RePassword: UITextField!
    @IBOutlet weak var GoToProfile: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    
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
        Auth.auth().createUser(withEmail: Email.text!, password: Password.text!) { (user, Error) in
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
                if (Error == nil) {
                        if(user != nil){
                            print("Account created")
                            self.performSegue(withIdentifier: "Profile", sender: self);
                             NewUser.email = self.Email.text!
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class CreateAccountViewController: UIViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Position: UITextField!
    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var BrotherName: UITextField!
    @IBOutlet weak var School: UITextField!
    @IBOutlet weak var Degree: UITextField!
    @IBOutlet weak var GradDate: UITextField!
    @IBOutlet weak var Birthday: UITextField!
    @IBOutlet weak var ImageButton: UIButton!
    
    var ref: DatabaseReference!
    
    let imagePicker = UIImagePickerController()
    var pickedImage: UIImage!
    
    let positionOptions = ["Brother", "Alumni", "Pledge", "LT Master", "Scribe", "Exchequer", "Pledge Master", "Rush Chair"]
    
    @IBOutlet weak var Create: UIButton!
    @IBAction func CreateAccount(_ sender: Any) {
        if FirstName.text! == "" || LastName.text! == "" || BrotherName.text! == "" || School.text! == "" || Degree.text! == "" || GradDate.text! == "" || Birthday.text! == "" {
            let empty = UIAlertController(title: "Empty Field", message: "No Fields can be left empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            empty.addAction(okAction)
            self.present(empty, animated: true, completion: nil)
            return
        }
        //validate birthday
        //validate grad date
        //validate position
        if positionOptions.index(of: Position.text!) == nil {
            let invalid = UIAlertController(title: "Invalid", message: "Invalid position", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            return
        }
        if self.pickedImage == nil {
            let invalid = UIAlertController(title: "Picture", message: "Please post a picture along with your profile details", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            invalid.addAction(okAction)
            self.present(invalid, animated: true, completion: nil)
            return
        }
        var image = "Empty"
        if self.pickedImage != nil {
            let imageName = "\(self.BrotherName.text!).png"
            let storageRef = Storage.storage().reference().child(imageName)
            if let uploadData = UIImagePNGRepresentation(self.pickedImage!){
                storageRef.putData(uploadData, metadata: nil, completion:{ (metadata, error) in
                    if error != nil {
                        print(error!)
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
                    let newUserData = [
                        "BrotherName": self.BrotherName.text!,
                        "Degree": self.Degree.text!,
                        "First Name": self.FirstName.text!,
                        "Last Name": self.LastName.text!,
                        "School": self.School.text!,
                        "GraduationDate": self.GradDate.text!,
                        "Birthday": self.Birthday.text!,
                        "Postition": self.Position.text!,
                        "Username": username,
                        "Email": NewUser.email,
                        "Image": image
                    ]
                    
                    self.CreateProfile(newPostData: newUserData) {(success ,error) in
                        self.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "ProfileCreated", sender: self)
                    }
                
                })
                
            }
        }
    }
    
    func CreateProfile(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        ref = Database.database().reference()
        ref.child("Users").child(self.BrotherName.text!).setValue(newPostData)
        completion(true, nil)
    }
    
    @IBAction func GetImage(_ sender: Any) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            ImageButton.contentMode = .scaleAspectFill //this aint right
            ImageButton.setBackgroundImage(pickedImage, for: .normal)
            ImageButton.setTitle("", for: .normal)
            self.pickedImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Create.layer.cornerRadius = 5
        ImageButton.layer.borderColor = UIColor.black.cgColor
        ImageButton.layer.borderWidth = 1
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        imagePicker.delegate = self

        Position.inputView = pickerView

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
