//
//  ViewController.swift
//  Rawlapse
//
//  Created by Dongyuan Liu on 2015-02-21.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession();
        let videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        let videoInput = AVCaptureDeviceInput(device: videoDevice, error: &error)
        captureSession.addInput(videoInput)
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
        let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession.startRunning()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.capture({ image in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            })
        }
    }
    
    func capture(completion:(UIImage? -> Void)) {
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {
            (buffer, error) -> Void in
            if error == nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: imageData)
                completion(image)
            }
        })
    }

}

