# rppg_common

A Flutter plugin for iOS and Android allowing scan the face to get the vitals data.

|                | Android | iOS       |
|----------------|---------|-----------|
| **Support**    | SDK 23+ | iOS 13.1+ |

## Features

* Display live camera preview in a widget.
* Easy to handle the face analysis process.
* Combines the functionality of core and common into single flutter module.
* Can get the state of camera analysis flow (for e.g. initial, prepared, videoStarted
  and analysisRunning), will help to know the state of going on process in flutter sdk.

## Installation and Usage

First, in your flutter project’s pubspec.yaml file add the dependency as given below:

```
rppg_common:
  git:
    url: git@github.com:vastmindz-public-repository/flutter-sdk.git
    ref: main
```

, and run `flutter pub get`

Secondly, Now import it in your Dart code, you can use:

```
import 'package:rppg_common/rppg_common.dart';
```

You can access the camera view by using widget: `RppgCameraView()`

```
@override
  Widget build(BuildContext context) {
      return Scaffold(
          body: RppgCameraView(),
          ),
  }
```

You can access all the available methods by using `RppgCommon` class:

```
final rppgCommon = RppgCommon();
```

For e.g:  rppgCommon.askPermissions(); 
and so on.


Possible `states` of the `RppgCommon` object.
Valid transitions between states are:

`initial` <-> `prepared` <-> `videoStarted` <-> `analysisRunning`

* Initial state of the RppgCommon (right after initialization).
* Prepared state of the RppgCommon when video session is configured. Web socket is not configured yet.
* Video started State of the RppgCommon when input and output devices of video session are initialized
  and connected to session, input video should be already rendered in RppgCameraView().
* Analysis running state of the RppgCommon when both video session and web socket are configured and running, images captured and
  passed to face detector, BGR signals calculated and submitted to the backend and vitals should be received
  through web socket (analysis is running).

### iOS

1. Add one row to the `ios/Runner/Info.plist`:

* with the key `Privacy - Camera Usage Description` and a usage description.

If editing `Info.plist` as text, add:

```
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
```

2. Update the `ios/Podfile`:

```
#Uncomment this line to define a global platform for your project
platform :ios, '13.1'
```

3. Update the below code at the bottom of your `ios/Podfile`: 

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
          xcconfig_path = config.base_configuration_reference.real_path
          xcconfig = File.read(xcconfig_path)
          xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
          File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
        end
      end
    end
  end
end
```

4. Run command `pod install`:

```
pod install
```


### Android

1. Change the minimum Android sdk version to `23` (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 23
```

2. Add the following code snippet in your `android/app/build.gradle` file under `android` tag:

```
android{

packagingOptions {
    pickFirst 'lib/arm64-v8a/libopencv_java4.so'
    pickFirst 'lib/arm64-v8a/libc++_shared.so'
    pickFirst 'lib/armeabi-v7a/libopencv_java4.so'
    pickFirst 'lib/armeabi-v7a/libc++_shared.so'
    pickFirst 'lib/x86_64/libc++_shared.so'
    pickFirst 'lib/x86_64/libopencv_java4.so'
    pickFirst 'lib/x86/libc++_shared.so'
    pickFirst 'lib/x86/libopencv_java4.so'
}

}
```

3. Add the below snippet to `allproject` `repositories` of your app in `project level` `build.gradle` file:

```
allprojects {
    repositories {
        ...
        // This one.
        maven {
            // [required] aar plugin
            url "${project(':rppg_common').projectDir}/build"
        }
    }
}
```


4. Add the below snippet to `buildTypes` under `release` of your app in `app level` `build.gradle` file: (Only required for release build.) 

```
buildTypes {
   release {
      ...
      ...
      minifyEnabled false
      shrinkResources false
   }
}
```

It's important to note that the `RppgCommon` class is not working on emulators. !!!


### Camera access permissions

Plugin camera will only be visible, if camera permission is set to allowed state.


### Example

Here is a small example flutter app displaying a full screen rppg camera preview.

<?code-excerpt "readme_full_example.dart (FullAppExample)"?>
```dart
import 'package:rppg_common/rppg_common.dart';
import 'package:flutter/material.dart';

late final RppgCommon _rppgCommon;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RppgCommonApp());
}

/// RppgCommonApp is the Main Application.
class RppgCommonApp extends StatefulWidget {
  /// Default Constructor
  const RppgCommonApp({super.key});

  @override
  State<RppgCommonApp> createState() => _RppgCommonAppState();
}

class _RppgCommonAppState extends State<RppgCommonApp> {

  @override
  void initState() {
    super.initState();
    _rppgCommon = RppgCommon();
    _rppgCommon.askPermissions();
  }

  @override
  void dispose() {
    _rppgCommon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RppgCameraView(),
    );
  }
}
```

