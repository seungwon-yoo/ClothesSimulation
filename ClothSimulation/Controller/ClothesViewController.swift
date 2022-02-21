//
//  ViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Alamofire

class ClothesViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    
    let corgiList = ["corgi1","corgi2","corgi3","corgi4","corgi5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for corgi in corgiList {
            let dummyView = configureStackView(name: corgi)
            stackView.addArrangedSubview(dummyView)
        }
    }
    
    func configureStackView(name: String) -> UIImageView {
        let view = UIImageView()
        if let image = UIImage(named: name) {
            let resizedImage = resizeImage(image: image, width: 180, height: 180)
            view.image = resizedImage
            view.contentMode = .scaleAspectFit
        }
        
        return view
    }
    
    // 이미지 사이즈 조절
    func resizeImage(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?
            .withAlignmentRectInsets(UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5))
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

