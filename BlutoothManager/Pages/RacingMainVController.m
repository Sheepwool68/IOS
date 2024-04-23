//
//  RacingMainVController.m
//  RFIDRacing
//
//  Created by user1 on 2/10/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "RacingMainVController.h"
#import "BLECMD.h"
#import "BLEManager.h"
#import "LogicViewController.h"
#import "DeviceMemory.h"
#import "AppDelegate.h"
#import "BLECommand.h"
#import "CommonAPI.h"
#import "SetTimeViewController.h"
#import "RemoteViewController.h"
#import "AdvancedViewController.h"
#import "UIIPAddresstextfield.h"
#import "ShareViewController.h"

@interface RacingMainVController ()<BluetoothDeviceResultDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIIPAddresstextfieldDelegate>
{
    int current_timezone;
    
    int action_height;
    
    int action_index;
    NSString * responseData;
    
    BOOL initialize;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl_battery;
@property (weak, nonatomic) IBOutlet UILabel *lbl_3G;
@property (weak, nonatomic) IBOutlet UILabel *lbl_gps;
@property (weak, nonatomic) IBOutlet UITextField *edt_dynamic;
@property (weak, nonatomic) IBOutlet UITextField *edt_gating;
@property (weak, nonatomic) IBOutlet UIButton *btn_ant1;
@property (weak, nonatomic) IBOutlet UIButton *btn_ant2;
@property (weak, nonatomic) IBOutlet UIButton *btn_ant3;
@property (weak, nonatomic) IBOutlet UIButton *btn_ant4;
@property (weak, nonatomic) IBOutlet UITextField *edt_id;
@property (weak, nonatomic) IBOutlet UISlider *slde_timezone;
@property (weak, nonatomic) IBOutlet UITextField *edt_logfile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timezone;
@property (weak, nonatomic) IBOutlet UITextField *edt_beep;
@property (weak, nonatomic) IBOutlet UITextField *edt_chip;
@property (retain, nonatomic) IBOutlet UIView *edt_static_view;
@property (retain, nonatomic) IBOutlet UIIPAddresstextfield *edt_static;

@end

@implementation RacingMainVController

char commandIds[12] = {0x33,0x34,0x35,0x36,0x2C,0x1E,0x0c,0x21,0x25,0x23,0x09,0x1C};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
    
    action_index = 0;
    responseData = @"";
    
    initialize = YES;
    
    
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done_id_Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onIDKeyboardHide)];
    UIBarButtonItem * done_file_Button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onFileKeyboardHide)];
    
    UIToolbar * idtoolbar = [[UIToolbar alloc] init];
    [idtoolbar setBarStyle:UIBarStyleBlackTranslucent];
    [idtoolbar sizeToFit];
    NSArray * itemsidArray = [NSArray arrayWithObjects:flexButton,done_id_Button, nil];
    [idtoolbar setItems:itemsidArray];
    [self.edt_id setInputAccessoryView:idtoolbar];
    
    UIToolbar * filetoolbar = [[UIToolbar alloc] init];
    [filetoolbar setBarStyle:UIBarStyleBlackTranslucent];
    [filetoolbar sizeToFit];

    NSArray * itemsfileArray = [NSArray arrayWithObjects:flexButton,done_file_Button, nil];
    [filetoolbar setItems:itemsfileArray];
    [self.edt_logfile setInputAccessoryView:filetoolbar];
    
    self.edt_static = [[UIIPAddresstextfield alloc] init];
    [self.edt_static setFrame:self.edt_static_view.bounds];
    [self.edt_static initializeView];
    [self.edt_static_view addSubview:self.edt_static];
    self.edt_static.ipDelegate = self;
    
