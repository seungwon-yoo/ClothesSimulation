//
//  ViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import SceneKit

class ClothesViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let model = ClothesViewModel.shared
    let userModelService = UserModelService.shared
    let activityIndicator = ActivityIndicatorService()
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userModelService.userModelPath.bind { url in
            if let url = url {
                self.model.set3DModelUsingFileDirectory(sceneView: self.sceneView, url: url)
            }
        }
        
//        userModelService.userModelPath.bind { path in
//            if let path = path {
//                self.model.set3DModel(sceneView: self.sceneView, name: path)
//            }
//        }
        
        // 툴바 색 관련
        toolbar.items![toolbar.items!.startIndex].tintColor = .black
        
        model.set3DModel(sceneView: sceneView, name: K.dancingMan)
        
        setupLongPressGestureonCollectionView(collectionView: collectionView)
        
        sceneView.allowsCameraControl = true
        
        // set3DModel(name: "art.scnassets/bboyFixed.scn")
        
        // model.fetchClothesInfo(collectionView: collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }
    
//    //MARK: - 3D model View settings
//    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
//        let transition = sender.translation(in: sceneView)
//        sceneView.defaultCameraController.rotateBy(x: Float(-transition.x), y: Float(0))
//        sender.setTranslation(CGPoint.zero, in: sceneView)
//    }
    
//    @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer) {
//        // 모델 자체를 확대 축소해야 한다.
//        let cameraNode = sceneView.scene?.rootNode.childNodes[1]
//        let maximumFOV:CGFloat = 25
//        let minimumFOV:CGFloat = 90
//
//        switch sender.state {
//        case .began:
//            break
//        case .changed:
//            cameraNode?.camera?.fieldOfView = (cameraNode?.camera!.fieldOfView)! - sender.velocity
//            if (cameraNode?.camera!.fieldOfView)! <= maximumFOV {
//                cameraNode?.camera?.fieldOfView = maximumFOV
//            }
//            if (cameraNode?.camera!.fieldOfView)! >= minimumFOV {
//                cameraNode?.camera?.fieldOfView = minimumFOV
//            }
//        default:
//            break
//        }
//    }
    
    @IBAction func changeButtonPressed(_ sender: UIButton) {
        // Create the action buttons for the alert.
        let bulkyManAction = UIAlertAction(title: "일반 남성",
                                      style: .default) { (action) in
            self.model.set3DModel(sceneView: self.sceneView, name: K.ordinaryMan)
        }
        let skinnyManAction = UIAlertAction(title: "SMPL 남성",
                                      style: .default) { (action) in
            self.model.set3DModel(sceneView: self.sceneView, name: K.SMPLMan)
        }
        let womanAction = UIAlertAction(title: "SMPL 여성",
                                        style: .default) { (action) in
            self.model.set3DModel(sceneView: self.sceneView, name: K.SMPLWoman)
        }
        let cancelAction = UIAlertAction(title: "닫기", style: .cancel)
        
        // Create and configure the alert controller.
        let alert = UIAlertController(title: "모델 선택",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(bulkyManAction)
        alert.addAction(skinnyManAction)
        alert.addAction(womanAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
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
}

//MARK: - UICollectionView Delegate Methods

extension ClothesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = model.imageInfo(at: indexPath.row).getImage() else {
            return
        }
        
        // 로딩창 띄우기
        DispatchQueue.main.async {
            self.activityIndicator.setActivityIndicator(view: self.tabBarController!.view)
        }
        
        // 로딩창 종료 로직
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.activityIndicator.endActivityIndicator(view: self.view)
        }
    }
}

//MARK: - UICollectionView DataSource Methods

extension ClothesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.countOfImageList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ClothesCollectionCell else {
            return UICollectionViewCell()
        }
        
        let imageInfo = model.imageInfo(at: indexPath.item)
        cell.update(info: imageInfo)
        
        return cell
    }
}

//MARK: - UICollectionView long press gesture
extension ClothesViewController: UIGestureRecognizerDelegate {
    func setupLongPressGestureonCollectionView(collectionView: UICollectionView) {
        let longPressedGesture = UILongPressGestureRecognizer()
        longPressedGesture.addTarget(self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        
        let p = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = collectionView.indexPathForItem(at: p) {
            print("Long press at item: \(indexPath.row)")
            
            let deleteAction = UIAlertAction(title: "Delete",
                                             style: .destructive) { action in
                // CollectionView Cell delete
                let imageInfo = self.model.imageInfo(at: indexPath.item)
                self.model.deleteImageInfo(imageInfo: imageInfo)
                self.collectionView.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "닫기", style: .cancel)
            
            let alert = UIAlertController(title: "의상 삭제",
                                          message: "해당 의상을 옷장에서 삭제하려면 Delete를 눌러주세요",
                                          preferredStyle: .actionSheet)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
