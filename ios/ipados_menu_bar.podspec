#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ipados_menu_bar.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ipados_menu_bar'
  s.version          = '0.4.0'
  s.summary          = 'A Flutter plugin for integrating the iPadOS menubar into Flutter apps.'
  s.description      = <<-DESC
A Flutter plugin that enables developers to add a native-like iPadOS menubar to their Flutter applications.
It provides customizable menu items and actions, following Apple's Human Interface Guidelines for a seamless iPad experience.
                       DESC
  s.homepage         = 'https://github.com/ELadrimonos/ipados_menu_bar'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Adrián Primo Bernat' => 'aprimo.developer@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'

  # Doesn't need to be at version 26, on older devices it will just not show the
  # menu bar but the app would still compile.
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'ipados_menu_bar_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
