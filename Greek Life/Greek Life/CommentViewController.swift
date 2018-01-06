//
//  CommentViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-03.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit
import FirebaseDatabase
import IQKeyboardManagerSwift
import UserNotifications

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
    let position = LoggedIn.User["Position"] as! String
    let userName = "\(LoggedIn.User["First Name"] as! String) \(LoggedIn.User["Last Name"] as! String)"
    let userId = LoggedIn.User["UserID"] as! String
    var InteractedCommentIndex = 0

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Toolbar: UIToolbar!
    @IBOutlet weak var Layout: UIStackView!
    
    @IBAction func BackToForum(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //--Process comment --//
    func leaveComment(sender: UIButton) {
        let date = Date().timeIntervalSince1970
       // let comment = CommentBox.text
        let components = textField.text!.components(separatedBy: .whitespacesAndNewlines)
        let PostWords = components.filter { !$0.isEmpty }
        if  textField.text == "" {
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
                "Post":  textField.text!,
                "Poster": self.userName,
                "Epoch": date,
                "PosterId": userId,
                "CommentId": postId
                ] as [String : Any]

            self.PostData(newPostData: NewComment){(success, error) in
                if error != nil {
                GenericTools.Logger(data: "\n Error posting comment: \(error!)")
                    let emptyError = UIAlertController(title: "Internal Server Error", message: "Error posting comment", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
                    emptyError.addAction(okAction)
                    self.present(emptyError, animated: true, completion: nil)
                }
                else {
                    self.textField.text = ""
                }
            }

        }
    }
    let textField = UITextView()
    let containerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        ReadCommentsForPost()
        IQKeyboardManager.sharedManager().enable = false
        self.TableView.allowsSelection = false
        TableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        self.TableView?.keyboardDismissMode = .interactive
        
       // textField.placeholder = "Enter comment..."
        textField.frame = CGRect(x: 0, y: 5 , width: (self.view.frame.width - 80), height:30)
        textField.backgroundColor = UIColor.white
        textField.delegate = self
        textField.layer.cornerRadius = 10

    }
    
    lazy var inputContainerView: UIView = {
        self.containerView.frame = CGRect(x:0, y:0, width: self.view.frame.width, height: 40)
        self.containerView.backgroundColor = UIColor.black
        self.containerView.layer.borderWidth = 0.5

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Post", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(leaveComment), for: .touchUpInside)
        self.containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: self.containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: self.containerView.heightAnchor).isActive = true

       self.containerView.addSubview(self.textField)
        
        self.textField.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 8).isActive = true
        self.textField.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        self.textField.rightAnchor.constraint(equalTo: sendButton.rightAnchor).isActive = true
        self.textField.heightAnchor.constraint(equalTo: self.containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        let color = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
       self.containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 8).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true


        
        return self.containerView
    }()
    
    func textViewDidChange(_ textField: UITextView) {
        let originalHeight = textField.frame.size.height
        if originalHeight < 100 {
            GenericTools.FrameToFitTextView(View: textField)
            let newHeight = textField.frame.size.height
            let diff = newHeight - originalHeight
            self.containerView.frame.origin.y -= diff
            self.containerView.frame.size.height += diff
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.containerView.frame.size.height = 40
        textField.frame.size.height = 30
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    //---Write comment data to database---//
    func PostData(newPostData: Dictionary<String, Any>, completion: @escaping (Bool, Any?) -> Void){
        let commentId = newPostData["CommentId"] as! String
        Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").child(commentId).setValue(newPostData){ error in
            GenericTools.Logger(data: "\n Could not post comment data: \(error)")
            completion(false, error)
        }
        completion(true, nil)
    }
    
    public func ReadCommentsForPost() {
        Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").observe(.value, with: { (snapshot) in
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
            Database.database().reference().child((Configuration.Config!["DatabaseNode"] as! String)+"/Forum").child(Postings.AllPosts![Postings.myIndex].PostId).child("Comments").child(CommentList[self.InteractedCommentIndex - 1].CommentId).removeValue(){ error in
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
            cell.layer.backgroundColor = UIColor(displayP3Red: 35/255, green: 35/255, blue: 35/255, alpha: 1).cgColor
            cell.CommenterName.textColor = UIColor(displayP3Red: 36/255, green: 91/255, blue: 155/255, alpha: 1)

            return cell
        }
        cell.Delete.isHidden = false
        //--Set Content--//
        if CommentList.count > 0 {
        cell.backgroundColor = UIColor(displayP3Red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        cell.layer.borderWidth = 0.1
        cell.CommenterName.text = CommentList[indexPath.row - 1].Poster
        let timeSince = CreateDate.getTimeSince(epoch: CommentList[indexPath.row - 1].PostEpoch)
        cell.CommentDate.text = timeSince
        cell.Comment.text = CommentList[indexPath.row - 1].Post
        //--Change cell height--//
        GenericTools.FrameToFitTextView(View: cell.Comment)
        cell.CommenterName.frame.origin.y = 20
        cell.CommentDate.frame.origin.y = cell.CommenterName.frame.origin.y
        cell.Comment.frame.origin.y = cell.CommenterName.frame.origin.y + cell.CommenterName.frame.size.height
        cell.Delete.frame.origin.y = (cell.Comment.frame.origin.y + cell.Comment.frame.size.height) + 5
            if CommentList[indexPath.row - 1].PosterId != self.userId && self.position != "Master" {
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
