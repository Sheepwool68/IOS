//
//  DeviceMemory.m
//  BluetoothManager
//
//  Created by user1 on 11/20/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "DeviceMemory.h"

@implementation DeviceMemory
static DeviceMemory * _deviceMemory;

- (void) setSelectedDeviceUUID:(NSString*)uuidStr
{
    self.device_uuidStr = uuidStr;
}
- (NSString *) getSelectedDeviceUUID
{
    return self.device_uuidStr;
}
- (void) alreadyConnected:(BOOL)res
{
    self.alreadyConnectToDevice = res;
}
- (BOOL) checkDeviceConnected
{
    return self.alreadyConnectToDevice;
}

+(id) createInstance
{
    if(!_deviceMemory)
        _deviceMemory = [DeviceMemory new];
    return _deviceMemory;
}
@end
