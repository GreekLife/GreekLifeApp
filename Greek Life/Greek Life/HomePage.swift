//
//  HomePage.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-12-02.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class News: Comparable {
    
    static func ==(lhs: News, rhs: News) -> Bool {
        return lhs.postId == rhs.postId
    }
    static func < (lhs: News, rhs: News) -> Bool {
        return lhs.Epoch < rhs.Epoch
    }
    
    var Epoch: Double
    var Post: String
    var postId: String
    
    init(Epoch: Double, Post: String, Id: String) {
        self.Epoch = Epoch
        self.Post = Post
        self.postId = Id
    }
}

class HomePageCell: UITableViewCell {
    
    @IBOutlet weak var news: UITextView!
    
}

class HomePage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.NewsPosts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(position == "Master") {
            deleteNews(index: indexPath.row);
            TableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! HomePageCell
        cell.news.text = self.NewsPosts[indexPath.row].Post
        GenericTools.FrameToFitTextView(View: cell.news)
        self.newsHeight = cell.news.frame.origin.y + cell.news.frame.size.height
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.newsHeight
    }
    
    var buttonIdentifier = ""
    func deleteNews(index: Int) {
        if Reachability.isConnectedToNetwork() == true {
            self.buttonIdentifier = self.NewsPosts[index].postId
            let verify = UIAlertController(title: "Alert!", message: "Are you sure you want to permanantly delete this post?", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: deleteNewsInternal)
            let destructorAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            verify.addAction(okAction)
            verify.addAction(destructorAction)
            self.present(verify, animated: true, completion: nil)
        }
        else {
            let error = Banner.ErrorBanner(errorTitle: "No Internet Connection Available")
            error.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.view.addSubview(error)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5){
            error.removeFromSuperview()
            }
            GenericTools.Logger(data: "\n Internet Connection not Available!")
        }
    }
    
    func deleteNewsInternal(action: UIAlertAction) {
        FirebaseDatabase.Database.database().reference(withPath: (Configuration.Config!["DatabaseNode"] as! String)+"/News").child(self.buttonIdentifier).removeValue(){ (error) in
            GenericTools.Logger(data: "\n Error writing news: \(error)")
        }
        self.TableView.reloadData()
    }
    
    
    
    @IBOutlet weak var InstantMessaging: UIButton!
    @IBOutlet weak var Forum: UIButton!
    @IBOutlet weak var Calendar: UIButton!
    @IBOutlet weak var Poll: UIButton!
    @IBOutlet weak var Members: UIButton!
    @IBOutlet weak var Profile: UIButton!
    @IBOutlet weak var GoogleDrive: UIButton!
    @IBOutlet weak var Info: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var MasterControls: UIBarButtonItem!
    @IBOutlet weak var Beta: UIBarButtonItem!
    
    var newsHeight: CGFloat = 0
    var ref: DatabaseReference!
    let defaults:UserDefaults = UserDefaults.standard
    let position = LoggedIn.User["Position"] as! String
    
    var NewsPosts: [News] = []
    
    @IBAction func Beta(_ sender: Any) {
        performSegue(withIdentifier: "Beta", sender: self)
    }
    @IBAction func MasterControls(_ sender: Any) {
        performSegue(withIdentifier: "MasterControls", sender: self)
    }
    @IBAction func Signout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GenericTools.Logger(data: "\n Succesfully signed out")
        } catch let signOutError as NSError {
            GenericTools.Logger(data: "\n Error signing out: \(signOutError)")
        }
        defaults.set(nil, forKey: "Password")
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func buttonClicked(sender: UIButton)
    {
        switch sender.tag {
        case 2:
            performSegue(withIdentifier: "InstantMessaging", sender: self)
            break;
        case 3:
            performSegue(withIdentifier: "Forum", sender: self)
            break;
        case 4:
            performSegue(withIdentifier: "Calendar", sender: self)
            break;
        case 5:
            performSegue(withIdentifier: "Poll", sender: self)
            break;
        case 6:
            performSegue(withIdentifier: "Members", sender: self)
            break;
        case 7:
            NewUser.edit = true
            performSegue(withIdentifier: "PersonalProfile", sender: self)
            break;
        case 8:
           // performSegue(withIdentifier: "GoogleDrive", sender: self)
            break;
        case 9:
            performSegue(withIdentifier: "Info", sender: self)
            break;
        case 10:
            performSegue(withIdentifier: "Beta", sender: self)
            break;
        default: ()
            break;
        }
    }
    
    func ReadNews(completion: @escaping (Bool) -> Void){
        ref = Database.database().reference()
        self.ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/News").observe(.value, with: { (snapshot) in
            self.NewsPosts.removeAll()
            for snap in snapshot.children{
                if let childSnapshot = snap as? DataSnapshot
                {
                  if let postDictionary = childSnapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                    if let post = postDictionary["Post"] as? String {
                        if let postId = postDictionary["PostId"] as? String {
                            if let date = postDictionary["Epoch"] as? Double {
                                let news = News(Epoch: date, Post: post, Id: postId)
                                self.NewsPosts.append(news)
                   }
                  }
                 }
                }
               }
             }
            completion(true);
            }){ (error) in
                GenericTools.Logger(data: "\n Error reading news from database: \(error)")
            completion(false)
        }
    }
    
    func UserIsBlocked(userId: String, completion: @escaping (Bool, Any?, Bool) -> Void) {
         Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Blocked/\(userId)").observe(.value, with: { (snapshot) in
                    if let postDictionary = snapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                        if let blocked = postDictionary["Blocked"] as? Bool {
                            if let delay = postDictionary["Delay"] as? Int {
                                    completion(blocked, delay, true)
                            }
                        }
                    }
         }){ (error) in
            GenericTools.Logger(data: "\n Error reading blocked user from database: \(error)")
            completion(false, nil, false)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let id = LoggedIn.User["UserID"] as! String
        self.UserIsBlocked(userId: id){(blocked, value, success) in
            if success == true {
                if blocked == true {
                    let time = String(describing: value)
                    let blocked = UIAlertController(title: "Get Wrecked", message: "Your Master has temporarily disabled your access. It will return in " + time + " minutes?", preferredStyle: .alert)
                   let presentViewController: UIViewController! = UIApplication.shared.keyWindow?.currentViewController()
                    presentViewController.present(blocked, animated: true, completion: nil)
                    let ban = (value as! Int) * 60
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(ban)){
                        blocked.dismiss(animated: true, completion: nil)
                        Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Blocked/\(id)").updateChildValues(["Blocked": false]) { (error) in
                            GenericTools.Logger(data: "\n Error editing blocked user in database: \(error)")
                        }
                    }
                }
            }
        }
        self.ReadNews(){(success) in
            guard success else {
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not get posts from database.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5){
                    BadPostRequest.removeFromSuperview()
                }
                GenericTools.Logger(data: "\n Could not get posts from database!")
                return
            }
            self.NewsPosts.sort()
            self.NewsPosts = mergeSorting.mergeSort(self.NewsPosts)
            self.TableView.reloadData()
        }
        
        if (LoggedIn.User["Position"] as! String) != "Master" {
            MasterControls.isEnabled = false
            MasterControls.image = UIImage(named: "")
        }
        //Add targets
        InstantMessaging.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Forum.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Calendar.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Poll.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Members.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Profile.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        GoogleDrive.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        Info.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)

        //Styles
        let color = UIColor(red: 70/255.0, green: 70/255.0, blue: 70/255.0, alpha: 1.0)
        InstantMessaging.layer.borderColor = color.cgColor
        InstantMessaging.layer.borderWidth = 1
        Forum.layer.borderColor = color.cgColor
        Forum.layer.borderWidth = 1
        Calendar.layer.borderColor = color.cgColor
        Calendar.layer.borderWidth = 1
        Poll.layer.borderColor = color.cgColor
        Poll.layer.borderWidth = 1
        Members.layer.borderColor = color.cgColor
        Members.layer.borderWidth = 1
        Profile.layer.borderColor = color.cgColor
        Profile.layer.borderWidth = 1
        GoogleDrive.layer.borderColor = color.cgColor
        GoogleDrive.layer.borderWidth = 1
        Info.layer.borderColor = color.cgColor
        Info.layer.borderWidth = 1

        self.getUsers(){(response) in
            if !response {
                let error = Banner.ErrorBanner(errorTitle: "Could not connect to database")
                error.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(error)
                let when = DispatchTime.now() + 5
                DispatchQueue.main.asyncAfter(deadline: when){
                    error.removeFromSuperview()
                }
                GenericTools.Logger(data: "\n Internet Connection not Available!")
            }
            else {
                self.getPics(){(response) in
                    if !response {
                        let error = Banner.ErrorBanner(errorTitle: "Could not connect to database")
                        error.backgroundColor = UIColor.black.withAlphaComponent(1)
                        self.view.addSubview(error)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5){
                            error.removeFromSuperview()
                        }
                        GenericTools.Logger(data: "\n Internet Connection not Available!")
                    }
                }
            }
        }
    }
    func getPics(completion: @escaping (Bool) -> Void) {
        for index in 0...(mMembers.MemberList.count - 1) {
            if mMembers.MemberList[index].imageURL != "Empty" {
            Storage.storage().reference(forURL: mMembers.MemberList[index].imageURL).getData(maxSize: 10000000) { (data, error) -> Void in
                if error == nil {
                    if let pic = UIImage(data: data!) {
                        mMembers.MemberList[index].picture = pic
                        completion(true)
                    }
                    else {
                        mMembers.MemberList[index].picture = UIImage(named: "Icons/Placeholder.png")!
                        GenericTools.Logger(data: "\n Error get url data of member \(mMembers.MemberList[index].id)")
                        completion(true)
                    }
                }
                else {
                    GenericTools.Logger(data: "\n Error reading image url of member \(mMembers.MemberList[index].id): \(error!)")
                }
            }
          }
        }
    }
    
    func getUsers(completion: @escaping (Bool) -> Void){
        Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Users").observe(.value, with: { (snapshot) in
            mMembers.MemberList.removeAll()
            for snap in snapshot.children{
                if let childSnapshot = snap as? DataSnapshot
                {
                    if let user = childSnapshot.value as? [String:AnyObject] , user.count > 0{
                        if let brotherName = user["BrotherName"] as? String {
                            if let first = user["First Name"] as? String {
                                if let last = user["Last Name"] as? String {
                                    if let degree = user["Degree"] as? String {
                                        if let status = user["Validated"] as? Bool {
                                            if let birthday = user["Birthday"] as? String {
                                                if let email = user["Email"] as? String {
                                                    if let grad = user["GraduationDate"] as? String {
                                                        if let position = user["Position"] as? String {
                                                            if let school = user["School"] as? String {
                                                                if let id = user["UserID"] as? String {
                                                                    if let image = user["Image"] as? String {
                                                                        let imageHolder = UIImage(named: "Icons/Placeholder.png")
                                                                        let member = Member(brotherName: brotherName, first: first, last: last, degree: degree, status: status, birthday: birthday, email: email, graduate: grad, picture: imageHolder!,ImageURL: image, position: position, school: school, id: id)
                                                                        
                                                                        mMembers.MemberList.append(member)
                                                                        
                                                                        if id == LoggedIn.User["UserID"] as! String {
                                                                            LoggedIn.User["BrotherName"] = member.brotherName
                                                                            LoggedIn.User["First Name"] = member.first
                                                                            LoggedIn.User["Last Name"] = member.last
                                                                            LoggedIn.User["Degree"] = member.degree
                                                                            LoggedIn.User["Validated"] = member.status
                                                                            LoggedIn.User["Birthday"] = member.birthday
                                                                            LoggedIn.User["Email"] = member.email
                                                                            LoggedIn.User["GraduationDate"] = member.graduateDay
                                                                            LoggedIn.User["Position"] = member.position
                                                                            LoggedIn.User["School"] = member.school
                                                                            LoggedIn.User["UserID"] = member.id
                                                                            LoggedIn.User["Image"] = member.imageURL
                                                                        }
                                                                        completion(true)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    completion(false)
                    
                }
            }
        }){ (error) in
            GenericTools.Logger(data: "\n Error getting Users: \(error)")
        }
    }

}

