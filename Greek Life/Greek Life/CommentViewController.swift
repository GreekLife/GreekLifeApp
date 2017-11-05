//
//  CommentViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-03.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var rowHeight:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(displayP3Red: 2/255, green: 0/255, blue: 176/255, alpha: 0.1)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Postings.AllPosts![Postings.myIndex].Comments.count
    }
    var commentIndex = 0
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        cell.Comment.text = Postings.AllPosts![Postings.myIndex].Comments[commentIndex].Post
        cell.CommenterName.text = Postings.AllPosts![Postings.myIndex].Comments[commentIndex].Poster
        cell.CommentDate.text = Postings.AllPosts![Postings.myIndex].Comments[commentIndex].PostDate
        commentIndex += 1
        
        let oldWidth = cell.Comment.frame.size.width
        GenericTools.FrameToFitTextView(View: cell.Comment)
        cell.Comment.frame.size.width = oldWidth
        let newHeight = cell.Comment.frame.size.height
        let cellHeight = 127 + newHeight
        self.rowHeight = cellHeight
        return(cell)
    }

}
