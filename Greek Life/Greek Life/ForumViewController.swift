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
import FirebaseStorage

class ForumCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var PostTitle: UITextView!
    @IBOutlet weak var Post: UITextView!
    @IBOutlet weak var PosterName: UILabel!
    @IBOutlet weak var PosterImage: UIImageView!
    @IBOutlet weak var PostDate: UILabel!
    @IBOutlet weak var NumberOfComments: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

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
    var CommentId: String
    var PostEpoch:Double
    var PosterId: String
    
    init(Poster:String, PostDate:String, PostEpoch:Double, Post:String, PosterId: String, CommentId: String){
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Post = Post;
        self.PostEpoch = PostEpoch;
        self.PosterId = PosterId
        self.CommentId = CommentId
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
    var PosterId: String
    var PostDate:Double
    var PostTitle:String
    var User:String
    var Image: UIImage
    var Comments: [Int]
    var hashValue: Int {
        return self.uid
    }
    var Epoch:Double
    
    init(uId: Int, PosterId: String, PostId:String, Post:String, Poster:String, PostDate:Double, PostTitle:String, User:String, Epoch:Double, Comments:[Int]){
        self.uid = uId;
        self.Post = Post;
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Comments = Comments;
        self.PostTitle = PostTitle;
        self.User = User;
        self.Epoch = Epoch;
        self.PostId = PostId;
        self.PosterId = PosterId;
        self.Image = UIImage(named: "Icons/Placeholder.png")!
    }
}

