//
//  CylinderSceneVC.swift
//  Imaginator
//
//  Created by Ravi Tripathi on 10/03/19.
//  Copyright © 2019 Ravi Tripathi. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation
class CylinderSceneVC: UIViewController, SecondViewControllerDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var sceneView: SCNView!
    var selectedMaterial: SCNMaterial?
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SCNScene()
        
        let gradient = CAGradientLayer()
        gradient.colors = [(UIColor(red: 242.0 / 255.0, green: 140.0 / 255.0, blue: 24.0 / 255.0, alpha: 1.0)).cgColor, (UIColor(red: 245.0 / 255.0, green: 193.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)).cgColor]
        gradient.frame = view.frame
        scene.background.contents =  gradient
        
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
        
        let cylinder = SCNCylinder(radius: 5.0, height: 10.0)
        cylinder.materials = [getMaterial(text: "Body"),getMaterial(text: "Top"), getMaterial(text: "Bottom")]
//        self.material = cylinder.materials
//        box.materials = [getMaterial(text: "front"), getMaterial(text: "right"), getMaterial(text: "back"), getMaterial(text: "left"), getMaterial(text: "top"), getMaterial(text: "bottom")]
        let node = SCNNode(geometry: cylinder)
        scene.rootNode.addChildNode(node)
        
        
        self.sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .done, target: self, action: #selector(showAlert))
        // Do any additional setup after loading the view.
    }
    
    @objc func showAlert() {
        let alert = UIAlertController(title: "Export", message: "Enter filename", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter File Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            if let alert = alert, let textField = alert.textFields, let text = textField[0].text {
                self.exportModel(fileName: text)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: self.sceneView)
        let hitResults = self.sceneView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            
            // get its material
            guard let index = hitResults.first?.geometryIndex,let count = hitResults.first?.node.geometry?.materials.count, count > 0, count > index, let material = hitResults.first?.node.geometry?.materials[index] else {return}
            self.selectedMaterial = material
            performSegue(withIdentifier: "doStitching", sender: self)
        }
    }
    
    @objc func exportModel(fileName: String) {
        guard let url = Utility.shared.getFileURL(withFileName: "test1.scn"), let scene = self.sceneView.scene else {
            return
        }
        self.progressText.text = "Exporting Scene"
        self.progressView.isHidden = false
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doStitching", let vc = segue.destination as? SecondViewController {
            vc.delegate = self
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
    
    //MARK:- SecondViewControllerDelegate
    
    func getImage(image: UIImage?) {
        if let image = image, let data = image.jpegData(compressionQuality: 0) {
            let tImage = UIImage(data: data)
            self.selectedMaterial?.diffuse.contents = tImage
        }
        UIApplication.getTopMostViewController()?.navigationController?.popViewController(animated: true)
    }
    
}
