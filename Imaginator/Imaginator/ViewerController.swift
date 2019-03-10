//
//  ViewerController.swift
//  Imaginator
//
//  Created by Ravi Tripathi on 10/03/19.
//  Copyright © 2019 Ravi Tripathi. All rights reserved.
//

import UIKit
import SceneKit

class ViewerController: UIViewController {
    
    @IBOutlet weak var sceneKitView: SCNView!
    var scene: SCNScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneKitView.scene = self.scene
//        DispatchQueue.main.async {
//            if let sceneURL = self.sceneURL {
//                do{
//                    self.sceneKitView.scene = try SCNScene(url: sceneURL, options: nil)
//                } catch {
//
//                }
//            }
//        }
        self.sceneKitView.allowsCameraControl = true
        self.sceneKitView.showsStatistics = true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
