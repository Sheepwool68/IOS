//
//  FindViewController.m
//  BluetoothManager
//
//  Created by user1 on 11/30/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "FindViewController.h"
#import "SetupViewController.h"
#import "DeviceMemory.h"
#import "BLECMD.h"
#import "BLEManager.h"
#import "BLERESP.h"
#import "CommonAPI.h"
#import "AppDelegate.h"

@interface FindViewController ()<BluetoothDeviceResultDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * device_array;
    NSString * m_selectedUUID;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    device_array = [NSMutableArray new];
    // Do any additional setup after loading the view.
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    m_mainview.delegate = self;
    
    
    if([[DeviceMemory createInstance] checkDeviceConnected]){
        
        [self sendCMDdisConnect];
        [[DeviceMemory createInstance] alreadyConnected:NO];
    }
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onScan:(id)sender {
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    [m_mainview removeDeviceList];
//    [self sendCMDScan];
}

- (void)sendCMDdisConnect
{
//    NSString * deviceName =  [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_NAME];
//    NSString * deviceUUID =  [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_UUID];
//    
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 5;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:deviceUUID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"motor=%d#",0] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
//    
//    scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_DISCONNECTDEVICE;
//    scanCommand.cmd_id = 90;
//    scanCommand.cmd_waitTime = 10;
//    dict = [NSMutableDictionary new];
//    [dict setObject:deviceUUID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    scanCommand.cmdData = dict;
//    
//    [m_mainview sendCMDObject:scanCommand];
//    
//    [CommonAPI saveStringToLocal:@"" keyString:USERKEY_DEVICE_NAME];
//    [CommonAPI saveStringToLocal:@"" keyString:USERKEY_DEVICE_UUID];
}

- (void) sendCMDScan
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_SCANDEVICE;
//    scanCommand.cmd_id = 0;
//    scanCommand.cmd_waitTime = 20;
//    [m_mainview sendCMDObject:scanCommand];
//    
//    AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appdelegate showLoader];
}
- (void)BluetoothDeviceResult:(BLERESP*)response
{
//    if([response.function isEqualToString:@"didDiscoverPeripheral"]){
//        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appdelegate hideLoader];
//        
//        SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//        device_array = [m_mainview getDeviceList];
//        [self.tbl_data reloadData];
//    }else if([response.function isEqualToString:@"didConnectPeripheral"]){
//        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appdelegate hideLoader];
//        
//        [self.navigationController popViewControllerAnimated:YES];
//        if([self.parent_viewController isKindOfClass:[SetupViewController class]]){
//            [(SetupViewController*)self.parent_viewController reloadTables];
//        }
//        [[DeviceMemory createInstance] alreadyConnected:YES];
//        [CommonAPI saveStringToLocal:[((DeviceMemory*)[DeviceMemory createInstance]) getSelectedDeviceUUID] keyString:USERKEY_DEVICE_UUID];
//    }else if([response.function isEqualToString:@"endCMD"]){
//        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        [appdelegate hideLoader];
//        SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//        device_array = [m_mainview getDeviceList];
//        [self.tbl_data reloadData];
//    }else if([response.function isEqualToString:@"didDisconnectPeripheral"]){
//    }
}
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [device_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"basicDeviceCell"];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        NSDictionary * device  = [device_array objectAtIndex:indexPath.row];
        NSString * deviceUUID = [device objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * deviceName = [device objectForKey:@"peripheral-name"];
        [cell.detailTextLabel setText:deviceUUID];
        [cell.textLabel setText:deviceName];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary * selectedDevice  = [device_array objectAtIndex:indexPath.row];
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_CONNECTDEVICE;
//    scanCommand.cmd_id = 10;
//    scanCommand.cmd_waitTime = 10;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:[selectedDevice objectForKey:@"peripheral-identifier-UUIDString"] forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:[selectedDevice objectForKey:@"peripheral-name"] forKey:@"peripheral-identifier-Name"];
//    scanCommand.cmdData = dict;
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    [m_mainview sendCMDObject:scanCommand];
//    
//    [CommonAPI saveStringToLocal:[selectedDevice objectForKey:@"peripheral-name"] keyString:USERKEY_DEVICE_NAME];
//    [((DeviceMemory*)[DeviceMemory createInstance]) setSelectedDeviceUUID:[selectedDevice objectForKey:@"peripheral-identifier-UUIDString"]];
//    
//    AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appdelegate showLoader];
}
@end
