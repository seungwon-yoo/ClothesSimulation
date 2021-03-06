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
    
    var currentPage = 1
    
    var fetchingMore = false
    
    var imageInfoDict: [String: [ImageInfo]] = ["TOTAL": [],
                                                "OUTER": [],
                                                "TOP": [],
                                                "PANTS": [],
                                                "DRESS": [],
                                                "SKIRT": []]
    
    let categoryDict = ["전체": "TOTAL",
                        "아우터": "OUTER",
                        "상의": "TOP",
                        "바지": "PANTS",
                        "원피스": "DRESS",
                        "스커트": "SKIRT"]
    
    var currentCategory = "TOTAL"
    
    // currentCategory가 '전체'일 경우 -> 각 카테고리 당 5개씩 옷을 들고 온다
    // currentCategory가 개별 카테고리일 경우 -> 20개의 옷을 들고 온다
    
    var countOfImageList: Int {
        return imageInfoDict[currentCategory]!.count
    }
    
    func addImageInfo(of category: String, image: UIImage, path: String) {
        imageInfoDict[category]!.append(ImageInfo(category: category, image: image, path: path))
    }
    
    func imageInfo(at index: Int) -> ImageInfo {
        return imageInfoDict[currentCategory]![index]
    }
    
    func setupUI(progressView: UIProgressView, toolbar: UIToolbar, collectionView: UICollectionView) {
        
        // tool bar 선택 색상
        toolbar.items![toolbar.items!.startIndex].tintColor = .black
        
        setProgressView(progressView: progressView)
        
        // 이미지 가져와서 progress View, Collection View 화면에 띄우기
        fetchClothesImages(page: 1) {
            self.setProgressRate(progressView: progressView, currentValue: 5, totalValue: 5)
            collectionView.reloadData()
        }
    }
    
    func setupUI() {
        fetchClothesImages(page: 1) {
            return
        }
    }
    
    // 특정 카테고리의 이미지를 가져옴
    func fetchClothesImages(page: Int, completion: @escaping () -> Void) {
        
        if currentCategory == "TOTAL" {
            fetchTotalImages(page: page, numPerPage: K.numberPerPageInTotal, completion: completion)
        } else {
            fetchCategoryImages(of: currentCategory, page: page, numPerPage: K.numberPerPageInCategory, completion: completion)
        }
    }
    
    private func fetchTotalImages(page: Int, numPerPage: Int, completion: @escaping () -> Void) {
        K.categoryList.forEach { category in
            StorageService().fetchStorageClothesList(of: category) { result in
                switch result {
                case .success(let refArray):
                    let totalCount = refArray.count
                    
                    var count = 0
                    
                    if totalCount > page * numPerPage {
                        count = numPerPage
                    } else if totalCount > (page-1) * numPerPage {
                        count = totalCount - (page-1) * numPerPage
                    } else {
                        count = 0
                    }
                    
                    var completionCount: Int = count {
                        didSet(oldValue) {
                            if completionCount == 0 {
                                completion()
                            }
                        }
                    }
                    
                    refArray[(page-1)*numPerPage..<(page-1)*numPerPage+count].forEach { ref in
                        
                        StorageService().loadImage(childURL: ref.fullPath) { [weak self] result in
                            switch result {
                            case .success(let image):
                                self?.addImageInfo(of: self!.currentCategory, image: image, path: ref.fullPath)
                                
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
    }
    
    private func fetchCategoryImages(of category: String, page: Int, numPerPage: Int, completion: @escaping () -> Void) {
        StorageService().fetchStorageClothesList(of: category) { result in
            switch result {
            case .success(let refArray):
                let totalCount = refArray.count
                
                var count = 0
                
                if totalCount > page * numPerPage {
                    count = numPerPage
                } else if totalCount > (page-1) * numPerPage {
                    count = totalCount - (page-1) * numPerPage
                } else {
                    count = 0
                }
                
                var completionCount: Int = count {
                    didSet(oldValue) {
                        if completionCount == 0 {
                            completion()
                        }
                    }
                }
                
                refArray[(page-1)*numPerPage..<(page-1)*numPerPage+count].forEach { ref in
                    
                    StorageService().loadImage(childURL: ref.fullPath) { [weak self] result in
                        switch result {
                        case .success(let image):
                            self!.addImageInfo(of: self!.currentCategory, image: image, path: ref.fullPath)
                            
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
    
    // 프로그레스 뷰를 설정함
    func setProgressRate(progressView: UIProgressView, currentValue: Int, totalValue: Int) {
        let rate = Float(currentValue) / Float(totalValue)
        progressView.setProgress(rate, animated: true)
    }
    
    func logout() {
        for category in K.categoryList {
            imageInfoDict[category]?.removeAll()
        }
    }
    
    func initializeCategoryItems() {
        imageInfoDict[currentCategory]?.removeAll()
    }
    
    // 때려 맞춘다
    func setProgressView(progressView: UIProgressView) {
        // Progress View
        progressView.trackTintColor = .lightGray
        progressView.progressTintColor = .black
        progressView.progress = 0.1
        
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 * Double(i)) {
                self.setProgressRate(progressView: progressView, currentValue: i+1, totalValue: 5)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            progressView.trackTintColor = .white
            progressView.progressTintColor = .white
        }
    }
    
    func beginBatchFetch(completion: @escaping () -> Void) {
        fetchingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.currentPage += 1
            
            self.fetchClothesImages(page: self.currentPage, completion: completion)
            
        })
    }
}
