//
//  ViewController.swift
//  OpenCVSample
//
//  Created by yudoufu on 2016/12/13.
//  Copyright © 2016年 Personal. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageView2: UIImageView!

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recognize()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopSession()
    }

    private func startSession() {
        setupPreviewLayer()
        session.startRunning()
    }

    private func stopSession() {
        session.stopRunning()
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            print("no camera")
            return
        }

        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

        switch status {
        case .authorized:
            connectSession(device: camera)
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] authorized in
                if  authorized {
                    self?.connectSession(device: camera)
                }
            })
            break
        case .restricted, .denied:
            print("camera not autherized")
            return
        }
    }

    private func connectSession(device: AVCaptureDevice) {
        do {
            try setVideoInput(device: device)
            setVideoOutput()
        } catch let error as NSError {
            print(error)
        }
    }

    private func setVideoInput(device: AVCaptureDevice) throws {
        let videoInput = try AVCaptureDeviceInput(device: device)
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
    }

    private func setVideoOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.beginConfiguration()

        var videoConnection: AVCaptureConnection? = nil

        for connection in videoOutput.connections {
            for port in (connection as! AVCaptureConnection).inputPorts {
                if (port as! AVCaptureInputPort).mediaType == AVMediaTypeVideo {
                    videoConnection = connection as? AVCaptureConnection
                }
            }
        }

        if videoConnection!.isVideoOrientationSupported {
            videoConnection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }

        session.commitConfiguration()
    }

    private func setupPreviewLayer() {
        guard let layer = AVCaptureVideoPreviewLayer(session: session) else {
            print("layer error")
            return
        }

        layer.frame = CGRect(origin: CGPoint.zero, size: previewView.frame.size)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill

        previewView.layer.addSublayer(layer)

        previewLayer = layer
    }

    private var latestCIImage: CIImage?

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        latestCIImage = ciImage
    }

    func recognize() {
        guard let ciImage = latestCIImage else { return }

        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let image = UIImage(cgImage: cgImage!)

        previewImageView.image = OpenCVBridge.recognizeRect(image)
        previewImageView2.image = OpenCVBridge.recognizeEdge(image)
    }
}
