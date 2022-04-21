//
//  CategoryViewModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/14.
//

import Foundation
import UIKit

class CategoryViewModel {
    var imageInfoList: [ImageInfo] = []
    var totalImageInfoList: [ImageInfo] = []
    
    func addImageInfo(category: String, image: UIImage) {
        totalImageInfoList.append(ImageInfo(category: category, image: image))
    }
    
    var countOfImageList: Int {
        return imageInfoList.count
    }
    
    func setToShowSpecificImageList(of category: String = "전체") {
        imageInfoList.removeAll()
        
        if category == "전체" {
            imageInfoList = totalImageInfoList
            return
        }
        
        for imageInfo in totalImageInfoList {
            if imageInfo.category == category {
                imageInfoList.append(imageInfo)
            }
        }
    }
    
    func imageInfo(at index: Int) -> ImageInfo {
        return imageInfoList[index]
    }
}
