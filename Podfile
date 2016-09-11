project 'ZhihuDaily.xcodeproj'

# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'ZhihuDaily' do
  use_frameworks!
  
  pod 'Alamofire', '~> 4.0'
  pod 'AlamofireImage', '~> 3.0'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.0'
  # pod 'Kingfisher', :git => 'https://github.com/onevcat/Kingfisher.git', :branch => 'swift3'

end

post_install do |installer| 
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end
