package com.example.rppg_common.utils

class SDKManager {

    // Possible SDK states
    enum class SDKState {
        INITIAL,
        PREPARED,
        VIDEO_STARTED,
        ANALYSIS_RUNNING
    }

    // Singleton instance
    companion object {
        @Volatile
        private var instance: SDKManager? = null

        fun getInstance(): SDKManager {
            if (instance == null) {
                synchronized(this) {
                    if (instance == null) {
                        instance = SDKManager()
                    }
                }
            }
            return instance!!
        }
    }


    // Variable to store the current SDK state
    private var sdkState: SDKState = SDKState.INITIAL

    // Function to set the SDK state
    fun setSDKState(newState: SDKState) {
        sdkState = newState
    }

    // Function to get the current SDK state
    fun getSDKState(): SDKState {
        return sdkState
    }
}