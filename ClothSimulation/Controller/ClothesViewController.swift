//
//  ViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Alamofire
import SceneKit
import Firebase
import SideMenu
import FirebaseStorage

class ClothesViewController: UIViewController {
    
    let storage = Storage.storage()
    
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let model = ImageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.items![toolbar.items!.startIndex].tintColor = .systemBlue
        // set3DModel(name: "art.scnassets/FinalBaseMesh.obj")
        set3DModel(name: "art.scnassets/bboyFixed.scn")
        
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = "나의 모델"
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
        let transition = sender.translation(in: sceneView)
        sceneView.defaultCameraController.rotateBy(x: Float(-transition.x), y: Float(0))
        sender.setTranslation(CGPoint.zero, in: sceneView)
    }
    
    @IBAction func pinchAction(_ sender: UIPinchGestureRecognizer) {
        // 모델 자체를 확대 축소해야 한다.
        let cameraNode = sceneView.scene?.rootNode.childNodes[1]
        let maximumFOV:CGFloat = 25
        let minimumFOV:CGFloat = 90
        
        switch sender.state {
        case .began:
            break
        case .changed:
            cameraNode?.camera?.fieldOfView = (cameraNode?.camera!.fieldOfView)! - sender.velocity
            if (cameraNode?.camera!.fieldOfView)! <= maximumFOV {
                cameraNode?.camera?.fieldOfView = maximumFOV
            }
            if (cameraNode?.camera!.fieldOfView)! >= minimumFOV {
                cameraNode?.camera?.fieldOfView = minimumFOV
            }
        default:
            break
        }
    }
    
    @IBAction func changeButtonPressed(_ sender: UIButton) {
        // Create the action buttons for the alert.
        let bulkyManAction = UIAlertAction(title: "일반 남성",
                                      style: .default) { (action) in
            self.set3DModel(name: "art.scnassets/FinalBaseMesh.obj")
        }
        let skinnyManAction = UIAlertAction(title: "SMPL 남성",
                                      style: .default) { (action) in
            self.set3DModel(name: "art.scnassets/SMPL_male.obj")
        }
        let womanAction = UIAlertAction(title: "SMPL 여성",
                                        style: .default) { (action) in
            self.set3DModel(name: "art.scnassets/SMPL_female.obj")
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
        
        self.present(alert, animated: true) {
            // The alert was presented
        }
    }
    
    
    //MARK: - Emphasize the toolbar items
    @IBAction func itemTapped(_ sender: UIBarButtonItem) {
        model.setToShowSpecificImageList(of: sender.title!)
        
        for index in toolbar.items!.indices {
            toolbar.items![index].tintColor = .systemGray4
        }
        
        if let senderIndex = toolbar.items?.firstIndex(of: sender) {
            toolbar.items![senderIndex].tintColor = .systemBlue
        }
        
        self.collectionView.reloadData()
    }
}

extension ClothesViewController {
//    //MARK: - Initial Setting Methods
//    func startInitialSettings() {
//        let url = "http://192.168.0.9:80"
//        let settingUrl = "/settings/init"
//        Alamofire.request(url + settingUrl, method: .get).responseJSON { response in
//            var settings: Settings
//            do {
//                let decoder = JSONDecoder()
//                settings = try decoder.decode(Settings.self, from: response.data!)
//
//                for clothes in settings.clothes {
//                    let imageUrl = clothes.image
//                    Alamofire.request(url + imageUrl, method: .get).response { response in
//                        if let image = UIImage(data: response.data!) {
//                            self.model.addImageInfo(category: clothes.category, image: image)
//                            self.model.setToShowSpecificImageList()
//                            self.collectionView.reloadData()
//                        }
//                    }.resume()
//                }
//            } catch {
//                print("\(error)")
//            }
//        }.resume()
//    }
    
    func set3DModel(name: String) {
        // 1: Load .obj file
        let scene = SCNScene(named: name)
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 25)
        
        // 4: Set camera on scene
        scene?.rootNode.addChildNode(cameraNode)
        
        // 5-1: Adding front light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 25)
        scene?.rootNode.addChildNode(lightNode)
        
        // 5-2: Adding back light to scene
        let backLightNode = SCNNode()
        backLightNode.light = SCNLight()
        backLightNode.light?.type = .omni
        backLightNode.position = SCNVector3(x: 0, y: 10, z: -25)
        scene?.rootNode.addChildNode(backLightNode)
        
        // 6: Creating and adding ambient light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.lightGray
        scene?.rootNode.addChildNode(ambientLightNode)
        
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
}


//MARK: - UICollectionView Delegate Methods

extension ClothesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = model.imageInfo(at: indexPath.row).getImage() else {
            return
        }
        // mainImageView.image = image
    }
}

//MARK: - UICollectionView DataSource Methods

extension ClothesViewController: UICollectionViewDataSource {
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
}

class Cell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func update(info: ImageInfo) {
        imageView.image = info.image
        // label.text = String(info.id)
    }
}

