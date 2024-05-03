//
//  StatusMessages.swift
//  rppg_common
//
//  Created by Wegile on 31/01/24.
//

import Foundation
import RPPGCommon

/// Custom response pair
class StatusMessages {
    static func getMessage(forStatus status: RPPGSocketMessageDataStatus.StatusCode?) -> (statusCode: String, statusMessage: String) {
        switch status {
        case .success:
            return ("success", "Calculating vitals…")

        case .noFace:
            return ("noFace", "No Face Detected")

        case .faceLost:
            return ("faceLost", "Please make sure your face is still in the frame")

        case .calibrating:
            return ("calibrating", "Analyzing PPG signals…")

        case .recalibrating:
            return ("recalibrating", "Recalibrating…")

        case .brightLightIssue:
            return ("brightLightIssue", "Bright light interference")

        case .noiseDuringExecution:
            return ("noiseDuringExecution", "Interference detected")
            
        @unknown default:
            return ("unknown", "")
        }
    }
}

