//
//  JPSVolumeButtonHandlerLogger+Private.h
//  JPSVolumeButtonHandler
//
//  Created by Mark Godfrey on 4/6/17.
//  inspired by (copied from) JPSLogger
//
//

#import "JPSVolumeButtonHandlerLogger.h"

@interface JPSVolumeButtonHandlerLogger ()

+ (void) logMessage:(NSString *)message level:(JPSLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line;

@end

#define JPSVolumeButtonHandlerLog(_level, format, ...) [JPSVolumeButtonHandlerLogger logMessage:([NSString stringWithFormat:format, ##__VA_ARGS__]) level:(_level) file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__]

#define JPSLogError(...)   JPSVolumeButtonHandlerLog(JPSLogLevelError, __VA_ARGS__ )
#define JPSLogWarning(...) JPSVolumeButtonHandlerLog(JPSLogLevelWarning, __VA_ARGS__ )
#define JPSLogInfo(...)    JPSVolumeButtonHandlerLog(JPSLogLevelInfo, __VA_ARGS__ )
#define JPSLogDebug(...)   JPSVolumeButtonHandlerLog(JPSLogLevelDebug, __VA_ARGS__ )
#define JPSLogVerbose(...) JPSVolumeButtonHandlerLog(JPSLogLevelVerbose, __VA_ARGS__ )

