//
//  DashboardViewController.m
//  BluetoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "DashboardViewController.h"
#import "BashboardCell.h"
#import "DeviceMemory.h"
#import "BLECMD.h"
#import "BLEManager.h"
#import "BLERESP.h"
#import "CommonAPI.h"
#import "AppDelegate.h"

@interface DashboardViewController ()<UITableViewDataSource, UITableViewDelegate, BluetoothDeviceResultDelegate, UIAlertViewDelegate>
{
    NSMutableArray * titleArray;
    
    NSString * m_deviceUDID;
    NSString * m_stateResponse;
    
    BLERESPONSE_State * state_item;
    
    
    NSMutableArray * m_stateStrings;
    
    int current_count;
    int currtnt_time;
    
    
    NSString * deviceName;
    
    
    int longTouchTimerTime;
    BOOL longTouchEnd;
    
    
    BOOL sendSyncADisconnect;
}
@property (weak, nonatomic) IBOutlet UIButton *btn_move;
@property (weak, nonatomic) IBOutlet UIButton *btn_stop;
@property (weak, nonatomic) IBOutlet UIButton *btn_reset;
@property (weak, nonatomic) IBOutlet UIButton *btn_goal;
@property (weak, nonatomic) IBOutlet UIButton *btn_sprint;
@property (weak, nonatomic) IBOutlet UIButton *btn_run;
@property (weak, nonatomic) IBOutlet UIButton *btn_jog;
@property (weak, nonatomic) IBOutlet UIButton *btn_walk;
@property (weak, nonatomic) IBOutlet UILabel *lbl_steps;
@property (weak, nonatomic) IBOutlet UILabel *lbl_times;
@property (weak, nonatomic) IBOutlet UITableView *tbl_data;
@property (weak, nonatomic) IBOutlet UILabel *lbl_alert;
@property (weak, nonatomic) IBOutlet UILabel *lbl_stepsRemain;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timeRemain;
@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    current_count = 0;
    currtnt_time = 0;
    
    [self.lbl_alert setHidden:YES];
    
    deviceName =  [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_NAME];
    
    // Do any additional setup after loading the view.
    titleArray = [[NSMutableArray alloc] initWithObjects:@"Goal",@"Total",@"Remaining",@"Total Time", nil];
    
    [self updateState];
    
    m_stateResponse = @"";
    
    m_deviceUDID = [[DeviceMemory createInstance] getSelectedDeviceUUID];
    ((DeviceMemory*)[DeviceMemory createInstance]).BluetoothDeviceResultReceiver = self;
  
    [self sendCMDNotifySet];
    [self sendCMDSync];
    [self sendCMDDate];
}
- (void) updateState{
    m_stateStrings = [[NSMutableArray alloc] init];
    [m_stateStrings addObject:[CommonAPI getLocalValeuForKey:DEVICECONF_STEPS]];
     NSUserDefaults * defaultSaver = [NSUserDefaults standardUserDefaults];
    int count_value = (int)[defaultSaver integerForKey:@"KEY_COUNT"];
    int time_value = (int)[defaultSaver integerForKey:@"KEY_TIME"];
    [m_stateStrings addObject:[NSString stringWithFormat:@"%d",count_value]];
    int remain_count = [[CommonAPI getLocalValeuForKey:DEVICECONF_STEPS] intValue] - count_value;
    if(remain_count >= 0)
        [m_stateStrings addObject:[NSString stringWithFormat:@"%d",remain_count]];
    else
        [m_stateStrings addObject:[NSString stringWithFormat:@"%d Over",- remain_count]];
    [m_stateStrings addObject:[CommonAPI convertSecondToTime:(time_value / 1000)]];
    [self.tbl_data reloadData];
//    int today_count = [[CommonAPI getLocalValeuForKey:@"KEY_COUNT"] intValue];
//    [m_stateStrings addObject:today_count];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"BashboardCell"];
    BashboardCell * cell = (BashboardCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell){
        [cell.lbl_title setText:[titleArray objectAtIndex:indexPath.row]];
        [cell.lbl_value setText:[m_stateStrings objectAtIndex:indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (IBAction)onMove:(id)sender {
    [self sendCMDMoto:1];
}
- (IBAction)onStop:(id)sender {
    [self sendCMDMoto:0];
}
- (void)longPressTimerEvent
{
    longTouchTimerTime += 1;
    if(longTouchEnd){/// press end
    }else{// press yet
        if(longTouchTimerTime == 1){
            [self sendinitSpeedACount];
            [self performSelector:@selector(longPressTimerEvent) withObject:nil afterDelay:1];
        }else if(longTouchTimerTime == 5){
           [CommonAPI resetTodayCountATime];
            [self updateState];
        }else{
            [self performSelector:@selector(longPressTimerEvent) withObject:nil afterDelay:1];
        }
    }
    
}
- (void) sendinitSpeedACount
{
    if([CommonAPI getLocalValeuForKey:USERKEY_USERNAME].length > 0){
        NSString * userName = [CommonAPI getLocalValeuForKey:USERKEY_USERNAME];
        [self sendNameSync:userName];
    }
    NSString * device_speed = [CommonAPI getLocalValeuForKey:DEVICECONF_SPEED];
    if(device_speed){///@"Walk",@"Jog",@"Run",@"Sprint"
        if([device_speed isEqualToString:@"Walk"]) [self sendCMDSpeed:1];
        else if([device_speed isEqualToString:@"Jog"]) [self sendCMDSpeed:2];
        else if([device_speed isEqualToString:@"Run"]) [self sendCMDSpeed:3];
        else if([device_speed isEqualToString:@"Sprint"]) [self sendCMDSpeed:4];
    }
    NSString * device_steps = [CommonAPI getLocalValeuForKey:DEVICECONF_STEPS];
    if(device_steps){
        [self sendCMDCount:device_steps];
    }
}
- (IBAction)onResetTouchDown:(id)sender {
    longTouchTimerTime = 0;
    longTouchEnd = NO;
    [self performSelector:@selector(longPressTimerEvent) withObject:nil afterDelay:1];
}
- (IBAction)onReset:(id)sender {
    longTouchEnd = YES;
}
- (IBAction)onGoal:(id)sender {
}
- (IBAction)onSprint:(id)sender {
    [self sendCMDSpeed:4];
}
- (IBAction)onRun:(id)sender {
    [self sendCMDSpeed:3];
}
- (IBAction)onJog:(id)sender {
    [self sendCMDSpeed:2];
}
- (IBAction)onwalk:(id)sender {
    [self sendCMDSpeed:1];
}


- (void) sendCMDMoto:(int)value
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 5;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"motor=%d#",value] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDNotifySet
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_NOTIFY;
//    scanCommand.cmd_id = 100;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDSpeed:(int)value
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 6;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"speed=%d#",value] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDTarget:(int)value
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 7;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"target=%d#",value] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDDate
{
//    CFAbsoluteTime cfTime =  CFAbsoluteTimeGetCurrent();
//    CFDateRef cfDate = CFDateCreate(kCFAllocatorDefault, cfTime);
//    CFDateFormatterRef dateFormatter = CFDateFormatterCreate(kCFAllocatorDefault, CFLocaleCopyCurrent(), kCFDateFormatterFullStyle, kCFDateFormatterFullStyle);
//    CFStringRef newString = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, dateFormatter, cfDate);
//    CFRelease(dateFormatter);
//    CFRelease(cfDate);
//    
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 8;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"date=%@#",(__bridge NSString*)newString] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDReset
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 9;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:@"reset=0#" forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDSync
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 10;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:@"sync=0#" forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendCMDCount:(NSString*)count
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 11;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"count=%@#",count] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}
- (void) sendNameSync:(NSString*)name
{
//    SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//    BLECMD * scanCommand = [BLECMD new];
//    scanCommand.cmdStr = CMDSTR_WRITEDATA;
//    scanCommand.cmd_id = 11;
//    scanCommand.cmd_waitTime = 40;
//    NSMutableDictionary * dict = [NSMutableDictionary new];
//    [dict setObject:m_deviceUDID forKey:@"peripheral-identifier-UUIDString"];
//    [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//    [dict setObject:[NSString stringWithFormat:@"name=%@#",name] forKey:@"peripheral-write"];
//    scanCommand.cmdData = dict;
//    [m_mainview sendCMDObject:scanCommand];
}

