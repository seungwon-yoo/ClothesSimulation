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
    let number: Int
    
    init(category: String, image: UIImage, path: String) {
        self.category = category
        self.image = image
        
        let start = path.index(path.lastIndex(of: "/")!, offsetBy: 1)
        let end = path.index(path.endIndex, offsetBy: -5)
        
        self.number = Int(path[start...end])!
    }
    
    init(category: String, image: UIImage, number: Int) {
        self.category = category
        self.image = image
        self.number = number
    }
    
    func getImage() -> UIImage? {
        return image
    }
}
