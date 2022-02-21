//
//  ViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Alamofire

class ClothesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    let model = ImageViewModel()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.countOfImageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? Cell else {
            return UICollectionViewCell()
        }
        
        let imageInfo = model.imageInfo(at: indexPath.item)
        cell.update(info: imageInfo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = model.imageInfo(at: indexPath.row).getImage() else {
            return
        }
        mainImageView.image = image
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startInitialSettings()
    }
    
    func startInitialSettings() {
        let url = "http://127.0.0.1:5000/settings/init"
        Alamofire.request(url, method: .get).responseJSON { response in
            var settings: Settings
            do {
                let decoder = JSONDecoder()
                settings = try decoder.decode(Settings.self, from: response.data!)
                
                for i in 0..<settings.result.count {
                    if let image = self.convertStringToUIImage(str: settings.result[i]) {
                        self.model.addImageInfo(index: i, image: image)
                    }
                }
                
                self.collectionView.reloadData()
            } catch {
                print("\(error)")
            }
        }.resume()
    }
    
    func convertStringToUIImage(str: String) -> UIImage? {
        if let data = Data(base64Encoded: str, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

class Cell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func update(info: ImageInfo) {
        imageView.image = info.image
        label.text = String(info.id)
    }
}

