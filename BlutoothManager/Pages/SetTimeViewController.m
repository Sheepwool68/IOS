//
//  SetTimeViewController.m
//  RFIDRacing
//
//  Created by user1 on 2/12/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "SetTimeViewController.h"
#import "LogicViewController.h"
#import "CommonAPI.h"
#import "DeviceMemory.h"
#import "AppDelegate.h"

@interface SetTimeViewController () <BluetoothDeviceResultDelegate>
{
    NSString * responseData;
    BOOL initialize;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_dateTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *datetimePicker;

@end

@implementation SetTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    responseData = @"";
    initialize = YES;
    
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    
    char command[2];
    command[0] = 0x72;
    command[1] = '\n';
    [self sendCMD:command :2];
    
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoader];
    
    NSTimer * checkerTimer = [NSTimer new];
    checkerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onCancel:) userInfo:nil repeats:NO];
    
}
- (void)onCancel:(id)sender
{
    if(initialize){
        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate hideLoader];
        LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
        m_mainview.ble_delegate = self;
        BLECMD * scanCommand = [BLECMD new];
        scanCommand.cmdStr = CMDSTR_DISCONNECTDEVICE;
        scanCommand.cmd_id = 2;
        scanCommand.cmd_waitTime = 40;
        NSMutableDictionary * dict = [NSMutableDictionary new];
        [dict setObject:self.device_udid forKey:@"peripheral-identifier-UUIDString"];
        [dict setObject:self.device_name forKey:@"peripheral-identifier-Name"];
        scanCommand.cmdData = dict;
        [m_mainview sendCMDObject:scanCommand];
        [[[UIAlertView alloc] initWithTitle:nil message:@"Timeout to connect device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        RacingScanVController * scanCtr = ((DeviceMemory*)[DeviceMemory createInstance])._scanViewController;
        [self.navigationController popToViewController:scanCtr animated:YES];
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSetTime:(id)sender {
    NSString * formatterStr = @"MMM dd yyyy hh:mm aa";
    NSDateFormatter * defaultFormatter = [NSDateFormatter new];
    [defaultFormatter setDateFormat:formatterStr];
    NSString * dateString = [defaultFormatter stringFromDate:self.datetimePicker.date];
    [self.edt_dateTime setText:dateString];
 
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * component = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.datetimePicker.date];
    
    char command[8];
    command[0] = 0x74;
    command[1] = component.hour;
    command[2] = component.minute;
    command[3] = component.second;
    command[4] = component.day;
    command[5] = component.month;
    command[6] = component.year - 1900;
    command[7] = '\n';
    [self sendCMD:command :8];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) sendCMD:(char*)cmdData :(int)length
{
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_WRITEDATA;
    scanCommand.cmd_id = 8;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    NSString * cmd = [CommonAPI convertDataToHexString:[NSData dataWithBytes:cmdData length:length]];
    [dict setObject:self.device_udid forKey:@"peripheral-identifier-UUIDString"];
    [dict setObject:self.device_name forKey:@"peripheral-identifier-Name"];
    NSLog(@"Send Command : %@",cmd);
    [dict setObject:cmd forKey:@"peripheral-write"];
    scanCommand.cmdData = dict;
    [m_mainview sendCMDObject:scanCommand];
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
}
- (void)BluetoothDeviceResult:(BLERESP*)response
{
    if([response.function isEqualToString:@"didUpdateValueForCharacteristic"]){
        if(!response.message)
            return;
        NSString * value = response.message;
        if(value){
            responseData = [responseData stringByAppendingString:value];
            if(responseData){
                NSData * data = [CommonAPI convertStringToHexData:responseData];
                if([[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] containsString:@"JOEY CONNECTED"]){
                    responseData = @"";
//                    [self initializingUI];
                    return;
                }
            }
            
            BOOL containsU = NO;
            BOOL containsEnd = NO;
            BOOL containsu = NO;
            for(int i=0;i<responseData.length;i+=2){
                NSString * subString = [[responseData substringFromIndex:i] substringToIndex:2];
                if([subString isEqualToString:@"55"]){
                    containsU = YES;
                }
                if([subString isEqualToString:@"75"]){
                    containsu = YES;
                }
                if([subString isEqualToString:@"0a"]){
                    containsEnd = YES;
                }
            }
            if(containsU && containsEnd){
                
                NSString * string = [responseData stringByReplacingOccurrencesOfString:@"55" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0d" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0a" withString:@""];
                
                NSData * cmdResponseData = [CommonAPI convertStringToHexData:string];
                NSString * logString = [[NSString alloc] initWithData:cmdResponseData encoding:NSASCIIStringEncoding];
                responseData = @"";
                if(initialize){
                    if(string.length > 2){
                        NSLog(@"Command time value %@",logString);
                        //                        [self parseCommand:commandId :value];
                        [self.edt_dateTime setText:logString];
                    }
                    
                    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    [appDelegate hideLoader];
                    initialize = NO;
                }
            }
            if(containsu && containsEnd){
                NSString * string = [responseData stringByReplacingOccurrencesOfString:@"75" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0d" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0a" withString:@""];
                NSData * cmdResponseData = [CommonAPI convertStringToHexData:string];
                NSString * logString = [[NSString alloc] initWithData:cmdResponseData encoding:NSASCIIStringEncoding];
                responseData = @"";
//                if(initialize){
                    if(string.length > 2){
                        NSLog(@"Command set time value %@",logString);
                        [self.edt_dateTime setText:logString];
//                        [self parseCommand:commandId :value];
                    }
//                }
            }
        }
    }else if([response.function isEqualToString:@"didDisconnectPeripheral"]){
    }else if([response.function isEqualToString:@"didConnectPeripheral"]){
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
