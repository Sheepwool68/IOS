//
//  SplashViewController.h
//  BluetoothManager
//
//  Created by user1 on 11/18/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLERESP.h"
#import "BLECMD.h"

@protocol BluetoothDeviceResultDelegate

- (void)BluetoothDeviceResult:(BLERESP*)response;

@end

@interface SplashViewController : UIViewController
@property (nonatomic, retain) id<BluetoothDeviceResultDelegate> delegate;
- (void) sendCMDObject:(NSObject*)object;
- (NSMutableArray *) getDeviceList;
- (void) removeDeviceList;

@end
