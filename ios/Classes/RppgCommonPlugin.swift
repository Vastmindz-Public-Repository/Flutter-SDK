import Flutter
import AVFoundation
import UIKit
import RPPGCommon
import RPPGCore

public class RppgCommonPlugin: NSObject, FlutterPlugin {

    let shared = Analysis.shared
    
    // MARK: Singleton Instance:
    /// Defines a shared instance of the RppgCommonPlugin class using the singleton pattern
    static let rppgPluginShared : RppgCommonPlugin = {
        let instace = RppgCommonPlugin()
        
        return instace
    }()
    
    /// Declare our eventSink, it will be initialized later
    private var eventSink: FlutterEventSink?
    
    override init() {
        super.init()
    }
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        /// Method Channel
        let channel = FlutterMethodChannel(name: "rppg_common", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(rppgPluginShared, channel: channel)
        
        /// Event Channel
        let eventChannel = FlutterEventChannel(name: "rppgCommon/analysisDataStream", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(rppgPluginShared)
                
        /// Platform View
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "rppg_native_camera")
    
    }

    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getState":
            result(shared.getState())
        case "askPermissions":
            result(shared.askPermissions())
        case "configure":
            if let arguments = call.arguments as? [String: Any] {
                if let fps = arguments["fps"] as? Int {
                    if let isFrontCamera = arguments["isFrontCamera"] as? Bool {
                        var userCameraPosition: RPPGVideoSessionSettings.CameraPosition = .front
                        if isFrontCamera == true {
                            userCameraPosition = .front
                        } else {
                            userCameraPosition = .back
                        }
                        shared.configure(CMTimeScale(fps), userCameraPosition)
                    }
                }
            }
        case "startVideo":
            shared.startVideo()
        case "startAnalysis":
            if let arguments = call.arguments as? [String: Any] {
                if let baseUrl = arguments["baseUrl"] as? String {
                    if let authToken = arguments["authToken"] as? String {
                        if let fps = arguments["fps"] as? String {
                            if let age = arguments["age"] as? String {
                                if let sex = arguments["sex"] as? String {
                                    if let height = arguments["height"] as? String {
                                        if let weight = arguments["weight"] as? String {
                                            shared.startAnalysis(baseUrl: baseUrl, authToken: authToken, fps: fps, age: age, sex: sex, height: height, weight: weight)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case "stopAnalysis":
            shared.stopAnalysis()
        case "cleanMesh":
            shared.cleanMesh()
        case "meshColor":
            shared.meshColor()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

}

//MARK: - FlutterStreamHandler

extension RppgCommonPlugin: FlutterStreamHandler {
   
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    /// Method to send dynamic data
    public func sendEvent(data: Any) {
        /// Check if the eventSink is available
        guard let eventSink = self.eventSink else {
            return
        }
        eventSink(data)
    }
    
    /// Method to stop the listener
    public func stopListening() {
        /// Check if the eventSink is available
        guard eventSink != nil else {
            return
        }
        /// Send a closing event
        ///
        /// Release resources if needed
        ///
        /// Set eventSink to nil to indicate that the listener has been stopped
        self.eventSink = nil
    }
}
