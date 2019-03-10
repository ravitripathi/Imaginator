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
    
    func downloadFile(withUrl fileURL: URL, completition: @escaping (_ success: Bool, _ url: SCNScene?) -> ()) {
        self.clearTempFolder()
        guard let documentsUrl:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completition(false,nil)
            return
        }
        //
        let destinationFileUrl = documentsUrl.appendingPathComponent("display.scn")
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL)
        
        if FileManager.default.fileExists(atPath: destinationFileUrl.absoluteString) {
            do {
                try FileManager.default.removeItem(at: destinationFileUrl)
            } catch {
                completition(false,nil)
                return
            }
        } else {
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Successfully downloaded. Status code: \(statusCode)")
                        
                        
                        do {
                            let data = try Data.init(contentsOf: tempLocalUrl)
                            try data.write(to: destinationFileUrl, options: .atomic)
                            let scene = try SCNScene(url: destinationFileUrl, options: nil)
                            completition(true, scene)
                        } catch (let exception) {
                            print("Error creating a file \(destinationFileUrl) : \(exception)")
                            completition(false, nil)
                        }
                    }
                } else {
                    print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
                    completition(false,nil)
                }
            }
            task.resume()
        }
    }
    
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: NSTemporaryDirectory() + filePath)
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
    }

}
