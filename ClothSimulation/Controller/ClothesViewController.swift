//
//  ViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/02/19.
//

import UIKit
import Alamofire
import SceneKit

class ClothesViewController: UIViewController {

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let model = ImageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbar.items![toolbar.items!.startIndex].tintColor = .systemBlue
        set3DModel()
        startInitialSettings()
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
    //MARK: - Initial Setting Methods
    func startInitialSettings() {
        let url = "http://192.168.0.8:80/settings/init"
        Alamofire.request(url, method: .get).responseJSON { response in
            var settings: Settings
            do {
                let decoder = JSONDecoder()
                settings = try decoder.decode(Settings.self, from: response.data!)
                
                for clothes in settings.clothes {
                    if let image = self.convertStringToUIImage(str: clothes.result) {
                        self.model.addImageInfo(category: clothes.category, image: image)
                    }
                }
                
                self.model.setToShowSpecificImageList()
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
    
    func set3DModel() {
        // 1: Load .obj file
        let scene = SCNScene(named: "art.scnassets/FinalBaseMesh.obj")
        
        // 2: Add camera node
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
        
        // 4: Set camera on scene
        scene?.rootNode.addChildNode(cameraNode)
        
        // 5: Adding light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
        scene?.rootNode.addChildNode(lightNode)
        
        // 6: Creating and adding ambient light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene?.rootNode.addChildNode(ambientLightNode)
        
        // If you don't want to fix manually the lights
        // sceneView.autoenablesDefaultLighting = true
        
        // Allow user to manipulate camera
        sceneView.allowsCameraControl = true
        
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

