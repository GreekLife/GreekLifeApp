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

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var BackgroundPic: UIImageView!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password_Icon: UIImageView!
    @IBOutlet weak var User_Icon: UIImageView!
    @IBOutlet weak var Title_Pic: UIImageView!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var LoginLabel: UIButton!
    
    var ref: DatabaseReference!
    
    @IBAction func Login(_ sender: Any) {
        validate();
    }
    
    func EmptyStringAlert() {
        let alert = UIAlertController(title: "Alert", message: "Please enter your username", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getEmail(name: String) -> String{
        var email = ""
        ref = Database.database().reference()
        self.ref.child("Users").child(name).observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? [String:Any] {
                print("email retrieved");
                email = user["email"] as! String;
                print(email)
                return;
            }
            else{
                print("email could not be retrieved from the user.");
            
            }
        }){ (error) in
            print("Could not retrieve object from database because: ");
            print((Any).self);
        }
        return email;
    }
    
    func validate(){
        if(Username.text == ""){
            EmptyStringAlert();
        }
        
        let email = getEmail(name: Username.text!);
        print(email)
        if(email == ""){
            return;
        }
        performSegue(withIdentifier: "LoginSuccess", sender: nil)
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
