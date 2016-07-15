platform :osx, '10.10'
abstract_target 'waka_watcher' do
    pod 'AFNetworking'
    pod 'CocoaLumberjack'
    pod 'XCDLumberjackNSLogger'
    pod 'AFNetworkActivityLogger'

    target :waka_watcher do
        pod 'NSColor-Pantone'
        pod 'NSColor-Crayola'
        pod 'SSKeychain'
        pod 'LetsMove'
        pod 'MTEThreadsafeCollections', :git => 'https://github.com/sdevore/MTEThreadsafeCollections.git'
        pod 'DevMateKit'
    end
    
    target :waka_watcher_heartbeat do
        
    end
    
    target :waka_watcherTests do
        pod 'OHHTTPStubs'
    end
    target :waka_watcherUITests do
        pod 'OHHTTPStubs'
    end
end