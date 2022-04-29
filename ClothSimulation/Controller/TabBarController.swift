//
//  TabBarController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/21.
//

import UIKit
import SideMenu
import Photos
import PhotosUI

class TabBarController: UITabBarController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.hidesBackButton = true
    }
    
    
}

//MARK: - Navigation right button functions

extension TabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 원래 뷰 컨트롤러에서 하려 했는데 self.navigationController?.navigationItem 요 부분이 먹통임.
        if item.title == "나의 모델" {
            activateRightButton()
        } else {
            deactivateRightButton()
        }
    }
    
    func activateRightButton() {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        
        rightButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightButton
        
    }
    
    func deactivateRightButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        // 갤러리 화면을 가져온다.
        if #available(iOS 14, *) {
            pickImage()
        } else {
            openGallery()
        }
    }
}

//MARK: - Navigation Items functions

extension TabBarController {
    func setNavItems() {
        // side menu button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: self,
            action: #selector(sideMenuPressed))

        self.navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc
    func sideMenuPressed() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Nav") as! CustomSideMenuNavigation
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - PHPPickerView functions

extension TabBarController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 이미지 선택이 끝나면 할 것들
        picker.dismiss(animated: true, completion: nil)
    }
    
    func pickImage() {
        var configuration = PHPickerConfiguration()
        
        
        
        configuration.selectionLimit = 1 // 가져올 이미지 갯수 제한
        configuration.filter = .any(of: [.images]) // 보여줄 asset type
        
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerController functions

extension TabBarController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 선택한 다음 할 것들
    }
    
    
    func openGallery() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}
