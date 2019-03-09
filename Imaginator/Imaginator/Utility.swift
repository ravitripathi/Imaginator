//
//  Utility.swift
//  Imaginator
//
//  Created by Ravi Tripathi on 09/03/19.
//  Copyright © 2019 Ravi Tripathi. All rights reserved.
//

import Foundation
import SceneKit
import FirebaseStorage

class Utility {
    
    let storage = Storage.storage()
    
    func getFileURL(withFileName name: String) -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return nil
        }
        return dir.appendingPathComponent(name)
    }
    
    func export(scene: SCNScene, withURL url: URL, progressHandler: @escaping SCNSceneExportProgressHandler) {
        scene.write(to: url, options: nil, delegate: nil, progressHandler: progressHandler)
    }
    
    func uploadScene(withURL url: URL, completition: @escaping (_ progress: Progress?)-> Void) {
        let fileName = url.lastPathComponent
        let storageRef = storage.reference().child("scenes/\(fileName).scn")
        let uploadTask = storageRef.putFile(from: url, metadata: nil)
        uploadTask.observe(.progress) { snapshot in
            completition(snapshot.progress)
        }
    }
    
}
