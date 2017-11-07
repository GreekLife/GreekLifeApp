//
//  BrotherViewController.swift
//  Greek Life
//
//  Created by Brandon Goldwax on 2017-11-06.
//  Copyright © 2017 ConcordiaDev. All rights reserved.
//

import UIKit

class BrotherView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
   
    let brothers: [String] = ["Bradley Hier", "Hershey Bl", "Jonah Elbaz", "Jordan Fefer", "Mike Nashen", "Nate Polachek", "Stevie Conscister", "Swann Sauves"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brothers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let brotherPic = collectionView.dequeueReusableCell(withReuseIdentifier: "brotherPic", for: indexPath) as! brotherImg
        brotherPic.brotherImage.image = UIImage(named: brothers[indexPath.row] + ".png")
        return brotherPic
    }
    
    
    
}
