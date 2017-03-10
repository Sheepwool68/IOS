//
//  RemoteViewController.m
//  RFIDRacing
//
//  Created by user1 on 2/12/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "RemoteViewController.h"
#import "LogicViewController.h"
#import "CommonAPI.h"
#import "DeviceMemory.h"
#import "AppDelegate.h"
#import "UIIPAddresstextfield.h"

@interface RemoteViewController ()<UIActionSheetDelegate,UITextFieldDelegate,BluetoothDeviceResultDelegate,UIIPAddresstextfieldDelegate>
{
    int action_height;
    
    int action_index;
    NSString * responseData;
    
    BOOL initialize;
}
@property (weak, nonatomic) IBOutlet UITextField *edt_remote;
@property (weak, nonatomic) IBOutlet UITextField *edt_port;
@property (retain, nonatomic) IBOutlet UIIPAddresstextfield *edt_remoteServer;
@property (weak, nonatomic) IBOutlet UIView *edt_remoteServer_view;
@property (weak, nonatomic) IBOutlet UITextField *edt_apn;
@property (retain, nonatomic) IBOutlet UIIPAddresstextfield *edt_gateway;
@property (weak, nonatomic) IBOutlet UIView *edt_gateway_view;
@property (retain, nonatomic) IBOutlet UIIPAddresstextfield *edt_dnsserver;
@property (weak, nonatomic) IBOutlet UIView *edt_dnsserver_view;
@property (weak, nonatomic) IBOutlet UITextField *edt_rabbit;

@end

@implementation RemoteViewController

char remote_commandIds[7] = {0x01,0x03,0x02,0x04,0x2A,0x2B,0x39};

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    action_index = 0;
    responseData = @"";
    
    initialize = YES;
    
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    
    UIToolbar * porttoolbar = [[UIToolbar alloc] init];
    [porttoolbar setBarStyle:UIBarStyleBlackTranslucent];
    [porttoolbar sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done_port_Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onportKeyboardHide)];
    
    NSArray * itemsportArray = [NSArray arrayWithObjects:flexButton,done_port_Button, nil];
    [porttoolbar setItems:itemsportArray];
    [self.edt_port setInputAccessoryView:porttoolbar];
    
    
    self.edt_remoteServer = [[UIIPAddresstextfield alloc] init];
    [self.edt_remoteServer setFrame:self.edt_remoteServer_view.bounds];
    [self.edt_remoteServer initializeView];
    [self.edt_remoteServer_view addSubview:self.edt_remoteServer];
    self.edt_remoteServer.ipDelegate = self;
    
    self.edt_gateway = [[UIIPAddresstextfield alloc] init];
    [self.edt_gateway setFrame:self.edt_gateway_view.bounds];
    [self.edt_gateway initializeView];
    [self.edt_gateway_view addSubview:self.edt_gateway];
    self.edt_gateway.ipDelegate = self;
    
    self.edt_dnsserver = [[UIIPAddresstextfield alloc] init];
    [self.edt_dnsserver setFrame:self.edt_dnsserver_view.bounds];
    [self.edt_dnsserver initializeView];
    [self.edt_dnsserver_view addSubview:self.edt_dnsserver];
    self.edt_dnsserver.ipDelegate = self;
    
    
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
    
    [self initializingUI];
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoader];
    
    NSTimer * checkerTimer = [NSTimer new];
    checkerTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(onCancel:) userInfo:nil repeats:NO];
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
    char intializeCommand1[3] = {'U',remote_commandIds[action_index],'\n'};
    [self sendCMD:intializeCommand1 :3];
}


