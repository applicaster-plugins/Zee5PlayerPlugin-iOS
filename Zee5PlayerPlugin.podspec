Pod::Spec.new do |s|
  s.name             = "Zee5PlayerPlugin"
  s.version          = '1.0.0'
  s.summary          = "Zee5PlayerPlugin"
  s.description      = <<-DESC
                        Zee5PlayerPlugin.
                       DESC
  s.homepage         = "https://github.com/applicaster/Zee5PlayerPlugin-iOS"
  s.license          = 'CMPS'
  s.author           = "Applicaster LTD."
  s.source           = { :git => "git@github.com:applicaster/Zee5PlayerPlugin-iOS.git", :tag => s.version.to_s }
  s.platform         = :ios, '10.0'
  s.requires_arc = true
  s.static_framework = false

  s.source_files  = 'PluginClasses/**/*.{h,m,swift}'
  s.resources = [ 'PluginClasses/**/*.{xib,png}']

  s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                'ENABLE_BITCODE' => 'YES',
                'SWIFT_VERSION' => '5.1',
                'COMPRESS_PNG_FILES' => 'NO',
                'STRIP_PNG_TEXT' => 'NO'
              }


  s.dependency 'ZappPlugins'
  s.dependency 'ApplicasterSDK'
  s.dependency 'React', '~> 0.59.10'

end
