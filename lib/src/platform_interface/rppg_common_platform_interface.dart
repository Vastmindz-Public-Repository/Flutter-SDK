import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../analysis_data/analysis_data.dart';
import '../method_channel/rppg_common_method_channel.dart';

abstract class RppgCommonPlatform extends PlatformInterface {
  /// Constructs a RppgCommonPlatform.
  RppgCommonPlatform() : super(token: _token);

  static final Object _token = Object();

  static RppgCommonPlatform _instance = MethodChannelRppgCommon();

  /// The default instance of [RppgCommonPlatform] to use.
  ///
  /// Defaults to [MethodChannelRppgCommon].
  static RppgCommonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RppgCommonPlatform] when
  /// they register themselves.
  static set instance(RppgCommonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Exception getState()
  Future<String> getState() =>
      throw UnimplementedError('getState() has not been implemented.');

  /// Exception askPermissions()
  Future<bool> askPermissions() =>
      throw UnimplementedError('askPermissions() has not been implemented.');

  /// Exception configure()
  configure(int fps, bool isFrontCamera) =>
      throw UnimplementedError('configure() has not been implemented.');

  /// Exception startVideo()
  startVideo() =>
      throw UnimplementedError('startVideo() has not been implemented.');

  /// Exception startAnalysis()
  Stream<AnalysisData> startAnalysis(String baseUrl, String authToken,
          String fps, String age, String sex, String height, String weight) =>
      throw UnimplementedError('startAnalysis() has not been implemented.');

  /// Exception stopAnalysis()
  stopAnalysis() =>
      throw UnimplementedError('stopAnalysis() has not been implemented.');

  /// Exception meshColor()
  meshColor() =>
      throw UnimplementedError('meshColor() has not been implemented.');

  /// Exception cleanMesh()
  cleanMesh() =>
      throw UnimplementedError('cleanMesh() has not been implemented.');
}
