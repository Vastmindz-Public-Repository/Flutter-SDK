class RppgConstants {
  /// Channel Names
  static const String methodChannelName = "rppg_common";
  static const String eventChannelName = "rppgCommon/analysisDataStream";
  static const String cameraViewTypeName = 'rppg_native_camera';

  /// Methods Names
  static const String getState = "getState";
  static const String askPermissions = "askPermissions";
  static const String configure = "configure";
  static const String startVideo = "startVideo";
  static const String stopVideo = "stopVideo";
  static const String startAnalysis = "startAnalysis";
  static const String stopAnalysis = "stopAnalysis";
  static const String cleanMesh = "cleanMesh";
  static const String meshColor = "meshColor";
  static const String beginSession = "beginSession";

  /// default
  static const String defaultString = "default";

  // Add more constants as needed...
}
