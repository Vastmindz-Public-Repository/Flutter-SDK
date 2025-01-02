#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rppg_common.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rppg_common'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.1'
  s.platform = :ios
  s.ios.deployment_target = '13.1'

  s.static_framework = true
  s.public_header_files = 'Classes/**/*.h'


  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Specify any additional frameworks or libraries needed by your plugin
  s.ios.framework = 'RPPGCommon', 'RPPGCore'

  # Library dependencies
  s.dependency 'GoogleMLKit/FaceDetection'
  s.dependency 'Starscream', '4.0.4'
  s.dependency 'Protobuf'

  # Native frameworks
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => [ '"${PODS_ROOT}/GoogleMLKit/MLKitCore/Sources"' ],
                 'OTHER_LDFLAGS' => '-framework RPPGCore -framework RPPGCommon '}
  s.preserve_paths = 'Frameworks/*.framework'
  s.vendored_frameworks = 'Frameworks/RPPGCommon.framework', 'Frameworks/RPPGCore.framework'


end
