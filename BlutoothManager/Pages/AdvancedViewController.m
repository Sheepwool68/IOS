//
//  AdvancedViewController.m
//  RFIDRacing
//
//  Created by user1 on 2/12/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "AdvancedViewController.h"
#import "LogicViewController.h"
#import "CommonAPI.h"
#import "DeviceMemory.h"
#import "AppDelegate.h"

@interface AdvancedViewController ()<UIActionSheetDelegate,BluetoothDeviceResultDelegate,UIAlertViewDelegate>
{
    int action_index;
    NSString * responseData;
    
    BOOL initialize;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_region;
@property (weak, nonatomic) IBOutlet UITextField *onPower;
@property (weak, nonatomic) IBOutlet UITextField *onLockout;

@end

@implementation AdvancedViewController
char advanced_commandIds[3] = {0x07,0x18,0x37};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    action_index = 0;
    responseData = @"";
    
    initialize = YES;
    
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    
    // Do any additional setup after loading the view.
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
    
    [self initializingUI];
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoader];
    
    NSTimer * checkerTimer = [NSTimer new];
    checkerTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(onCancel:) userInfo:nil repeats:NO];
    
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
- (void) initializingUI
{
    char intializeCommand1[3] = {'U',advanced_commandIds[action_index],'\n'};
    [self sendCMD:intializeCommand1 :3];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSelectRegion:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    alert.tag = 100;
    [alert show];
    
    
}
- (IBAction)onSelectPower:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Power" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Hi" otherButtonTitles:@"Lo", nil];
    gatingAction.tag = 2;
    [gatingAction showInView:self.view];
}
- (IBAction)onSelectLockout:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Button Lockout?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Off" otherButtonTitles:@"On", nil];
    gatingAction.tag = 3;
    [gatingAction showInView:self.view];
}
- (IBAction)onClearData:(id)sender {
   UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    alertView.tag = 2;
    [alertView show];
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2){
        if(buttonIndex == 1){
            char command[4];
            command[0] = 'u';
            command[1] = 0xC8;
            command[2] = 0xC8;
            command[3] = '\n';
            [self sendCMD:command :4];
        }
    }else if(alertView.tag == 100){
        NSString * password = [[alertView textFieldAtIndex:0] text];
        if([password isEqualToString:@"1234"]){
            UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Region" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"FCC" otherButtonTitles:@"AU",@"EU", nil];
            gatingAction.tag = 1;
            [gatingAction showInView:self.view];
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"Incorrect Password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)///region
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"FCC",@"AU",@"EU", nil];
        if(buttonIndex >= [array count])
            return;
        [self.edt_region setText:[array objectAtIndex:buttonIndex]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x07;
        command[2] = 48 + (int)buttonIndex + 1;
        command[3] = '\n';
        [self sendCMD:command :4];
        
    }else if(actionSheet.tag == 2)///power
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Hi",@"Lo", nil];
        if(buttonIndex >= [array count])
            return;
        [self.onPower setText:[array objectAtIndex:buttonIndex]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x18;
        command[2] = 48 + (int)buttonIndex + 1;
        command[3] = '\n';
        [self sendCMD:command :4];
        
    }else if(actionSheet.tag == 3)///Lockout
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Off",@"On", nil];
        if(buttonIndex >= [array count])
            return;
        [self.onLockout setText:[array objectAtIndex:buttonIndex]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x37;
        command[2] = 48 + (int)buttonIndex;
        command[3] = '\n';
        [self sendCMD:command :4];
    }

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
                    [self initializingUI];
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
                    if(string.length > 1){
                        int command = advanced_commandIds[action_index];
                        
                        NSString * commandId = [logString substringToIndex:2];
                        NSString * value = [logString substringFromIndex:2];
                        if(command < 16){
                            commandId = [logString substringToIndex:1];
                            value = [logString substringFromIndex:1];
                        }
                        NSLog(@"Command %@ value %@",commandId, value);
                        [self parseCommand:commandId :value];
                    }
                    action_index ++;
                    if(action_index < sizeof(advanced_commandIds)){
                        [self initializingUI];
                    }else{
                        initialize = NO;
                        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                        [appDelegate hideLoader];
                    }
                }
            }
            if(containsu && containsEnd){
                NSString * string = [responseData stringByReplacingOccurrencesOfString:@"75" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0d" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0a" withString:@""];
                NSData * cmdResponseData = [CommonAPI convertStringToHexData:string];
                NSString * logString = [[NSString alloc] initWithData:cmdResponseData encoding:NSASCIIStringEncoding];
                responseData = @"";
                if(initialize){
                    if(string.length > 2){
                        NSString * commandId = [logString substringToIndex:2];
                        NSString * value = [logString substringFromIndex:2];
                        NSLog(@"Command %@ value %@",commandId, value);
                        //                        [self parseCommand:commandId :value];
                    }
                }
            }
        }
    }else if([response.function isEqualToString:@"didDisconnectPeripheral"]){
    }else if([response.function isEqualToString:@"didConnectPeripheral"]){
    }
    
}
- (void) parseCommand:(NSString*) commandId :(NSString*)value
{
    if([commandId isEqualToString:@"7"]){
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"FCC",@"AU",@"EU", nil];
        [self.edt_region setText:[array objectAtIndex:[value intValue]-1]];
    }else if([commandId isEqualToString:@"18"]){
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Hi",@"Lo", nil];
        [self.onPower setText:[array objectAtIndex:[value intValue]-1]];
        
    }else if([commandId isEqualToString:@"37"]){
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Off",@"On", nil];
        [self.onLockout setText:[array objectAtIndex:[value intValue]]];
    }
}
@end
