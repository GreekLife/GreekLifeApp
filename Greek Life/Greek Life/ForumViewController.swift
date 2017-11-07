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

class Comment: Comparable {
    static func <(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.PostEpoch > rhs.PostEpoch
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.PostEpoch == rhs.PostEpoch
    }
    
    var Poster:String
    var PostDate:String
    var Post:String
    var PostEpoch:Double
    
    init(Poster:String, PostDate:String, PostEpoch:Double, Post:String){
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Post = Post;
        self.PostEpoch = PostEpoch;
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
    var PostId:String
    var Post:String
    var Poster:String
    var PostDate:Double
    var PostTitle:String
    var User:String
    var Comments = [Comment]()
    var hashValue: Int {
        return self.uid
    }
    var Epoch:Double
    
    init(uId: Int, PostId:String, Post:String, Poster:String, PostDate:Double, PostTitle:String, User:String, Epoch:Double, Comments:[Comment]){
        self.uid = uId;
        self.Post = Post;
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Comments = Comments;
        self.PostTitle = PostTitle;
        self.User = User;
        self.Epoch = Epoch;
        self.PostId = PostId;
    }
}

struct Postings {
    static var AllPosts:[ForumPost]? = nil
    static var myIndex = 0
    static let containerView = UIView()
}

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    var ref: DatabaseReference!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForumViewController.dismissKeyboard))
    let Username = LoggedIn.User["Username"] as! String
    var rowHeight:CGFloat = 427


    var NumberOfCells:Int = 0;
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
    
    @IBOutlet weak var DeletePost: UIButton!
    var Deleting = false
    @IBAction func DeletePost(_ sender: Any) {
        if(Deleting == false){
        Deleting = true
        DeletePost.layer.backgroundColor = UIColor.black.cgColor
        }
        else{
            Deleting = false
            DeletePost.layer.backgroundColor = UIColor.clear.cgColor
        }
            self.TableView.reloadData()
    }
    
    
    
    
    
    
    
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
        let FirstName = LoggedIn.User["First Name"] as! String
        let LastName = LoggedIn.User["Last Name"] as! String
        var Name = FirstName + " " + LastName
        if(Username == "Master"){
            Name = Name + " (Master)"
        }
        let Epoch = Date().timeIntervalSince1970
        let Title = PostTitle.text
        let Posting = NewPost.text
        let postId = UUID().uuidString

        //let Picture = LoggedIn.User["Picture"]
        if(Title != nil && Posting != nil){
            let Post = [
                "Post": Posting!,
                "PostTitle": Title!,
                "Poster": Name,
                "Epoch": Epoch,
                "Username": Username,
                "PostId": postId
                ] as [String : Any]
            PostData(newPostData: Post){(success, error) in
                if(success == true){
                    self.PostError.text = "Post Succesfully added"
                    self.PostError.textColor = .blue
                    self.PostTitle.text = ""
                    self.NewPost.text = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.PostError.text = ""
                    }
                    self.activityIndicator.stopAnimating();
                    UIApplication.shared.endIgnoringInteractionEvents();
                }
            }
        }
    }
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        ref = Database.database().reference()
        let commentID = UUID().uuidString
        let pID = newPostData["PostId"] as! String
        self.ref.child("Forum").child(pID).setValue(newPostData)
