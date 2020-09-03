Pod::Spec.new do |s|
  s.name             = "Zee5PlayerPlugin"
  s.version          = '1.1.100'
  s.summary          = "Zee5PlayerPlugin"
  s.description      = <<-DESC
                        Zee5PlayerPlugin.
                       DESC
  s.homepage         = "https://github.com/applicaster/Zee5PlayerPlugin-iOS"
  s.license          = 'CMPS'
  s.author           = "Applicaster LTD."
  s.source           = { :git => "git@github.com:applicaster-plugins/Zee5PlayerPlugin-iOS.git", :tag => s.version.to_s }
  s.platform         = :ios, '10.0'
  s.requires_arc = true
  
  s.ios.deployment_target = "10.0"
  s.swift_version       = '5.1'
  
  s.libraries = 'z'
  s.frameworks = 'UIKit','AVFoundation'

  s.static_framework = true

  s.source_files  = 'PluginClasses/**/*.{h,m,swift,pch}'
  s.resources = [ 'PluginClasses/**/*.{xib,storyboard,png,ttf,json}']
  
  s.dependency 'ZappPlugins'
  s.dependency 'ApplicasterSDK'
  s.dependency 'ZappSDK'
  s.dependency 'PlayKit_IMA', '~> 1.8.0'
  s.dependency 'Protobuf'
  s.dependency 'google-cast-sdk-no-bluetooth', '= 4.4.7'
  s.dependency 'ComScore'
  s.dependency 'LotameDMP', '~> 5.0'
  s.dependency 'Zee5CoreSDK'
  s.dependency 'CarbonKit'
  s.dependency 'DropDown'
  s.dependency 'UICircularProgressRing'
  s.dependency 'SDWebImage'
  s.dependency 'DownloadToGo'
  s.dependency 'SQLite.swift'
  s.dependency 'ZeeHomeScreen'
  s.dependency 'Zee5Advertisement'
  s.vendored_frameworks = 'ConvivaSDK.framework'

  s.xcconfig =  {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'ENABLE_BITCODE' => 'YES',
    'SWIFT_VERSION' => '5.1',
    'OTHER_CFLAGS'  => '-fembed-bitcode',
    'OTHER_LDFLAGS' => '-objc -ObjC -lc++ -framework "GoogleCast" -framework "ConvivaSDK"',
    'FRAMEWORK_SEARCH_PATHS' =>'$(inherited) "${PODS_ROOT}/ConvivaSDK/Frameworks"',
    'GCC_SYMBOLS_PRIVATE_EXTERN' => 'YES'
  }
end
