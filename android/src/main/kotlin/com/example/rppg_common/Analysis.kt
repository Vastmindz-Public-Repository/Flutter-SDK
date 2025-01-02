@file:OptIn(InternalCoroutinesApi::class)

package com.example.rppg_common


import android.app.Activity
import android.graphics.Color
import android.util.Log
import android.widget.Toast
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.lifecycle.asLiveData
import androidx.lifecycle.lifecycleScope
import com.example.rppg_common.utils.PermissionManager
import com.example.rppg_common.utils.PermissionResult
import com.example.rppg_common.utils.SDKManager
import com.example.rppg_common.utils.StatusMessages
import com.rppg.library.common.BuildConfig
import com.rppg.library.common.RppgCoreManager
import com.rppg.library.common.camera.CameraConfig
import com.rppg.library.common.camera.FaceData
import com.rppg.library.common.camera.FpsCallback
import com.rppg.library.common.camera.RppgCameraManager
import com.rppg.library.common.camera.RppgCameraView
import com.rppg.library.common.camera.overlay.OverlayConfig
import com.rppg.library.common.socket.RppgTypedSocketManager
import com.rppg.library.common.socket.model.MeasurementStatus
import com.rppg.library.common.socket.model.SocketMessage
import com.rppg.library.common.socket.model.UnknownType
import com.rppg.library.core.RppgCore
import com.rppg.net.models.sendReport.AnalysisData
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.InternalCoroutinesApi
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import kotlin.coroutines.CoroutineContext


class Analysis {

    companion object {
        @Volatile
        private var instance: Analysis? = null

        fun getInstance(): Analysis {
            if (instance == null) {
                synchronized(this) {
                    if (instance == null) {
                        instance = Analysis()
                    }
                }
            }
            return instance!!
        }
    }

    private lateinit var activity: Activity
    private lateinit var lifecycle: Any

    private var eventSink: EventChannel.EventSink? = null

    val sdkManagerInstance = SDKManager.getInstance()
    lateinit var analysisData: AnalysisData

    private lateinit var permissionManager: PermissionManager
    private lateinit var cameraManager: RppgCameraManager
    lateinit var rppgCameraView: RppgCameraView
    private lateinit var cameraConfig: CameraConfig

    private lateinit var socketManager: RppgTypedSocketManager
    private lateinit var coreManager: RppgCoreManager
    private lateinit var socketOpened: MutableStateFlow<Flow<SocketMessage>?>
    private lateinit var messagesFlow: Flow<SocketMessage>
    private lateinit var bpmEventMessage: LiveData<Pair<String, String>>
    private var pointer = 0L


    /// Initialize Analysis class
    fun initialization(activity: Activity, lifecycle: Any) {
        this.activity = activity
        this.lifecycle = lifecycle
        analysisData = AnalysisData()
        permissionManager = PermissionManager()
        rppgCameraView = RppgCameraView(activity, null)

        /// Initialize the Socket
        initializeSocket()

        /// Setup Observers
        setupObservers()

        /// Set initial state of SDKManager
        sdkManagerInstance.setSDKState(SDKManager.SDKState.INITIAL)
    }

    /// Initialize the Socket
    private fun initializeSocket() {
        socketManager = RppgTypedSocketManager()
        coreManager = RppgCoreManager().apply {
            pointer = init(fps = 30, mode = RppgCore.CalculationMode.BGR.mode)
        }

        socketOpened = MutableStateFlow<Flow<SocketMessage>?>(null)
        messagesFlow = socketOpened.flatMapLatest {
            it ?: emptyFlow()
        }
            .onEach { data ->
                analysisData.handleSocketResponse(data)
                activity.runOnUiThread(
                    Runnable {

                        try {
                            if (eventSink != null) {

                                // Simulate fetching data from native source

                                // Simulate fetching data from native source
//                                val dataList: ArrayList<Map<String, Any>> = analysisData.fetchData()


                                ///  new lines add for testing...
//                                val text = analysisData.getAnalysisData().toString()
//                                val duration = Toast.LENGTH_SHORT
//
//                                Toast.makeText(activity.applicationContext, text, duration).show()
                                ///

                                this.eventSink!!.success(analysisData.getAnalysisData())
//                                this.eventSink!!.success(dataList)

                            }

                        } catch (ex: Exception) {
                            Log.d("Exception Socket" , "initializeSocket: " + ex.message)
                            /// if eventSink == null
                            ///  new lines add for testing...
                            val duration = Toast.LENGTH_SHORT

                            Toast.makeText(activity.applicationContext, ex.message, duration).show()
                            ///
                        }

                    }
                )

            }
            .flowOn(Dispatchers.Main)
            .catch {
                Log.d("Exception Socket" , "initializeSocket: ")
                /// tokenExpired
            }

        bpmEventMessage = messagesFlow
            .filter { it is UnknownType || it is MeasurementStatus }
            .map { data ->
                when (data) {

                    is MeasurementStatus -> StatusMessages.getMessage(data.statusCode)

                    else -> null
                }
            }
            .onEach {
            }
            .filterNotNull()
            .asLiveData(Dispatchers.IO)


    }

