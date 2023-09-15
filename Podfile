source 'https://cdn.cocoapods.org/'

platform :ios, '15.0'

install! 'cocoapods', :generate_multiple_pod_projects => true

inhibit_all_warnings!

use_frameworks! :linkage => :static

use_modular_headers!

target 'Tangram' do
    pod 'Alamofire', '5.7.1'
    pod 'Kingfisher', '7.8.1'
    pod 'RxSwift', '6.5.0'
    pod 'RxCocoa', '6.5.0'
end

# remove warning
post_install do |installer|
  installer.generated_projects.each do |project|
    project.build_configurations.each do |config|
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
    
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
