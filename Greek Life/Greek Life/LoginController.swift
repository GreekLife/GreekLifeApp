//
//  LoginController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-21.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var BackgroundPic: UIImageView!
    @IBOutlet weak var Letters_Pic: UIImageView!
    @IBOutlet weak var LoginLabel: UIButton!
    @IBAction func Login(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pic = BackgroundPic;
        pic?.image = UIImage(named: "AEPiDocs/school");
        pic?.alpha = 0.3;
        
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

        Letters_Pic.image = UIImage(named: "AEPiDocs/Logos/AEPi_Letters_Blue.png");
        
        LoginLabel.layer.cornerRadius = LoginLabel.frame.height / 2;
        let tempColor = LoginLabel.layer.backgroundColor?.copy(alpha: 0.5);
        LoginLabel.layer.backgroundColor = tempColor;
        

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
