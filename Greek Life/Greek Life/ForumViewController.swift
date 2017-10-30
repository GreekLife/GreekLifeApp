//
//  ForumViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-10-29.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class Comment {
    var Poster:String
    var PostDate:NSDate
    var Post:String
    
    init(Poster:String, PostDate:NSDate, Post:String){
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Post = Post;
    }
}

class ForumPost {
    var Post:String
    var Poster:String
    var PostDate:NSDate
    var Comments = [Comment]()
    
    init(Post:String, Poster:String, PostDate:NSDate,Comments:[Comment]){
        self.Post = Post;
        self.Poster = Poster;
        self.PostDate = PostDate;
        self.Comments = Comments;
    }
}

class ForumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var Posts:[ForumPost] = []
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(5)//number of cells
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    //edit cell however you want
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForumCell", for: indexPath) as! ForumCellTableViewCell
        
        return(cell)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        self.view.backgroundColor?.withAlphaComponent(0.2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
