platform :ios, '13.0'
use_frameworks!

def shared_pods
    use_frameworks!
    pod 'FontAwesome.swift'
    pod 'Kanna'
    pod 'MBProgressHUD'
    pod 'PromiseKit'
    #pod 'SDWebImageSwiftUI', '>= 1.0.0-beta2'
    pod 'SDWebImage'
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
