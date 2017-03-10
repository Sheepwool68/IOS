//
//  LogicViewController.m
//  RFIDRacing
//
//  Created by user1 on 2/10/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "LogicViewController.h"
#import "DeviceMemory.h"
#import "BLECommand.h"
#import "WebService.h"
#import "CommonAPI.h"
#import "CMDTestViewController.h"
#import "AppDelegate.h"

@interface LogicViewController ()<WebServiceDelegate>
{
    BLECommand * command;
    
    
    NSMutableArray * m_device_udid;
    
    NSDictionary * selectedDevice;
    
    int nowCMDIndex;
    
    
    BOOL didConnected;
    
}
@end

@implementation LogicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_device_udid = [NSMutableArray new];
    // Do any additional setup after loading the view.
    didConnected = NO;
    
    ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController = self;
    
    command = [BLECommand new];
    [self performSelector:@selector(receiveRESP) withObject:nil afterDelay:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) sendCMD:(BLECMD*)com{
    
    WebService * service= [[WebService alloc] init];
    service.delegate = self;
    NSDictionary * cmdDict = [com convertToDictionary];
    [service sendCMDToDest:cmdDict];
    
}
- (void) sendRESP:(BLERESP*)resp{
    
    NSDictionary * cmdDict = [resp convertToDictionary];
    WebService * service= [[WebService alloc] init];
    service.delegate = self;
    
    [service sendRespToSrc:cmdDict];
}
- (void) receiveCMD{
    WebService * service= [[WebService alloc] init];
    service.delegate = self;
    [service getCMDFromSrc];
    
    [self performSelector:@selector(receiveCMD) withObject:nil afterDelay:3];
}
- (void) receiveRESP{
    WebService * service= [[WebService alloc] init];
    service.delegate = self;
    [service getRespFromDest];
    
    [self performSelector:@selector(receiveRESP) withObject:nil afterDelay:2];
}
- (void)WebServiceDelegate_recieveCMD:(NSArray*)data
{
    for(NSString * cmd in data){
        NSDictionary * dict = [CommonAPI createDictFromJson:cmd];
        BLECMD * comStr = [BLECMD convertFromDictionary:dict];
        [command execCommand:comStr];
    }
}
- (void)WebServiceDelegate_recieveRSP:(NSArray*)data
{
    for(NSString * cmd in data){
        NSDictionary * dict = [CommonAPI createDictFromJson:cmd];
        BLERESP * respStr = [BLERESP convertFromDictionary:dict];
        NSLog(@"RESP: %@ %@ %@ %d",respStr.function,respStr.message, respStr.send, respStr.messageType);
        [self manageBLEResponse:respStr];
    }
}
- (void) sendCMDObject:(NSObject*)object
{
    [self sendCMD:(BLECMD*)object];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
/////////// manage BLE responses
- (void) manageBLEResponse:(BLERESP*)resp
{
    if([resp.function isEqualToString:@"centralManagerDidUpdateState"]){
        [self centralManagerDidUpdateState:resp];
    }else if([resp.function isEqualToString:@"didDiscoverPeripheral"]){
        [self didDiscoverPeripheral:resp];
    }else if([resp.function isEqualToString:@"didConnectPeripheral"]){
        [self didConnectPeripheral:resp];
    }else if([resp.function isEqualToString:@"didDisconnectPeripheral"]){
        [self didDisconnectPeripheral:resp];
    }else if([resp.function isEqualToString:@"didDiscoverServices"]){
        [self didDiscoverServices:resp];
    }else if([resp.function isEqualToString:@"didDiscoverCharacteristicsForService"]){
        [self didDiscoverCharacteristicsForService:resp];
    }else if([resp.function isEqualToString:@"didUpdateValueForCharacteristic"]){
        [self didUpdateValueForCharacteristic:resp];
    }else if([resp.function isEqualToString:@"didWriteValueForCharacteristic"]){
        [self didWriteValueForCharacteristic:resp];
    }else if([resp.function isEqualToString:@"didUpdateNotificationStateForCharacteristic"]){
        [self didUpdateNotificationStateForCharacteristic:resp];
    }else if([resp.function isEqualToString:@"endCMD"]){
        [self endCMD:resp];
    }
}
- (void)centralManagerDidUpdateState:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
    }else{ ///end cmd
    }
}
- (void)didDiscoverPeripheral:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
    }else{ ///end cmd
        if(!m_device_udid)
            m_device_udid = [NSMutableArray new];
        NSString * deviceName = [(NSDictionary*)resp.message objectForKey:@"peripheral-name"];
        NSString * deviceUUID = [(NSDictionary*)resp.message objectForKey:@"peripheral-identifier-UUIDString"];
        
        if(deviceName && deviceName.length > 0){
            BOOL alreadyContains = NO;
            for(NSDictionary * sunresp in m_device_udid){
                NSString * recent_deviceName = [sunresp objectForKey:@"peripheral-name"];
                if([recent_deviceName isEqualToString:deviceName]){
                    alreadyContains = YES;
                }
            }
            if(!alreadyContains)
                [m_device_udid addObject:resp.message];
        }
        
        if(nowCMDIndex == 100){
            NSString * uuidString = [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_UUID];
            NSString * deviceName = [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_NAME];
            if([uuidString isEqualToString:deviceUUID]){
                BLECMD * scanCommand = [BLECMD new];
                scanCommand.cmdStr = CMDSTR_CONNECTDEVICE;
                scanCommand.cmd_id = 10;
                scanCommand.cmd_waitTime = 10;
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setObject:uuidString forKey:@"peripheral-identifier-UUIDString"];
                [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
                scanCommand.cmdData = dict;
                nowCMDIndex = 1;
                [self sendCMD:scanCommand];
                [((DeviceMemory*)[DeviceMemory createInstance]) setSelectedDeviceUUID:uuidString];
            }
        }
        if(self.ble_delegate){
            [self.ble_delegate BluetoothDeviceResult:resp];
        }
    }
}
- (NSMutableArray *) getDeviceList
{
    return m_device_udid;
}
- (void) removeDeviceList
{
    m_device_udid = [NSMutableArray new];
}
- (void)didConnectPeripheral:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return
    {
        if(nowCMDIndex == 1){
            [CommonAPI saveStringToLocal:@"" keyString:USERKEY_DEVICE_NAME];
            
        }
    }else{ ///end cmd
        //        [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_NAME]
        NSString * uuidString = [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_UUID];
        for(NSDictionary * subDict in m_device_udid){
            NSString * deviceName = [subDict objectForKey:@"peripheral-name"];
            NSString * deviceUUID = [subDict objectForKey:@"peripheral-identifier-UUIDString"];
            if([deviceUUID isEqualToString:uuidString]){
                [CommonAPI saveStringToLocal:deviceName keyString:USERKEY_DEVICE_NAME];
            }
        }
        
        if(self.ble_delegate){
            [self.ble_delegate BluetoothDeviceResult:resp];
        }else if(nowCMDIndex == 1){
            if(didConnected){
                return;
            }
            didConnected = YES;
            [[DeviceMemory createInstance] alreadyConnected:YES];
        }
    }
}
- (void)didDisconnectPeripheral:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingString:@"-----DisConnect fail!!!-----\n"]];
    }else{ ///end cmd
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingString:@"-----DisConnected!!!------\n"]];
        if(self.ble_delegate){
            [self.ble_delegate BluetoothDeviceResult:resp];
        }
    }
}
- (void)didDiscoverServices:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
    }else{ ///end cmd
    }
}
- (void)didDiscoverCharacteristicsForService:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
    }else{ ///end cmd
    }
}
- (void)didUpdateValueForCharacteristic:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingFormat:@"-----Read Error!!!%@-----\n",resp.message]];
    }else{ ///end cmd
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingFormat:@"-----Read Success!!!%@-----\n",resp.message]];
        self.ble_delegate = ((DeviceMemory*)[DeviceMemory createInstance]).BluetoothDeviceResultReceiver;
        if(self.ble_delegate){
            [self.ble_delegate BluetoothDeviceResult:resp];
        }
    }
}
- (void)didWriteValueForCharacteristic:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingFormat:@"-----Write Error!!!%@-----\n",resp.message]];
    }else{ ///end cmd
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingFormat:@"-----Write Success!!!%@-----\n",resp.message]];
    }
}
- (void)didUpdateNotificationStateForCharacteristic:(BLERESP*)resp
{
    if(resp.messageType == 0)/// return error
    {
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingFormat:@"-----Notify Error!!!%@-----\n",resp.message]];
    }else{ ///end cmd
        //        [testcontroller.textView setText:[testcontroller.textView.text stringByAppendingFormat:@"-----Notify Success!!!%@-----\n",resp.message]];
        self.ble_delegate = ((DeviceMemory*)[DeviceMemory createInstance]).BluetoothDeviceResultReceiver;
        if(self.ble_delegate){
            [self.ble_delegate BluetoothDeviceResult:resp];
        }
    }
}
- (void)endCMD:(BLERESP*)resp
{
    if(nowCMDIndex == 100){
        nowCMDIndex = -1;
        if([resp.message isEqualToString:@"0"]){
            [CommonAPI saveStringToLocal:@"" keyString:USERKEY_DEVICE_NAME];
        }
    }
    
    if(self.ble_delegate){
        [self.ble_delegate BluetoothDeviceResult:resp];
    }
}
@end
