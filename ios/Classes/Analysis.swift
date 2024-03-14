import Flutter
import AVFoundation
import UIKit
import RPPGCommon
import RPPGCore


public class Analysis: NSObject {
    
    // MARK: Singleton Instance:
    //Defines a shared instance of the RppgCommonPlugin class using the singleton pattern
    static let shared : Analysis = {
        let instace = Analysis()
        
        return instace
    }()
    
    /// Handle Gap if face will out of focus
    var gapsCount = 0;
    var GAPS_THRESHOLD = 10;
    
    
    var cameraViewContainer: UIView!
    
    var rppgFacade: RPPGCommonFacadeProtocol!
    var videoSettings = RPPGVideoSessionSettings.default
    var socketManager: RPPGSocketManagerProtocol?
    
    var cameraSettings: CameraSettings!
    var cameraPosition: RPPGVideoSessionSettings.CameraPosition = .front
    
    var askPermissionsResponse: Bool = false
    
    var lastAnalysis = AnalysisData()
    var createURL = CreateURL()
    
    
    override init() {
        /// Dimensions setup of camera view
        self.cameraViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        
        super.init()
        /// Initialize and configure UIView
        self.setupFacade()
        self.setupCameraView()
    }
    
    /// Initialization of native sdk
    private func setupFacade() {
        rppgFacade = RPPGCommonFacade()
        rppgFacade.delegate = self
        rppgFacade.diagnosticsDelegate = self
        rppgFacade.rawDelegate = self
        RPPGCommonFacade.enableDebugLogs(true)
    }
    
    /// Pre configure the camera view
    private func setupCameraView(){
        let cameraView = self.rppgFacade.cameraView
        cameraView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cameraView.translatesAutoresizingMaskIntoConstraints = true
        cameraView.frame = cameraViewContainer.bounds
        cameraViewContainer.addSubview(cameraView)
        cameraViewContainer.sendSubviewToBack(cameraView)
    }
    
    func setupCameraSettings(socketUrlString: String, fps: CMTimeScale, quality: AVCaptureSession.Preset, duration: CGFloat) {
        self.cameraSettings = .init(socketUrlString: socketUrlString, fps: fps, quality: quality, duration: duration)
    }
    
    /// Get current SDK state
    public func getState () -> String {
        switch self.rppgFacade.state {
        case .initial:
            return "initial"
        case .prepared:
            return "prepared"
        case .videoStarted:
            return "videoStarted"
        case .analysisRunning:
            return "analysisRunning"
        @unknown default:
            return "default"
        }
    }
    
    
    /// Ask permission
    public func askPermissions() -> Bool {
        self.rppgFacade.askPermissions(completion: { [weak self] granted in
            if granted {
                self?.askPermissionsResponse = true
            } else {
                self?.askPermissionsResponse = false
            }
        })
        return self.askPermissionsResponse
    }
    
    /// Configure camera
    public func configure(_ fps: CMTimeScale,_ userCameraPosition: RPPGVideoSessionSettings.CameraPosition) {
        let userVideoSessionSettings = RPPGVideoSessionSettings(fps: fps,
                                                                cameraPosition: userCameraPosition)
        self.rppgFacade.configure(settings: userVideoSessionSettings)
    }
    
    /// Start Camera
    public func startVideo() {
        self.rppgFacade.startVideo()
    }
    
    /// Fixme: - After when this functionality will available on other platforms
    /// Not using it, because it's not available on other platforms
    // public func stopVideo() {
    //     self.rppgFacade.stopVideo()
    // }
    
    
    /// Start analysis
    public func startAnalysis(baseUrl: String, authToken: String, fps: String?, age: String?, sex: String?, height: String?, weight: String?) {
        /// Reset Previous Data (if any)
        lastAnalysis.resetData()
        /// Construct socket url
        createURL.createWebSocketURL(baseUrl: baseUrl, authToken: authToken, fps: fps, age: age, sex: sex, height: height, weight: weight)
        /// Check for safe url
        if let safeWebUrl = createURL.webSocketUrl {
            let url = URL(string: safeWebUrl)!
            self.rppgFacade.startAnalysis(socketURL: url)
        }
        
    }
    
