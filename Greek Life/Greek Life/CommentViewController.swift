//
//  CommentViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-03.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var CommentDate: UILabel!
    @IBOutlet weak var CommenterName: UILabel!
    @IBOutlet weak var Comment: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var rowHeight:CGFloat = 0
    var ref: DatabaseReference!
    var CommentList:[Comment] = []
    let user = LoggedIn.User["Username"] as! String

    @IBAction func BackToForum(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //---Prototype cell component declarations---//
    @IBOutlet weak var TableView: UITableView!
    
    //---Function to add a comment to a post---//
    @IBOutlet weak var CommentBox: UITextField!
    @IBOutlet weak var LeaveComment: UIBarButtonItem! //button
    @IBAction func LeaveComment(_ sender: Any) {
        let date = Date().timeIntervalSince1970
        let comment = CommentBox.text
        let components = comment!.components(separatedBy: .whitespacesAndNewlines)
        let PostWords = components.filter { !$0.isEmpty }
        if comment == "" {
            let emptyError = UIAlertController(title: "Empty Comment", message: "Your Comment cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
            self.present(emptyError, animated: true, completion: nil)
        }
        else if PostWords.count > 200 {
            let emptyError = UIAlertController(title: "Too Large", message: "Your Comment cannot be larger than 200 words!", preferredStyle: UIAlertControllerStyle.alert)
            self.present(emptyError, animated: true, completion: nil)
        }
        else {
            let NewComment = [
                "Post": comment!,
                "Poster": self.user,
                "Epoch": date
                ] as [String : Any]
            PostData(newPostData: NewComment, completion: { (success, error) in
                self.CommentBox.text = ""
            })
            
        }
    }
    
    //---Write comment data to database---//
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Error?) -> Void){
        ref = Database.database().reference()
        let commentID = UUID().uuidString
        self.ref.child("Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").child(commentID).setValue(newPostData)
        completion(true, nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ReadCommentsForPost()
        self.TableView.allowsSelection = false
        

        //---Add styles---//
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func ReadCommentsForPost() {
        ref = Database.database().reference()
        ref.child("Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").observe(.value, with: { (snapshot) in
            self.CommentList.removeAll();
            for snap in snapshot.children{
                if let childSnapshot = snap as? DataSnapshot
                {
                   if let postDictionary = childSnapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                     if let comment = postDictionary["Post"] as? String {
                        if let commenter = postDictionary["Poster"] as? String {
                            if let commentDate = postDictionary["Epoch"] as? Double {
                            let pDate = CreateDate.getCurrentDate(epoch: commentDate)
                              let aComment = Comment(Poster: commenter, PostDate: pDate, PostEpoch: commentDate, Post: comment)
                                self.CommentList.append(aComment)
                      }
                    }
                  }
                }
            }
        }
           self.CommentList = mergeSorting.mergeSort(self.CommentList)
            self.CommentList = self.CommentList.reversed()
           self.TableView.reloadData();
        }){ (error) in
            print("Could not retrieve object from database");
        }
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        if(indexPath.row == 0){
            cell.layer.borderWidth = 1
            cell.Comment.text = Postings.AllPosts![Postings.myIndex].Post
            cell.CommenterName.text = Postings.AllPosts![Postings.myIndex].Poster
            cell.CommenterName.textColor = UIColor.purple
            let timeSince = CreateDate.getTimeSince(epoch: Postings.AllPosts![Postings.myIndex].PostDate) //4 days
            cell.CommentDate.text = timeSince
            
            GenericTools.FrameToFitTextView(View: cell.Comment)
            self.rowHeight = cell.Comment.frame.origin.y + cell.Comment.frame.size.height
            
            return cell
        }

        //--Set Content--//
        if CommentList.count > 0 {
        cell.layer.borderWidth = 0.1
        cell.Comment.text = CommentList[indexPath.row - 1].Post
        cell.CommenterName.text = CommentList[indexPath.row - 1].Poster
        cell.CommenterName.textColor = .blue
        if cell.CommenterName.text == self.user {
            cell.CommenterName.textColor = .green
        }
        let timeSince = CreateDate.getTimeSince(epoch: CommentList[indexPath.row - 1].PostEpoch) //<4 days
        cell.CommentDate.text = timeSince
        
        //--Change cell height--//
        let oldHeight = cell.Comment.frame.size.height
        GenericTools.FrameToFitTextView(View: cell.Comment)
        let newHeight = cell.Comment.frame.size.height
        let cellHeight = newHeight + 20 + 12
        let heightDifference = oldHeight - newHeight
        cell.CommentDate.frame.size.height -= heightDifference
        self.rowHeight = cellHeight
        
        }
        return(cell)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var postings = CommentList.count
        if postings == 0 {
            postings = 1
        }
        return postings + 1
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }

}
