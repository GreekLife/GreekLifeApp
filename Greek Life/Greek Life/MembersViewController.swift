//
//  MembersViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-07.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class Member {
    
    var brotherName: String
    var first: String
    var last: String
    var degree: String
    var status: Bool
    var birthday: String
    var email: String
    var graduateDay: String
    var picture: UIImage
    var position: String
    var school: String
    var id: String
    var imageURL: String
    
    init(brotherName: String, first: String, last: String, degree: String, status: Bool, birthday: String, email: String, graduate: String, picture: UIImage, ImageURL: String, position: String, school: String, id: String){
        self.brotherName = brotherName
        self.first = first
        self.last = last
        self.degree = degree
        self.status = status
        self.birthday = birthday
        self.email = email
        self.graduateDay = graduate
        self.picture = picture
        self.position = position
        self.school = school
        self.id = id
        self.imageURL = ImageURL
    }
    
    
}

struct mMembers {
    static var MemberList: [Member] = []
    static var memberObj: Member?

}

class MemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MemberImage: UIImageView!
    @IBOutlet weak var MemberName: UILabel!
    @IBOutlet weak var MemberSpecialty: UILabel!
}

class MembersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var CollectionView: UICollectionView!
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mMembers.MemberList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mMembers.memberObj = mMembers.MemberList[indexPath.row]
        performSegue(withIdentifier: "ShowMember", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let member = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as! MemberCollectionViewCell
        member.MemberSpecialty.text = mMembers.MemberList[indexPath.row].degree
        member.MemberName.text = "\(mMembers.MemberList[indexPath.row].first) \(mMembers.MemberList[indexPath.row].last)"
        member.MemberImage.image = mMembers.MemberList[indexPath.row].picture
        
        return member
    }

}

class MemberProfile: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var First: UILabel!
    @IBOutlet weak var Last: UILabel!
    @IBOutlet weak var Brother: UILabel!
    @IBOutlet weak var Graduation: UILabel!
    @IBOutlet weak var School: UILabel!
    @IBOutlet weak var Save: UIButton!
    
    @IBOutlet weak var mPosition: UITextField!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Birthday: UILabel!
    @IBOutlet weak var Degree: UILabel!
    @IBOutlet weak var Email: UILabel!
    @IBOutlet weak var Position: UILabel!
    @IBOutlet weak var mBrother: UITextField!
    
    let user = LoggedIn.User["Username"] as? String
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Save(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        Database.database().reference().child("Users/\(mMembers.memberObj!.id)/Position").setValue(mPosition.text)
        Database.database().reference().child("Users/\(mMembers.memberObj!.id)/BrotherName").setValue(mBrother.text)
        Database.database().reference().child("Users/\(mMembers.memberObj!.id)/Validated").setValue(true)
        
        mMembers.memberObj?.brotherName = mBrother.text!
        mMembers.memberObj?.position = mPosition.text!
        mMembers.memberObj?.status = true
        let success = UIAlertController(title: "Success", message: "The user has been updated and validated", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
        success.addAction(okAction)
        self.present(success, animated: true, completion: nil)
        self.activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
        return
    }
    
    let positionOptions = ["Brother", "Alumni", "Pledge", "LT Master", "Scribe", "Exchequer", "Pledge Master", "Rush Chair"]

    override func viewDidLoad() {
        super.viewDidLoad()
        Save.layer.cornerRadius = 10
        let pickerView = UIPickerView()
        pickerView.delegate = self
        mPosition.inputView = pickerView
        
        First.text = mMembers.memberObj?.first
        Last.text = mMembers.memberObj?.last
        Brother.text = "Brother \(mMembers.memberObj?.brotherName ?? "")"
        Graduation.text = mMembers.memberObj?.graduateDay
        School.text = mMembers.memberObj?.school
        Birthday.text = mMembers.memberObj?.birthday
        Degree.text = mMembers.memberObj?.degree
        Email.text = mMembers.memberObj?.email
        Position.text = mMembers.memberObj?.position
        if mMembers.memberObj?.status == false {
            Status.text = "Unverified"
        }
        else {
            Status.text = "Verified"
        }
        if let pic = mMembers.memberObj?.picture {
            Image.image = pic
        }
        
        if self.user == "Master" && mMembers.memberObj?.position != "Master" {
            Position.isHidden = true
            mPosition.frame.origin.y = Position.frame.origin.y
            mPosition.frame.origin.x = Position.frame.origin.x
            mPosition.frame.size.width = Position.frame.size.width
            mPosition.isHidden = false
            mPosition.text = Position.text
            
            Brother.isHidden = true
            mBrother.frame.origin.y = Brother.frame.origin.y
            mBrother.frame.origin.x = Brother.frame.origin.x
            mBrother.frame.size.width = Brother.frame.size.width
            mBrother.isHidden = false
            mBrother.text = Brother.text
            
        }
        else {
            Save.isHidden = true
            mPosition.isHidden = true
            mBrother.isHidden = true
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return positionOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return positionOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        mPosition.text = positionOptions[row]
    }
    
}
