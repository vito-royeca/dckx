platform :ios, '15.5'
use_frameworks!

def shared_pods
    use_frameworks!
    pod 'Firebase/Analytics'
    pod 'Firebase/Crashlytics'
    # Recommended: Add the Firebase pod for Google Analytics
    pod 'Firebase/Analytics'

    pod 'Kanna'
    pod 'nlohmann_json', '~>3.1.2'
    pod 'OpenCV', '~> 3.1.0.1'
    pod 'PromiseKit'
    pod 'ReadabilityKit'
    pod 'SDWebImage'
    pod 'SDWebImageSwiftUI'
    pod "SwiftRater"
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

target 'dckx WidgetExtension' do
    inherit! :search_paths
    use_frameworks!
    pod 'PromiseKit'
    pod 'SDWebImage'
    pod 'SDWebImageSwiftUI'
end

target 'dckxUITests' do
    inherit! :search_paths
    shared_pods
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