-(void)UIIPAddresstextfieldDidBeginEditing:(id)sender
{
    UIView * senderView = (UIView*)sender;
    CGRect inViewRect = [self.view convertRect:senderView.frame fromView:senderView.superview];
    if(self.view.frame.size.height - inViewRect.origin.y < 300){
        action_height = 300 - (self.view.frame.size.height - inViewRect.origin.y);
    }else{
        action_height = 0;
    }
    if(action_height > 0){
        [UIView animateWithDuration:0.1 animations:^(void){
            [self.view setFrame:CGRectMake(0, - action_height, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}
-(void)UIIPAddresstextfieldDidFinishEditing:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^(void){
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished){
        action_height = 0;
        if(sender == self.edt_remoteServer){
            NSArray * splitArray = [[self.edt_remoteServer getText] componentsSeparatedByString:@"."];
            if(splitArray.count == 4){
                char command[7];
                command[0] = 'u';
                command[1] = 0x02;
                int index = 2;
                for(NSString * subString in splitArray){
                    int value = [subString intValue];
                    command[index] = value;
                    index ++;
                }
                command[6] = '\n';
                [self sendCMD:command :7];
                return;
            }
        }else if(sender == self.edt_gateway){
            NSArray * splitArray = [[self.edt_gateway getText] componentsSeparatedByString:@"."];
            if(splitArray.count == 4){
                char command[7];
                command[0] = 'u';
                command[1] = 0x2A;
                int index = 2;
                for(NSString * subString in splitArray){
                    int value = [subString intValue];
                    command[index] = value;
                    index ++;
                }
                command[6] = '\n';
                [self sendCMD:command :7];
                return;
            }
        }else if(sender == self.edt_dnsserver){
            NSArray * splitArray = [[self.edt_dnsserver getText] componentsSeparatedByString:@"."];
            if(splitArray.count == 4){
                char command[7];
                command[0] = 'u';
                command[1] = 0x2B;
                int index = 2;
                for(NSString * subString in splitArray){
                    int value = [subString intValue];
                    command[index] = value;
                    index ++;
                }
                command[6] = '\n';
                [self sendCMD:command :7];
                return;
            }
        }
    }];
}
- (void)onportKeyboardHide
{
    [self resignKeyboards];
    [self.edt_port resignFirstResponder];
    [UIView animateWithDuration:0.1 animations:^(void){
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished){
        action_height = 0;
        
        if(self.edt_port.text.length > 0){
            int port = [self.edt_port.text intValue];
            char command[4];
            command[0] = 'u';
            command[1] = 0x03;
            command[2] = port;
            command[3] = '\n';
            [self sendCMD:command :4];
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert Port." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        [self.edt_port resignFirstResponder];
    }];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSelectRemote:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Remote Control Method" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Off" otherButtonTitles:@"3G",@"LAN", nil];
    gatingAction.tag = 1;
    [gatingAction showInView:self.view];
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)resignKeyboards
{
    [self.edt_remoteServer resignFirstResponder];
    [self.edt_port resignFirstResponder];
    [self.edt_apn resignFirstResponder];
    [self.edt_gateway resignFirstResponder];
    [self.edt_dnsserver resignFirstResponder];
    [self.edt_rabbit resignFirstResponder];
    [self.view resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)///remote
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Off",@"3G",@"LAN", nil];
        if(buttonIndex >= [array count])
            return;
        [self.edt_remote setText:[array objectAtIndex:buttonIndex]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x01;
        command[2] = 48 + (int)buttonIndex;
        command[3] = '\n';
        [self sendCMD:command :4];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect inViewRect = [self.view convertRect:textField.frame fromView:textField.superview];
    if(self.view.frame.size.height - inViewRect.origin.y < 300){
        action_height = 300 - (self.view.frame.size.height - inViewRect.origin.y);
    }else{
        action_height = 0;
    }
    if(action_height > 0){
        [UIView animateWithDuration:0.1 animations:^(void){
            [self.view setFrame:CGRectMake(0, - action_height, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignKeyboards];
    [UIView animateWithDuration:0.1 animations:^(void){
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished){
        action_height = 0;
        [textField resignFirstResponder];
        if(self.edt_apn == textField){
            if(self.edt_apn.text.length  == 0){
                [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert valide APN address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }else{
                NSMutableData * cmdData = [NSMutableData new];
                char commadHead = 'u';
                [cmdData appendBytes:&commadHead length:1];
                int commandCode = 0x04;
                [cmdData appendBytes:&commandCode length:1];
                [cmdData appendData:[self.edt_apn.text dataUsingEncoding:NSASCIIStringEncoding]];
                char endn = '\n';
                [cmdData appendBytes:&endn length:sizeof(endn)];
                
                [self sendCMD:(char*)[cmdData bytes] :cmdData.length];
            }
        }else if(self.edt_rabbit == textField){
            if(self.edt_rabbit.text.length  == 0){
                [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert valide MAC address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }else{
                NSArray * splitArray = [self.edt_rabbit.text componentsSeparatedByString:@":"];
                if(splitArray.count < 2){
                    [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert valide MAC address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }else{
                    NSMutableData * cmdData = [NSMutableData new];
                    int commandCode = 0x39;
                    [cmdData appendBytes:&commandCode length:1];
                    for(NSString * subString in splitArray){
                        NSData * sunData = [CommonAPI convertStringToHexData:subString];
                        [cmdData appendData:sunData];
                    }
                    char endn = '\n';
                    [cmdData appendBytes:&endn length:sizeof(endn)];
                    [self sendCMD:(char*)[cmdData bytes] :cmdData.length];
                    return;

                }
            }
        }
        
    }];
    [textField resignFirstResponder];
    return YES;
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
                        int command = remote_commandIds[action_index];
                        
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
                    if(action_index < sizeof(remote_commandIds)){
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
                        [self parseCommand:commandId :value];
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
    if([commandId isEqualToString:@"1"]){
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Off",@"3G",@"LAN", nil];
        [self.edt_remote setText:[array objectAtIndex:[value intValue]]];
    }else if([commandId isEqualToString:@"3"]){
        [self.edt_port setText:value];
    }else if([commandId isEqualToString:@"2"]){
        NSString * ipString = [CommonAPI getIPStyleStringFromHex:value];
        [self.edt_remoteServer setText:ipString];
    }else if([commandId isEqualToString:@"4"]){
        [self.edt_apn setText:value];
    }else if([commandId isEqualToString:@"2a"]){
        NSString * ipString = [CommonAPI getIPStyleStringFromHex:value];
        [self.edt_gateway setText:ipString];
    }else if([commandId isEqualToString:@"2b"]){
        NSString * ipString = [CommonAPI getIPStyleStringFromHex:value];
        [self.edt_dnsserver setText:ipString];
    }else if([commandId isEqualToString:@"39"]){
        NSString * ipString = [CommonAPI getMACStyleStringFromHex:value];
        [self.edt_rabbit setText:ipString];
    }
}
@end
