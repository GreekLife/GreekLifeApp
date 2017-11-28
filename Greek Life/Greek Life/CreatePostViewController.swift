//
//  CreatePostViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-25.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CreatePostViewController: UIViewController {
    
    @IBOutlet weak var PosterImage: UIImageView!
    @IBOutlet weak var PosterName: UILabel!
    @IBOutlet weak var PostTitle: UITextView!
    @IBOutlet weak var Post: UITextView!
    @IBOutlet weak var WritePost: UIButton!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    let user = LoggedIn.User["Username"] as! String
    var CreatePostRef: DatabaseReference!

    @IBAction func BackToForum(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func WritePost(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator, view: self.view);
        let components = Post.text.components(separatedBy: .whitespacesAndNewlines)
        let PostWords = components.filter { !$0.isEmpty }
        
        let valid = validate(words: PostWords.count)
        
        if(valid == true)
        {
            UploadPost()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.WritePost.layer.cornerRadius = 5
        self.Post.layer.borderWidth = 0.7
        self.Post.layer.borderColor = UIColor.black.cgColor
        self.Post.layer.cornerRadius = 5

        self.PostTitle.layer.borderWidth = 0.7
        self.PostTitle.layer.borderColor = UIColor.black.cgColor
        self.PostTitle.layer.cornerRadius = 5

        self.PosterImage.image = UIImage(named: "Docs/user_icon.png")
        self.PosterName.text = self.user
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func validate(words:Int)->Bool{
        if(words < 20) {
            let emptyError = UIAlertController(title: "Too Small", message: "Post must be at least 20 words", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
        else if(words > 1000){
            let emptyError = UIAlertController(title: "Too Large", message: "Post must be no more than 1000 words", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
            
        else if(PostTitle.text?.count == 0 || PostTitle.text == nil){
            let emptyError = UIAlertController(title: "No Title", message: "Post must have a title", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
        else{
            return true
        }
        
        
    }
    
    func UploadPost(){
        let FirstName = LoggedIn.User["First Name"] as! String
        let LastName = LoggedIn.User["Last Name"] as! String
        var Name = FirstName + " " + LastName
        if(self.user == "Master"){
            Name = Name + " (Master)"
        }
        let Epoch = Date().timeIntervalSince1970
        let Title = PostTitle.text
        let Posting = Post.text
        let postId = UUID().uuidString
        
        //let Picture = LoggedIn.User["Picture"]
        if(Title != nil && Posting != nil){
            let Post = [
                "Post": Posting!,
                "PostTitle": Title!,
                "Poster": Name,
                "Epoch": Epoch,
                "Username": self.user,
                "PostId": postId
                ] as [String : Any]
            PostData(newPostData: Post){(success, error) in
                guard success else{
                    let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not post.")
                    BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                    self.view.addSubview(BadPostRequest)
                    print("Internet Connection not Available!")
                    return
                }
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
               // performSegue(withIdentifier: "BackToForum", sender: self)
            }
        }
    }
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        CreatePostRef = Database.database().reference()
        let pID = newPostData["PostId"] as! String
        self.CreatePostRef.child("Forum").child(pID).setValue(newPostData)
        completion(true, nil)
    }

}

