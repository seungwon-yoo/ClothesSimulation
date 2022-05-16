//
//  CategoryCell.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/14.
//

import UIKit

class CategoryCell : UICollectionViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productName: UILabel!
    
    func update(info: ImageInfo) {
        productImageView.image = info.image
        productName.text = info.name
        // label.text = String(info.id)
    }
}
