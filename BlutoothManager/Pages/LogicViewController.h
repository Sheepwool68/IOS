//
//  LogicViewController.h
//  RFIDRacing
//
//  Created by user1 on 2/10/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECMD.h"

@protocol BluetoothDeviceResultDelegate

- (void)BluetoothDeviceResult:(BLERESP*)response;

@end

@interface LogicViewController : UINavigationController
@property (nonatomic, retain) id<BluetoothDeviceResultDelegate> ble_delegate;
- (void) sendCMDObject:(NSObject*)object;
- (NSMutableArray *) getDeviceList;
- (void) removeDeviceList;
@end
