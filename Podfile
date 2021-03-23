platform :ios, '14.0'
use_frameworks!

def shared_pods
    use_frameworks!
    pod 'FontAwesome.swift'
    pod 'Kanna'
    pod 'MBProgressHUD'
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
end
