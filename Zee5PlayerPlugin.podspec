Pod::Spec.new do |s|
  s.name             = "Zee5PlayerPlugin"
  s.version          = '1.1.97'
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



 s.subspec 'Core' do |c|
       c.source_files  = 'PluginClasses/**/*.{h,m,swift,pch}'
       c.resources = [ 'PluginClasses/**/*.{xib,storyboard,png,ttf,xcassets,json}']
       c.frameworks = 'UIKit','AVFoundation'
       c.dependency 'ZappPlugins'
       c.dependency 'ApplicasterSDK'
       c.dependency 'ZappSDK'
       c.dependency 'PlayKit_IMA', '~> 1.8.0'
       c.dependency 'Protobuf'
       c.dependency 'google-cast-sdk-no-bluetooth', '= 4.4.7'
       c.dependency 'ConvivaSDK'
       c.dependency 'ComScore'
       c.dependency 'LotameDMP', '~> 5.0'
       c.dependency 'Zee5CoreSDK'
       c.dependency 'CarbonKit'
       c.dependency 'DropDown'
       c.dependency 'UICircularProgressRing'
       c.dependency 'SDWebImage'
       c.dependency 'DownloadToGo'
       c.dependency 'SQLite.swift'
       c.dependency 'ZeeHomeScreen'
       c.dependency 'Zee5Advertisement'
       c.vendored_frameworks = 'ConvivaSDK.framework'
       c.static_framework = true


  end

  s.xcconfig =  {
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
      'ENABLE_BITCODE' => 'YES',
      'SWIFT_VERSION' => '5.1',
      'OTHER_CFLAGS'  => '-fembed-bitcode',
      'OTHER_LDFLAGS' => '-objc -ObjC -lc++ -framework "GoogleCast" -framework "ConvivaSDK"',
      'FRAMEWORK_SEARCH_PATHS' =>'$(inherited) "${PODS_ROOT}/ConvivaSDK/Frameworks"'
      'GCC_SYMBOLS_PRIVATE_EXTERN' => 'YES'
  }

  s.default_subspec = 'Core'

end
