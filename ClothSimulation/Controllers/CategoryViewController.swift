//
//  CategoryViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/14.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let model = CategoryViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CollectionView Settings
        collectionView.delegate = self
        collectionView.dataSource = self
        
        progressView.trackTintColor = .white
        progressView.progressTintColor = .white
        
        collectionView.register(PageCollectionViewCell.nib(), forCellWithReuseIdentifier: PageCollectionViewCell.identifier)
        
        // tool bar 선택 색상
        toolbar.items![toolbar.items!.startIndex].tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }
    
    //MARK: - Emphasize the toolbar items
    @IBAction func itemTapped(_ sender: UIBarButtonItem) {
        
        model.initializeCategoryItems()
        
        model.currentCategory = K.categoryDict[sender.title!]!
        
        model.setProgressView(progressView: progressView)
        model.fetchClothesImages(page: 1) { [weak self] in
            self!.model.setProgressRate(progressView: self!.progressView, currentValue: 5, totalValue: 5)
            self!.collectionView.reloadData()
            self!.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        
        for index in toolbar.items!.indices {
            toolbar.items![index].tintColor = .systemGray4
        }
        
        if let senderIndex = toolbar.items?.firstIndex(of: sender) {
            toolbar.items![senderIndex].tintColor = .black
        }
    }
}

//MARK: - Collection View Functions
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
        
        guard let vc = storyboard?.instantiateViewController(identifier: "CategoryItemViewController") as? CategoryItemViewController else { return }
        
        let info = model.imageInfo(at: indexPath.item)
        vc.clothesInfo = info
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.contentOffset.y > (collectionView.contentSize.height - collectionView.bounds.size.height) {
            if !model.fetchingMore {
                model.beginBatchFetch {
                    self.model.fetchingMore = false
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

//MARK: - Collection View Cell Layout Functions
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
        
        if indexPath.row == model.countOfImageList {
            
            let width = collectionView.frame.width
            
            let height = collectionView.frame.width / 2 - 1
            
            let size = CGSize(width: width, height: height)
            
            return size
            
        } else {
            let width = collectionView.frame.width / 2 - 1 ///  2등분하여 배치, 옆 간격이 1이므로 1을 빼줌
            
            //        print("collectionView width=\(collectionView.frame.width)")
            //        print("cell하나당 width=\(width)")
            //        print("root view width = \(self.view.frame.width)")
            
            let size = CGSize(width: width, height: width)
            return size
        }
    }
}
