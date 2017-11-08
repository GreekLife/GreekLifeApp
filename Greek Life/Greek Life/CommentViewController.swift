//
//  CommentViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-03.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var rowHeight:CGFloat = 0
    var ref: DatabaseReference!

    @IBOutlet weak var CommentBox: UITextView!
    @IBOutlet weak var CommentButton: UIButton!
    @IBOutlet weak var OriginalPost: UITextView!
    @IBOutlet weak var OriginalPoster: UILabel!
    @IBOutlet weak var OriginalPostDate: UILabel!
    
    @IBAction func LeaveComment(_ sender: Any) {
        let user = LoggedIn.User["Username"] as! String
        let date = Date().timeIntervalSince1970
        let comment = CommentBox.text
        if comment == "" {
            
        }
        else {
        let NewComment = [
            "Post": comment!,
            "Poster": user,
            "Epoch": date
        ] as [String : Any]
            PostData(newPostData: NewComment, completion: { (success, error) in
                self.CommentBox.text = ""
            })
            
        }
    }
    
    @IBAction func Exit(_ sender: Any) {
        performSegue(withIdentifier: "EndCommentView", sender: self)
        
    }
    
    @IBAction func AddComment(_ sender: Any) {
    }
    
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        ref = Database.database().reference()
        let commentID = UUID().uuidString
        self.ref.child("Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").child(commentID).setValue(newPostData)
        completion(true, nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.CommentBox.layer.borderWidth = 1
        self.CommentBox.layer.borderColor = UIColor.black.cgColor
        self.CommentBox.text = "Add comment here..."
        self.CommentButton.layer.cornerRadius = 10
        self.CommentButton.layer.shadowColor = UIColor.black.cgColor
        self.CommentButton.layer.shadowOpacity = 1
        self.CommentButton.layer.shadowOffset = CGSize.zero
        self.CommentButton.layer.shadowRadius = 10

        self.CommentBox.layer.cornerRadius = 10
        self.CommentBox.layer.shadowColor = UIColor.black.cgColor
        self.CommentBox.layer.shadowOpacity = 1
        self.CommentBox.layer.shadowOffset = CGSize.zero
        self.CommentBox.layer.shadowRadius = 10
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var postings = Postings.AllPosts?[Postings.myIndex].Comments.count
        if postings == nil{
            postings = 1
        }
        return postings!
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        Postings.AllPosts![Postings.myIndex].Comments = mergeSorting.mergeSort(Postings.AllPosts![Postings.myIndex].Comments)
        //style
        cell.layer.borderWidth = 1
        GenericTools.FrameToFitTextView(View: cell.Comment)
        let newHeight = cell.Comment.frame.size.height
        let cellHeight = newHeight
        self.rowHeight = 45 + cellHeight
        
        //content
        cell.Comment.text = Postings.AllPosts![Postings.myIndex].Comments[indexPath.row].Post //comment index out of bounds???
        cell.CommenterName.text = Postings.AllPosts![Postings.myIndex].Comments[indexPath.row].Poster
        cell.CommentDate.text = Postings.AllPosts![Postings.myIndex].Comments[indexPath.row].PostDate
        return(cell)
    }

}
