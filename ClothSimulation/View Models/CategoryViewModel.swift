//
//  ImageViewModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/21.
//

import Foundation
import UIKit
import FirebaseFirestore

class CategoryViewModel {
    static let shared = CategoryViewModel()
    
    var imageInfoList: [ImageInfo] = []
    var totalImageInfoList: [ImageInfo] = []
    
    var currentCategory = "전체"
    
    let categoryDict = ["아우터": "OUTER", "상의": "TOP", "바지": "PANTS", "원피스": "DRESS", "스커트": "SKIRT"]
    
    func addImageInfo(of category: String, image: UIImage, path: String) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, path: path))
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
    
    func setupUI(progressView: UIProgressView, toolbar: UIToolbar, collectionView: UICollectionView) {
        // Progress View
        progressView.trackTintColor = .lightGray
        progressView.progressTintColor = .black
        progressView.progress = 0.1
        
        // tool bar 선택 색상
        toolbar.items![toolbar.items!.startIndex].tintColor = .black
        
        // 의상 이미지 설정
        fetchAllImages(progressView: progressView, collectionView: collectionView)
        collectionView.reloadData()
    }
    
    // 특정 카테고리의 이미지를 가져옴
    func fetchClothesImages(of category: String, completion: @escaping () -> Void) {
        
        StorageService().fetchStorageClothesList(of: category) { result in
            switch result {
            case .success(let refArray):
                var completionCount: Int = refArray.count {
                    didSet(oldValue) {
                        if completionCount == 0 {
                            completion()
                        }
                    }
                }
                
                refArray.forEach { ref in
                    
                    StorageService().loadImage(childURL: ref.fullPath) { [weak self] result in
                        switch result {
                        case .success(let image):
                            self!.addImageInfo(of: category, image: image, path: ref.fullPath)
                            
                            completionCount -= 1
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // 모든 이미지를 가져옴
    func fetchAllImages(progressView: UIProgressView, collectionView: UICollectionView) {
        let categories = K.categoryList
        let total = categories.count
        
        var count: Int = 0 {
            didSet(oldValue) {
                if count == total {
                    setToShowSpecificImageList()
                    collectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        progressView.trackTintColor = .white
                        progressView.progressTintColor = .white
                    }
                }
            }
        }
        
        for cat in categories {
            fetchClothesImages(of: cat) {
                self.setProgressRate(progressView: progressView, currentValue: count+1, totalValue: total)
                count += 1
            }
        }
    }
    
    // 프로그레스 뷰를 설정함
    func setProgressRate(progressView: UIProgressView, currentValue: Int, totalValue: Int) {
        let rate = Float(currentValue) / Float(totalValue)
        progressView.setProgress(rate, animated: true)
    }
}
