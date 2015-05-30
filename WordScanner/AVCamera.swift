//
//  AVCamera.swift
//  WordScanner
//
//  Created by Cody Schrank on 5/6/15.
//  Copyright (c) 2015 TheTapAttack. All rights reserved.
//

import Foundation
import AVFoundation

class AVCamera {
    let captureSession = AVCaptureSession()
    
    var captureDevice: AVCaptureDevice?
    
    func getDevicesAndSetCaptureSession() -> AVCaptureSession? {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) && device.position == AVCaptureDevicePosition.Back {
                captureDevice = device as? AVCaptureDevice
                if captureDevice != nil {
                    var err: NSError? = nil
                    
                    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
                    
                    if err != nil {
                        println("error: \(err?.localizedDescription)")
                    }
                    
                    return captureSession
                }
            }
        }
        return nil
    }
}
