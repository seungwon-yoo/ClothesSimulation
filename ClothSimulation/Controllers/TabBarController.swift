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
import NVActivityIndicatorView
import Alamofire

class TabBarController: UITabBarController, UINavigationControllerDelegate {
    let model = ClothesViewModel.shared
    let userModelService = UserModelService.shared
    let activityIndicator = ActivityIndicatorService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavItems()
        
        self.navigationItem.title = "의상"
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
            self.navigationItem.title = "나의 옷장"
        } else {
            deactivateRightButton()
            self.navigationItem.title = "의상"
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
        let cameraAction = UIAlertAction(title: "카메라", style: .default) { (action) in
            let camera = UIImagePickerController()
            camera.sourceType = .camera
            camera.allowsEditing = false
            camera.cameraDevice = .rear
            camera.cameraCaptureMode = .photo
            camera.delegate = self
            self.present(camera, animated: true, completion: nil)
        }
        let galleryAction = UIAlertAction(title: "앨범", style: .default) { (action) in
            // 갤러리 화면을 가져온다.
            if #available(iOS 14, *) {
                self.pickImage()
            } else {
                self.openGallery()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (action) in
            // Respond to user selection of the action
        }
        
        let alert = UIAlertController(title: "이미지 가져오기",
                                      message: "모델로 사용할 이미지를 가져옵니다.",
                                      preferredStyle: .actionSheet)
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
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
        
        picker.dismiss(animated: true, completion: nil)
        
        guard results.isEmpty != true else { return }
        
        // 1. 선택한 이미지를 웹 서버로 전송
        let itemProvider = results[0].itemProvider
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let image = object as? UIImage {
                    self.userModelService.getUserModel(image) {
                        // 로딩창 종료 로직
                        self.activityIndicator.endActivityIndicator(view: self.view)
                    }
                    // self.userModelService.getTempUserModel()
                }
            }
        }
        
        
        // 2. 로딩창 띄우기
        DispatchQueue.main.async {
            self.activityIndicator.setActivityIndicator(view: self.view)
        }
//
//        // 로딩창 종료 로직
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.activityIndicator.endActivityIndicator(view: self.view)
//        }
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
        
        picker.dismiss(animated: true, completion: nil)
        
        // 1. 선택한 이미지를 웹 서버로 전송
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // userModelService.getTempUserModel()
            userModelService.getUserModel(image) {
                // 로딩창 종료 로직
                self.activityIndicator.endActivityIndicator(view: self.view)
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        
        // 2. 로딩창 띄우기
        DispatchQueue.main.async {
            self.activityIndicator.setActivityIndicator(view: self.view)
        }
    }
    
    
    func openGallery() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}
