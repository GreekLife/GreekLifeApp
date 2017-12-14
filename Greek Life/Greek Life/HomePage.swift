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

class News: Comparable {
    
    static func ==(lhs: News, rhs: News) -> Bool {
        return lhs.postId == rhs.postId
    }
    static func < (lhs: News, rhs: News) -> Bool {
        return lhs.Epoch > rhs.Epoch
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
    @IBOutlet weak var newsDate: UILabel!
    @IBOutlet weak var Delete: UIButton!
    
}

class HomePage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.NewsPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! HomePageCell
        if username != "Master" {
            cell.Delete.isHidden = true
        }
        else {
            cell.Delete.accessibilityValue = self.NewsPosts[indexPath.row].postId
            cell.Delete.addTarget(self, action: #selector(deleteNews(button:)), for: .touchUpInside)
        }
        cell.news.text = self.NewsPosts[indexPath.row].Post
        let date = CreateDate.getTimeSince(epoch: self.NewsPosts[indexPath.row].Epoch)
        cell.newsDate.text = date
        GenericTools.FrameToFitTextView(View: cell.news)
        self.newsHeight = cell.news.frame.origin.y + cell.news.frame.size.height
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.newsHeight
    }
    
    var buttonIdentifier = ""
    func deleteNews(button: UIButton) {
        if Reachability.isConnectedToNetwork() == true {
            self.buttonIdentifier = button.accessibilityValue!
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
            print("Internet Connection not Available!")
        }
    }
    
    func deleteNewsInternal(action: UIAlertAction) {
        FirebaseDatabase.Database.database().reference(withPath: "News").child(self.buttonIdentifier).removeValue()
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
    
    var newsHeight: CGFloat = 0
    var ref: DatabaseReference!
    let defaults:UserDefaults = UserDefaults.standard
    let username = LoggedIn.User["Username"] as! String
    
    var NewsPosts: [News] = []
    
    @IBAction func MasterControls(_ sender: Any) {
        performSegue(withIdentifier: "MasterControls", sender: self)
    }
    @IBAction func Signout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Signed out");
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
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
          //  performSegue(withIdentifier: "Profile", sender: self)
            break;
        case 8:
           // performSegue(withIdentifier: "GoogleDrive", sender: self)
            break;
        case 9:
            performSegue(withIdentifier: "Info", sender: self)
            break;
        default: ()
            break;
        }
    }
    
    func ReadNews(completion: @escaping (Bool) -> Void){
        ref = Database.database().reference()
        self.ref.child("News").observe(.value, with: { (snapshot) in
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
            })
            { (error) in
            print("Could not retrieve object from database");
            completion(false)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
       self.TableView.allowsSelection = false
        self.ReadNews(){(success) in
            guard success else {
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not get posts from database.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                print("Internet Connection not Available!")
                return
            }
            self.NewsPosts = mergeSorting.mergeSort(self.NewsPosts)
            self.TableView.reloadData()
        }
        
        if (LoggedIn.User["Username"] as! String) != "Master" {
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
        InstantMessaging.layer.borderColor = UIColor.white.cgColor
        InstantMessaging.layer.borderWidth = 1
        Forum.layer.borderColor = UIColor.white.cgColor
        Forum.layer.borderWidth = 1
        Calendar.layer.borderColor = UIColor.white.cgColor
        Calendar.layer.borderWidth = 1
        Poll.layer.borderColor = UIColor.white.cgColor
        Poll.layer.borderWidth = 1
        Members.layer.borderColor = UIColor.white.cgColor
        Members.layer.borderWidth = 1
        Profile.layer.borderColor = UIColor.white.cgColor
        Profile.layer.borderWidth = 1
        GoogleDrive.layer.borderColor = UIColor.white.cgColor
        GoogleDrive.layer.borderWidth = 1
        Info.layer.borderColor = UIColor.white.cgColor
        Info.layer.borderWidth = 1

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
