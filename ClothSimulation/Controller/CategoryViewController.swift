//
//  CategoryViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/14.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let storage = Storage.storage()
    
    let db = Firestore.firestore()
    
    let model = CategoryCollectionViewModel.shared
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firestore에 사용자 의상 정보 초기화
        if let uid = UserInfo.shared.uid {
            let uidRef = db.collection("users").document(uid)

            uidRef.getDocument { document, error in
                if let document = document, document.exists {
                    print("Document exist")
                } else {
                    print("Document does not exist")
                    
                    self.initializeUserDB(uid: uid, email: UserInfo.shared.email!)
                }
            }
        }
        
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
        
        if category == "전체" { categories = model.categoryList }
        else { categories = [category] }
        
        for cat in categories {
            let mainURL = "gs://clothsimulation-3af50.appspot.com/"
            let url = mainURL + "clothes/" + cat
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
                    let url = mainURL// + ref.fullPath
                    
                    let ref = self.storage.reference(forURL: url).child(ref.fullPath)
                    
                    ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {

                            print(error)

                        } else {
                            if let image = UIImage(data: data! as Data) {
                                self.model.addImageInfo(category: cat, image: image, path: ref.fullPath)
                                
                                if category == "전체" {
                                    self.model.setToShowSpecificImageList()
                                } else {
                                    self.model.setToShowSpecificImageList(of: cat)
                                }
                                
                                count += 1
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
    
    func initializeUserDB(uid: String, email: String) {
        var data: [String: Any] = ["email": email]
        for cat in model.categoryList {
            data[cat] = []
        }
        
        db.collection("users").document(uid).setData(data)
    }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // Firestore 사용자 의상 정보에 해당 의상 추가
//        if let uid = UserInfo.shared.uid {
//            insertClothesInfo(imageInfo: model.imageInfo(at: indexPath.item), uid: uid)
//        }
        
        guard let vc = storyboard?.instantiateViewController(identifier: "clothesItemViewController") as? ClothesItemViewController else { return }
        
        let info = model.imageInfo(at: indexPath.item)
        vc.clothesInfo = info
        
        self.navigationController?.pushViewController(vc, animated: true)
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
