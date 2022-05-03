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
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 툴바 색 관련
        toolbar.items![toolbar.items!.startIndex].tintColor = .systemBlue
        
        model.set3DModel(sceneView: sceneView, name: K.dancingMan)
        
        // set3DModel(name: "art.scnassets/bboyFixed.scn")
        
        model.fetchClothesInfo(collectionView: collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.reloadData()
        
        self.navigationController?.navigationBar.topItem?.title = "나의 옷장"
    }
    
    //MARK: - 3D model View settings
    
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
            toolbar.items![senderIndex].tintColor = .systemBlue
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
