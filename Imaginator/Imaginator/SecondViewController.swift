//
//  ViewController.swift
//  AV Foundation
//
//  Created by Pranjal Satija on 5/22/17.
//  Copyright © 2017 Pranjal Satija. All rights reserved.
//

import UIKit
import Photos
protocol SecondViewControllerDelegate {
    func getImage(image: UIImage?)
}
class SecondViewController: UIViewController, CameraControllerDelegate {
    
    
    var imageArray: [UIImage] = []
    @IBOutlet fileprivate var captureButton: UIButton!
    
    ///Displays a preview of the video output generated by the device's cameras.
    @IBOutlet fileprivate var capturePreviewView: UIView!
    var delegate: SecondViewControllerDelegate?
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }
    
}

extension SecondViewController {
    override func viewDidLoad() {
        
        func configureCameraController() {
            cameraController.delegate = self
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        configureCameraController()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Do Stitching", style: .done, target: self, action: #selector(showAlert))
    }
    @objc func showAlert() {
        self.delegate?.getImage(image: self.stitchImages(images: self.imageArray, isVertical: false))
    }
    //MARK:- CameraControllerDelegate
    func returnImages(images: UIImage) {
        self.imageArray.append(images)
    }
    
    func stitchImages(images: [UIImage], isVertical: Bool) -> UIImage? {
        var stitchedImages : UIImage?
        if images.count > 0 {
            var maxWidth = CGFloat(0), maxHeight = CGFloat(0)
            for image in images {
                if image.size.width > maxWidth {
                    maxWidth = image.size.width
                }
                if image.size.height > maxHeight {
                    maxHeight = image.size.height
                }
            }
            var totalSize : CGSize
            let maxSize = CGSize(width: maxWidth, height: maxHeight)
            if isVertical {
                totalSize = CGSize(width: maxSize.width, height: maxSize.height * (CGFloat)(images.count))
            } else {
                totalSize = CGSize(width: maxSize.width  * (CGFloat)(images.count), height:  maxSize.height)
            }
            UIGraphicsBeginImageContext(totalSize)
            for image in images {
                let offset = (CGFloat)(images.index(of: image)!)
                let rect =  AVMakeRect(aspectRatio: image.size, insideRect: isVertical ?
                    CGRect(x: 0, y: maxSize.height * offset, width: maxSize.width, height: maxSize.height) :
                    CGRect(x: maxSize.width * offset, y: 0, width: maxSize.width, height: maxSize.height))
                image.draw(in: rect)
            }
            stitchedImages = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return stitchedImages
    }
}

extension SecondViewController {
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
}

