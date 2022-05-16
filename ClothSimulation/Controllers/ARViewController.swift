//
//  ARViewController.swift
//  ClothSimulation
//
//  Created by 유승원 on 2022/03/02.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var humanCreated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // feature point를 볼 수 있는 디버그 옵션.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/FinalBaseMesh.scn")!
        
                if let diceNode = diceScene.rootNode.childNode(withName: "Group1_default", recursively: true) {
                    diceNode.position = SCNVector3(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y,
                        // + diceNode.boundingSphere.radius,
                        hitResult.worldTransform.columns.3.z
                    )
        
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    humanCreated = true
                }
            }
        }
    }
    
    // when horizontal plane is detected, this function will start.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let placeAnchor = anchor as! ARPlaneAnchor
            
            print("\(placeAnchor.center.x),\(placeAnchor.center.y),\(placeAnchor.center.z)")
            
            let plane = SCNPlane(width: CGFloat(placeAnchor.extent.x), height: CGFloat(placeAnchor.extent.z))
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(placeAnchor.center.x, 0, placeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named:"art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
