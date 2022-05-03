//
//  CategoryInfo.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/14.
//

import Foundation
import UIKit

struct CategoryInfo {
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
