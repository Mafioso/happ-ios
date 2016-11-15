# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Happ' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Happ
  pod 'PromiseKit', '~> 3.4'
  pod 'RealmSwift'
  pod 'Alamofire', '~> 3.4'
  pod 'ObjectMapper', '~> 1.3'
  pod 'ObjectMapper+Realm'
  pod 'HanekeSwift' # fetch&cache images by urls
  pod 'KeychainSwift', git: "https://github.com/marketplacer/keychain-swift.git", branch: "swift_2_3"
  pod 'SlideMenuControllerSwift', git: "https://github.com/dekatotoro/SlideMenuControllerSwift.git", branch: "swift2.3"
  pod 'GoogleMaps'
  pod 'GooglePlaces'


  pod 'Jibber-Framework', '~> 2.0.0', :configurations => ['Debug']


  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3' # or '3.0'
        end
    end
  end

end
