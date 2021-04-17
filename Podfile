platform :ios, '14.0'
use_frameworks!

def shared_pods
    use_frameworks!
    pod 'Firebase/Analytics'
    pod 'Firebase/Crashlytics'
    # Recommended: Add the Firebase pod for Google Analytics
    pod 'Firebase/Analytics'

    pod 'FontAwesome.swift'
    pod 'Kanna'
    #pod 'LegoCV'
    pod 'MBProgressHUD'
    pod 'nlohmann_json', '~>3.1.2'
    pod 'OpenCV', '~> 3.1.0.1'
    pod 'PromiseKit'
    pod 'ReadabilityKit'
    pod 'SDWebImage'
    pod 'SDWebImageSwiftUI'
    pod 'Sync'
end

target 'dckx' do
    inherit! :search_paths
    shared_pods
end

target 'dckxTests' do
    inherit! :search_paths
    shared_pods
end

target 'dckxUITests' do
    inherit! :search_paths
    shared_pods
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

