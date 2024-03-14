//
//  AnalysisData.swift
//  rppg_common
//
//  Created by Wegile on 21/12/23.
//

import Foundation
import RPPGCommon

// MARK: - Analysis
struct AnalysisData {

    var avgBpm: Double = 0
    var avgO2SaturationLevel: Double  = 0
    var avgRespirationRate: Double  = 0
    var stressStatus: String = ""
    var afibRiskStatus: String = ""
    var bloodPressureStatus: String = ""
    var statusCode: String = ""
    var statusMessage: String = ""
    var rateWarning : RateWarning = RateWarning(delayValue: 0,notificationMessage: "")
    var isMovingWarning: Bool = false
    var progressPercentage: Int = 0
    var signals: [Int] = []
    var accessToken: String = ""
    var bloodPressure: BloodPressurePair = BloodPressurePair(systolic: 0,diastolic: 0)
    var snr: Float = 0.0
    var sdnns: Float  = 0.0
    var ibi: Float = 0.0
    var rmssd: Float = 0.0
    
    
    /// JSON Structure for Response (Computed Property)
    var jsonRepresentation: [String: Any] {
        return [
            "avgBpm": avgBpm,
            "avgO2SaturationLevel": avgO2SaturationLevel,
            "avgRespirationRate": avgRespirationRate,
            "stressStatus": stressStatus,
            "afibRiskStatus": afibRiskStatus,
            "bloodPressureStatus": bloodPressureStatus,
            "statusCode": statusCode,
            "statusMessage": statusMessage,
            "rateWarning": [
                "delayValue": rateWarning.delayValue,
                "notificationMessage": rateWarning.notificationMessage
            ],
            "isMovingWarning": isMovingWarning,
            "progressPercentage": progressPercentage,
            "signals": signals,
            "accessToken": accessToken,
            "bloodPressure": [
                "systolic": bloodPressure.systolic,
                "diastolic": bloodPressure.diastolic
            ],
            "snr": snr,
            "sdnns": sdnns,
            "ibi": ibi,
            "rmssd": rmssd
        ]
    }
    
    /// Reset All Data
    mutating func resetData()
    {
        avgBpm  = 0
        avgO2SaturationLevel   = 0
        avgRespirationRate   = 0
        stressStatus  = ""
        afibRiskStatus = ""
        bloodPressureStatus  = ""
        statusCode = ""
        statusMessage  = ""
        rateWarning  = RateWarning(delayValue: 0,notificationMessage: "")
        isMovingWarning  = false
        progressPercentage  = 0
        signals  = []
        accessToken = ""
        bloodPressure  = BloodPressurePair(systolic: 0,diastolic: 0)
        snr   = 0.0
        sdnns  = 0.0
        ibi  = 0.0
        rmssd  = 0.0
    }
    
    
    // Send Socket Response to Flutter
    func sendDataToFlutter() {
        RppgCommonPlugin.rppgPluginShared.sendEvent(data: self.convertToJSON())
    }
    
    // Convert (String to JSON)
    func convertToJSON() -> String {
        do {
            // Convert the dictionary to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: self.jsonRepresentation, options: [])
            
            // Convert the JSON data to a String (optional)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                return ""
            }
            
        } catch {
            return ""
        }
    }
    
    
    /// Handling different types of socket response
    ///
    ///
    mutating public func handleSocketData(_ message: RPPGSocketMessage) {
        switch message.messageType {
        case let .data(messageData):
            handleMessageDataResponse(messageData)
        case let .meanData(data):
            handleMeanDataResponse(data)            
        case let .status(data):
            handleStatusDataResponse(data)
        case let .rateWarning(data):
            handleRateWarningDataResponse(data)
        case .moveWarning:
            handleMoveWarning()
        case let .progress(data):
            handleProgressDataResponse(data)
        case let .signal(data):
            handleSignalDataResponse(data)
        case let .accessToken(data):
            handleAccessTokenDataResponse(data)
        case let .bloodPressure(data):
            handleBloodPressureDataResponse(data)
        case let .signalQuality(data):
            handleSignalQualityDataResponse(data)
        case let .hrvMetrics(data):
            handleHRVMetricsResponse(data)
        default:
            break
        }
    }
    
    mutating func handleMessageDataResponse(_ data: RPPGSocketMessageData) {
        /// Possible data
        /// data.bpm
        /// data.oxygenSaturation
        /// data.respirationRate
    }
    
    mutating func handleMeanDataResponse(_ data: RPPGSocketMessageMeanData) {
        /// Possible data
        /// data.bpm
        /// data.oxygenSaturation
        /// data.respirationRate
        /// data.afibRiskStatus
        /// data.stressStatus
        /// data.bloodPressureStatus
        self.avgBpm = data.bpm ?? 0
        self.avgO2SaturationLevel = data.oxygenSaturation ?? 0
        self.avgRespirationRate = data.respirationRate ?? 0
        self.afibRiskStatus = data.afibRiskStatus?.localizedDescription ?? ""
        self.stressStatus = data.stressStatus?.localizedDescription ?? ""
        self.bloodPressureStatus = data.bloodPressureStatus?.localizedDescription ?? ""

        self.sendDataToFlutter()
    }
    
    mutating func handleStatusDataResponse(_ data: RPPGSocketMessageDataStatus) {
        /// Possible data
        /// data.statusCode
        /// data.statusMessage
        guard let status = data.statusCode else { return }
        let (statusCode, statusMessage) = StatusMessages.getMessage(forStatus: status)
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }

    
    mutating func handleRateWarningDataResponse(_ data: RPPGSocketMessageSendingRateWarning) {
        /// Possible data
        /// data.delay
        /// data.message
        guard let sendingDelay = data.delay else { return }
        self.rateWarning.delayValue = sendingDelay
        self.rateWarning.notificationMessage = data.message ?? ""
    }

    func handleMoveWarning() {
        /// Not using it
    }
    
    mutating func handleProgressDataResponse(_ data: RPPGSocketMessageProgress) {
        /// Possible data
        /// data.progressPercent
        guard let safeProgressPercent = data.progressPercent else { return }
        self.progressPercentage = safeProgressPercent
    }
    
    mutating func handleSignalDataResponse(_ data: RPPGSocketMessageSignal) {
        /// Possible data
        /// data.signalValues
        guard let safeSignals = data.signalValues else { return }
        self.signals = safeSignals
    }
    
    mutating func handleAccessTokenDataResponse(_ data: RPPGSocketMessageToken) {
        /// Possible data
        /// data.accessToken
        guard let safeToken = data.accessToken else { return }
        self.accessToken = safeToken
    }
    
    mutating func handleBloodPressureDataResponse(_ data: RPPGSocketMessageBloodPressure) {
        /// Possible data
        ///  data.systolic
        ///  data.diastolic
        self.bloodPressure.systolic = data.systolic
        self.bloodPressure.diastolic = data.diastolic
    }
    
    mutating func handleSignalQualityDataResponse(_ data: RPPGSocketMessageSignalQuality) {
        /// Possible data
        /// data.snr
        self.snr = data.snr
    }
    
    mutating func handleHRVMetricsResponse(_ data: RPPGSocketMessageHeartRateVariability) {
        /// Possible data
        /// data.ibi
        /// data.rmssd
        /// data.sdnn
        self.ibi = data.ibi
        self.rmssd = data.rmssd
        self.sdnns = data.sdnn
    }
    
}


struct BloodPressurePair {
    var systolic: Int
    var diastolic: Int
}

struct RateWarning {
    var delayValue: Int
    var notificationMessage: String
}
