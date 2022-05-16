//
//  ClothesItemView.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/25.
//

import UIKit

class CategoryItemViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var categoryLabel: UILabel?
    @IBOutlet var nameLabel: UILabel?
    
    var clothesInfo: ImageInfo?
    let model = ClothesViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialView()
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        if let uid = UserInfo.shared.uid {
            FirestoreService().insertClothesInfo(imageInfo: clothesInfo!, uid: uid)
            model.addImageInfoSelectively(of: clothesInfo!.category, image: clothesInfo!.image, name: clothesInfo!.name)
            model.setToShowSpecificImageList(of: model.currentCategory)
        }
    }
    
    func setInitialView() {
        categoryLabel?.text = clothesInfo?.category
        nameLabel?.text = clothesInfo?.name
        imageView?.image = clothesInfo?.image
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
    }
}


