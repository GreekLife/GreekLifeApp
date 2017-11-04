//
//  ForumViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-29.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Comment {
    var Poster:String
    var PostDate:String
    var Post:String
    
    init(Poster:String, PostDate:String, Post:String){
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Post = Post;
    }
}

class ForumPost: Hashable, Comparable {
    
    static func ==(lhs: ForumPost, rhs: ForumPost) -> Bool {
        return lhs.uid == rhs.uid
    }
    static func < (lhs: ForumPost, rhs: ForumPost) -> Bool {
        return lhs.PostDate > rhs.PostDate
    }
    
    var uid: Int
    var Post:String
    var Poster:String
    var PostDate:Double
    var PostTitle:String
    var Comments = [Comment]()
    var hashValue: Int {
        return self.uid
    }
    
    init(uId: Int, Post:String, Poster:String, PostDate:Double, PostTitle:String, Comments:[Comment]){
        self.uid = uId;
        self.Post = Post;
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Comments = Comments;
        self.PostTitle = PostTitle
    }
}

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    var ref: DatabaseReference!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForumViewController.dismissKeyboard))

    var NumberOfCells:Int = 0;
    var AllPosts:[ForumPost]? = nil
    @IBOutlet weak var TableView: UITableView!
    
    //List order button properties
    @IBOutlet weak var PostTitle: UITextField!
    @IBOutlet weak var Newest: UIButton!
    @IBOutlet weak var Oldest: UIButton!
    @IBOutlet weak var ThisMonth: UIButton!
    @IBOutlet weak var ThisYear: UIButton!
    @IBOutlet weak var NewPost: UITextView!
    @IBOutlet weak var NewPostView: UIView!
    @IBOutlet weak var PostButton: UIButton!
    @IBOutlet weak var PostError: UILabel!
    @IBAction func ExitPost(_ sender: Any) {
         UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.NewPostView.alpha = 0
        })
        NewPost.text = "Write your post here..."
        PostError.text = ""
        PostTitle.text = ""
        self.view.endEditing(true)
        view.removeGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func validate(words:Int)->Bool{
        if(words < 20) {
            self.PostError.textColor = .red
            PostError.text = "Post must be at least 20 words"
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.PostError.text = ""
            }
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
        else if(words > 150){
            self.PostError.textColor = .red
            PostError.text = "Post must be no more than 150 words"
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.PostError.text = ""
            }
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
        
        else if(PostTitle.text?.count == 0 || PostTitle.text == nil){
            self.PostError.textColor = .red
            PostError.text = "Post must have a title"
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.PostError.text = ""
            }
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return false
        }
        else{
            return true
        }
        
        
    }
    
    @IBAction func Post(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: NewPostView); //loading wheel is not showing
        let components = NewPost.text.components(separatedBy: .whitespacesAndNewlines)
        let PostWords = components.filter { !$0.isEmpty }
        
        let valid = validate(words: PostWords.count)
        
        if(valid == true)
        {
            UploadPost()
        }
}
    func UploadPost(){
        let Username = LoggedIn.User["Username"] as! String
        let FirstName = LoggedIn.User["First Name"] as! String
        let LastName = LoggedIn.User["Last Name"] as! String
        var Name = FirstName + " " + LastName
        if(Username == "Master"){
            Name = Name + " (Master)"
        }
        let Epoch = Date().timeIntervalSince1970
        let Title = PostTitle.text
        let Post = NewPost.text
        //let Picture = LoggedIn.User["Picture"]
        if(Title != nil && Post != nil){
            let Post = [
                "Post": Post!,
                "PostTitle": Title!,
                "Poster": Name,
                "Epoch": Epoch
                ] as [String : Any]
            PostData(newPostData: Post){(success, error) in
                if(success == true){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { //Queue is not dispatching here
                        self.PostError.text = "Post Succesfully added"
                        self.PostError.textColor = .blue
                        self.PostTitle.text = ""
                        self.NewPost.text = ""
                    }
                    self.activityIndicator.stopAnimating();
                    UIApplication.shared.endIgnoringInteractionEvents();
                }
            }
        }
    }
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        ref = Database.database().reference()
        let postId = UUID().uuidString
        let commentID = UUID().uuidString
        self.ref.child("Forum").child(postId).setValue(newPostData)
        let comments = [
            "Post": "",
            "Poster": "",
            "Epoch": ""
            ] as [String : Any]
        self.ref.child("Forum").child(postId).child("Comments").child(commentID).setValue(comments)
        completion(true, nil)
    }
    
    //Create Post
    @IBOutlet weak var CreatePost: UIButton!
    @IBAction func CreatePost(_ sender: Any) {
        view.addGestureRecognizer(tap)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.NewPostView.layer.backgroundColor = UIColor.black.cgColor
            self.PostButton.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
            self.NewPostView.layer.cornerRadius = 10;
            self.NewPostView.layer.shadowColor = UIColor.black.cgColor
            self.NewPostView.layer.shadowOffset = CGSize(width: 3, height: 3)
            self.NewPostView.layer.shadowOpacity = 0.7
            self.NewPostView.layer.shadowRadius = 4.0
            self.NewPost.layer.cornerRadius = 10;
            self.NewPostView.alpha = 0.95

        })
    }
    //drop text field on enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //List order button actions
    @IBAction func Newest(_ sender: Any) {
        if NewestClicked == true{
            return
        }
        else {
            self.SortByDate(Posts: self.AllPosts!)
            Newest.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
            NewestClicked = true;
            OldestClicked = false;
            Oldest.layer.backgroundColor = UIColor.clear.cgColor
            ThisMonthClicked = false;
            ThisMonth.layer.backgroundColor = UIColor.clear.cgColor
            ThisYearClicked = false;
            ThisYear.layer.backgroundColor = UIColor.clear.cgColor
            self.TableView.reloadData();
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return;
        }
    }
    @IBAction func Oldest(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if OldestClicked == true{
            return
        }
        else {
            Oldest.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
            self.AllPosts?.reverse()
            self.TableView.reloadData();
            OldestClicked = true;
            NewestClicked = false;
            Newest.layer.backgroundColor = UIColor.clear.cgColor
            ThisMonthClicked = false;
            ThisMonth.layer.backgroundColor = UIColor.clear.cgColor
            ThisYearClicked = false;
            ThisYear.layer.backgroundColor = UIColor.clear.cgColor
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return;
        }
    }
    @IBAction func ThisMonth(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if ThisMonthClicked == true{
            return
        }
        else {
            self.SortByDate(Posts: self.AllPosts!)
            ThisMonth.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
            ThisMonthClicked = true;
            OldestClicked = false;
            Oldest.layer.backgroundColor = UIColor.clear.cgColor
            NewestClicked = false;
            Newest.layer.backgroundColor = UIColor.clear.cgColor
            ThisYearClicked = false;
            ThisYear.layer.backgroundColor = UIColor.clear.cgColor
            self.TableView.reloadData();
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return;
        }
    }
    @IBAction func ThisYear(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if ThisYearClicked == true{
            return
        }
        else {
            self.SortByDate(Posts: self.AllPosts!)
            ThisYear.backgroundColor = UIColor(displayP3Red: 60/255, green: 146/255, blue: 255/255, alpha: 1)
            ThisYearClicked = true;
            OldestClicked = false;
            Oldest.layer.backgroundColor = UIColor.clear.cgColor
            NewestClicked = false;
            Newest.layer.backgroundColor = UIColor.clear.cgColor
            ThisMonthClicked = false;
            ThisMonth.layer.backgroundColor = UIColor.clear.cgColor
            self.TableView.reloadData();
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return;
        }
    }
    //List order button clicked properties
    var OldestClicked = false;
    var NewestClicked = true;
    var ThisMonthClicked = false;
    var ThisYearClicked = false;
    //
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(NumberOfCells)//number of cells
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCell", for: indexPath) as! ForumCellTableViewCell
        if(self.AllPosts != nil){
            if(ThisMonthClicked == true){
                if((Date().timeIntervalSince1970 - self.AllPosts![indexPath.row].PostDate) <= 2678400){
                    cell.PosterName.text = self.AllPosts![indexPath.row].Poster
                    cell.PostTitle.text = self.AllPosts![indexPath.row].PostTitle
                    cell.Post.text = self.AllPosts![indexPath.row].Post
                    let date = CreateDate.getCurrentDate(epoch: self.AllPosts![indexPath.row].PostDate)
                    cell.PostDate.text = date
                }
                else {
                    cell.isHidden = true
                }

            }
            else if(ThisYearClicked == true){
                if((Date().timeIntervalSince1970 - self.AllPosts![indexPath.row].PostDate) <= 31536000){
                    cell.PosterName.text = self.AllPosts![indexPath.row].Poster
                    cell.PostTitle.text = self.AllPosts![indexPath.row].PostTitle
                    cell.Post.text = self.AllPosts![indexPath.row].Post
                    let date = CreateDate.getCurrentDate(epoch: self.AllPosts![indexPath.row].PostDate)
                    cell.PostDate.text = date
                }
                else {
                    cell.isHidden = true;
                }
            }
            else {
            cell.PosterName.text = self.AllPosts![indexPath.row].Poster
            cell.PostTitle.text = self.AllPosts![indexPath.row].PostTitle
            cell.Post.text = self.AllPosts![indexPath.row].Post
            let date = CreateDate.getCurrentDate(epoch: self.AllPosts![indexPath.row].PostDate)
            cell.PostDate.text = date
            }
        }
        return(cell)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popVC = storyboard.instantiateViewController(withIdentifier: "CommentPop") // your viewcontroller's id
        popVC.preferredContentSize = CGSize(width: 500, height: 600)
        popVC.modalPresentationStyle = .popover
        let popover =  popVC.popoverPresentationController
        popover?.delegate = self as? UIPopoverPresentationControllerDelegate
        self.present(popVC, animated: true, completion: nil)
    }
    
    func SortByDate(Posts:[ForumPost]){
        let post : [ForumPost] = mergeSorting.mergeSort(Posts)
        AllPosts = post
    }
    
    func getPosts(completion: @escaping (Bool, Any?) -> Void){
        ref = Database.database().reference()
        self.ref.child("Forum").observe(.value, with: { (snapshot) in
            var count = 1;
            var Posts:[ForumPost] = []
            for snap in snapshot.children{
                if let childSnapshot = snap as? DataSnapshot
                {
                    if let postDictionary = childSnapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                        if let post = postDictionary["Post"] as? String {
                            if let poster = postDictionary["Poster"] as? String{
                                if let postTitle = postDictionary["PostTitle"] as? String {
                                    if let _ = postDictionary["Comments"] as? Dictionary<String, AnyObject> {
                                        if let date = postDictionary["Epoch"] as? Double {
                                            let newComment:[Comment] = []
                                      //  for comm in comment{
                                          //  let dic = comm as? [AnyObject]
//                                            if let ComPoster = dic!["Poster"] {
//                                                if let ComPost = dic!["Post"] {
//                                                    if let ComDate = dic!["PostDate"] {
//                                                        let createComment = Comment(Poster: ComPoster as! String, PostDate: ComDate as! String, Post: ComPost as! String)
//                                                        newComment.append(createComment);
//                                                    }
//                                                }
//                                            } //observe new event
 //                                       }
                                        let newPost = ForumPost(uId: count, Post: post, Poster: poster, PostDate: date, PostTitle: postTitle, Comments: newComment)
                                        Posts.append(newPost);
                                        count = count + 1
                                       }
                                    }
                                }
                            }
                        }
                    }
                }
            }
                completion(true, Posts);
        }){ (error) in
            print("Could not retrieve object from database");
            completion(false, error)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        UIApplication.shared.endIgnoringInteractionEvents();
        self.view.backgroundColor = UIColor.lightGray
        self.view.backgroundColor?.withAlphaComponent(0.2)
        if Reachability.isConnectedToNetwork(){
        self.getPosts(){(success, response) in
            guard success, let PostList = response as? [ForumPost] else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not get posts from database.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                print("Internet Connection not Available!")
                if(response != nil){
                    print(response!)
                }
                return
            }
            self.AllPosts = PostList
            self.NumberOfCells = PostList.count
            self.SortByDate(Posts: self.AllPosts!)
            self.TableView.reloadData();
            self.activityIndicator.stopAnimating();
    }
        }
        else {
            let internetError =  Banner.ErrorBanner(errorTitle:"You're not connected to the Internet")
            self.view.addSubview(internetError)
            print("Internet Connection not Available!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                internetError.isHidden = true
            }
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        }
        self.PostTitle.delegate = self
        tap = UITapGestureRecognizer(target: self, action: #selector(ForumViewController.dismissKeyboard))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
