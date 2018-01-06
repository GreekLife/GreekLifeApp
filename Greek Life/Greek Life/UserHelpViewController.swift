//
//  UserHelpViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-12-17.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import MessageUI

class UserHelpViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var EmailText: UITextView!
    @IBOutlet weak var SendEmail: UIButton!
    
    @IBAction func SendEmail(_ sender: Any) {
        if EmailText.text == "" {
            let empty = UIAlertController(title: "Empty", message: "You cannot send an empty email", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            empty.addAction(okAction)
            self.present(empty, animated: true, completion: nil)
            return
        }
        sendEmail()
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("BETA: Message from user")
            mail.setToRecipients(["fraternity.ios.dev@gmail.com"])
            mail.setMessageBody(EmailText.text, isHTML: true)
            
            present(mail, animated: true)
        } else {
            let error = UIAlertController(title: "Error", message: "You must enable email settings to send an email", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            error.addAction(okAction)
            self.present(error, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        EmailText.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailText.layer.cornerRadius = 10
        SendEmail.layer.cornerRadius = 10
    }

}
