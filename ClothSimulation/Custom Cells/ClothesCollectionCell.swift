//
//  ClothesCollectionCell.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/27.
//

import UIKit

class ClothesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func update(info: ImageInfo) {
        imageView.image = info.image
        // label.text = String(info.id)
    }
}
