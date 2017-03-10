//
//  DeviceMemory.h
//  BluetoothManager
//
//  Created by user1 on 11/20/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogicViewController.h"
#import "RacingScanVController.h"

@interface DeviceMemory : NSObject
@property (nonatomic, retain) NSString * device_uuidStr;
@property (nonatomic, retain) LogicViewController * _mainViewController;
@property (nonatomic, retain) RacingScanVController * _scanViewController;
@property (nonatomic, retain) id BluetoothDeviceResultReceiver;
@property (atomic) BOOL alreadyConnectToDevice;
@property (nonatomic, retain) NSString*  shared_fileName;

- (void) setSelectedDeviceUUID:(NSString*)uuidStr;
- (NSString *) getSelectedDeviceUUID;

- (void) alreadyConnected:(BOOL)res;
- (BOOL) checkDeviceConnected;

+(id) createInstance;
@end