struct Postings {
    static var AllPosts:[ForumPost]? = nil
    static var myIndex = 0
}

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var ref: DatabaseReference!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    let position = LoggedIn.User["Position"] as! String
    let userId = LoggedIn.User["UserID"] as! String
    var deleting = false
    
    var rowHeight:CGFloat = 0
    var numberOfCells:Int = 0;
    @IBOutlet weak var TableView: UITableView!
    
    //List order button properties
    @IBOutlet weak var Newest: UIButton!
    @IBOutlet weak var Oldest: UIButton!
    @IBOutlet weak var ThisMonth: UIButton!
    @IBOutlet weak var ThisWeek: UIButton!
    @IBAction func CreatePost(_ sender: Any) {
        performSegue(withIdentifier: "WritePost", sender: self)
    }
    
    @IBAction func BackHome(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
    @IBOutlet weak var DeleteBtn: UIBarButtonItem!
    @IBAction func Deleting(_ sender: Any) {
        if deleting == true {
            deleting = false
            self.DeleteBtn.tintColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
        }
        else {
            deleting = true
            self.DeleteBtn.tintColor = .red
        }
        self.TableView.reloadData()
    }
    let backgroundColor = UIColor(displayP3Red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
    //List order button actions
    @IBAction func Newest(_ sender: Any) {
        if NewestClicked == true{
            return
        }
        else {
            self.SortByDate(Posts: Postings.AllPosts!)
            Newest.backgroundColor = UIColor.black
            NewestClicked = true;
            OldestClicked = false;
            Oldest.layer.backgroundColor = self.backgroundColor.cgColor
            ThisMonthClicked = false;
            ThisMonth.layer.backgroundColor = self.backgroundColor.cgColor
            ThisWeekClicked = false;
            ThisWeek.layer.backgroundColor = self.backgroundColor.cgColor
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
            Oldest.backgroundColor = UIColor.black
            Postings.AllPosts?.reverse()
            self.TableView.reloadData();
            OldestClicked = true;
            NewestClicked = false;
            Newest.layer.backgroundColor = self.backgroundColor.cgColor
            ThisMonthClicked = false;
            ThisMonth.layer.backgroundColor = self.backgroundColor.cgColor
            ThisWeekClicked = false;
            ThisWeek.layer.backgroundColor = self.backgroundColor.cgColor
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return;
        }
    }
    
    @IBAction func ThisWeek(_ sender: Any) {
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if ThisWeekClicked == true{
            return
        }
        else {
            self.SortByDate(Posts: Postings.AllPosts!)
            ThisWeek.backgroundColor = UIColor.black
            ThisWeekClicked = true;
            OldestClicked = false;
            Oldest.layer.backgroundColor = self.backgroundColor.cgColor
            NewestClicked = false;
            Newest.layer.backgroundColor = self.backgroundColor.cgColor
            ThisMonthClicked = false;
            ThisMonth.layer.backgroundColor = self.backgroundColor.cgColor
            self.TableView.reloadData();
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
            return;
        }
    }
    
    @IBAction func ThisMonth(_ sender: Any) { //actually this week
        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        if ThisMonthClicked == true{
            return
        }
        else {
            self.SortByDate(Posts: Postings.AllPosts!)
            ThisMonth.backgroundColor = UIColor.black
            ThisMonthClicked = true;
            OldestClicked = false;
            Oldest.layer.backgroundColor = self.backgroundColor.cgColor
            NewestClicked = false;
            Newest.layer.backgroundColor = self.backgroundColor.cgColor
            ThisWeekClicked = false;
            ThisWeek.layer.backgroundColor = self.backgroundColor.cgColor
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
    var ThisWeekClicked = false;
    //
    
    func SortByDate(Posts:[ForumPost]){
        Postings.AllPosts = mergeSorting.mergeSort(Posts)
    }
    
    func getPosts(completion: @escaping (Bool, Any?, Any?) -> Void){
        ref = Database.database().reference()
        self.ref.child((Configuration.Config!["DatabaseNode"] as! String)+"/Forum").observe(.value, with: { (snapshot) in
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
                                                    if let userId = postDictionary["PosterId"] as? String {
                                                        var newComment:[Int] = []
                                                        var x = 0
                                                        if let comments = postDictionary["Comments"] as? [String : [String:AnyObject]] {
                                                            for _ in comments {
                                                                x = x + 1
                                                                newComment.append(x)
                                                            }
                                                        }
                                                        let newPost = ForumPost(uId: count, PosterId: userId, PostId: postId, Post: post, Poster: poster, PostDate: date, PostTitle: postTitle, User: user, Epoch: date, Comments: newComment)
                                                        Posts.append(newPost);
                                                        count += 1
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
                completion(true, Posts, nil);
        }){ (error) in
            GenericTools.Logger(data: "\n Could not retrieve posts: \(error)")
            completion(false, nil, error)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        self.TableView.backgroundColor = backgroundColor
        self.Newest.layer.borderWidth = 1
        self.Oldest.layer.borderWidth = 1
        self.ThisWeek.layer.borderWidth = 1
        self.ThisMonth.layer.borderWidth = 1

        ActivityWheel.CreateActivity(activityIndicator: activityIndicator,view: self.view);
        self.TableView.allowsSelection = false
        self.view.backgroundColor = UIColor.lightGray
        self.view.backgroundColor?.withAlphaComponent(0.2)
        if Reachability.isConnectedToNetwork(){
        self.getPosts(){(success, response, error) in
            guard success, let PostList = response as? [ForumPost] else{
                let BadPostRequest = Banner.ErrorBanner(errorTitle: "Could not get posts from database.")
                BadPostRequest.backgroundColor = UIColor.black.withAlphaComponent(1)
                self.view.addSubview(BadPostRequest)
                GenericTools.Logger(data: "\n Could not get posts from database: \(error!)")
                if(response != nil){
                    print(response!)
                    }
                return
                }
            Postings.AllPosts = PostList
            self.numberOfCells = PostList.count
            self.SortByDate(Posts: Postings.AllPosts!)
                self.TableView.reloadData();
                self.activityIndicator.stopAnimating();
                UIApplication.shared.endIgnoringInteractionEvents();
            }
        }
        else {
            let internetError =  Banner.ErrorBanner(errorTitle:"You're not connected to the Internet")
            self.view.addSubview(internetError)
            GenericTools.Logger(data: "\n You're not connected to the Internet")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                internetError.isHidden = true
            }
            self.activityIndicator.stopAnimating();
            UIApplication.shared.endIgnoringInteractionEvents();
        }
    }
    
    func DeleteSelectedPoll(button: UIButton) {
        if Reachability.isConnectedToNetwork() == true {
            let verify = UIAlertController(title: "Alert!", message: "Are you sure you want to permanantly delete this post?", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: DeleteSelectedPollInternal)
            let destructorAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
            verify.addAction(okAction)
            verify.addAction(destructorAction)
            self.present(verify, animated: true, completion: nil)
            self.buttonIdentifier = button.accessibilityLabel!
        }
        else {
            let error = Banner.ErrorBanner(errorTitle: "No Internet Connection Available")
            error.backgroundColor = UIColor.black.withAlphaComponent(1)
            self.view.addSubview(error)
            GenericTools.Logger(data: "\n You're not connected to the Internet")
        }
        
    }

    @objc func ViewComments(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        Postings.myIndex = indexPath!.row
        self.performSegue(withIdentifier: "ForumComments", sender: self)
    }
    
    var buttonIdentifier: String = ""
    func DeleteSelectedPollInternal(action: UIAlertAction) {
            Database.database().reference(withPath: "Forum").child(self.buttonIdentifier).removeValue()
            self.deleting = false
            self.DeleteBtn.tintColor = UIColor(displayP3Red: 255/255, green: 223/255, blue: 0/255, alpha: 1)
            self.TableView.reloadData()
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfCells
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCell", for: indexPath) as! ForumCellTableViewCell
        //cell.PosterImage.contentMode = .scaleToFill
        cell.PosterImage.layer.borderWidth = 1.0
        cell.PosterImage.frame.size.width = cell.PosterImage.frame.size.height
        cell.PosterImage.layer.cornerRadius = cell.PosterImage.frame.size.width / 2
        cell.PosterImage.clipsToBounds = true
        
        for mem in mMembers.MemberList {
            if mem.id == Postings.AllPosts![indexPath.row].PosterId {
            cell.PosterImage.image = mem.picture
            }
        }
        
        if(self.deleting == true){
            cell.DeleteButton.isHidden = false
            cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
            cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
            cell.Post.text = Postings.AllPosts![indexPath.row].Post
            let date = CreateDate.getTimeSince(epoch: Postings.AllPosts![indexPath.row].PostDate)
            cell.PostDate.text = date
            if self.position == "Master" || Postings.AllPosts![indexPath.row].PosterId == self.userId {
                cell.DeleteButton.accessibilityLabel = Postings.AllPosts![indexPath.row].PostId
                cell.DeleteButton.addTarget(self, action: #selector(DeleteSelectedPoll(button:)), for: .touchUpInside)
            }
            else {
                cell.isHidden = true
            }
            GenericTools.FrameToFitTextView(View: cell.PostTitle)
            cell.Post.frame.origin.y = cell.PostTitle.frame.origin.y + cell.PostTitle.frame.size.height + 10
            GenericTools.FrameToFitTextView(View: cell.Post)
            cell.DeleteButton.frame.origin.y = cell.Post.frame.origin.y + cell.Post.frame.size.height + 10
            cell.NumberOfComments.frame.origin.y = cell.DeleteButton.frame.origin.y + cell.DeleteButton.frame.size.height + 10
            cell.PostDate.frame.origin.y = cell.NumberOfComments.frame.origin.y
            self.rowHeight = cell.NumberOfComments.frame.origin.y + cell.NumberOfComments.frame.size.height + 15
        }
        else if(Postings.AllPosts != nil){
            cell.DeleteButton.isHidden = true
            cell.PosterName.text = Postings.AllPosts![indexPath.row].Poster
            cell.PostTitle.text = Postings.AllPosts![indexPath.row].PostTitle
            cell.Post.text = Postings.AllPosts![indexPath.row].Post
            let date = CreateDate.getTimeSince(epoch: Postings.AllPosts![indexPath.row].PostDate)
            cell.PostDate.text = date
            
            if(ThisMonthClicked == true){
                if(!((Date().timeIntervalSince1970 - Postings.AllPosts![indexPath.row].PostDate) <= 2678400)){
                    cell.isHidden = true
                }
            }
            else if(ThisWeekClicked == true){
                if(!((Date().timeIntervalSince1970 - Postings.AllPosts![indexPath.row].PostDate) <= 604800)){
                    cell.isHidden = true;
                }
            }
            GenericTools.FrameToFitTextView(View: cell.PostTitle)
            cell.Post.frame.origin.y = cell.PostTitle.frame.origin.y + cell.PostTitle.frame.size.height + 10
            GenericTools.FrameToFitTextView(View: cell.Post)
            cell.NumberOfComments.frame.origin.y = cell.Post.frame.origin.y + cell.Post.frame.size.height + 10
            cell.PostDate.frame.origin.y = cell.NumberOfComments.frame.origin.y
            self.rowHeight = cell.NumberOfComments.frame.origin.y + cell.NumberOfComments.frame.size.height + 15
        }
        cell.NumberOfComments.setTitle("\(Postings.AllPosts![indexPath.row].Comments.count) Comments", for: .normal)
        cell.NumberOfComments.addTarget(self, action: #selector(ViewComments(button:)), for: .touchUpInside)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    


}
