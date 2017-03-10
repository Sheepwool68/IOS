//
//  CMDTestViewController.m
//  BluetoothManager
//
//  Created by user1 on 11/17/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "CMDTestViewController.h"
#import "MainViewController.h"

@interface CMDTestViewController ()

@end

@implementation CMDTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.lbl_deviceName setText:self.m_deviceName];
    [self.lbl_deviceUUID setText:self.m_deviceUDID];
    [self.textView setText:@""];
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
- (IBAction)onConnected:(id)sender {
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_CONNECTDEVICE;
    scanCommand.cmd_id = 1;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
    scanCommand.cmdData = dict;
    [self.m_mainview sendCMDObject:scanCommand];
}
- (IBAction)onDisconnected:(id)sender {
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_DISCONNECTDEVICE;
    scanCommand.cmd_id = 2;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
    scanCommand.cmdData = dict;
    [self.m_mainview sendCMDObject:scanCommand];
}
- (IBAction)onRead:(id)sender {
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_READDATA;
//    scanCommand.cmd_id = 3;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:self.m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    scanCommand.cmdData = dict;
//    [self.m_mainview sendCMDObject:scanCommand];
    
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_WRITEDATA;
    scanCommand.cmd_id = 3;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
    [dict setObject:@"S1=1#" forKey:@"peripheral-write"];
    scanCommand.cmdData = dict;
    [self.m_mainview sendCMDObject:scanCommand];
}
- (IBAction)onWrite:(id)sender {
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_WRITEDATA;
    scanCommand.cmd_id = 4;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
    [dict setObject:@"S1=0#" forKey:@"peripheral-write"];
    scanCommand.cmdData = dict;
    [self.m_mainview sendCMDObject:scanCommand];
}
- (IBAction)onNotify:(id)sender {
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_NOTIFY;
    scanCommand.cmd_id = 5;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
    scanCommand.cmdData = dict;
    [self.m_mainview sendCMDObject:scanCommand];

}

@end
