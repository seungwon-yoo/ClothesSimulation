//
//  ClothesCollectionViewModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/25.
//

import UIKit

class ClothesCollectionViewModel {
    static let shared = ClothesCollectionViewModel()
    
    var imageInfoList: [ImageInfo] = []
    var totalImageInfoList: [ImageInfo] = []
    
    var currentCategory = "전체"
    
    let categoryList = ["OUTER", "TOP", "PANTS", "DRESS", "SKIRT"]
    let categoryDict = ["아우터": "OUTER", "상의": "TOP", "바지": "PANTS", "원피스": "DRESS", "스커트": "SKIRT"]
    
    func addImageInfo(of category: String, image: UIImage, path: String) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, path: path))
    }
    
    func addImageInfo(of category: String, image: UIImage, number: Int) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, number: number))
    }
    
    func addImageInfoSelectively(of category: String, image: UIImage, number: Int) {
        for imageInfo in totalImageInfoList {
            if imageInfo.category == category && imageInfo.number == number {
                return
            }
        }
        
        addImageInfo(of: category, image: image, number: number)
    }
    
    var countOfImageList: Int {
        return imageInfoList.count
    }
    
    func setToShowSpecificImageList(of category: String = "전체") {
        currentCategory = category
        imageInfoList.removeAll()
        
        if category == "전체" {
            imageInfoList = totalImageInfoList
            return
        }
        
        for imageInfo in totalImageInfoList {
            if imageInfo.category == categoryDict[category] {
                imageInfoList.append(imageInfo)
            }
        }
    }
    
    func imageInfo(at index: Int) -> ImageInfo {
        return imageInfoList[index]
    }
    
    func logout() {
        imageInfoList.removeAll()
        totalImageInfoList.removeAll()
    }
    
    func startInitialSettings() {
//        let url = "http://192.168.0.9:80"
//        let settingUrl = "/settings/init"
//        Alamofire.request(url + settingUrl, method: .get).responseJSON { response in
//            var settings: Settings
//            do {
//                let decoder = JSONDecoder()
//                settings = try decoder.decode(Settings.self, from: response.data!)
//
//                for clothes in settings.clothes {
//                    let imageUrl = clothes.image
//                    Alamofire.request(url + imageUrl, method: .get).response { response in
//                        if let image = UIImage(data: response.data!) {
//                            self.addImageInfo(category: clothes.category, image: image)
//                            self.setToShowSpecificImageList()
//                            // self.collectionView.reloadData()
//                        }
//                    }.resume()
//                }
//            } catch {
//                print("\(error)")
//            }
//        }.resume()
    }
}
