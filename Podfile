platform :osx, '10.11'
abstract_target 'waka_watcher' do
    pod 'CocoaLumberjack'
    pod 'XCDLumberjackNSLogger'

    target :waka_watcher do
        pod 'NSColor-Pantone'
        pod 'NSColor-Crayola'
        pod 'SAMKeychain'
        pod 'LetsMove'
        pod 'MTEThreadsafeCollections', :git => 'https://github.com/sdevore/MTEThreadsafeCollections.git'
        pod 'DevMateKit'
        pod 'CDEvents'
    end
    
    target :waka_watcher_heartbeat do
        
    end
    
    target :waka_watcherTests do
        pod 'OHHTTPStubs'
        
      
       pod 'OCMockito'
    end
    target :waka_watcherUITests do
        pod 'OHHTTPStubs'
       
    end
end