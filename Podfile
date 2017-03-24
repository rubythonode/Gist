source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

target 'Gist' do
	pod 'Realm'
	pod 'RxSwift',    '~> 3.0'
	pod 'RxCocoa',    '~> 3.0'
	pod 'RealmSwift'

end

target 'GistTests' do
	pod 'RealmSwift'
	pod 'RxBlocking', '~> 3.0'
	pod 'RxTest', '~>3.0'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end