//    self.device_udid = @"";
//    self.device_name = @"";
//
//    
    // Do any additional setup after loading the view.
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_CONNECTDEVICE;
    scanCommand.cmd_id = 10;
    scanCommand.cmd_waitTime = 10;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.device_udid forKey:@"peripheral-identifier-UUIDString"];
    [dict setObject:self.device_name forKey:@"peripheral-identifier-Name"];
    scanCommand.cmdData = dict;
    [m_mainview sendCMDObject:scanCommand];
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoader];
    
    NSTimer * checkerTimer = [NSTimer new];
    checkerTimer = [NSTimer scheduledTimerWithTimeInterval:200.0 target:self selector:@selector(onCancel:) userInfo:nil repeats:NO];
}
- (void) onCancel:(id)sender
{
    if(initialize){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Timeout to connect device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [self onBack:nil];
        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate hideLoader];
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
}
-(void)UIIPAddresstextfieldDidBeginEditing:(id)sender
{
    CGRect inViewRect = [self.view convertRect:self.edt_static.frame fromView:self.edt_static.superview];
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
        [self.edt_static resignFirstResponder];
        action_height = 0;
        
        if([self.edt_static getText].length > 0){
            NSArray * splitArray = [[self.edt_static getText] componentsSeparatedByString:@"."];
            if(splitArray.count == 4){
                char command[7];
                command[0] = 'u';
                command[1] = 0x2C;
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
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert valide IP address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (void)onIDKeyboardHide
{
    [UIView animateWithDuration:0.1 animations:^(void){
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished){
        [self.edt_id resignFirstResponder];
        action_height = 0;
        if(self.edt_id.text.length > 0){
            int idValue = [self.edt_id.text intValue];
            char command[4];
            command[0] = 'u';
            command[1] = 0x25;
            command[2] = idValue;
            command[3] = '\n';
            [self sendCMD:command :4];
            
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert ID value." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        
    }];

}
- (void)onFileKeyboardHide
{
    [UIView animateWithDuration:0.1 animations:^(void){
        [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished){
        [self.edt_logfile resignFirstResponder];
        action_height = 0;
        
        if(self.edt_logfile.text.length > 0){
            int idValue = [self.edt_logfile.text intValue];
            char command[4];
            command[0] = 'u';
            command[1] = 0x1C;
            command[2] = idValue;
            command[3] = '\n';
            [self sendCMD:command :4];
            
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please insert Log file size." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }

    }];

}


- (void) initializingUI
{
    char intializeCommand1[3] = {'U',commandIds[action_index],0x01};
    [self sendCMD:intializeCommand1 :3];
}

- (IBAction)onSelectGating:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Gating(sec)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"1" otherButtonTitles:@"2",@"3",@"4",@"5", nil];
    gatingAction.tag = 1;
    [gatingAction showInView:self.view];
}
- (IBAction)onSelectBeep:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Beep Volume" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"High" otherButtonTitles:@"Low",@"Off", nil];
    gatingAction.tag = 2;
    [gatingAction showInView:self.view];
}
- (IBAction)onSelectChip:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Chip Output Type." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Dec" otherButtonTitles:@"Hex", nil];
    gatingAction.tag = 3;
    [gatingAction showInView:self.view];
}
- (IBAction)onSelectAnt1:(id)sender {
//    [self.btn_ant1 setSelected:!self.btn_ant1.selected];
//    
//    int selected = self.btn_ant1.isSelected;
//    char command[5];
//    command[0] = 'u';
//    command[1] = 0x0C;
//    command[2] = 1;
//    command[3] = 48 + selected;
//    command[4] = '\n';
//    [self sendCMD:command :5];
}
- (IBAction)onSelectAnt2:(id)sender {
    [self.btn_ant2 setSelected:!self.btn_ant2.selected];
    char command[7];
    command[0] = 'u';
    command[1] = 0x0C;
    command[2] = 0x01;
    command[3] = self.btn_ant2.isSelected;
    command[4] = self.btn_ant3.isSelected;
    command[5] = self.btn_ant4.isSelected;
    command[6] = '\n';
    [self sendCMD:command :7];
}
- (IBAction)onSelectAnt3:(id)sender {
    [self.btn_ant3 setSelected:!self.btn_ant3.selected];
    
    char command[7];
    command[0] = 'u';
    command[1] = 0x0C;
    command[2] = 0x01;
    command[3] = self.btn_ant2.isSelected;
    command[4] = self.btn_ant3.isSelected;
    command[5] = self.btn_ant4.isSelected;
    command[6] = '\n';
    [self sendCMD:command :7];
}
- (IBAction)onSelectAnt4:(id)sender {
    [self.btn_ant4 setSelected:!self.btn_ant4.selected];
    
    char command[7];
    command[0] = 'u';
    command[1] = 0x0C;
    command[2] = 0x01;
    command[3] = self.btn_ant2.isSelected;
    command[4] = self.btn_ant3.isSelected;
    command[5] = self.btn_ant4.isSelected;
    command[6] = '\n';
    [self sendCMD:command :7];
}
- (IBAction)onSliding:(id)sender {
    int UITime = [self.slde_timezone value] - 12;
    [self.lbl_timezone setText:[NSString stringWithFormat:@"%d",UITime]];
}
- (IBAction)onSlideValueChange:(id)sender {
    int UITime = [self.slde_timezone value] - 12;
    if(current_timezone != UITime){
        current_timezone = UITime;
        [self.lbl_timezone setText:[NSString stringWithFormat:@"%d",UITime]];
        
        int timeValue = UITime;
        char command[4];
        command[0] = 'u';
        command[1] = 0x23;
        command[2] = 48 + timeValue;
        command[3] = '\n';
        [self sendCMD:command :4];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
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
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1)///gating
    {
        if(buttonIndex >= 5)
            return;
        [self.edt_gating setText:[NSString stringWithFormat:@"%d",(int)buttonIndex + 1]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x1E;
        command[2] = 48 + (int)buttonIndex + 1;
        command[3] = '\n';
        [self sendCMD:command :4];
        
    }else if(actionSheet.tag == 2)// beep volume
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"High",@"Low",@"Off", nil];
        if(buttonIndex >= [array count])
            return;
        [self.edt_beep setText:[array objectAtIndex:buttonIndex]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x21;
        command[2] = 48 + 2 - (int)buttonIndex;
        command[3] = '\n';
        [self sendCMD:command :4];
        
    }else if(actionSheet.tag == 3)// chip output
    {
        NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:@"Dec",@"Hex", nil];
        if(buttonIndex >= [array count])
            return;
        [self.edt_chip setText:[array objectAtIndex:buttonIndex]];
        
        char command[4];
        command[0] = 'u';
        command[1] = 0x09;
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
    if(action_height > 0){
        [UIView animateWithDuration:0.1 animations:^(void){
            [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        } completion:^(BOOL finished){
            action_height = 0;
            
            if(textField == self.edt_dynamic){
                
            }
            
        }];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void) sendCMD:(char*)cmdData :(int)length
{
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_WRITEDATA;
    scanCommand.cmd_id = 8;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    NSString * cmd = [CommonAPI convertDataToHexString:[NSData dataWithBytes:cmdData length:length]];
    NSLog(@"Send Command : %@",cmd);
    [dict setObject:self.device_udid forKey:@"peripheral-identifier-UUIDString"];
    [dict setObject:self.device_name forKey:@"peripheral-identifier-Name"];
    
    [dict setObject:cmd forKey:@"peripheral-write"];
    scanCommand.cmdData = dict;
    [m_mainview sendCMDObject:scanCommand];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"showSetTime"]){
        SetTimeViewController * controller = (SetTimeViewController*)segue.destinationViewController;
        controller.device_name = self.device_name;
        controller.device_udid = self.device_udid;
    }else if([segue.identifier isEqualToString:@"gotoRemote"]){
        RemoteViewController * controller = (RemoteViewController*)segue.destinationViewController;
        controller.device_name = self.device_name;
        controller.device_udid = self.device_udid;
    }else if([segue.identifier isEqualToString:@"gotoAdvance"]){
        AdvancedViewController * controller = (AdvancedViewController*)segue.destinationViewController;
        controller.device_name = self.device_name;
        controller.device_udid = self.device_udid;
    }else if([segue.identifier isEqualToString:@"showShared"]){
        ShareViewController *controller = (ShareViewController*)segue.destinationViewController;
        controller.device_name = self.device_name;
        controller.device_udid = self.device_udid;
    }
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
                    if(string.length > 2){
                        NSString * commandId = [logString substringToIndex:2];
                        NSString * value = [logString substringFromIndex:2];
                        NSLog(@"Command %@ value %@",commandId, value);
                        [self parseCommand:commandId :value];
                    }
                    
                    action_index ++;
                    if(action_index < sizeof(commandIds)){
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
        if(response.messageType == 0)/// return connect error
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Device connect fail." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }else{
            [self sendCMDNotifySet];
        }
    }else if([response.function isEqualToString:@"didUpdateNotificationStateForCharacteristic"]){
        initialize = YES;
//        [self initializingUI];
    }
    
}
- (void) parseCommand:(NSString*) commandId :(NSString*)value
{
    if([commandId isEqualToString:@"33"]){
        int ivalue = [value intValue];
        //ivalue = (ivalue - 147) * 100/(200-147);
        if(ivalue < 0) ivalue = 0;
        if(ivalue > 100) ivalue = 100;
        if(ivalue <= 20){
            [self.lbl_battery setTextColor:[UIColor redColor]];
        }else if(20<ivalue && ivalue <= 45){
            [self.lbl_battery setTextColor:[UIColor orangeColor]];
        }else{
            [self.lbl_battery setTextColor:[UIColor greenColor]];
        }
        [self.lbl_battery setText:[NSString stringWithFormat:@"%d %%",ivalue]];
    }else if([commandId isEqualToString:@"34"]){
        int ivalue = [value intValue];
        if(ivalue == 4){
            [self.lbl_3G setText:@"YES"];
        }else{
            [self.lbl_3G setText:@"NO"];
        }
    }else if([commandId isEqualToString:@"35"]){
        int ivalue = [value intValue];
        if(ivalue == 0){
            [self.lbl_gps setText:@"NO"];
        }else{
            [self.lbl_3G setText:@"YES"];
        }
    }else if([commandId isEqualToString:@"36"]){
        NSString * ipString = [CommonAPI getIPStyleStringFromHex:value];
        [self.edt_dynamic setText:ipString];
    }else if([commandId isEqualToString:@"2c"]){
        NSString * ipString = [CommonAPI getIPStyleStringFromHex:value];
        [self.edt_static setText:ipString];
    }else if([commandId isEqualToString:@"1e"]){
        [self.edt_gating setText:value];
    }else if([commandId isEqualToString:@"c0"]){
        NSString * at2 = [[value substringFromIndex:0] substringToIndex:1];
        NSString * at3 = [[value substringFromIndex:1] substringToIndex:1];
        NSString * at4 = [[value substringFromIndex:2] substringToIndex:1];
        [self.btn_ant1 setSelected:NO];
        [self.btn_ant2 setSelected:NO];
        [self.btn_ant3 setSelected:NO];
        [self.btn_ant4 setSelected:NO];
        if([at2 isEqualToString:@"1"]) [self.btn_ant2 setSelected:YES];
        if([at3 isEqualToString:@"1"]) [self.btn_ant3 setSelected:YES];
        if([at4 isEqualToString:@"1"]) [self.btn_ant4 setSelected:YES];
//        if(ivalue == )
    }else if([commandId isEqualToString:@"c1"]){
        NSString * at2 = [[value substringFromIndex:0] substringToIndex:1];
        NSString * at3 = [[value substringFromIndex:1] substringToIndex:1];
        NSString * at4 = [[value substringFromIndex:2] substringToIndex:1];
        [self.btn_ant1 setSelected:YES];
        [self.btn_ant2 setSelected:NO];
        [self.btn_ant3 setSelected:NO];
        [self.btn_ant4 setSelected:NO];
        if([at2 isEqualToString:@"1"]) [self.btn_ant2 setSelected:YES];
        if([at3 isEqualToString:@"1"]) [self.btn_ant3 setSelected:YES];
        if([at4 isEqualToString:@"1"]) [self.btn_ant4 setSelected:YES];
        //        if(ivalue == )
    }else if([commandId isEqualToString:@"21"]){
        int ivalue = [value intValue];
        if(ivalue == 2){[self.edt_beep setText:@"High"];}
        if(ivalue == 1){[self.edt_beep setText:@"Low"];}
        if(ivalue == 0){[self.edt_beep setText:@"Off"];}
    }else if([commandId isEqualToString:@"23"]){
        NSString * timeVal = [value substringToIndex:1];
        NSString * minVal = [value substringFromIndex:1];
        int ivalue = [timeVal intValue];
        int UITime = ivalue + 12;
        [self.slde_timezone setValue:UITime];
        if([minVal isEqualToString:@"0"])
            [self.lbl_timezone setText:[NSString stringWithFormat:@"%d",[timeVal intValue]]];
        else
            [self.lbl_timezone setText:[NSString stringWithFormat:@"%d:30",[timeVal intValue]]];
    }else if([commandId isEqualToString:@"25"]){
        [self.edt_id setText:value];
    }else if([commandId isEqualToString:@"90"]){
        [self.edt_chip setText:@"Dec"];
    }else if([commandId isEqualToString:@"91"]){
        [self.edt_chip setText:@"Hex"];
    }else if([commandId isEqualToString:@"1c"]){
        [self.edt_logfile setText:value];
    }
}
- (void) sendCMDNotifySet
{
    LogicViewController * m_mainview = ((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
    m_mainview.ble_delegate = self;
    BLECMD * scanCommand = [BLECMD new];
    scanCommand.cmdStr = CMDSTR_NOTIFY;
    scanCommand.cmd_id = 100;
    scanCommand.cmd_waitTime = 40;
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.device_udid forKey:@"peripheral-identifier-UUIDString"];
    [dict setObject:self.device_name forKey:@"peripheral-identifier-Name"];
    scanCommand.cmdData = dict;
    [m_mainview sendCMDObject:scanCommand];
}
@end
