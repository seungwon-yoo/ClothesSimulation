//
//  ImageInfo.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/21.
//

import Foundation
import UIKit

struct ImageInfo {
    let id: Int
    let image: UIImage
    
    init(id: Int, image: UIImage) {
        self.id = id
        self.image = image
    }
    
    func getImage() -> UIImage? {
        return image
    }
}
