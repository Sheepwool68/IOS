//
//  BLEManager.m
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import "BLEManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "CommonAPI.h"

@interface BLEManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *_centralManager;
    CBPeripheral *_discoveredPeripheral;
    NSMutableArray* _mData;
    NSArray* _tmpService;
    
    CBCharacteristic * read_characteristic;
    CBCharacteristic * write_characteristic;
    CBCharacteristic * notify_characteristic;
}
@end

@implementation BLEManager
static BLEManager * _bleManager;
+ (id) createInstanceWithReceiver:(id)reciverID
{
    if(!_bleManager)
        _bleManager = [BLEManager new];
    _bleManager.ble_delegate = reciverID;
    return _bleManager;
}

- (void) initialBLELib
{
    if(_mData){
        [self disconnectToDevice:@"" name:@""];
    }
    
    _mData = [NSMutableArray array];
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
- (void) stopScan
{
     [_centralManager stopScan];
}
- (void) connectToDevice:(NSString*)uuids name:(NSString*)name
{
    CBPeripheral * destPheral = nil;
    for (CBPeripheral* i in _mData)
    {
        if ([[i.identifier UUIDString] isEqualToString:uuids] && [i.name isEqualToString:name])
        {
            destPheral = i;
        }
    }
    if(destPheral){
        [_centralManager connectPeripheral:destPheral options:nil];
    }else{
        [self.ble_delegate BLEManagerDelegate_Message:@"didConnectPeripheral" :0 :@"No Device" :YES];
    }
}
- (void) disconnectToDevice:(NSString*)uuids name:(NSString*)name
{
//    CBPeripheral * destPheral = nil;
    for (CBPeripheral* i in _mData)
    {
        [_centralManager cancelPeripheralConnection:i];
     /*   if ([[i.identifier UUIDString] isEqualToString:uuids] && [i.name isEqualToString:name])
        {
            destPheral = i;
        }
      */
    }
//    if(destPheral){
//        [_centralManager cancelPeripheralConnection:destPheral];
//    }else{
//        [self.ble_delegate BLEManagerDelegate_Message:@"didDisConnectPeripheral" :0 :@"no device" :YES];
//    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
//        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please turn Bluetooth on" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.ble_delegate BLEManagerDelegate_Message:@"centralManagerDidUpdateState" :0 :@"Please turn Bluetooth on" :NO];
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        //        [_centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        [self.ble_delegate BLEManagerDelegate_Message:@"centralManagerDidUpdateState" :1 :@"Scanning started" :NO];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BOOL exist = NO;
    
    for (CBPeripheral* i in _mData)
    {
        if ([i.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
        {
            exist = YES;
            return;
        }
    }
    
    if (!exist)
    {
        [_mData addObject:peripheral];
        NSMutableDictionary * sendData = [NSMutableDictionary new];
        [sendData setObject:[NSNumber numberWithInteger:peripheral.state] forKey:@"peripheral-state"];
        [sendData setObject:[peripheral.identifier UUIDString] forKey:@"peripheral-identifier-UUIDString"];
        if(peripheral.name)
            [sendData setObject:peripheral.name forKey:@"peripheral-name"];
        [sendData setObject:RSSI forKey:@"RSSI"];
        [self.ble_delegate BLEManagerDelegate_Dict:@"didDiscoverPeripheral" :1 :sendData :NO];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"######## Connected peripheral %@ ########\n", [peripheral.identifier UUIDString]);
//    [self.ble_delegate BLEManagerDelegate_Message:@"didConnectPeripheral" :1 :[peripheral.identifier UUIDString] :YES];
    
    [_centralManager stopScan];
    _discoveredPeripheral = peripheral;
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"######## Disconnected peripheral %@ %@ #########\n", peripheral.name, [peripheral.identifier UUIDString]);
    [self.ble_delegate BLEManagerDelegate_Message:@"didDisconnectPeripheral" :1 :[NSString stringWithFormat:@"%@-%@",peripheral.name,[peripheral.identifier UUIDString]] :YES];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services)
    {
        NSLog(@"====== Discovered service %@ for peripheral %@ ======\n", [service.UUID UUIDString], [peripheral.identifier UUIDString]);
        
        [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverServices" :1 :[NSString stringWithFormat:@"%@-%@",[service.UUID UUIDString], [peripheral.identifier UUIDString]] :NO];
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"++++ Discovered characteristics %@ for service %@ ++++\n", [characteristic.UUID UUIDString], [service.UUID UUIDString]);
        [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :[NSString stringWithFormat:@"%@-%@",[characteristic.UUID UUIDString], [service.UUID UUIDString]] :NO];
        
        if ((characteristic.properties & CBCharacteristicPropertyBroadcast))
        {
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyBroadcast" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyRead))
        {
            read_characteristic = characteristic;
            NSLog(@"CBCharacteristicPropertyRead\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyRead" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse))
        {
            NSLog(@"CBCharacteristicPropertyWriteWithoutResponse\n");
            write_characteristic = characteristic;
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyWriteWithoutResponse" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyWrite))
        {
            NSLog(@"CBCharacteristicPropertyWrite\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyWrite" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyNotify))
        {
            NSLog(@"CBCharacteristicPropertyNotify\n");
            notify_characteristic = characteristic;
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyNotify" :NO];
            [self.ble_delegate BLEManagerDelegate_Message:@"didConnectPeripheral" :1 :[peripheral.identifier UUIDString] :YES];
        }
        if ((characteristic.properties & CBCharacteristicPropertyIndicate))
        {
            NSLog(@"CBCharacteristicPropertyIndicate\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyIndicate" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyAuthenticatedSignedWrites))
        {
            NSLog(@"CBCharacteristicPropertyAuthenticatedSignedWrites\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyAuthenticatedSignedWrites" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyExtendedProperties))
        {
            NSLog(@"CBCharacteristicPropertyExtendedProperties\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyExtendedProperties" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyNotifyEncryptionRequired))
        {
            NSLog(@"CBCharacteristicPropertyNotifyEncryptionRequired\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyNotifyEncryptionRequired" :NO];
        }
        if ((characteristic.properties & CBCharacteristicPropertyIndicateEncryptionRequired))
        {
            NSLog(@"CBCharacteristicPropertyIndicateEncryptionRequired\n");
            [self.ble_delegate BLEManagerDelegate_Message:@"didDiscoverCharacteristicsForService" :1 :@"CBCharacteristicPropertyIndicateEncryptionRequired" :NO];
        }
        
//        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//        
//        [peripheral readValueForCharacteristic:characteristic];
        //        [peripheral writeValue:dataToWrite forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        //        [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicPropertyWrite];
    }
}
- (void) readDataFromConnection:(NSString*)uuids name:(NSString*)name
{
    CBPeripheral * destPheral = nil;
    for (CBPeripheral* i in _mData)
    {
        if ([[i.identifier UUIDString] isEqualToString:uuids] && [i.name isEqualToString:name])
        {
            destPheral = i;
        }
    }
    if(read_characteristic){
        [destPheral readValueForCharacteristic:read_characteristic];
    }
}
- (void) writeDataToConnection:(NSData*)str :(NSString*)uuids name:(NSString*)name
{
    CBPeripheral * destPheral = nil;
    for (CBPeripheral* i in _mData)
    {
        if ([[i.identifier UUIDString] isEqualToString:uuids] && [i.name isEqualToString:name])
        {
            destPheral = i;
        }
    }
    if(write_characteristic){
        [destPheral writeValue:str forCharacteristic:write_characteristic type:CBCharacteristicWriteWithoutResponse];
        [self.ble_delegate BLEManagerDelegate_Message:@"didWriteValueForCharacteristic" :1 :@"Writed" :YES];
    }
}
- (void) notifyDataFromConnection:(NSString*)uuids name:(NSString*)name
{
    CBPeripheral * destPheral = nil;
    for (CBPeripheral* i in _mData)
    {
        if ([[i.identifier UUIDString] isEqualToString:uuids] && [i.name isEqualToString:name])
        {
            destPheral = i;
        }
    }
    if(notify_characteristic){
        [destPheral setNotifyValue:YES forCharacteristic:notify_characteristic];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating characteristic %@ with error %@", characteristic.UUID, [error localizedDescription]);
        [self.ble_delegate BLEManagerDelegate_Message:@"didUpdateValueForCharacteristic" :0 :@"Read error" :YES];
        return;
    }
    else
    {
        NSData *data = characteristic.value;
        NSString *str = @"";
        if(data)
            str = [CommonAPI convertDataToHexString:data];
//            str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//            str = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"Update characteristics %@ with value %@", characteristic.UUID, str);
        [self.ble_delegate BLEManagerDelegate_Message:@"didUpdateValueForCharacteristic" :1 :str  :YES];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error writing characteristic %@ with value %@", characteristic.UUID, [error localizedDescription]);
        [self.ble_delegate BLEManagerDelegate_Message:@"didWriteValueForCharacteristic" :0 :@"Write error" :YES];
    }
    else
    {
        NSData *data = characteristic.value;
        NSString *str = @"";
        if(data)
            str = [CommonAPI convertDataToHexString:data];
//            str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//            str = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"Write characteristics %@ with value %@", characteristic.UUID, str);
        [self.ble_delegate BLEManagerDelegate_Message:@"didWriteValueForCharacteristic" :1 :str :YES];

    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error notify characteristic %@ with value %@", characteristic.UUID, [error localizedDescription]);
        [self.ble_delegate BLEManagerDelegate_Message:@"didWriteValueForCharacteristic" :0 :@"Write error" :YES];
    }
    else
    {
        NSData *data = characteristic.value;
        NSString *str = @"";
        if(data)
            str = [CommonAPI convertDataToHexString:data];
//            str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//            str = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"Notify characteristics %@ with value %@", characteristic.UUID, str);
        [self.ble_delegate BLEManagerDelegate_Message:@"didUpdateNotificationStateForCharacteristic" :1 :str :YES];
        
    }
}


@end
