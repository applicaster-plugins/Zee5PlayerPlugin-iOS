platform :ios, '10.0'
use_frameworks!
install! 'cocoapods', :deterministic_uuids => false

source 'git@github.com:applicaster/CocoaPods.git'
source 'git@github.com:applicaster/PluginsBuilderCocoaPods.git'
source 'https://itai_navot_applicaster:ZPrtZkpRTtseT7ezBXu3@bitbucket.org/zee5in/coresdk-ios.git'
source 'git@github.com:CocoaPods/Specs.git'
#source 'https://cdn.cocoapods.org/'

target 'Zee5PlayerPlugin' do

  pod 'FBAudienceNetwork'
  pod 'PlayKit', '3.16.0'
  pod 'PlayKit_IMA', '1.7.1'
  pod 'SnapKit'
  pod 'google-cast-sdk', '=3.5.3'
  pod 'Zee5CoreSDK'
  pod 'DownloadToGo'
  pod 'SQLite.swift'
  ### Download UI
  pod 'CarbonKit'
  pod 'DropDown'
  pod 'UICircularProgressRing'
  pod 'SDWebImage'
  pod 'ConvivaSDK'  # Analytics Helper
  # Applicaster START -----
  pod 'ZappPlugins'
  pod 'ApplicasterSDK'
  pod 'ZappSDK'
  # Applicaster END -----
  pod 'ComScore'
  pod 'LotameDMP', '~> 5.0'

pre_install do |installer|
	# workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
	Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

end
