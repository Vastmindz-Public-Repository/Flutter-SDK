package com.example.rppg_common.utils

import com.rppg.library.common.socket.model.MessageStatus

/// Custom response pair
class StatusMessages {
    companion object {
        fun getMessage(status: MessageStatus): Pair<String, String> {
            return when (status) {
                MessageStatus.SUCCESS -> "success" to "Calculating vitals…"
                MessageStatus.NO_FACE -> "noFace" to "No Face Detected"
                MessageStatus.FACE_LOST -> "faceLost" to "Please make sure your face is still in the frame"
                MessageStatus.CALIBRATING -> "calibrating" to "Analyzing PPG signals…"
                MessageStatus.RECALIBRATING -> "recalibrating" to "Recalibrating…"
                MessageStatus.BRIGHT_LIGHT_ISSUE -> "brightLightIssue" to "Bright light interference"
                MessageStatus.NOISE_DURING_EXECUTION -> "noiseDuringExecution" to "Interference detected"
                else -> "unknown" to ""
            }
        }
    }
}
