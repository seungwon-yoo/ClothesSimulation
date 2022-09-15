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
        
//        userModelService.userModelPath.bind { url in
//            guard let url = url else { return }
//
//            self.model.set3DModel(url: url) { scene in
//                self.setSceneViewConfiguration(scene)
//            }
//        }
        
        // 툴바 색 관련
        toolbar.items![toolbar.items!.startIndex].tintColor = .black
        
        model.setTemp3DModel { scene in
            self.setSceneViewConfiguration(scene)
        }
        
        setupLongPressGestureonCollectionView(collectionView: collectionView)
        
        sceneView.allowsCameraControl = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
    }
    
    @IBAction func changeButtonPressed(_ sender: UIButton) {
        // Create and configure the alert controller.
        let alert = UIAlertController(title: "모델 선택",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        // Create the action buttons for the alert.
        let bulkyManAction = createAlertAction(title: "일반 남성", modelName: K.ordinaryMan)
        let skinnyManAction = createAlertAction(title: "SMPL 남성", modelName: K.SMPLMan)
        let womanAction = createAlertAction(title: "SMPL 여성", modelName: K.SMPLWoman)
        
//        guard let url = userModelService.userModelPath.value else { return }
//        let userModelAction = UIAlertAction(title: "사용자 모델", style: .default) { (action) in
//            self.model.set3DModel(url: url) { scene in
//                self.setSceneViewConfiguration(scene)
//            }
//        }
//        alert.addAction(userModelAction)
        
        let request = HumanModel.fetchRequest()
        let data = PersistenceManager.shared.fetch(request: request)
        for (i, model) in data.enumerated() {
            let url = URL(string: UserModelService.shared.getFilePathInDocuments(fileName: model.fileName!)!)!
            alert.addAction(createAlertAction(title: "사용자 모델", number: i+1, url: url))
        }
        
        let cancelAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(bulkyManAction)
        alert.addAction(skinnyManAction)
        alert.addAction(womanAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func skinChangeButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "피부색 선택",
                                      message: "",
                                      preferredStyle: .actionSheet)
        
        let whiteSkinAction = UIAlertAction(title: "하얀 피부", style: .default) { (action) in
            self.sceneView.scene?.rootNode.childNode(withName: "human", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = UIColor(rgb: 0xFBE8D4)
        }
        
        let middleSkinAction = UIAlertAction(title: "중간 피부", style: .default) { (action) in
            self.sceneView.scene?.rootNode.childNode(withName: "human", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = UIColor(rgb: 0xE5BEA3)
        }
        
        let darkSkinAction = UIAlertAction(title: "어두운 피부", style: .default) { (action) in
            self.sceneView.scene?.rootNode.childNode(withName: "human", recursively: true)?.geometry?.firstMaterial?.diffuse.contents = UIColor(rgb: 0x9E694F)
        }
        
        let cancelAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(whiteSkinAction)
        alert.addAction(middleSkinAction)
        alert.addAction(darkSkinAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Emphasize the toolbar items
    @IBAction func itemTapped(_ sender: UIBarButtonItem) {
        model.setToShowSpecificImageList(of: sender.title!)
        
        toolbar.items!.indices.forEach {
            toolbar.items![$0].tintColor = .systemGray4
        }
        
        guard let senderIndex = toolbar.items?.firstIndex(of: sender) else { return }
        toolbar.items![senderIndex].tintColor = .black
        
        self.collectionView.reloadData()
    }
}

extension ClothesViewController {
    func setSceneViewConfiguration(_ scene: SCNScene) {
        sceneView.backgroundColor = UIColor.white
        sceneView.cameraControlConfiguration.allowsTranslation = false
        sceneView.scene = scene
    }
    
    func createAlertAction(title: String, modelName: String) -> UIAlertAction {
        UIAlertAction(title: title, style: .default) { (action) in
            self.model.set3DModel(modelName: modelName) { scene in
                self.setSceneViewConfiguration(scene)
            }
        }
    }
    
    func createAlertAction(title: String, number: Int, url: URL) -> UIAlertAction {
        let title = title + "\(number)"
        
            return UIAlertAction(title: title, style: .default) { action in
            self.model.set3DModel(url: url) { scene in
                self.setSceneViewConfiguration(scene)
                UserInfo.shared.addModeFilelName(modelFileName: "\(number).obj")
            }
        }
    }
}

//MARK: - UICollectionView Delegate Methods

extension ClothesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = model.imageInfo(at: indexPath.row).getImageName()
        
        // 해당 의상 이름 + 현재 인체 모델 -> CoreData에 저장되어 있는지 확인
        if let humanModelFileName = UserInfo.shared.modelFileName {
            let request = ClothesModel.fetchRequest()
            var data = PersistenceManager.shared.fetch(request: request)
            
            data = data.filter{$0.humanModelFileName == humanModelFileName && $0.name == imageName}
            
            // 1. 저장되어 있으면 입힌다
            if !data.isEmpty {
                let url = URL(string: UserModelService.shared.getFilePathInDocuments(fileName: data[0].fileName!)!)!
                
                model.putOnClothes(url: url) { node in
                    self.sceneView.scene?.rootNode.addChildNode(node)
                }
            }
            // 2. 저장되어 있지 않으면 의상을 다운로드 받는다
            else {
                //TODO: 의상 다운로드받는 코드 삽입
                userModelService.downloadClothesModel(humanFileName: humanModelFileName, clothesName: imageName)
            }
        }
        // UserInfo에 인체 모델 파일 이름이 없으면 임시방편으로 이미지 이름에 해당하는 옷을 art asset에서 찾아 입힌다
        else {
            // 해당 이름을 가진 3D 의상을 모델에 입힌다.
            model.putOnClothes(of: imageName) { node in
                self.sceneView.scene?.rootNode.addChildNode(node)
            }
            
            //        // 로딩창 띄우기
            //        DispatchQueue.main.async {
            //            self.activityIndicator.setActivityIndicator(view: self.tabBarController!.view)
            //        }
            //
            //        // 로딩창 종료 로직
            //        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            //            self.activityIndicator.endActivityIndicator(view: self.view)
            //        }
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
        if (gestureRecognizer.state != .began) { return }
        
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
