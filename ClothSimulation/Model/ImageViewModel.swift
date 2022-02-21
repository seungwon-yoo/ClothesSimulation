//
//  ImageViewModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/21.
//

import Foundation
import UIKit

class ImageViewModel {
    var imageInfoList: [ImageInfo] = []
    
    func addImageInfo(index: Int, image: UIImage) {
        imageInfoList.append(ImageInfo(id: index, image: image))
    }
    
    var countOfImageList: Int {
        return imageInfoList.count
    }
    
    func imageInfo(at index: Int) -> ImageInfo {
        return imageInfoList[index]
    }
}
