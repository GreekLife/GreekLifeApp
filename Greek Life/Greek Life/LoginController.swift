//
//  LoginController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-21.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct LoggedIn {
    static var User: [String: Any] = [:]
}

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Title_Pic: UIImageView!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var LoginLabel: UIButton!
    
    @IBOutlet weak var CodeBox1: UITextField!
    @IBOutlet weak var CodeBox2: UITextField!
    @IBOutlet weak var CodeBox3: UITextField!
    @IBOutlet weak var CodeBox4: UITextField!
    
    
    @IBOutlet weak var Login: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    let defaults:UserDefaults = UserDefaults.standard
    var ref: DatabaseReference!
    var email:String = ""
    var NotifId = ""
    
    @IBOutlet weak var ForgotPassword: UIButton!
    @IBOutlet weak var CreateAccount: UIButton!
    @IBAction func CreateAccount(_ sender: Any) {
        NewUser.edit = false
    
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        let enteredCode = CodeBox1.text! + CodeBox2.text! + CodeBox3.text! + CodeBox4.text!
        
        //should actually be testing for nil on type cast
        if CodeBox1.text == "" || CodeBox2.text == "" || CodeBox3.text == "" || CodeBox4.text == "" {
            self.CodeBox1.becomeFirstResponder()
            let alert = UIAlertController(title: "Code", message: "You must enter the code. You can get the correct code from your master.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return
        }
        ref = Database.database().reference()
        ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/CreateAccount/GeneratedKey").observeSingleEvent(of: .value, with: { (snapshot) in
            let code = snapshot.value as? String
            if code == enteredCode {
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                self.performSegue(withIdentifier: "CreateAccount", sender: self)
            }
            else {
                let alert = UIAlertController(title: "Code", message: "You entered the incorrect code. You can get the correct code from your master.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
            }
        }) {(error) in
            print(error.localizedDescription)
            GenericTools.Logger(data: "\n Error entering code to create an account!")
            let alert = UIAlertController(title: "Error", message: "An internal server error occured", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        }
    }
    
    
    @IBAction func ForgotPassword(_ sender: Any) {
        performSegue(withIdentifier: "ForgotPassword", sender: self)
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count > 0 {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        return
    }

    
    @IBAction func Login(_ sender: Any?) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if(Username.text == ""){
            self.LoginAlert(problem: "Empty");
        }
        else{
            if Reachability.isConnectedToNetwork(){
                validateUsername();
            }else{
                let internetError = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
                internetError.textColor = .red
                internetError.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                internetError.textAlignment = .center
                internetError.text = "You're not connected to the internet"
                self.view.addSubview(internetError)
                GenericTools.Logger(data: "\n Internet Connection not Available!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                internetError.isHidden = true
                }
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
            }
        }
    }
    
    func validateUsername(){
        self.getEmail(name: Username.text!){(success, response, error) in
            guard success, let tempEmail = response as? String else{
                self.LoginAlert(problem: "Incorrect");
                GenericTools.Logger(data: "\n couldn't log in: \(String(describing: error))")

                return;
            }
            self.email = tempEmail
            self.validateEmail();
        }
        
    }
    
    func LoginAlert(problem: String) { //Revisit what sends alerts.
        if(problem == "Empty"){
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        let alert = UIAlertController(title: "Empty", message: "Please enter your username", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        }
        if(problem == "Incorrect"){
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            let alert = UIAlertController(title: "Incorrect", message: "The username you entered is incorrect", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if(problem == "Invalid"){
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            let alert = UIAlertController(title: "Invalid", message: "The password you entered is incorrect", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func getEmail(name: String, completion: @escaping (Bool, Any?, Error?) -> Void){
        ref = Database.database().reference()
        self.ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/Users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? [String:[String:Any]] {
                for (key, _ ) in user {
                    if (user[key]!["Username"] as! String) == name || (user[key]!["Email"] as! String) == name {
                        print("User found");
                        LoggedIn.User = user[key]!;
                        let userEmail = user[key]!["Email"] as! String;
                        completion(true, userEmail, nil);
                        return
                    }
                }
                completion(false, nil, nil)
            }
            else{
                print("The username is incorrect.");
                completion(false, nil, nil)
            }
        }){ (error) in
            GenericTools.Logger(data: "\n Could not connect to firebase auth to validate entry")
            completion(false, nil, nil)
        }
    }
    
    func validateEmail(){
        Auth.auth().signIn(withEmail: email, password: Password.text!) { (user, Error) in
            if(user != nil){
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                self.defaults.set(self.Username.text!, forKey: "Username")
                self.defaults.set(self.Password.text!, forKey: "Password")
                self.Password.text = ""
                let user: [String: Any] = [
                    "Id": self.NotifId,
                    "UserId": LoggedIn.User["UserID"] as! String,
                    "Username": LoggedIn.User["Username"] as! String
                ]
                if self.NotifId != "" {
                    Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/NotificationIds/IOS/\(self.NotifId)").setValue(user){(error) in
                        GenericTools.Logger(data: "\n Could not add notification id to list: \(error)")
                    }
                    Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Users/"+(LoggedIn.User["UserID"] as! String)+"/NotificationId").setValue(self.NotifId){(error) in
                        GenericTools.Logger(data: "\n Could not change users notification id: \(error)")
                    }
                }
                self.performSegue(withIdentifier: "LoginSuccess", sender: LoggedIn.User);
            }
            else {
                if let myError = Error?.localizedDescription{
                    GenericTools.Logger(data: "\n Could not authenticate: \(myError)")
                }
                else {
                    GenericTools.Logger(data: "\n Could not authenticate")
                }
                LoggedIn.User = [:];
                self.LoginAlert(problem: "Invalid");
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LoadConfiguration.loadConfig(); //load config and store in structure to always be available.
        if let notifId = defaults.string(forKey: "NotificationId") {
            self.NotifId = notifId
            if let username = defaults.string(forKey: "Username") {
                self.Username.text = username
                if let password = defaults.string(forKey: "Password") {
                    self.Password.text = password
                    self.Login(nil)
                }
            }
        }
        else {
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            let alert = UIAlertController(title: "Notifications", message: "You must accept notifications to sign in", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        CodeBox1.delegate = self
        CodeBox2.delegate = self
        CodeBox3.delegate = self
        CodeBox4.delegate = self

        //self.addBackground(imageName: "AEPiDocs/School.png", contextMode: .scaleAspectFit);
        Username.layer.borderColor = UIColor.black.cgColor
        Username.layer.borderWidth = 1
        Username.layer.cornerRadius = 5
        
        Password.layer.borderColor = UIColor.black.cgColor
        Password.layer.borderWidth = 1
        Password.layer.cornerRadius = 5
        
    }

}

class ForgotPassword: UIViewController {
    
    @IBOutlet weak var ResetPassword: UIButton!
    @IBOutlet weak var Email: UITextField!
    
    
    @IBAction func ResetPassword(_ sender: Any) {
        if Email.text == "" {
            let alert = UIAlertController(title: "Invalid", message: "Please enter an email address", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            Auth.auth().sendPasswordReset(withEmail: Email.text!) { error in
                if error != nil {
                let alert = UIAlertController(title: "Error", message: "Account could not be reset", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                GenericTools.Logger(data: "\n Could not undergo reset password process \(error!)")
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ResetPassword.layer.cornerRadius = 5
    }
    
}

