//
//  MembersViewController.swift
//  Greek Life
//
//  Created by Jonah Elbaz on 2017-11-07.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var MemberImage: UIImageView!
    @IBOutlet weak var MemberName: UILabel!
    @IBOutlet weak var MemberSpecialty: UILabel!
    
}


class MembersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 //return number of cells --> should be array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let member = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as! MemberCollectionViewCell
        member.MemberSpecialty.text = "SOEN" //example -> Real value should be read from database.
        member.MemberName.text = "Jonah Elbaz" //example
        member.MemberImage.image = UIImage(named: "Docs/user_icon.png") //example
        
        return member //returns the cell defined above
    }

}
