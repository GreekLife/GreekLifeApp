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
    @IBOutlet weak var Delete: UIButton!
    
}
class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    var rowHeight:CGFloat = 0
    var ref: DatabaseReference!
    var CommentList:[Comment] = []
    let user = LoggedIn.User["Username"] as! String
    let userName = "\(LoggedIn.User["First Name"] as! String) \(LoggedIn.User["Last Name"] as! String)"
    let userId = LoggedIn.User["UserID"] as! String
    var OriginalTextHeight:CGFloat = 0
    var OriginalTextY:CGFloat = 0
    var OriginalViewY:CGFloat = 0
    var OriginalViewHeight:CGFloat = 0
    var InteractedCommentIndex = 0
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var LeaveComment: UIButton!
    @IBOutlet weak var CommentBox: UITextView!
    @IBOutlet weak var CommentView: UIView!
    @IBOutlet weak var Toolbar: UIToolbar!
    
    @IBAction func BackToForum(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //--Process comment --//
    @IBAction func LeaveComment(_ sender: Any) {
        let date = Date().timeIntervalSince1970
        let comment = CommentBox.text
        let components = comment!.components(separatedBy: .whitespacesAndNewlines)
        let PostWords = components.filter { !$0.isEmpty }
        if comment == "" {
            let emptyError = UIAlertController(title: "Empty Comment", message: "Your comment cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
        }
        else if PostWords.count > 200 {
            let emptyError = UIAlertController(title: "Too Large", message: "Your comment cannot be larger than 200 words!", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            emptyError.addAction(okAction)
            self.present(emptyError, animated: true, completion: nil)
        }
        else {
            let postId = UUID().uuidString
            let NewComment = [
                "Post": comment!,
                "Poster": self.userName,
                "Epoch": date,
                "PosterId": userId,
                "CommentId": postId
                ] as [String : Any]
            
            self.PostData(newPostData: NewComment){(success, error) in
                if error != nil {
                GenericTools.Logger(data: "\n Error posting comment: \(error!)")
                }
                else {
                self.CommentBox.text = ""
                self.CommentBox.frame.origin.y = self.OriginalTextY
                self.CommentBox.frame.size.height = self.OriginalTextHeight
                self.CommentView.frame.size.height = self.OriginalViewHeight
                self.CommentView.frame.origin.y = self.OriginalViewY
                self.view.endEditing(true)
                }

            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ReadCommentsForPost()
        self.TableView.allowsSelection = false
        self.CommentBox.layer.cornerRadius = 10
        self.CommentBox.delegate = self
        
         OriginalTextHeight = CommentBox.frame.size.height
         OriginalTextY = CommentBox.frame.origin.y
         OriginalViewY = CommentView.frame.origin.y
         OriginalViewHeight = CommentView.frame.size.height
    }
    
     func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let oldHeight = textView.frame.size.height
        if oldHeight <= (2.5 * OriginalTextHeight) {
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newFrame = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame.size = newFrame
        let heightChange = newSize.height - oldHeight
        self.CommentView.frame.origin.y -= heightChange
        self.CommentView.frame.size.height += heightChange
        NewTextHeight = textView.frame.size.height
        NewTextY = textView.frame.origin.y
        NewViewY = self.CommentView.frame.origin.y
        NewViewHeight = self.CommentView.frame.size.height
        }
    }
    
    var NewTextHeight:CGFloat = 0
    var NewTextY:CGFloat = 0
    var NewViewY:CGFloat = 0
    var NewViewHeight:CGFloat = 0
    var HeightChanged = false
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if HeightChanged == true {
        self.CommentView.frame.size.height = NewViewHeight
        self.CommentView.frame.origin.y = NewViewY
        self.CommentBox.frame.size.height = NewTextHeight
        self.CommentBox.frame.origin.y = NewTextY
        }
    }
    
    //---Write comment data to database---//
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Any?) -> Void){
        let commentId = newPostData["CommentId"] as! String
        Database.database().reference().child("Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").child(commentId).setValue(newPostData){ error in
            GenericTools.Logger(data: "\n Could not post comment data: \(error)")
            completion(false, error)
        }
        completion(true, nil)
    }
    
    public func ReadCommentsForPost() {
        Database.database().reference().child("Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").observe(.value, with: { (snapshot) in
            self.CommentList.removeAll();
            for snap in snapshot.children{
                if let childSnapshot = snap as? DataSnapshot
                {
                   if let postDictionary = childSnapshot.value as? [String:AnyObject] , postDictionary.count > 0{
                     if let comment = postDictionary["Post"] as? String {
                        if let commenter = postDictionary["Poster"] as? String {
                            if let commentDate = postDictionary["Epoch"] as? Double {
                                if let commenterId = postDictionary["PosterId"] as? String {
                                    if let commentID = postDictionary["CommentId"] as? String {
                            let pDate = CreateDate.getCurrentDate(epoch: commentDate)
                                    let aComment = Comment(Poster: commenter, PostDate: pDate, PostEpoch: commentDate, Post: comment, PosterId: commenterId, CommentId: commentID)
                                self.CommentList.append(aComment)
                            }
                        }
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
            GenericTools.Logger(data: "\n Could not retrieve comments: \(error)")
        }
    }
    
    @objc func DeleteBtn(button: UIButton) {
        let cell = button.superview?.superviewOfClassType(UITableViewCell.self) as! UITableViewCell
        let tbl = cell.superviewOfClassType(UITableView.self) as! UITableView
        let indexPath = tbl.indexPath(for: cell)
        self.InteractedCommentIndex = indexPath!.row
        let delete = UIAlertController(title: "Delete", message: "Are you sure you would like to delete your comment?", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: DeleteComment)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default)
        delete.addAction(cancelAction)
        delete.addAction(okAction)
        self.present(delete, animated: true, completion: nil)
    }
    
    func DeleteComment(action: UIAlertAction) {
            Database.database().reference().child("Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").child(CommentList[self.InteractedCommentIndex - 1].CommentId).removeValue(){ error in
            GenericTools.Logger(data: "\n Could not remove comment: \(error)")
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        if(indexPath.row == 0){
            cell.Comment.text = Postings.AllPosts![Postings.myIndex].Post
            cell.CommenterName.text = Postings.AllPosts![Postings.myIndex].Poster
            let timeSince = CreateDate.getTimeSince(epoch: Postings.AllPosts![Postings.myIndex].PostDate) //4 days
            cell.CommentDate.text = timeSince
            GenericTools.FrameToFitTextView(View: cell.Comment)
            cell.layer.borderWidth = 1
            self.rowHeight = cell.Comment.frame.origin.y + cell.Comment.frame.size.height + 30
            cell.Delete.isHidden = true

            return cell
        }
        cell.Delete.isHidden = false
        //--Set Content--//
        if CommentList.count > 0 {
            cell.backgroundColor = .white
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor(displayP3Red: 250/255, green: 234/255, blue: 234/255, alpha: 0.5)
            }
            else {
            }
        cell.layer.borderWidth = 0.1
        cell.CommenterName.text = CommentList[indexPath.row - 1].Poster
        let timeSince = CreateDate.getTimeSince(epoch: CommentList[indexPath.row - 1].PostEpoch)
        cell.CommentDate.text = timeSince
        cell.Comment.text = CommentList[indexPath.row - 1].Post
        if CommentList[indexPath.row - 1].PosterId  == self.userId {
            cell.CommenterName.textColor = .blue
        }
        //--Change cell height--//
        GenericTools.FrameToFitTextView(View: cell.Comment)
        cell.CommenterName.frame.origin.y = 20
        cell.CommentDate.frame.origin.y = cell.CommenterName.frame.origin.y
        cell.Comment.frame.origin.y = cell.CommenterName.frame.origin.y + cell.CommenterName.frame.size.height
        cell.Delete.frame.origin.y = (cell.Comment.frame.origin.y + cell.Comment.frame.size.height) + 5
            if CommentList[indexPath.row - 1].PosterId != self.userId && self.user != "Master" {
                cell.Delete.isHidden = true
                self.rowHeight = cell.Comment.frame.origin.y + cell.Comment.frame.size.height
            }
            else {
                cell.Delete.addTarget(self, action: #selector(DeleteBtn(button:)), for: .touchUpInside)
                self.rowHeight = cell.Delete.frame.origin.y + cell.Delete.frame.size.height + 5
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentList.count + 1
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }

}
