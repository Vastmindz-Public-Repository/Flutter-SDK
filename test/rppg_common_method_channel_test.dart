import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rppg_common/src/method_channel/rppg_common_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelRppgCommon platform = MethodChannelRppgCommon();
  const MethodChannel channel = MethodChannel('rppg_common');

  /// Only Sample not in proper working yet

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return 'default';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getState', () async {
    expect(await platform.getState(), 'default');
  });
}
