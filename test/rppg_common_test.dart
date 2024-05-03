import 'package:flutter_test/flutter_test.dart';
import 'package:rppg_common/src/analysis_data/analysis_data.dart';
import 'package:rppg_common/rppg_common.dart';
import 'package:rppg_common/src/platform_interface/rppg_common_platform_interface.dart';
import 'package:rppg_common/src/method_channel/rppg_common_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRppgCommonPlatform
    with MockPlatformInterfaceMixin
    implements RppgCommonPlatform {

  @override
  Future<String> getState() {
    // TODO: implement getState
    throw UnimplementedError();
  }

  @override
  Future<bool> askPermissions() {
    // TODO: implement askPermissions
    throw UnimplementedError();
  }

  @override
  cleanMesh() {
    // TODO: implement cleanMesh
    throw UnimplementedError();
  }

  @override
  configure(int fps,bool isFrontCamera) {
    // TODO: implement configure
    throw UnimplementedError();
  }

  @override
  meshColor() {
    // TODO: implement meshColor
    throw UnimplementedError();
  }

  @override
  startVideo() {
    // TODO: implement startVideo
    throw UnimplementedError();
  }

  @override
  Stream<AnalysisData> startAnalysis(String baseUrl, String authToken, String fps, String age, String sex, String height, String weight) {
    // TODO: implement startAnalysis
    throw UnimplementedError();
  }

  @override
  stopAnalysis() {
    // TODO: implement stopAnalysis
    throw UnimplementedError();
  }
}

void main() {
  final RppgCommonPlatform initialPlatform = RppgCommonPlatform.instance;

  /// Only Sample not in proper working yet

  test('$MethodChannelRppgCommon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRppgCommon>());
  });

  test('getState', () async {
    RppgCommon rppgCommonPlugin = RppgCommon();
    MockRppgCommonPlatform fakePlatform = MockRppgCommonPlatform();
    RppgCommonPlatform.instance = fakePlatform;

    expect(await rppgCommonPlugin.getState(), 'default');
  });
}
