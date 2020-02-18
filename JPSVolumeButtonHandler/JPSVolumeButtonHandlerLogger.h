//
//  JPSVolumeButtonHandlerLogger.h
//  JPSVolumeButtonHandler
//
//  Created by Mark Godfrey on 10/8/19.
//  inspired by (copied from) XCDYouTubeLogger
//
//

#import <Foundation/Foundation.h>

/**
 *  The [context][1] used when logging with CocoaLumberjack.
 *
 *  [1]: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomContext.md
 */
extern const NSInteger JPSVolumeButtonHandlerLumberjackContext;

/**
 *  The log levels, closely mirroring the log levels of CocoaLumberjack.
 */
typedef NS_ENUM(NSUInteger, JPSLogLevel) {
    /**
     *  Used when an error is produced
     */
    JPSLogLevelError   = 0,
    
    /**
     *  Used on unusual conditions that may eventually lead to an error.
     */
    JPSLogLevelWarning = 1,
    
    /**
     *  Used when logging normal operational information is cancelled or finishes.
     */
    JPSLogLevelInfo    = 2,
    
    /**
     *  Used throughout for debugging purpose, e.g. for HTTP requests.
     */
    JPSLogLevelDebug   = 3,
    
    /**
     *  Used to report large amount of information, e.g. full HTTP responses.
     */
    JPSLogLevelVerbose = 4,
};

/**
 *  You can use the `JPSVolumeButtonHandlerLogger` class to configure how the JPSVolumeButtonHandler framework emits logs.
 *
 *  By default, logs are emitted through CocoaLumberjack if it is available, i.e. if the `DDLog` class is found at runtime.
 *  The [context][1] used for CocoaLumberjack is the `JPSVolumeButtonHandlerLumberjackContext` constant whose value is `(NSInteger)0xced70676`.
 *
 *  If CocoaLumberjack is not available, logs are emitted with `NSLog`, prefixed with the `[JPSVolumeButtonHandler]` string.
 *
 *  ## Controlling log levels
 *
 *  If you are using CocoaLumberjack, you are responsible for controlling the log levels with the CocoaLumberjack APIs.
 *
 *  If you are not using CocoaLumberjack, you can control the log levels with the `JPSVolumeButtonHandlerLogLevel` environment variable. See also the `<JPSLogLevel>` enum.
 *
 *  Level   | Value | Mask
 *  --------|-------|------
 *  Error   |   0   | 0x01
 *  Warning |   1   | 0x02
 *  Info    |   2   | 0x04
 *  Debug   |   3   | 0x08
 *  Verbose |   4   | 0x10
 *
 *  Use the corresponding bitmask to combine levels. For example, if you want to log *error*, *warning* and *info* levels, set the `JPSVolumeButtonHandlerLogLevel` environment variable to `0x7` (0x01 | 0x02 | 0x04).
 *
 *  If you do not set the `JPSVolumeButtonHandlerLogLevel` environment variable, only warning and error levels are logged.
 *
 *  [1]: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomContext.md
 */
@interface JPSVolumeButtonHandlerLogger : NSObject

@end
