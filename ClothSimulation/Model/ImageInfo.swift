//
//  ImageInfo.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/21.
//

import Foundation
import UIKit

struct ImageInfo {
    let category: String
    let image: UIImage
    
    init(category: String, image: UIImage) {
        self.category = category
        self.image = image
    }
    
    func getImage() -> UIImage? {
        return image
    }
}
