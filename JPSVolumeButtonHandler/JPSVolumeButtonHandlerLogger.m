//
//  JPSVolumeButtonHandlerLogger.m
//  JPSVolumeButtonHandler
//
//  Created by Mark Godfrey on 10/8/19.
//  inspired by (copied from) XCDYouTubeLogger
//
//

#import "JPSVolumeButtonHandlerLogger.h"

#import <objc/runtime.h>

const NSInteger JPSVolumeButtonHandlerLumberjackContext = (NSInteger)0x9C3cac90;

@protocol JPSVolumeButtonHandlerLogger_DDLog
// Copied from CocoaLumberjack's DDLog interface
+ (void) log:(BOOL)asynchronous message:(NSString *)message level:(NSUInteger)level flag:(NSUInteger)flag context:(NSInteger)context file:(const char *)file function:(const char *)function line:(NSUInteger)line tag:(id)tag;
@end

static Class DDLogClass = Nil;

@implementation JPSVolumeButtonHandlerLogger

+ (void) initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        DDLogClass = objc_lookUpClass("DDLog");
        if (DDLogClass)
        {
            const SEL logSeletor = @selector(log:message:level:flag:context:file:function:line:tag:);
            const char *typeEncoding = method_getTypeEncoding(class_getClassMethod(DDLogClass, logSeletor));
            const char *expectedTypeEncoding = protocol_getMethodDescription(@protocol(JPSVolumeButtonHandlerLogger_DDLog), logSeletor, /* isRequiredMethod: */ YES, /* isInstanceMethod: */ NO).types;
            if (!(typeEncoding && expectedTypeEncoding && strcmp(typeEncoding, expectedTypeEncoding) == 0))
            {
                NSLog(@"[JPSVolumeButtonHandler] Incompatible CocoaLumberjack version. Expected \"%@\", got \"%@\".", expectedTypeEncoding ? @(expectedTypeEncoding) : @"", typeEncoding ? @(typeEncoding) : @"");
            }
        }
    });
}

+ (void) logMessage:(NSString *)message level:(JPSLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line
{
    // The `GCDLogLevel` enum was carefully crafted to match the `DDLogFlag` options from DDLog.h
    [DDLogClass log:YES message:message level:NSUIntegerMax flag:(1 << level) context:JPSVolumeButtonHandlerLumberjackContext file:file function:function line:line tag:nil];
}

@end

