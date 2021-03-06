//
//  JPSVolumeButtonHandler.m
//  JPSImagePickerController
//
//  Created by JP Simard on 1/31/2014.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

#import "JPSVolumeButtonHandler.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "JPSVolumeButtonHandlerLogger+Private.h"

static NSString *const sessionVolumeKeyPath = @"outputVolume";
static void *sessionContext                 = &sessionContext;
static CGFloat maxVolume                    = 0.6f;
static CGFloat minVolume                    = 0.4f;

@interface JPSVolumeButtonHandler ()

@property (nonatomic, assign) CGFloat          initialVolume;
@property (nonatomic, assign) CGFloat          lastVolume;
@property (nonatomic, strong) AVAudioSession * session;
@property (nonatomic, strong) MPVolumeView   * volumeView;
@property (nonatomic, assign) BOOL             appIsActive;
@property (nonatomic, assign) BOOL             isStarted;
@property (nonatomic, assign) BOOL             disableSystemVolumeHandler;
@property (nonatomic, assign) BOOL             isAdjustingInitialVolume;


@end

@implementation JPSVolumeButtonHandler

#pragma mark - Init

- (id)init {
    self = [super init];
    
    if (self) {
        _appIsActive = YES;
        _sessionCategory = AVAudioSessionCategoryPlayAndRecord;

    }
    return self;
}

- (void)dealloc {
    [self stopHandler];
    [self.volumeView removeFromSuperview];
}

- (void)startHandler:(BOOL)disableSystemVolumeHandler {
	if (!self.volumeView) {
		self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0)];
		_volumeView.hidden = YES;
	}

	if (!self.volumeView.superview) {
		[[UIApplication sharedApplication].windows.firstObject addSubview:_volumeView];
	}

    [self setupSession];
    self.volumeView.hidden = NO; // Start visible to prevent changes made during setup from showing default volume
    self.disableSystemVolumeHandler = disableSystemVolumeHandler;

    // There is a delay between setting the volume view before the system actually disables the HUD
    [self performSelector:@selector(setupSession) withObject:nil afterDelay:1];
}

