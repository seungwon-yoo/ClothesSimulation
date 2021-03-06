//
//  ClothesCollectionViewModel.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/04/25.
//

import UIKit
import SceneKit

class ClothesViewModel {

    static let shared = ClothesViewModel()
    
    var imageInfoList: [ImageInfo] = []
    var totalImageInfoList: [ImageInfo] = []
    
    var currentCategory = "전체"
    let categoryDict = ["아우터": "OUTER", "상의": "TOP", "바지": "PANTS", "원피스": "DRESS", "스커트": "SKIRT"]
    
    func addImageInfo(of category: String, image: UIImage, path: String) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, path: path))
    }
    
    func addImageInfo(of category: String, image: UIImage, name: String) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, name: name))
    }
    
    func addImageInfoSelectively(of category: String, image: UIImage, name: String) {
        for imageInfo in totalImageInfoList {
            if imageInfo.category == category && imageInfo.name == name {
                return
            }
        }
        
        addImageInfo(of: category, image: image, name: name)
    }
    
    func deleteImageInfo(imageInfo: ImageInfo) {
        FirestoreService().deleteClothesInfo(imageInfo: imageInfo, uid: UserInfo.shared.uid!)
        
        // 현재 삭제 후 바로 CollectionView에 반영되지 않는 문제가 있음.
        for (i, info) in totalImageInfoList.enumerated() {
            if info.category == imageInfo.category {
                if info.name == imageInfo.name {
                    totalImageInfoList.remove(at: i)
                }
            }
        }
        
        setToShowSpecificImageList(of: currentCategory)
    }
    
    var countOfImageList: Int {
        return imageInfoList.count
    }
    
    func setToShowSpecificImageList(of category: String = "전체") {
        currentCategory = category
        imageInfoList.removeAll()
        
        if category == "전체" {
            imageInfoList = totalImageInfoList
            return
        }
        
        for imageInfo in totalImageInfoList {
            if imageInfo.category == categoryDict[category] {
                imageInfoList.append(imageInfo)
                
                
            }
        }
    }
    
    func imageInfo(at index: Int) -> ImageInfo {
        return imageInfoList[index]
    }
    
    func logout() {
        imageInfoList.removeAll()
        totalImageInfoList.removeAll()
    }
    
    func fetchClothesInfo() {
        if let uid = UserInfo.shared.uid {
            FirestoreService().fetchUserCloset(uid: uid) { [weak self] result in
                switch result {
                case .success(let categories):
                    for categoryDict in categories {
                        let category = categoryDict.key
                        let elements = categoryDict.value
                        
                        if K.categoryList.contains(category) {
                            for element in elements as! Array<String> {
                                let fullPath = "clothes/\(category)/\(element).png"
                                
                                StorageService().loadImage(childURL: fullPath) { [weak self] result in
                                    switch result {
                                    case .success(let image):
                                        self!.addImageInfo(of: category, image: image, path: fullPath)
                                        self!.setToShowSpecificImageList()
                                        // collectionView.reloadData()
                                        // 이거 여러번 반복하는게 싫었는데 rx 공부하면 해결할 수 있다고 함.
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    if error == .emptyError { print("Document does not exist") }
                    else if error == .uidError { print(error) }
                }
            }
        }
    }
    
    func set3DModelUsingFileDirectory(sceneView: SCNView, url: URL) {
        guard let scene = try? SCNScene(url: url) else { fatalError("Unable to load scene file.") }
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 25)
        
        // 4: Set camera on scene
        scene.rootNode.addChildNode(cameraNode)
        
        // 5-1: Adding front light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 25)
        scene.rootNode.addChildNode(lightNode)
        
        // 5-2: Adding back light to scene
        let backLightNode = SCNNode()
        backLightNode.light = SCNLight()
        backLightNode.light?.type = .omni
        backLightNode.position = SCNVector3(x: 0, y: 10, z: -25)
        scene.rootNode.addChildNode(backLightNode)
        
        // 6: Creating and adding ambient light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.lightGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        // sceneView.allowsCameraControl = true
        
        // Set to manipulate camera
        
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
        
        // Set background color
        sceneView.backgroundColor = UIColor.white
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = false
        
        // Set scene settings
        sceneView.scene = scene
    }
    
    func set3DModel(sceneView: SCNView, name: String) {
        // 1: Load .obj file
        guard let scene = SCNScene(named: name) else { fatalError("Unable to load scene file.") }
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 25)
        
        // 4: Set camera on scene
        scene.rootNode.addChildNode(cameraNode)
        
        // 5-1: Adding front light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 25)
        scene.rootNode.addChildNode(lightNode)
        
        // 5-2: Adding back light to scene
        let backLightNode = SCNNode()
        backLightNode.light = SCNLight()
        backLightNode.light?.type = .omni
        backLightNode.position = SCNVector3(x: 0, y: 10, z: -25)
        scene.rootNode.addChildNode(backLightNode)
        
        // 6: Creating and adding ambient light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.lightGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        // sceneView.allowsCameraControl = true
        
        // Set to manipulate camera
        
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
        
        // Set background color
        sceneView.backgroundColor = UIColor.white
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = false
        
        // Set scene settings
        sceneView.scene = scene
    }
    
    func setTemp3DModel(sceneView: SCNView) {
        // 1: Load .obj file
        guard let scene = SCNScene(named: "art.scnassets/any_copy.scn") else { fatalError("Unable to load scene file.") }
        
        guard let topScene = SCNScene(named: "art.scnassets/clothes.scn") else { fatalError("Unable to load top clothes scene file.") }
        
        guard let botScene = SCNScene(named: "art.scnassets/bottom.scn") else { fatalError("Unable to load bot clothes scene file.") }
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        
        // 4: Set camera on scene
        scene.rootNode.addChildNode(cameraNode)
        
        // 5-1: Adding front light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 20)
        scene.rootNode.addChildNode(lightNode)
        
        // 5-2: Adding back light to scene
        let backLightNode = SCNNode()
        backLightNode.light = SCNLight()
        backLightNode.light?.type = .omni
        backLightNode.position = SCNVector3(x: 0, y: 0, z: -20)
        scene.rootNode.addChildNode(backLightNode)
        
        // 6: Creating and adding ambient light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.lightGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        // sceneView.allowsCameraControl = true
        
        // Set to manipulate camera
        
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
        
        // Set background color
        sceneView.backgroundColor = UIColor.white
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = false
        
        // Set scene settings
        sceneView.scene = scene
        
        // 모델에 의상을 직접 렌더링하기
        guard let topNode = topScene.rootNode.childNode(withName: "top", recursively: true) else {
            fatalError("error is occured about topNode.")
        }
        
        guard let botNode = botScene.rootNode.childNode(withName: "bot", recursively: true) else {
            fatalError("error is occured about botNode.")
        }
        
        sceneView.scene?.rootNode.addChildNode(topNode)
        sceneView.scene?.rootNode.addChildNode(botNode)
    }
}
