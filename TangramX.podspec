Pod::Spec.new do |s|
s.name         = 'TangramX'
s.version      = '0.0.2'
s.author       = { 'lijingcheng' => 'bj_lijingcheng@163.com' }
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.homepage     = 'https://github.com/lijingcheng/Tangram'
s.source       = { :git => 'https://github.com/lijingcheng/Tangram.git', :tag => s.version.to_s }
s.summary      = 'Too big, Too strong, Too fast, Too good!!!'
s.static_framework = true
s.swift_version = '5.2'
s.ios.deployment_target = '10.0'
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
s.source_files = 'R.generated.swift', 'Tangram/Base/*.swift', 'Tangram/Extension/**/*.swift', 'Tangram/Service/*.swift', 'Tangram/Component/**/*.swift'
s.resource_bundles = { 'Tangram' => ['Tangram/Assets.xcassets'] }

s.dependency 'Alamofire', '5.4.1'
s.dependency 'Kingfisher', '5.15.8'
s.dependency 'SnapKit', '5.0.1'
s.dependency 'R.swift', '5.3.1'
s.dependency 'RxSwift', '6.0.0-rc.2'
s.dependency 'RxCocoa', '6.0.0-rc.2'
s.dependency 'SwiftLint', '0.42.0', :configurations => ['Debug']
    
end
