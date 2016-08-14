project 'ZhihuDaily.xcodeproj'

# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'ZhihuDaily' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'swift3'
  pod 'AlamofireImage', :git => 'https://github.com/kemchenj/AlamofireImage.git', :branch => 'swift3'

  # Pods for ZhihuDaily

end

  post_install do |installer| installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.0'
          config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.11'
        end
      end
    end