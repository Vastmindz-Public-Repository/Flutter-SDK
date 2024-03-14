package com.rppg.net.models.sendReport

import com.example.rppg_common.utils.StatusMessages
import com.google.gson.Gson
import com.rppg.library.common.socket.model.AccessToken
import com.rppg.library.common.socket.model.BloodPressure
import com.rppg.library.common.socket.model.HrvMetrics
import com.rppg.library.common.socket.model.MeasurementMeanData
import com.rppg.library.common.socket.model.MeasurementProgress
import com.rppg.library.common.socket.model.MeasurementSignal
import com.rppg.library.common.socket.model.MeasurementStatus
import com.rppg.library.common.socket.model.MessageStatus
import com.rppg.library.common.socket.model.MovingWarning
import com.rppg.library.common.socket.model.SendingRateWarning
import com.rppg.library.common.socket.model.SocketMessage
import java.io.Serializable


class AnalysisData: Serializable {

    public var avgBpm: Int = 0
    public var avgO2SaturationLevel: Int  = 0
    public var avgRespirationRate: Int  = 0
    public var stressStatus: String = ""
    public var bloodPressureStatus: String = ""
    public  var statusCode: String = ""
    public  var statusMessage: String = ""
    public  var rateWarning : RateWarning = RateWarning(0,"")
    public  var isMovingWarning: Boolean = false
    public var progressPercentage: Int = 0
    public  var signals: List<Int> = arrayListOf()
    public  var accessToken: String = ""
    public var bloodPressure: BloodPressurePair = BloodPressurePair(0,0)
    public var snr: Float  = 0.0F
    public var sdnns: Double  = 0.0
    public var ibi: Double = 0.0
    public var rmssd: Double = 0.0

    /// Reset All Data
    fun resetData()
    {
        avgBpm  = 0
        avgO2SaturationLevel   = 0
        avgRespirationRate   = 0
        stressStatus  = ""
        bloodPressureStatus  = ""
        statusCode = ""
        statusMessage  = ""
        rateWarning  = RateWarning(0,"")
        isMovingWarning  = false
        progressPercentage  = 0
        signals  = arrayListOf()
        accessToken = ""
        bloodPressure  = BloodPressurePair(0,0)
        snr = 0.0F
        sdnns = 0.0
        ibi = 0.0
        rmssd = 0.0
    }

    // Method to fetch data
    fun fetchData(): ArrayList<Map<String, Any>> {

        val dataList = ArrayList<Map<String, Any>>()

        val data: MutableMap<String, Any> = HashMap()
        data["avgBpm"] = avgBpm
        data["avgO2SaturationLevel"] = avgO2SaturationLevel
        data["avgRespirationRate"] = avgRespirationRate
        data["stressStatus"] = stressStatus
        data["bloodPressureStatus"] = bloodPressureStatus
        data["statusCode"] = statusCode
        data["statusMessage"] = statusMessage
        data["rateWarning"] = getRateWarningMap(rateWarning) // Convert RateWarning to Map
        data["isMovingWarning"] = isMovingWarning
        data["progressPercentage"] = progressPercentage
        data["signals"] = signals
        data["accessToken"] = accessToken
        data["bloodPressure"] =
            getBloodPressureMap(bloodPressure) // Convert BloodPressurePair to Map
        data["snr"] = snr
        data["sdnns"] = sdnns
        data["ibi"] = ibi
        data["rmssd"] = rmssd
        // Add other fields similarly
        dataList.add(data)
        return dataList
    }


    // Helper method to convert RateWarning to Map
    private fun getRateWarningMap(rateWarning: RateWarning): Map<String, Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["delayValue"] = rateWarning.delayValue
        map["notificationMessage"] = rateWarning.notificationMessage
        return map
    }

    // Helper method to convert BloodPressurePair to Map
    private fun getBloodPressureMap(bloodPressure: BloodPressurePair): Map<String, Any> {
        val map: MutableMap<String, Any> = HashMap()
        map["systolic"] = bloodPressure.systolic
        map["diastolic"] = bloodPressure.diastolic
        return map
    }

    /// Handling different types of socket response
    ///
    ///
    public fun handleSocketResponse(message: SocketMessage) {
        when (message) {
            is MeasurementMeanData -> showVitalData(message)
            is MeasurementSignal -> showSignalData(message)
            is MeasurementStatus -> {
                showStatusData(message)
            }
            is BloodPressure -> showBpData(message)
            is MeasurementProgress -> showProgressData(message)
            is SendingRateWarning -> showRateWarningData(message)
            is MovingWarning -> showMovingWarning(message)
            is AccessToken -> storeAccessToken(message)
            is HrvMetrics -> getSDNN(message)
            else -> {
                try {
                    var str = message.toString()
                    if(str.contains("snr"))
                    {
                        snr = str.substring(str.indexOf("snr")+4 , str.lastIndexOf(")")-1).toFloat()
                    }
                }catch (ex:Exception)
                {
                }

            }
        }
    }

    /// Convert object's data to JSON response
    fun getAnalysisData() : String? {
        return Gson().toJson(this)
    }


    private fun showVitalData(vital: MeasurementMeanData) {
        vital?.let {
            this.avgBpm = it.bpm
            this.avgRespirationRate = it.rr
            this.avgO2SaturationLevel = it.oxygen
            this.stressStatus = it.stressStatus?.name ?: ""
            this.bloodPressureStatus = it.bloodPressureStatus?.name ?: ""
        }
    }

    private fun showBpData(bp: BloodPressure) {
        this.bloodPressure =  BloodPressurePair(bp.systolic,bp.diastolic)
    }

    private fun showSignalData(signal: MeasurementSignal?) {
        signal?.let { measurementSignal ->
            if (measurementSignal.signal.isEmpty()) {
                return
            }
            val signalsNeeded = 256
            val signals: List<Int> = if (measurementSignal.signal.count() < signalsNeeded) {
                val originalSignals = measurementSignal.signal.map { it.toInt() }
                val signalsToBeAdded = signalsNeeded - measurementSignal.signal.size
                val filterSignal = originalSignals.first()
                val modifiedSignals = mutableListOf<Int>().apply {
                    repeat(signalsToBeAdded) {
                        add(filterSignal)
                    }
                }
                modifiedSignals.addAll(originalSignals)
                modifiedSignals
            } else {
                measurementSignal.signal.map { it.toInt() }
            }
            this.signals = signals
        }
    }

    private fun showStatusData(status: MeasurementStatus?) {
        status?.let {
            val status: MessageStatus = it.statusCode
            val (statusCode, statusMessage) = StatusMessages.getMessage(status)
            this.statusMessage = statusMessage
            this.statusCode =  statusCode
        }
    }

    private fun showProgressData(progress: MeasurementProgress?) {
        progress?.let {
            this.progressPercentage = it.progressPercent
        }
    }

    private fun showRateWarningData(warning: SendingRateWarning?) {
        warning?.let {
            this.rateWarning = RateWarning(warning.delayValue,warning.notificationMessage.toString())
        }
    }

    private fun showMovingWarning(warning: MovingWarning?) {
        if(warning!=null) {
        } else {
        }
    }
    private fun getSDNN(sdnn: HrvMetrics) {
        sdnn?.let {
            this.sdnns= it.sdnn
            this.ibi =  it.ibi
            this.rmssd = it.rmssd
        }
    }


    private fun storeAccessToken(tokenData: AccessToken?) {
        tokenData?.let {
            this.accessToken = it.accessToken
        }
    }



}

data class BloodPressurePair(val systolic: Int, val diastolic: Int): Serializable

data class RateWarning(val delayValue: Long, val notificationMessage: String): Serializable