    /// Set event sink
    fun setEventSink(eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    /// Get current SDK state
    public fun getState(): String {
        when (sdkManagerInstance.getSDKState()) {
            SDKManager.SDKState.INITIAL -> {
                return "initial"
            }

            SDKManager.SDKState.PREPARED -> {
                return "prepared"
            }

            SDKManager.SDKState.VIDEO_STARTED -> {
                return "videoStarted"
            }

            SDKManager.SDKState.ANALYSIS_RUNNING -> {
                return "analysisRunning"
            }

            else ->
                return "default"
        }
    }

    /// Ask permission
    public fun setupPermission(activity: Activity, listner: PermissionResult) {
        permissionManager.checkVideoPermission(activity, callback = { isGranted ->
            listner.onPermissionCheck(isGranted)
        })
        sdkManagerInstance.setSDKState(SDKManager.SDKState.INITIAL)
    }

    /// Configure camera
    public fun configure(fps: Int, isFrontCamera: Boolean) {
        cameraConfig =
            CameraConfig(isDebug = BuildConfig.DEBUG, isFrontCamera = isFrontCamera, fps = fps)
        sdkManagerInstance.setSDKState(SDKManager.SDKState.PREPARED)
    }

    /// Start Camera
    public fun startVideo(activity: Activity) {

        rppgCameraView.addFpsCallback(object : FpsCallback {
            override fun onMeasured(fps: Float) {
            }
        })
        cameraManager = RppgCameraManager.Builder(
            lifecycleOwner = activity as LifecycleOwner,
            camera = rppgCameraView,
            cameraConfig = cameraConfig
        ).buildFlow { dataFlow ->
            activity.lifecycleScope.launchWhenStarted {
                dataFlow.collect { data ->
                    val succeed = data.floatArray.isNotEmpty()
                    handleGaps(succeed)
                    if (succeed) sendFaceData(data)
                }
            }
        }

        sdkManagerInstance.setSDKState(SDKManager.SDKState.VIDEO_STARTED)

        cameraManager.setCameraStateListener {

        }
        cleanMesh()

    }

    /// Start analysis
    fun startAnalysis(
        baseUrl: String,
        authToken: String,
        fps: String,
        age: String,
        sex: String,
        height: String,
        weight: String
    ) {
        var urlSocket =
            baseUrl + "?authToken=" +
                    authToken +
                    "&fps=" + fps + "&age=" + age + "&sex=" + sex + "&height=" + height + "&weight=" + weight

        this.analysisData.resetData()

        var v = socketManager.startSocket(
            token = authToken,
            url = urlSocket
        )
        socketOpened.value = v

        cameraManager.startRecording()

        sdkManagerInstance.setSDKState(SDKManager.SDKState.ANALYSIS_RUNNING)
    }

    /// Stop analysis
    public fun stopAnalysis() {
        cameraManager.stopRecording()
        socketManager.stopSocket()
        sdkManagerInstance.setSDKState(SDKManager.SDKState.VIDEO_STARTED)
    }

    /// Clean mesh
    public fun cleanMesh() {
        rppgCameraView.setOverlayConfig(
            OverlayConfig(
                visibility = false,
                overlayAnalysingColor = Color.TRANSPARENT,
                overlayProcessingColor = Color.TRANSPARENT,
            )
        )
    }

    /// Add mesh with Color
    public fun meshColor() {
        rppgCameraView.setOverlayConfig(
            OverlayConfig(
                visibility = true,
                overlayAnalysingColor = Color.YELLOW,
                overlayProcessingColor = Color.WHITE,
            )
        )
    }

    /// Destroy camera manager
    public fun onDestroy() {
        cameraManager.destroy()
    }

    /// Setup observers
    private fun setupObservers() {
        bpmEventMessage.observe(activity as LifecycleOwner, Observer {

        })
    }

    /// Coroutine scope initialization
    private val job = SupervisorJob()
    private val coroutineExceptionHandler =
        CoroutineExceptionHandler { _, throwable ->
            throwable.printStackTrace()
            if (throwable !is CancellationException) handleException(throwable)
        }
    val scope: CoroutineScope = object : CoroutineScope {
        override val coroutineContext: CoroutineContext
            get() = Dispatchers.Main + job + coroutineExceptionHandler
    }

    /// Handle exceptions
    fun handleException(throwable: Throwable) {

    }

    /// Handle gaps in data
    private fun handleGaps(isSuccessCase: Boolean) {
        analysisData.isMovingWarning = !isSuccessCase
    }

    /// Send face data to the server
    fun sendFaceData(data: FaceData) {
        scope.launch(Dispatchers.IO) {
            with(data) {
                val result = coreManager.track(width, height, byteArray, timestamp, floatArray)
                socketManager.update(result, timestamp)
            }
        }
    }


}