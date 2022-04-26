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
import Photos
import PhotosUI

class ClothesViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    let model = ClothesCollectionViewModel.shared
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.items![toolbar.items!.startIndex].tintColor = .systemBlue
        set3DModel(name: "art.scnassets/FinalBaseMesh.obj")
        // set3DModel(name: "art.scnassets/bboyFixed.scn")
        
        fetchClothesInfo()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        // 갤러리 화면을 가져온다.
        if #available(iOS 14, *) {
            pickImage()
        } else {
            openGallery()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.title = "나의 모델"
        self.collectionView.reloadData()
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
    //MARK: - fetch User's clothes information
    func fetchClothesInfo() {
        let mainURL = "gs://clothsimulation-3af50.appspot.com/"
        
        if let uid = UserInfo.shared.uid {
            let uidRef = db.collection("users").document(uid)
            
            uidRef.getDocument { document, error in
                if let document = document, document.exists {
                    for data in document.data()! {
                        if self.model.categoryList.contains(data.key) {
                            for item in data.value as! Array<Int> {
                                let fullPath = "clothes/\(data.key)/\(item).png"
                                
                                let ref = self.storage.reference(forURL: mainURL).child(fullPath)
                                
                                ref.getData(maxSize: 1 * 1024 * 1024) { imageData, error in
                                    if let error = error {

                                        print(error)

                                    } else {
                                        if let image = UIImage(data: imageData! as Data) {
                                            self.model.addImageInfo(category: data.key, image: image, path: ref.fullPath)
                                            self.model.setToShowSpecificImageList()
                                            self.collectionView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    
    
    // 카테고리랑 네임을 모른다.
    func updateClothesInfo(category: String, name: String) {
        let mainURL = "gs://clothsimulation-3af50.appspot.com/"
        let fullPath = "clothes/\(category)/\(name).png"
        
        let ref = self.storage.reference(forURL: mainURL).child(fullPath)
        
        ref.getData(maxSize: 1 * 1024 * 1024) { imageData, error in
            if let error = error {
                print(error)
            } else {
                if let image = UIImage(data: imageData! as Data) {
                    self.model.addImageInfo(category: category, image: image, path: fullPath)
                    self.model.setToShowSpecificImageList(of: self.model.currentCategory)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
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

extension ClothesViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 이미지 선택이 끝나면 할 것들
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

extension ClothesViewController: UIImagePickerControllerDelegate {
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

class Cell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func update(info: ImageInfo) {
        imageView.image = info.image
        // label.text = String(info.id)
    }
}


