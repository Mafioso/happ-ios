# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Happ' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Happ
  pod 'PromiseKit', '~> 3.5'
  pod 'PromiseKit/CoreLocation'
  pod 'RealmSwift', '= 2.1.2'
  pod 'Alamofire', '~> 3.4'
  pod 'SwiftyJSON', '2.4.0'
  pod 'ObjectMapper', '~> 1.3'
  pod 'ObjectMapper+Realm', '0.1'
  pod 'HanekeSwift' # fetch&cache images by urls
  pod 'KeychainSwift', git: "https://github.com/marketplacer/keychain-swift.git", branch: "swift_2_3"
  pod 'SlideMenuControllerSwift', git: "https://github.com/dekatotoro/SlideMenuControllerSwift.git", branch: "swift2.3"
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Shimmer'
  pod 'WTLCalendarView', git: "https://github.com/lenyapugachev/CalendarView.git"
  pod 'FacebookCore', '0.1.1'
  pod 'FacebookLogin', '0.1.1'
  pod 'IQKeyboardManagerSwift', '4.0.5'
  pod 'UITextView+Placeholder', '~> 1.2'
  pod 'QuickBlox'
  pod 'QMChatViewController', git: "https://github.com/lenyapugachev/QMChatViewController-ios.git"

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3' # or '3.0'
        end
    end
  end

end
