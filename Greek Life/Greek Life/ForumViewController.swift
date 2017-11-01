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

class ForumPost: Hashable {
    static func ==(lhs: ForumPost, rhs: ForumPost) -> Bool {
        return lhs.uid == rhs.uid
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

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var ref: DatabaseReference!
    var NumberOfCells:Int = 1;
    var AllPosts:[ForumPost]? = nil
    @IBOutlet weak var TableView: UITableView!
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(NumberOfCells)//number of cells
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCell", for: indexPath) as! ForumCellTableViewCell
        if(self.AllPosts != nil){
            cell.PosterName.text = self.AllPosts![indexPath.row].Poster
            cell.PostTitle.text = self.AllPosts![indexPath.row].PostTitle
            cell.Post.text = self.AllPosts![indexPath.row].Post
            let date = getCurrentDate(epoch: self.AllPosts![indexPath.row].PostDate)
            cell.PostDate.text = date
        }
        return(cell)
    }
    
    func getCurrentDate(epoch:Double)->String{
        let date = NSDate(timeIntervalSince1970: epoch)
        print(epoch)
        let formattedDate = self.formatDate(date: date)
        return formattedDate
    }
    func formatDate(date:NSDate)->String{
        let formater = DateFormatter()
        //formater.timeZone = TimeZone(abbreviation: "GMT")
        formater.dateFormat = "MMM dd YYYY, hh:mm"
        let dateString = formater.string(from: date as Date)
        print(dateString)
        return dateString
    }
    
    func getPosts(completion: @escaping (Bool, Any?, Error?) -> Void){
        ref = Database.database().reference()
        self.ref.child("Forum").observeSingleEvent(of: .value, with: { (snapshot) in
            var count = 1;
            var Posts:[ForumPost] = []
            for _ in snapshot.children{
                if let childSnapshot = snapshot.childSnapshot(forPath: "Post\(count)") as? DataSnapshot
                {
                    if let postDictionary = childSnapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                        if let post = postDictionary["Post"] as? String {
                            if let poster = postDictionary["Poster"] as? String{
                                if let postTitle = postDictionary["PostTitle"] as? String {
                                if let postDate = postDictionary["PostDate"] as? String {
                                    if let _ = postDictionary["Comments"] as? [AnyObject] {
                                        if let date = postDictionary["Epoch"] as? Double {
                                       let newComment:[Comment] = []
//                                        for comm in comment{
//                                          let createComment = Comment(Poster: , PostDate: "comm['PostDate']", Post: "comm['Post']")
//                                          newComment.append(createComment);
//                                        }
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
            }
                completion(true, Posts, nil);
        }){ (error) in
            print("Could not retrieve object from database");
            completion(false, nil, error)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        self.view.backgroundColor?.withAlphaComponent(0.2)
        self.getPosts(){(success, response, error) in
            guard success, let PostList = response as? [ForumPost] else{
                return
            }
            self.AllPosts = PostList
            self.NumberOfCells = PostList.count
            self.TableView.reloadData();
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