    /// Stop analysis
    public func stopAnalysis() {
        self.rppgFacade.stopAnalysis()
    }
    
    /// Clean mesh
    public func cleanMesh() {
        self.rppgFacade.cameraView.cleanMesh()
    }
    
    /// Add mesh with Color
    public func meshColor() {
        self.rppgFacade.cameraView.meshColor = Constants.faceMeshFinalColor
    }
    
}


// MARK: - RPPGCommonFacadeDelegate
extension Analysis: RPPGCommonFacadeDelegate {
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveEventFromSocket event: RPPGCommon.RPPGSocketEvent) {
        
        switch event {
            
        case .connected:
            print("---------------socket connected----------------")
        case .disconnected:
            print("---------------socket disconnected----------------")
        case .cancelled:
            print("---------------socket cancelled----------------")
        case .message(let message):
            print("---------------socket message---------------- ")
            DispatchQueue.main.async{
                self.lastAnalysis.handleSocketData(message)
            }
            
        @unknown default:
            fatalError("Unknown socket event received: \(event)")
        }
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, analysisInterrupted reason: RPPGCommon.RPPGAnalysisInterruptionReason, error: Error?) {
        self.cleanupAfterInterruption()
    }
    
    func cleanupAfterInterruption() {
        rppgFacade.cameraView.cleanMesh()
    }
}


// MARK: - RPPGCommonFacadeDiagnosticsDelegate
extension Analysis: RPPGCommonFacadeDiagnosticsDelegate {
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveImageQualityData data: RPPGCommon.RPPGImageQualityData) {
        
    }
    
    
}

//MARK: - RPPGCommonFacadeRawDelegate
extension Analysis: RPPGCommonFacadeRawDelegate {
    public func facadeDidReceiveSocketConnected(_ facade: RPPGCommon.RPPGCommonFacade) {
        
    }
    
    public func facadeDidReceiveSocketDisconnected(_ facade: RPPGCommon.RPPGCommonFacade) {
        
    }
    
    public func facadeDidReceiveSocketCancelled(_ facade: RPPGCommon.RPPGCommonFacade) {
        
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveMessageFromSocket message: String) {
        
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, interruptionWithReason reason: String) {
        DispatchQueue.main.async{
            self.lastAnalysis.isMovingWarning = true
            self.lastAnalysis.sendDataToFlutter()
            self.lastAnalysis.isMovingWarning = false
        }
        
        //        handleGaps(isSuccessCase: true)
    }
    
    
    /// Handle Gap if face will out of focus
    private func handleGaps(isSuccessCase: Bool) {
        
        if (!isSuccessCase) {
            gapsCount = 0
            
        } else {
            gapsCount += 1
            
        }
        
        if (gapsCount > GAPS_THRESHOLD) {
            gapsCount = 0
            DispatchQueue.main.async{
                self.stopAnalysis()
                self.lastAnalysis.isMovingWarning = true
                self.lastAnalysis.sendDataToFlutter()
                /// Check for safe url
                if let safeWebUrl = self.createURL.webSocketUrl {
                    let url = URL(string: safeWebUrl)!
                    self.lastAnalysis.isMovingWarning = false
                    self.rppgFacade.startAnalysis(socketURL: url)
                }
            }
        }
        
    }
    
}



// MARK: - Constants
struct Constants {
    static let faceMeshInitialColor = UIColor.white.withAlphaComponent(0.3)
    static let faceMeshFinalColor = UIColor.yellow.withAlphaComponent(0.3)
    
#if DEV
    static let maxAnalysisTime: TimeInterval = 5 * 60
#elseif DBG
    static let maxAnalysisTime: TimeInterval = 5 * 60
#else
    static let maxAnalysisTime: TimeInterval = 3 * 60
#endif
    
    static let maxNoiseDetectedDuration: TimeInterval = 20
    static let stayStillAlertTimer: TimeInterval = 5
    static let stayStillAlertDuration: TimeInterval = 5
    static let maxDelay = 200
    static let videoViewTag = 777;
}






