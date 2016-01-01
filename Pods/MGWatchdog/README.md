# MGWatchdog

[![CI Status](http://img.shields.io/travis/Max Gordeev/MGWatchdog.svg?style=flat)](https://travis-ci.org/Max Gordeev/MGWatchdog)
[![Version](https://img.shields.io/cocoapods/v/MGWatchdog.svg?style=flat)](http://cocoapods.org/pods/MGWatchdog)
[![License](https://img.shields.io/cocoapods/l/MGWatchdog.svg?style=flat)](http://cocoapods.org/pods/MGWatchdog)
[![Platform](https://img.shields.io/cocoapods/p/MGWatchdog.svg?style=flat)](http://cocoapods.org/pods/MGWatchdog)

## Usage

Start the watchdog to catch use-cases that are freezes UI for more than 400 ms:
```objective-c
NSTimeInterval const delayInSeconds = 0.4; // 400 ms
[MGWatchdog startWithDelay:delayInSeconds handler:^{
    NSString *name = @"MGWatchdogException";
    NSString *reason = [NSString stringWithFormat:@"UI has been freezed for more than %.0f ms", delayinseconds * 1000.0];
    @throw [NSException exceptionWithName:name reason:reason userInfo:nil];
}];
```

After catching an exception you can simply analyze Main thread call stack and find the problem in your code.


Stop the watchdog:
```objective-c
[MGWatchdog stop];
```


If you have an unfixable UI freeze (ex. using of thirdparty UI libraries) you can simply tell watchdog to skip observing freezes till the end of current UI loop:
```objective-c
[MGWatchdog skipCurrentLoop];
```

## Installation

MGWatchdog is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, '7.0'
pod "MGWatchdog"
```

## Author

Max Gordeev, maxim.m.gordeev@gmail.com

## License

MGWatchdog is available under the MIT license. See the LICENSE file for more info.

