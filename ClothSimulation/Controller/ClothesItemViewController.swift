//
//  ClothesItemView.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/25.
//

import UIKit

class ClothesItemViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var categoryLabel: UILabel?
    @IBOutlet var nameLabel: UILabel?
    
    var clothesInfo: ImageInfo?
    let model = ClothesCollectionViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLabel?.text = clothesInfo?.category
        nameLabel?.text = String(clothesInfo!.number)
        imageView?.image = clothesInfo?.image
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        if let uid = UserInfo.shared.uid {
            insertClothesInfo(imageInfo: clothesInfo!, uid: uid)
            model.addImageInfoSelectively(of: clothesInfo!.category, image: clothesInfo!.image, number: clothesInfo!.number)
            model.setToShowSpecificImageList(of: model.currentCategory)
        }
    }
}


