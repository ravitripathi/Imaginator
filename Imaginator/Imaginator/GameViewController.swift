//
//  GameViewController.swift
//  Imaginator
//
//  Created by Ravi Tripathi on 09/03/19.
//  Copyright © 2019 Ravi Tripathi. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import WeScan

class GameViewController: UIViewController {
    
    @IBAction func exportTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Some Title", message: "Enter a text", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter File Name"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let alert = alert, let textField = alert.textFields, let text = textField[0].text {
                self.exportModel(fileName: text)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressText: UILabel!
    var selectedNode: SCNNode?
    var selectedIndex = -1
    enum CubeFace: Int {
        case Front, Right, Back, Left, Top, Bottom
        func getFaceString() -> String{
            switch self {
            case .Front:
                return "front"
            case .Right:
                return "right"
            case .Left:
                return "left"
            case .Back:
                return "back"
            case .Top:
                return "top"
            case .Bottom:
                return "bottom"
            }
        }
    }
    
    @IBOutlet var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .ambient
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        box.materials = [getMaterial(text: "front"), getMaterial(text: "right"), getMaterial(text: "back"), getMaterial(text: "left"), getMaterial(text: "top"), getMaterial(text: "bottom")]
        let node = SCNNode(geometry: box)
        scene.rootNode.addChildNode(node)
        
        
        self.sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: self.sceneView)
        let hitResults = self.sceneView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            
            // get its material
            guard let node = hitResults.first?.node, let index = hitResults.first?.geometryIndex,let count = hitResults.first?.node.geometry?.materials.count, count > 0, count > index, let material = hitResults.first?.node.geometry?.materials[index] else {return}
            // this is just to test which side is tapped
            print("Cube Face Tap is: ",CubeFace.init(rawValue: index)!)
            self.selectedNode = node
            self.selectedIndex = index
            let scannerViewController = ImageScannerController()
            scannerViewController.imageScannerDelegate = self
            present(scannerViewController, animated: true)
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            // on completion - unhighlight
            guard let label =  (material.diffuse.contents as? UILabel) else {return}
            label.text?.append(" +")
            material.diffuse.contents = label
            SCNTransaction.commit()
        }
    }
    
    func getMaterial(text: String) -> SCNMaterial {
        let label = UILabel(frame: CGRect.init(x:0 , y: 0, width: 100, height: 100))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = text.uppercased()
        label.textAlignment = .center
        let material = SCNMaterial()
        material.diffuse.contents = label
        material.locksAmbientWithDiffuse = true
        return material
    }
    
    func exportModel(fileName: String) {
        guard let url = Utility.shared.getFileURL(withFileName: "test1.scn"), let scene = self.sceneView.scene else {
            return
        }
        self.progressText.text = "Exporting Scene"
        self.progressView.setProgress(0.0, animated: true)
        Utility.shared.export(scene: scene, withURL: url) { (progress, error, _) in
            self.progressView.setProgress(progress, animated: true)
            if progress == 1.0 {
                self.progressView.setProgress(0.0, animated: true)
                self.progressText.text = "Uploading Scene"
                Utility.shared.uploadScene(withURL: url, fileName: fileName, completition: { (progress) in
                    self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
                    if progress.isFinished {
                        self.progressText.text = "Upload Done"
                    }
                })
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

extension GameViewController: ImageScannerControllerDelegate {
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        let image = results.scannedImage
        guard let selectedNodeMaterial = self.selectedNode?.geometry?.materials[self.selectedIndex] else{
            return
        }
        selectedNodeMaterial.diffuse.contents = image
        UIApplication.getTopMostViewController()?.dismiss(animated: true, completion: nil)
        
    }
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
    }
    
    
}
