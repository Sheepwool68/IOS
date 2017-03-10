//
//  MainViewController.h
//  BluetoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLERESP.h"
#import "BLECMD.h"

//@protocol BluetoothDeviceResultDelegate
//
//- (void)BluetoothDeviceResult:(BLERESP*)response;
//
//@end

@interface MainViewController : UIViewController
//@property (nonatomic, retain) id<BluetoothDeviceResultDelegate> delegate;
- (void) sendCMDObject:(NSObject*)object;
@end
