//
//  JPSVolumeButtonHandler.h
//  JPSImagePickerController
//
//  Created by JP Simard on 1/31/2014.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JPSVolumeButtonBlock)(void);

@interface JPSVolumeButtonHandler : NSObject

// A block to run when the volume up button is pressed
@property (nonatomic, copy) JPSVolumeButtonBlock upBlock;

// A block to run when the volume down button is pressed
@property (nonatomic, copy) JPSVolumeButtonBlock downBlock;

// A shared audio session category
@property (nonatomic, strong) NSString * sessionCategory;

@property (nonatomic, readonly) BOOL appIsActive;
@property (nonatomic, readonly) BOOL isStarted;

- (void)startHandler:(BOOL)disableSystemVolumeHandler;
- (void)stopHandler;

- (BOOL)isHeadsetPluggedIn;

// Returns a button handler with the specified up/down volume button blocks
+ (instancetype)volumeButtonHandlerWithUpBlock:(JPSVolumeButtonBlock)upBlock downBlock:(JPSVolumeButtonBlock)downBlock;

@end
