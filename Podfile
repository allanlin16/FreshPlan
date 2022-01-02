platform :ios, '10.3'
inhibit_all_warnings!
use_frameworks!

target 'FreshPlan' do
  pod 'SnapKit', '~> 4.0.0'
  pod 'RxSwift', '~> 4.0.0'
  pod 'RxCocoa', '~> 4.0.0'
  pod 'JWTDecode', '~> 2.1.1' 
  pod 'RxDataSources'
  pod 'RxGesture'
  pod 'RxSwiftExt'
  pod 'Moya/RxSwift'
  pod 'RxOptional'
  pod 'OneSignal', '>= 2.5.2', '< 3.0'
  pod 'MaterialComponents', '~> 42.0.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'ReachabilitySwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = "4.0"
    end
  end
end
