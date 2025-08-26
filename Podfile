platform :ios, '16.0'
use_frameworks!

target 'YouTubeAPI' do

  # Networking
  pod 'Moya/RxSwift', '~> 15.0'
  
  # Resources
  pod 'SwiftGen', '~> 6.0'
  pod 'SDWebImage', '~> 5.0'
  
  # Rx
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'
  pod 'RxDataSources', '~> 5.0'
  pod 'RxAnimated'
  
  # DI
  pod 'Swinject'
  
  # Layout
  pod 'SnapKit', '~> 5.6.0'
  
  # youtube
  pod 'YouTubePlayer'
  
  # progressHUD
  pod 'ProgressHUD'
  
end

 post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
     end
   end
 end