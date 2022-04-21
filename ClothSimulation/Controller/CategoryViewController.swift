//
//  CategoryViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/14.
//

import UIKit
import FirebaseStorage

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let storage = Storage.storage()
    
    let model = ImageViewModel()
    
    let categoryDict = ["아우터": "OUTER", "상의": "TOP", "바지": "PANTS", "원피스": "DRESS", "스커트": "SKIRT", "신발": "SNEAKERS", "모자": "CAP", "악세사리": "ACCESSORY"]
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Progress View
        progressView.trackTintColor = .lightGray
        progressView.progressTintColor = .black
        progressView.progress = 0.1
        
        // tool bar 선택 색상
        toolbar.items![toolbar.items!.startIndex].tintColor = .black
        
        // collectionView setting
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // 의상 이미지 설정
        downloadSpecificCategoryImages()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = "의상"
    }
    
    func downloadSpecificCategoryImages(of category: String = "전체") {
        var categories: [String]
        
        if category == "전체" { categories = Array(categoryDict.keys) }
        else { categories = [categoryDict[category]!] }
        
        for cat in categories {
            let mainURL = "gs://clothsimulation-3af50.appspot.com/"
            let url = mainURL + "clothes/" + categoryDict[cat]!
            storage.reference(forURL: url).listAll { result, error in
                if let error = error {
                    print(error)
                }
                
                // progressView 설정
                var count: Int = 0 {
                    didSet(oldValue) {
                        let rate = Float(count) / Float(result.items.count)
                        self.progressView.setProgress(rate, animated: true)
                        
                        if count == result.items.count {
                            
                            self.collectionView.reloadData()
                            
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                                self.progressView.trackTintColor = .white
                                self.progressView.progressTintColor = .white
                            }
                        }
                    }
                }
                
                result.items.forEach { ref in
                    let url = mainURL + ref.fullPath
                    
                    self.storage.reference(forURL: url).downloadURL { url, error in
                        if let error = error {
                            
                            print(error)
                            
                        } else {
                            
                            let data = NSData(contentsOf: url!)
                            if let image = UIImage(data: data! as Data) {
                                self.model.addImageInfo(category: cat, image: image, path: ref.fullPath)
                                self.model.setToShowSpecificImageList(of: cat)
                                count += 1
                                // self.collectionView.reloadData()
                            }
                            
                        }
                    }
                }
            }
            
        }
    }
    
    //MARK: - Emphasize the toolbar items
    @IBAction func itemTapped(_ sender: UIBarButtonItem) {
        model.setToShowSpecificImageList(of: sender.title!)
        
        for index in toolbar.items!.indices {
            toolbar.items![index].tintColor = .systemGray4
        }
        
        if let senderIndex = toolbar.items?.firstIndex(of: sender) {
            toolbar.items![senderIndex].tintColor = .black
        }
        
            self.collectionView.reloadData()
    }
    
//    //MARK: - Emphasize the toolbar items
//    @IBAction func itemTapped(_ sender: UIBarButtonItem) {
//        model.setToShowSpecificImageList(of: categoryDict[sender.title!])
//
//        for index in toolbar.items!.indices {
//            toolbar.items![index].tintColor = .systemGray4
//        }
//
//        if let senderIndex = toolbar.items?.firstIndex(of: sender) {
//            toolbar.items![senderIndex].tintColor = .systemBlue
//        }
//
//        self.collectionView.reloadData()
//    }
    
    
}

// cell data
extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.countOfImageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoryCell
        
        let imageInfo = model.imageInfo(at: indexPath.item)
        cell.update(info: imageInfo)
        
        return cell
    }
}

// cell layout
extension CategoryViewController: UICollectionViewDelegateFlowLayout {

    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width / 3 - 1 ///  3등분하여 배치, 옆 간격이 1이므로 1을 빼줌
        print("collectionView width=\(collectionView.frame.width)")
        print("cell하나당 width=\(width)")
        print("root view width = \(self.view.frame.width)")

        let size = CGSize(width: width, height: width)
        return size
    }
}
