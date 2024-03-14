import '../analysis_data/analysis_data.dart';
import '../platform_interface/rppg_common_platform_interface.dart';
export '../rppg_camera_view/rppg_camera_view.dart';

/// Initial state of the RppgCommon (right after initialization).
/// case initial

/// State of the RppgCommon when video session is configured. Web socket is not configured yet.
/// case prepared

/// State of the RppgCommon when input and output devices of video session are initialized
/// and connected to session, input video should be already rendered in RPPGCameraView.
/// case videoStarted

/// State of the RppgCommon when both video session and web socket are configured and running, images captured and
/// passed to face detector, BGR signals calculated and submitted to the backend and vitals should be received
/// through web socket (analysis is running).
/// case analysisRunning

class RppgCommon {
  /// Get the internal/current state of the RppgCommon
  /// Valid state transitions are: `initial -> prepared <-> videoStarted <-> analysisRunning`
  Future<String> getState() => RppgCommonPlatform.instance.getState();

  /// Asks for permissions to access camera.
  Future<bool> askPermissions() => RppgCommonPlatform.instance.askPermissions();

  /// To Configure the RppgCommon Camera before Preview of Camera
  /// Prepares video session.
  /// Should be invoked only when `state` is either `initial` or `prepared` otherwise will have no effect.
  /// Will change `state` to `prepared` in case of success.
  configure(int fps, bool isFrontCamera) => RppgCommonPlatform.instance
      .configure(fps = fps, isFrontCamera = isFrontCamera);

  /// Starts video capturing.
  /// Should be invoked only when `state` is `prepared` otherwise will have no effect.
  /// Will change `state` to `videoStarted` in case of success.
  startVideo() => RppgCommonPlatform.instance.startVideo();

  /// Starts analysis.
  /// Should be invoked only when `state` is `videoStarted` otherwise will have no effect.
  /// Will change `state` to `analysisRunning` in case of success.
  Stream<AnalysisData> startAnalysis(String baseUrl, String authToken,
          String fps, String age, String sex, String height, String weight) =>
      RppgCommonPlatform.instance.startAnalysis(
          baseUrl = baseUrl,
          authToken = authToken,
          fps = fps,
          age = age,
          sex = sex,
          height = height,
          weight = weight);

  /// Stops analysis.
  /// Should be invoked only when `state` is `analysisRunning` otherwise will have no effect.
  /// Will change `state` to `videoStarted` in case of success.
  stopAnalysis() => RppgCommonPlatform.instance.stopAnalysis();

  /// To Add the mesh over the face
  meshColor() => RppgCommonPlatform.instance.meshColor();

  /// To remove the mesh from the Face
  cleanMesh() => RppgCommonPlatform.instance.cleanMesh();
}
