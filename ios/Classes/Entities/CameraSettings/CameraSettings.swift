//
//  CameraSettings.swift
//  rppg_common
//
//  Created by Wegile on 15/12/23.
//

import Foundation
import AVFoundation

struct CameraSettings {
    var socketUrlString: String 
    var fps: CMTimeScale
    let quality: AVCaptureSession.Preset
    let duration: CGFloat
    
    init(socketUrlString: String, fps: CMTimeScale, quality: AVCaptureSession.Preset, duration: CGFloat) {
        self.socketUrlString = socketUrlString
        self.fps = fps
        self.quality = quality
        self.duration = duration
    }
}
