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
    var totalImageInfoList: [ImageInfo] = [ImageInfo(category: "TOP", image: UIImage(named: "black_top")!, name: "black_top"), ImageInfo(category: "SKIRT", image: UIImage(named: "black_skirt")!, name: "black_skirt")]
    
    var currentCategory = "전체"
    let categoryDict = ["아우터": "OUTER", "상의": "TOP", "바지": "PANTS", "원피스": "DRESS", "스커트": "SKIRT"]
    
    var countOfImageList: Int { return imageInfoList.count }
    
    func addImageInfo(of category: String, image: UIImage, path: String) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, path: path))
    }
    
    func addImageInfo(of category: String, image: UIImage, name: String) {
        totalImageInfoList.append(ImageInfo(category: category, image: image, name: name))
    }
    
    func addImageInfoSelectively(of category: String, image: UIImage, name: String) {
        totalImageInfoList.forEach {
            if $0.category == category && $0.name == name { return }
        }
        
        addImageInfo(of: category, image: image, name: name)
    }
    
    func deleteImageInfo(imageInfo: ImageInfo) {
        FirestoreService().deleteClothesInfo(imageInfo: imageInfo, uid: UserInfo.shared.uid!)
        
        totalImageInfoList.enumerated().forEach {
            if $1.category == imageInfo.category && $1.name == imageInfo.name {
                totalImageInfoList.remove(at: $0)
            }
        }
        
        setToShowSpecificImageList(of: currentCategory)
    }
    
    func setToShowSpecificImageList(of category: String = "전체") {
        currentCategory = category
        imageInfoList.removeAll()
        
        if category == "전체" {
            imageInfoList = totalImageInfoList
            return
        }
        
        totalImageInfoList.forEach {
            if $0.category == categoryDict[category] {
                imageInfoList.append($0)
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
        guard let uid = UserInfo.shared.uid else { return }
        
        FirestoreService().fetchUserCloset(uid: uid) { [weak self] result in
            switch result {
            case .success(let categories):
                categories.forEach { category, elements in
                    guard K.categoryList.contains(category) else { return }
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
                
            case .failure(let error):
                switch error {
                case .emptyError: print("Document does not exist")
                case .uidError: print(error)
                }
            }
        }
    }
    
    /// file URL을 이용하여 3D 모델을 불러온다.
    func set3DModel(url: URL, completion: @escaping (SCNScene) -> Void) {
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
        
        completion(scene)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        // sceneView.allowsCameraControl = true
        
        // Set to manipulate camera
        
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
    }
    
    /// art에 저장된 3D 모델을 불러온다.
    func set3DModel(modelName: String, completion: @escaping (SCNScene) -> Void) {
        // 1: Load .obj file
        guard let scene = SCNScene(named: modelName) else { fatalError("Unable to load scene file.") }
        
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
        
        completion(scene)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        // sceneView.allowsCameraControl = true
        
        // Set to manipulate camera
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
        
    }
    
    func setTemp3DModel(completion: @escaping (SCNScene) -> Void) {
        // 1: Load .obj file
        guard let scene = SCNScene(named: "art.scnassets/any_copy.scn") else { fatalError("Unable to load scene file.") }
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        
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
        
        completion(scene)
    }
    
    /// 의상을 현재 전시된 모델에 입힌다.
    func putOnClothes(of name: String, completion: @escaping (SCNNode) -> Void) {
        let path = "art.scnassets/\(name).scn"
        
        guard let newScene = SCNScene(named: path) else { fatalError("Unable to load top clothes scene file.") }
        
        guard let newNode = newScene.rootNode.childNode(withName: "\(name)", recursively: true) else { fatalError("error is occured about topNode.") }
        
//        let imageMaterial = SCNMaterial()
//        imageMaterial.isDoubleSided = false
//        imageMaterial.diffuse.contents = UIImage(named: "texture")
//        
//        newNode.geometry?.materials = [imageMaterial]
        
        completion(newNode)
    }
    
    /// 의상을 현재 전시된 모델에 입힌다.
    func putOnClothes() {
        // 1. 현재 인체 모델과 부합하는 의상 모델이 있는지 확인한다.
        let request = ClothesModel.fetchRequest()
        let data = PersistenceManager.shared.fetch(request: request)
        for model in data {
            if model.fileName == HumanModelInfo.shared.modelName {
                
            }
        }
        
        // 2. 있으면 입힌다.
        // 3. 없으면 서버에서 해당 의상 모델을 다운로드받고 CoreData에 저장한 뒤 인체 모델에 입힌다.
    }
}
