//
//  RacingScanVController.m
//  RFIDRacing
//
//  Created by user1 on 2/10/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "RacingScanVController.h"
#import "DeviceItemCell.h"
#import "BLECMD.h"
#import "BLEManager.h"
#import "LogicViewController.h"
#import "DeviceMemory.h"
#import "AppDelegate.h"
#import "RacingMainVController.h"
#import "CommonAPI.h"


@interface RacingScanVController ()<UITableViewDelegate, UITableViewDataSource,BluetoothDeviceResultDelegate>
{
    NSMutableArray * device_array;
    NSDictionary * selected_device;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_devices;
@property (weak, nonatomic) IBOutlet UIButton *btn_scan;
@end

@implementation RacingScanVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[DeviceMemory createInstance] set_scanViewController:self];
}
- (void) viewDidAppear:(BOOL)animated
{
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
    
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    
    [self onScan:nil];
}
- (IBAction)onScan:(id)sender {
    [self onStartScan];
}

- (void) onStartScan
{
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    [m_mainview removeDeviceList];
    [self sendCMDScan];
}

- (void) sendCMDScan
{
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_SCANDEVICE;
    scanCommand.cmd_id = 0;
    scanCommand.cmd_waitTime = 5;
    [m_mainview sendCMDObject:scanCommand];
    
    if(!device_array || device_array.count == 0){
        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate showLoader];
    }
}
- (void) sendCMDStopScan
{
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_STOPSCAN;
    scanCommand.cmd_id = 0;
    scanCommand.cmd_waitTime = 3;
    [m_mainview sendCMDObject:scanCommand];
    
    AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdelegate showLoader];
}
- (void)BluetoothDeviceResult:(BLERESP*)response
{
    if([response.function isEqualToString:@"didDiscoverPeripheral"]){
        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate hideLoader];
        
        LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
        device_array = [m_mainview getDeviceList];
        
        [device_array sortUsingComparator:^NSComparisonResult(id  obj1, id obj2){
            NSDictionary * Obj1 = (NSDictionary*)obj1;
            NSDictionary * Obj2 = (NSDictionary*)obj2;
            
            float rssi1 = [[Obj1 objectForKey:@"RSSI"] floatValue];
            float rssi2 = [[Obj2 objectForKey:@"RSSI"] floatValue];
            if(rssi1 < rssi2) return NSOrderedDescending;
            else if(rssi1 > rssi2) return NSOrderedAscending;
            return NSOrderedSame;
        }];
        
        [self.tbl_devices reloadData];
    }else if([response.function isEqualToString:@"didConnectPeripheral"]){
    }else if([response.function isEqualToString:@"endCMD"]){
        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate hideLoader];
        LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
        device_array = [m_mainview getDeviceList];
        [device_array sortUsingComparator:^NSComparisonResult(id  obj1, id obj2){
            NSDictionary * Obj1 = (NSDictionary*)obj1;
            NSDictionary * Obj2 = (NSDictionary*)obj2;
            
            float rssi1 = [[Obj1 objectForKey:@"RSSI"] floatValue];
            float rssi2 = [[Obj2 objectForKey:@"RSSI"] floatValue];
            if(rssi1 < rssi2) return NSOrderedDescending;
            else if(rssi1 > rssi2) return NSOrderedAscending;
            return NSOrderedSame;
        }];
        
        [self.tbl_devices reloadData];
        [self onScan:nil];
    }else if([response.function isEqualToString:@"didDisconnectPeripheral"]){
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"goroRacingmain"]){
        NSString * deviceUUID = [selected_device objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * deviceName = [selected_device objectForKey:@"peripheral-name"];
        RacingMainVController * controller = (RacingMainVController*)segue.destinationViewController;
        controller.device_name = deviceName;
        controller.device_udid = deviceUUID;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [device_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"DeviceItemCell"];
    DeviceItemCell * cell = (DeviceItemCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        NSDictionary * device  = [device_array objectAtIndex:indexPath.row];
        NSString * deviceUUID = [device objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * deviceName = [device objectForKey:@"peripheral-name"];
        NSNumber * rssi = [device objectForKey:@"RSSI"];
        [cell.lbl_macaddress setText:deviceUUID];
        [cell.lbl_deviceName setText:deviceName];
        [cell.lbl_rssi setText:[NSString stringWithFormat:@"Signal Strength %@",rssi]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected_device = [device_array objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"goroRacingmain" sender:self];
}
@end
