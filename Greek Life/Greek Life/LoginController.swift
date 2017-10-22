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
    
    var ref: DatabaseReference!
    var email:String = ""
    //var User: [String: Any] = [:] //This value stores the entire user object as long as the user exists

    @IBAction func Login(_ sender: Any) {
        if(Username.text == ""){
            self.LoginAlert(problem: "Empty");
        }
        else{
            validateUsername();
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
    
    func LoginAlert(problem: String) {
        if(problem == "Empty"){
        let alert = UIAlertController(title: "Empty", message: "Please enter your username", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            alert.view.tintColor = UIColor.yellow;
        
        self.present(alert, animated: true, completion: nil)
        }
        if(problem == "Incorrect"){
            let alert = UIAlertController(title: "Incorrect", message: "The username you entered is incorrect", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if(problem == "Invalid"){
            let alert = UIAlertController(title: "Invalid", message: "The password you entered is incorrect", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func getEmail(name: String, completion: @escaping (Bool, Any?, Error?) -> Void){
        var userEmail = ""
        ref = Database.database().reference()
        self.ref.child("Users").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? [String:Any] {
                print("email retrieved");
                LoggedIn.User = user;
                userEmail = user["email"] as! String;
                completion(true, userEmail, nil);
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
                print(LoggedIn.User)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LoginSuccess"){
            
            if let destination = segue.destination as? FirstViewController{
                destination.User = (sender as? [String: Any?])!
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Username.delegate = self;
        self.Password.delegate = self;
        
        let pic = BackgroundPic;
        pic?.image = UIImage(named: "AEPiDocs/School.png");
        pic?.alpha = 0.3;
        
//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "AEPiDocs/School.png")!);
//        self.view.alpha = 0.3;
        
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
        

        Title_Pic.image = UIImage(named: "AEPiDocs/Logos/AEPi_Letters_Blue.png");

        User_Icon.image = UIImage(named: "AEPiDocs/user_icon.png");
        Password_Icon.image = UIImage(named: "AEPiDocs/password_icon.png");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