- (void) parseString:(NSString*)str
{
    if(!state_item)
        state_item  = [BLERESPONSE_State new];
    NSArray * subSpliteArray = [str componentsSeparatedByString:@"="];
    NSString * value = @"";
    if(subSpliteArray.count > 1){
        value = [subSpliteArray objectAtIndex:1];
    }
    if(value && value.length > 0){
        if([[subSpliteArray objectAtIndex:0] isEqualToString:@"t"]){
            state_item.time = value.intValue;
//            if(state_item.time > 0){
                [self.lbl_times setText:[CommonAPI convertSecondToTime:(state_item.time / 1000)]];
//            }
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"r"]){
            state_item.reset = value.intValue;
            if(state_item.reset == 0){
                [self.btn_reset setSelected:YES];
//                [CommonAPI resetTodayCountATime];
//                currtnt_time = 0;
//                current_count = 0;
                [self updateState];
            }
            else {[self.btn_reset setSelected:NO];}
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"s"]){
            state_item.speed = value.intValue;
            if(state_item.speed == 1) {
                [self.btn_walk setSelected:YES];[self.btn_jog setSelected:NO];[self.btn_run setSelected:NO];[self.btn_sprint setSelected:NO];
            }else if(state_item.speed == 2){
                [self.btn_walk setSelected:NO];[self.btn_jog setSelected:YES];[self.btn_run setSelected:NO];[self.btn_sprint setSelected:NO];
            }else if(state_item.speed == 3){
                [self.btn_walk setSelected:NO];[self.btn_jog setSelected:NO];[self.btn_run setSelected:YES];[self.btn_sprint setSelected:NO];
            }else if(state_item.speed == 4){
                [self.btn_walk setSelected:NO];[self.btn_jog setSelected:NO];[self.btn_run setSelected:NO];[self.btn_sprint setSelected:YES];
            }
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"d"]){
            state_item.duration = value.intValue;
            if(state_item.duration == 0){
                [self sendCMDDate];
            }else{
                currtnt_time = state_item.duration;
                [CommonAPI setTodayTimeACount:currtnt_time];
                [self updateState];
            }
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"p"]){
            state_item.steps = value.intValue;
            current_count = state_item.steps;
            [CommonAPI setTodayCountATime:current_count];
            [self updateState];
            
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"c"]){
            state_item.count = value.intValue;
            if(state_item.count > 0){
                int setupCount = [[CommonAPI getLocalValeuForKey:DEVICECONF_STEPS] intValue];
                if(setupCount == state_item.count){
//                    [CommonAPI resetTodayCountATime];
//                    currtnt_time = 0;
//                    current_count = 0;
                    [self updateState];
                }
            }
            [self.lbl_steps setText:[NSString stringWithFormat:@"%d",state_item.count]];
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"m"]){
            state_item.motor = value.intValue;
            if(state_item.motor == 1){[self.btn_move setSelected:YES];[self.btn_stop setSelected:NO];}
            else if(state_item.motor == 0){[self.btn_move setSelected:NO];[self.btn_stop setSelected:YES];}
            
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"a"]){
            state_item.avgspeed = value.intValue;
            
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"u"]){
            state_item.powerUp = value.intValue;
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"xt"]){
            int m_value = value.intValue;
            if(m_value == 0){
                [self.lbl_timeRemain setText:@"Time"];
            }else{
                //                    [self.lbl_timeRemain setText:@"Time Remaining"];
            }
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"xs"]){
            int m_value = value.intValue;
            if(m_value == 0){
                [self.lbl_stepsRemain setText:@"Steps"];
            }else{
                [self.lbl_stepsRemain setText:@"Steps Left"];
            }
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"xa"]){
            if(![value isEqualToString:@" "])
                [self.lbl_alert setHidden:NO];
            else
                [self.lbl_alert setHidden:YES];
            [self.lbl_alert setText:value];
        }else if([[subSpliteArray objectAtIndex:0] isEqualToString:@"x"]){
            [self.lbl_alert setText:value];
        }
    }
}
- (void)BluetoothDeviceResult:(BLERESP*)response
{
    if([response.function isEqualToString:@"didUpdateValueForCharacteristic"]){
        if(!response.message)
            return;
        m_stateResponse = [m_stateResponse stringByAppendingString:response.message];
     
        NSMutableArray * spliteArray = [[NSMutableArray alloc] initWithArray:[m_stateResponse componentsSeparatedByString:@"#"]];
        NSString * lastString = [spliteArray lastObject];
        for(int i=0;i<[spliteArray count]-1;i++){
            NSString * subString = [spliteArray objectAtIndex:i];
            [self parseString:subString];
        }
        m_stateResponse = @"";
        if(lastString && ![lastString isEqualToString:@""]){
            m_stateResponse = lastString;
        }
    }else if([response.function isEqualToString:@"didDisconnectPeripheral"]){
//        SplashViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
//        BLECMD * scanCommand = [BLECMD new];
//        scanCommand.cmdStr = CMDSTR_CONNECTDEVICE;
//        scanCommand.cmd_id = 10;
//        scanCommand.cmd_waitTime = 10;
//        NSMutableDictionary * dict = [NSMutableDictionary new];
//        NSString * uuidString = [CommonAPI getLocalValeuForKey:USERKEY_DEVICE_UUID];
//        [dict setObject:uuidString forKey:@"peripheral-identifier-UUIDString"];
//        [dict setObject:deviceName forKey:@"peripheral-identifier-Name"];
//        scanCommand.cmdData = dict;
//        [m_mainview sendCMDObject:scanCommand];
        
        AppDelegate * appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate showLoader];
        
        sendSyncADisconnect = FALSE;
        
    }else if([response.function isEqualToString:@"didConnectPeripheral"]){
         if(response.messageType == 0)/// return connect error
         {
             [[[UIAlertView alloc] initWithTitle:nil message:@"Device connect fail." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
         }else{
             if(!sendSyncADisconnect){
                 [self sendCMDNotifySet];
                 [self sendCMDSync];
                 sendSyncADisconnect = YES;
             }
         }
    }

}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
    }
}
@end
