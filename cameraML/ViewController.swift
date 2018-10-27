//
//  ViewController.swift
//  cameraML
//
//  Created by Gleb Shendrik on 21/09/2018.
//  Copyright © 2018 Gleb Shendrik. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        captureSession.addOutput(dataOutput)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Camera", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
    
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            print(finishedReq)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            print("📸")
            print(firstObservation.identifier, firstObservation.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

}