//        let comments = [
//            "Post": "",
//            "Poster": "",
//            "Epoch": 0
//            ] as [String : Any]
//        self.ref.child("Forum").child(pID).child("Comments").child(commentID).setValue(comments)
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
            self.SortByDate(Posts: Postings.AllPosts!)
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
            Postings.AllPosts?.reverse()
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
            self.SortByDate(Posts: Postings.AllPosts!)
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
            self.SortByDate(Posts: Postings.AllPosts!)
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
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(Deleting == true){
            let foo = UIAlertController(title: "Alert!", message: "This post and all its comments will be completely erased.", preferredStyle: UIAlertControllerStyle.alert)
            let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                if editingStyle == UITableViewCellEditingStyle.delete {
                    Database.database().reference(withPath: "Forum").queryOrdered(byChild: "Epoch").queryEqual(toValue: Postings.AllPosts![indexPath.row].Epoch).observe(.value, with: { (snapshot) in
                        if let forumPosts = snapshot.value as? [String: [String: AnyObject]] {
                            for (key, _) in forumPosts  {
                                FirebaseDatabase.Database.database().reference(withPath: "Forum").child(key).removeValue()
                            }
                        }
                    })
                    Postings.AllPosts?.remove(at: indexPath.row)
                }
                print("Post Deleted")
            }
            
            foo.addAction(okAction)
            foo.addAction(DestructiveAction)

            self.present(foo, animated: true, completion: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCell", for: indexPath) as! ForumCellTableViewCell
        if(Deleting == true){
            if(Username == "Master"){
                cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
                cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
                cell.Post.text = Postings.AllPosts![indexPath.row].Post
                let date = CreateDate.getCurrentDate(epoch: Postings.AllPosts![indexPath.row].PostDate)
                cell.PostDate.text = date
            }
            else if(Postings.AllPosts![indexPath.row].User == Username){
                cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
                cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
                cell.Post.text = Postings.AllPosts![indexPath.row].Post
                let date = CreateDate.getCurrentDate(epoch: Postings.AllPosts![indexPath.row].PostDate)
                cell.PostDate.text = date
            }
            else {
                cell.isHidden = true
            }
        }
        else if(Postings.AllPosts != nil){
            if(ThisMonthClicked == true){
                if((Date().timeIntervalSince1970 - Postings.AllPosts![indexPath.row].PostDate) <= 2678400){
                    cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
                    cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
                    cell.Post.text = Postings.AllPosts![indexPath.row].Post
                    let date = CreateDate.getCurrentDate(epoch: Postings.AllPosts![indexPath.row].PostDate)
                    cell.PostDate.text = date
                }
                else {
                    cell.isHidden = true
                }

            }
            else if(ThisYearClicked == true){
                if((Date().timeIntervalSince1970 - Postings.AllPosts![indexPath.row].PostDate) <= 31536000){
                    cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
                    cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
                    cell.Post.text = Postings.AllPosts![indexPath.row].Post
                    let date = CreateDate.getCurrentDate(epoch: Postings.AllPosts![indexPath.row].PostDate)
                    cell.PostDate.text = date
                }
                else {
                    cell.isHidden = true;
                }
            }
            else {
            cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
            cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
            cell.Post.text = Postings.AllPosts![indexPath.row].Post
            let date = CreateDate.getCurrentDate(epoch: Postings.AllPosts![indexPath.row].PostDate)
            cell.PostDate.text = date
            }
        }
        
        let oldHeight = cell.Post.frame.size.height
        let oldWidth = cell.Post.frame.size.width
        GenericTools.FrameToFitTextView(View: cell.Post)
        cell.Post.frame.size.width = oldWidth
        let newHeight = cell.Post.frame.size.height
        let heightDifference = oldHeight - newHeight
        cell.PostDate.frame.origin.y -= heightDifference
        cell.NumberOfComments.frame.origin.y -= heightDifference
        let cellHeight = 127 + newHeight
        self.rowHeight = cellHeight
        
        cell.NumberOfComments.text = "\(Postings.AllPosts![indexPath.row].Comments.count) Comments"
        return(cell)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Postings.myIndex = indexPath.row
        Postings.containerView.layer.shadowColor = UIColor.black.cgColor
        Postings.containerView.layer.shadowOffset = CGSize.zero
        Postings.containerView.layer.shadowOpacity = 0.5
        Postings.containerView.layer.shadowRadius = 5
        Postings.containerView.translatesAutoresizingMaskIntoConstraints = false
        Postings.containerView.layer.cornerRadius = 10.0
        Postings.containerView.layer.borderColor = UIColor.gray.cgColor
        Postings.containerView.layer.borderWidth = 0.5
        Postings.containerView.clipsToBounds = true
        view.addSubview(Postings.containerView)
        NSLayoutConstraint.activate([
            Postings.containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            Postings.containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            Postings.containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            Postings.containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            ])
        
        // add child view controller view to container
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "CommentPop")
        addChildViewController(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        Postings.containerView.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: Postings.containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: Postings.containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: Postings.containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: Postings.containerView.bottomAnchor)
            ])
        
        controller.didMove(toParentViewController: self)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    
    func SortByDate(Posts:[ForumPost]){
        let post : [ForumPost] = mergeSorting.mergeSort(Posts)
        Postings.AllPosts = post
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
                                    if let postId = postDictionary["PostId"] as? String {
                                        if let date = postDictionary["Epoch"] as? Double {
                                            if let user = postDictionary["Username"] as? String {
                                                var newComment:[Comment] = []
                                                var x = 0
                                                if let comments = postDictionary["Comments"] as? [String : [String:AnyObject]] {
                                                for comm in comments {
                                                        x = x + 1
                                                        var commEpoch = comm.value["Epoch"] as? Double
                                                        if commEpoch == nil {
                                                            commEpoch = 0
                                                        }
                                                        let commPost = comm.value["Post"] as! String
                                                        let commPoster = comm.value["Poster"] as! String
                                                        var commDate = ""
                                                        if(commEpoch != 0){
                                                         commDate = CreateDate.getCurrentDate(epoch: commEpoch!)
                                                        }
                                                        let newComm = Comment(Poster: commPoster, PostDate: commDate, PostEpoch: commEpoch!, Post: commPost)
                                                        newComment.append(newComm)
                                                    }
                                                }
                                                    let newPost = ForumPost(uId: count, PostId: postId, Post: post, Poster: poster, PostDate: date, PostTitle: postTitle, User: user, Epoch: date, Comments: newComment)
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
            Postings.AllPosts = PostList
            self.NumberOfCells = PostList.count
            self.SortByDate(Posts: Postings.AllPosts!)
            self.TableView.reloadData();
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();

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
