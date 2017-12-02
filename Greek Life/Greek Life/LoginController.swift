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

struct LoggedIn {
    static var User: [String: Any] = [:]
}



class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var BackgroundPic: UIImageView!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password_Icon: UIImageView!
    @IBOutlet weak var User_Icon: UIImageView!
    @IBOutlet weak var Title_Pic: UIImageView!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var LoginLabel: UIButton!
    
    @IBOutlet weak var CodeView: UIView!
    @IBOutlet weak var CodeBox1: UITextField!
    @IBOutlet weak var CodeBox2: UITextField!
    @IBOutlet weak var CodeBox3: UITextField!
    @IBOutlet weak var CodeBox4: UITextField!
    @IBOutlet weak var Errors: UITextField!
    
    @IBOutlet weak var CancelCode: UIButton!
    
    @IBOutlet weak var EnterCode: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    
    var ref: DatabaseReference!
    var email:String = ""

    @IBOutlet weak var BlurBackground: UIVisualEffectView!
    
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var ForgotPassword: UIButton!
    @IBOutlet weak var CreateAccount: UIButton!
    @IBAction func CreateAccount(_ sender: Any) {
        Errors.layer.borderColor = UIColor.clear.cgColor
        Errors.layer.borderWidth = 0
        Errors.isHidden = false
        text.isHidden = false
        BlurBackground.isHidden = false
        BlurBackground.effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        EnterCode.layer.cornerRadius = 5
        CodeView.isHidden = false
        CancelCode.isHidden = false
        EnterCode.isHidden = false
        CodeBox1.text = "0"
        CodeBox2.text = "0"
        CodeBox3.text = "0"
        CodeBox4.text = "0"
    }
    @IBAction func ForgotPassword(_ sender: Any) {
        performSegue(withIdentifier: "ForgotPassword", sender: self)
        
    }
    @IBAction func EnterCode(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        let enteredCode = CodeBox1.text! + CodeBox2.text! + CodeBox3.text! + CodeBox4.text!
        
        //should actually be testing for nil on type cast
        if CodeBox1.text == "" || CodeBox2.text == "" || CodeBox3.text == "" || CodeBox4.text == "" {
            return
        }
        ref = Database.database().reference()
        ref.child("CreateAccount").child("GeneratedKey").observeSingleEvent(of: .value, with: { (snapshot) in
            let code = snapshot.value as? String
            if code == enteredCode {
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                self.performSegue(withIdentifier: "CreateAccount", sender: self)
            }
            else {
                self.Errors.text = "You entered the incorrect code"
                let delay = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.Errors.text = ""
                }
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
            }
        }) {(error) in
            print(error.localizedDescription)
            print("Could not read code from database")
            self.Errors.text = "An error occured"
            let delay = DispatchTime.now() + 3 
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.Errors.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.EnterCode.isEnabled = true
        if textField.text == "" {
            textField.text = "0"
            return
        }
        let val = Int(textField.text!)
        if val == nil {
            textField.text = "0"
            return
        }
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
        self.EnterCode.isEnabled = false
        return
    }

    
    @IBAction func CancelCode(_ sender: Any) {
        Errors.isHidden = true
        text.isHidden = true
        CancelCode.isHidden = true
        EnterCode.isHidden = true
        BlurBackground.isHidden = true
        CodeView.isHidden = true
        CodeBox1.text = ""
        CodeBox2.text = ""
        CodeBox3.text = ""
        CodeBox4.text = ""
    }
    
    @IBAction func Login(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if(Username.text == ""){
            self.LoginAlert(problem: "Empty");
        }
        else{
            if Reachability.isConnectedToNetwork(){
                print("Internet Connection Succesful!")
                validateUsername();
            }else{
                let internetError = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
                internetError.textColor = .red
                internetError.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                internetError.textAlignment = .center
                internetError.text = "You're not connected to the internet"
                self.view.addSubview(internetError)
                print("Internet Connection not Available!")
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
        self.ref.child("Users").observe(.value, with: { (snapshot) in
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
            print("Could not retrieve object from database");
            completion(false, nil, nil)
        }
    }
    
    func validateEmail(){
        Auth.auth().signIn(withEmail: email, password: Password.text!) { (user, Error) in
            if(user != nil){
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
                self.performSegue(withIdentifier: "LoginSuccess", sender: LoggedIn.User);
            }
            else {
                if let myError = Error?.localizedDescription{
                    debugPrint(myError);
                }
                else {
                    debugPrint("ERROR");
                }
                LoggedIn.User = [:];
                self.LoginAlert(problem: "Invalid");
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LoadConfiguration.loadConfig(); //load config and store in structure to always be available.
        CodeBox1.delegate = self
        CodeBox2.delegate = self
        CodeBox3.delegate = self
        CodeBox4.delegate = self
        
        let pic = BackgroundPic;
        pic?.image = UIImage(named: "Docs/School.png");
        pic?.alpha = 0.3;
        
        //self.addBackground(imageName: "AEPiDocs/School.png", contextMode: .scaleAspectFit);
        
        Username.alpha = 0.4;
        Username.backgroundColor = .black;
        Username.backgroundColor?.withAlphaComponent(0.3);
        let userplace = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor(white: 1, alpha: 1.0)]);
        Username.attributedPlaceholder = userplace;
        Username.textColor = .white;
        
        Password.alpha = 0.4;
        Password.backgroundColor = .black;
        Password.backgroundColor?.withAlphaComponent(0.3);
        let passwordplace = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName : UIColor(white: 1, alpha: 1.0)]);
        Password.attributedPlaceholder = passwordplace;
        Password.textColor = .white;
        
        LoginLabel.layer.cornerRadius = LoginLabel.frame.height / 2;
        LoginLabel.alpha = 0.7
        
        CreateAccount.layer.cornerRadius = LoginLabel.frame.height / 2;
        CreateAccount.alpha = 0.7
        
        ForgotPassword.layer.cornerRadius = LoginLabel.frame.height / 2;
        ForgotPassword.alpha = 0.7

        Title_Pic.image = UIImage(named: "Docs/Logos/Letters1.png");

        User_Icon.image = UIImage(named: "Docs/User_Icon.png");
        Password_Icon.image = UIImage(named: "Docs/Password_Icon.png");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                let alert = UIAlertController(title: "Invalid", message: "Account could not be reset", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print(error!)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

