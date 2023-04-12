# coding: utf-8

source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
inhibit_all_warnings!
use_frameworks!

target 'AppleMusic' do
  pod 'SwiftyJSON', '~> 5.0.0'
  pod 'Alamofire',  '~> 5.2.2'
  pod 'Himotoki',   '~> 3.0.1'
  pod 'PureLayout', '~> 3.1.7'
  pod 'MJRefresh',  '~> 3.5.0'
  pod 'ZFListView', '~> 0.0.5'

  pod 'ZFMediaPlayer',
    :path => 'ZFMediaPlayer.podspec'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            end
        end
    end
end
