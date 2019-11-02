//
//  CaptureViewController.swift
//  Selfiegram
//
//  Created by Alexander on 01.11.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit
import AVKit

class PreviewView: UIView {
    
    //MARK: - Properties
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    //MARK: - ViewController methods
    override func layoutSubviews() {
        
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    //MARK: - Methods
    func setSession(_ session: AVCaptureSession) {
        
        guard previewLayer == nil else {
            print("Warning: \(description) attempted to set its" + " preview layer more than once. This is not allowed.")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        layer.addSublayer(previewLayer)
        
        self.previewLayer = previewLayer
        
        setNeedsLayout()
    }
    
    func setCameraOrientation(_ orientation: AVCaptureVideoOrientation) {
        
        previewLayer?.connection?.videoOrientation = orientation
    }
}

class CaptureViewController: UIViewController {
    
    //MARK: - Properties
    typealias CompletionHandler = (UIImage?) -> Void
    var completion: CompletionHandler?
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    var currentVideoOrientation: AVCaptureVideoOrientation {
        let orientationMap: [UIDeviceOrientation : AVCaptureVideoOrientation]
        orientationMap = [
            .portrait : .portrait,
            .landscapeRight : .landscapeLeft,
            .landscapeLeft : .landscapeRight,
            .portraitUpsideDown : .portraitUpsideDown
        ]
        let currentOrientation = UIDevice.current.orientation
        let videoOrientation = orientationMap[currentOrientation, default : .portrait]
        return videoOrientation
    }
    
    //MARK: - Outlets
    @IBOutlet var cameraPreview: PreviewView!
    
    //MARK: - ViewController methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        guard let captureDevice = discovery.devices.first else {
            print("No capture devices available.")
            completion?(nil)
            return
        }
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch let error {
            print("Failed to add camera to capture session: \(error)")
            completion?(nil)
        }
        
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        cameraPreview.setSession(captureSession)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        cameraPreview.setCameraOrientation(currentVideoOrientation)
    }
    
    //MARK: - Actions
    @IBAction func close(_ sender: UIBarButtonItem) {
        
        completion?(nil)
    }
    
    @IBAction func takeSelfie(_ sender: UITapGestureRecognizer) {
        
        guard let videoConnection = photoOutput.connection(with: .video) else {
            print("Failed to get camera connection")
            return
        }
        videoConnection.videoOrientation = currentVideoOrientation
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CaptureViewController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("Failed to get the photo: \(error)")
            return
        }
        
        guard let jpegData = photo.fileDataRepresentation(), let image = UIImage(data: jpegData) else {
            print("Failed to get image from encoded data")
            return
        }
        completion?(image)
    }
}