- (void)stopHandler {
    if (!self.isStarted) {
        // Prevent stop process when already stop
        return;
    }
    
    self.isStarted = NO;
    
    self.volumeView.hidden = YES;
    // https://github.com/jpsim/JPSVolumeButtonHandler/issues/11
    // http://nshipster.com/key-value-observing/#safe-unsubscribe-with-@try-/-@catch
    @try {
        [self.session removeObserver:self forKeyPath:sessionVolumeKeyPath];
    }
    @catch (NSException * __unused exception) {
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupSession {
    if (self.isStarted){
        // Prevent setup twice
        return;
    }

    BOOL result = NO;
    NSError *error = nil;
    
    self.session = [AVAudioSession sharedInstance];
    // this must be done before calling setCategory or else the initial volume is reset
    [self setInitialVolume];
    result = [self.session setCategory:_sessionCategory
                                withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                      error:&error];
    if (!result) {
        JPSLogError(@"setCategory error: %@", [error localizedDescription]);
        return;
    }
    
    result = [self.session setActive:YES error:&error];
    if (!result) {
        JPSLogError(@"setActive error: %@", [error localizedDescription]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    
//    // Observe outputVolume
//    [self.session addObserver:self
//                   forKeyPath:sessionVolumeKeyPath
//                      options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
//                      context:sessionContext];

    // Audio session is interrupted when you send the app to the background,
    // and needs to be set to active again when it goes to app goes back to the foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidChangeActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidChangeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServicesWereLost:)
                                                 name:AVAudioSessionMediaServicesWereLostNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaServicesWereReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:nil];

    self.volumeView.hidden = !self.disableSystemVolumeHandler;
    
    self.isStarted = YES;
}

- (void)audioSessionInterrupted:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            JPSLogDebug(@"Audio Session Interruption case started.");
            break;
        case AVAudioSessionInterruptionTypeEnded:
        {
            JPSLogDebug(@"Audio Session Interruption case ended.");
            NSError *error = nil;
            BOOL result = [self.session setActive:YES error:&error];
            if (!result) {
                JPSLogError(@"setActive error: %@", error);
            }
            break;
        }
        default:
            break;
    }
}

- (void)setInitialVolume {
//    self.initialVolume = self.session.outputVolume;
//    if (self.initialVolume > maxVolume) {
//        self.initialVolume = maxVolume;
//        self.isAdjustingInitialVolume = YES;
//        [self setSystemVolume:self.initialVolume];
//    } else if (self.initialVolume < minVolume) {
//        self.initialVolume = minVolume;
//        self.isAdjustingInitialVolume = YES;
//        [self setSystemVolume:self.initialVolume];
//    }
    
    self.initialVolume = 0.5;
    [self setSystemVolume:self.initialVolume];
}

- (void)applicationDidChangeActive:(NSNotification *)notification {
    JPSLogDebug(@"applicationDidChangeActive: %@", notification.name);
    self.appIsActive = [notification.name isEqualToString:UIApplicationDidBecomeActiveNotification];
    if (self.appIsActive && self.isStarted) {
        [self setInitialVolume];
    }
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

- (void)routeChanged:(NSNotification *)notification
{
    JPSLogInfo(@"routeChanged: %@", notification.userInfo);
}

- (void)mediaServicesWereLost:(NSNotification *)notification
{
    JPSLogInfo(@"mediaServicesWereLost");
    self.isStarted = NO;
}

- (void)mediaServicesWereReset:(NSNotification *)notification
{
    JPSLogInfo(@"mediaServicesWereReset");
    [self setupSession];
}

- (void)volumeChanged:(NSNotification *)notification
{
    //JPSLogDebug(@"volumeChanged (%d %f): %@", _isAdjustingInitialVolume, _lastVolume, notification.userInfo);
    
    CGFloat volume = [notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] doubleValue];
    if (volume == _lastVolume)
    {
        return;
    }
    
    NSString *reason = notification.userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([reason isEqualToString:@"ExplicitVolumeChange"])
    {
        if (!_isAdjustingInitialVolume)
        {
            if (volume > _lastVolume) {
                if (self.upBlock) self.upBlock();
            } else {
                if (self.downBlock) self.downBlock();
            }
            
            // Reset volume
            [self setSystemVolume:self.initialVolume];
        }
        
        self.isAdjustingInitialVolume = NO;
    }
    
    //JPSLogDebug(@"done volumeChanged (%d): %@", _isAdjustingInitialVolume, notification.userInfo);
}

#pragma mark - Convenience

+ (instancetype)volumeButtonHandlerWithUpBlock:(JPSVolumeButtonBlock)upBlock downBlock:(JPSVolumeButtonBlock)downBlock {
    JPSVolumeButtonHandler *instance = [[JPSVolumeButtonHandler alloc] init];
    if (instance) {
        instance.upBlock = upBlock;
        instance.downBlock = downBlock;
    }
    return instance;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == sessionContext) {
        
        JPSLogDebug(@"volume changed! %@", change);
        
        if (!self.appIsActive) {
            // Probably control center, skip blocks
            JPSLogDebug(@"app not active!");
            return;
        }
        
        CGFloat newVolume = [change[NSKeyValueChangeNewKey] floatValue];
        CGFloat oldVolume = [change[NSKeyValueChangeOldKey] floatValue];

        if (self.disableSystemVolumeHandler && newVolume == self.initialVolume) {
            // Resetting volume, skip blocks
            return;
        } else if (self.isAdjustingInitialVolume) {
            if (newVolume == maxVolume || newVolume == minVolume) {
                // Sometimes when setting initial volume during setup the callback is triggered incorrectly
                return;
            }
            self.isAdjustingInitialVolume = NO;
        }
        
        if (newVolume > oldVolume) {
            if (self.upBlock) self.upBlock();
        } else {
            if (self.downBlock) self.downBlock();
        }

        if (!self.disableSystemVolumeHandler) {
            // Don't reset volume if default handling is enabled
            return;
        }

        // Reset volume
        [self setSystemVolume:self.initialVolume];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - System Volume

- (void)setSystemVolume:(CGFloat)volume {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:(float)volume];
    self.lastVolume = volume;
#pragma clang diagnostic pop
}

@end
