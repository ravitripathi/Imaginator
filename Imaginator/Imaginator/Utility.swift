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
import FirebaseDatabase

class Utility {
    
    let storage = Storage.storage()
    static let shared = Utility()
    let ref = Database.database().reference()
    
    func getFileURL(withFileName name: String) -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            return nil
        }
        return dir.appendingPathComponent(name)
    }
    
    func export(scene: SCNScene, withURL url: URL, progressHandler: @escaping SCNSceneExportProgressHandler) {
        scene.write(to: url, options: nil, delegate: nil, progressHandler: progressHandler)
    }
    
    func uploadScene(withURL url: URL, fileName: String, completition: @escaping (_ progress: Progress)-> Void) {
        let id = self.ref.child("models").childByAutoId()
        if let key = id.key {
            let storageRef = storage.reference().child("scenes/\(key).scn")
            
            let uploadTask = storageRef.putFile(from: url, metadata: nil) { (metaData, error) in
                guard let metadata = metaData else {
                    return
                }
                storageRef.downloadURL {
                    (url, error) in
                    guard let downloadUrl = url else {
                        return
                    }
                    var sceneData: SceneModel = SceneModel()
                    sceneData.fileName = fileName
                    sceneData.url = downloadUrl.absoluteString
                    self.ref.child("models").child(key).setValue(["fileName" :sceneData.fileName,
                                                                  "url": sceneData.url])
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                if let progress = snapshot.progress {
                     completition(progress)
                }
            }
        }
    }
    
    func retrieveScene(completition: @escaping (_ model:SceneModel) -> ()) {
        self.ref.child("models").observe(DataEventType.childAdded) {
            (snapshot) in
            let dictionary = snapshot.value as? [String: Any]
            var currentScene: SceneModel = SceneModel()
            if let dictionary = dictionary {
                if let url = dictionary["url"] as? String{
                    currentScene.url = url
                }
                if let name = dictionary["fileName"] as? String {
                    currentScene.fileName = name
                }
            }
            completition(currentScene)
        }
    }
    
}
