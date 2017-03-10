//
//  MainViewController.m
//  BluetoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "MainViewController.h"
#import "BLECommand.h"
#import "WebService.h"
#import "CommonAPI.h"
#import "CMDTestViewController.h"
#import "DeviceMemory.h"
#import "SplashViewController.h"

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource,WebServiceDelegate>
{
    BLECommand * command;
    
    
    NSMutableArray * m_device_udid;
    
    NSDictionary * selectedDevice;
    
    
//    CMDTestViewController * testcontroller;
}
@property (weak, nonatomic) IBOutlet UITableView *tbl_devices;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController = self;
//    
//    command = [BLECommand new];
//    [self performSelector:@selector(receiveRESP) withObject:nil afterDelay:2];
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
    if([segue.identifier isEqualToString:@"showCMDView"]){
//        testcontroller = (CMDTestViewController*)[segue destinationViewController];
//        testcontroller.m_mainview = self;
//        testcontroller.m_deviceUDID = [selectedDevice objectForKey:@"peripheral-identifier-UUIDString"];
    }else if([segue.identifier isEqualToString:@"showRealMode"]){
        SplashViewController * controller = (SplashViewController*)[segue destinationViewController];
        ((DeviceMemory*)[DeviceMemory createInstance]).BluetoothDeviceResultReceiver = controller;
    }
}

- (IBAction)onsScan:(id)sender {
//    m_device_udid = [NSMutableArray new];
//    
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_SCANDEVICE;
//    scanCommand.cmd_id = 0;
//    scanCommand.cmd_waitTime = 20;
//    [self sendCMD:scanCommand];
}
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_device_udid count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"basicCell"];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        NSDictionary * device  = [m_device_udid objectAtIndex:indexPath.row];
        NSString * deviceUUID = [device objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * deviceName = [device objectForKey:@"peripheral-name"];
        [cell.detailTextLabel setText:deviceUUID];
        [cell.textLabel setText:deviceName];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedDevice  = [m_device_udid objectAtIndex:indexPath.row];
    
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_CONNECTDEVICE;
    scanCommand.cmd_id = 10;
    scanCommand.cmd_waitTime = 10;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:[selectedDevice objectForKey:@"peripheral-identifier-UUIDString"] forKey:@"peripheral-identifier-UUIDString"];
    scanCommand.cmdData = dict;
    [self sendCMDObject:scanCommand];
    [((DeviceMemory*)[DeviceMemory createInstance]) setSelectedDeviceUUID:[selectedDevice objectForKey:@"peripheral-identifier-UUIDString"]];
}


@end
