//
//  ShareViewController.m
//  RFIDRacing
//
//  Created by user1 on 2/24/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "ShareViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "BLECMD.h"
#import "BLEManager.h"
#import "LogicViewController.h"
#import "DeviceMemory.h"
#import "AppDelegate.h"
#import "BLECommand.h"
#import "CommonAPI.h"

@interface ShareViewController ()<UIActionSheetDelegate,UITextFieldDelegate,BluetoothDeviceResultDelegate>
{
    int sharedType;
    
    int edting_index;
    
    NSString * responseData;
    
    NSString * fileName;
    
    
    NSMutableArray * dataArray;
    
    int packageNumber;
    NSString * m_packageData;
    
}
@property (weak, nonatomic) IBOutlet UITextField *edt_shareType;
@property (weak, nonatomic) IBOutlet UITextField *edt_from;
@property (weak, nonatomic) IBOutlet UITextField *edt_to;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPicker;
@property (weak, nonatomic) IBOutlet UIView *view_container;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    sharedType = 0;
    edting_index = 0;
    m_packageData = [NSString new];
    responseData = @"";
    dataArray = [NSMutableArray new];
    packageNumber = 0;
    
    [self.view_container setHidden:YES];
    
    [[DeviceMemory createInstance] setBluetoothDeviceResultReceiver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didPressLink
{
    if(![[DBSession sharedSession] isLinked]){
        [[DBSession sharedSession] linkFromController:self];
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onShare:(id)sender {
    NSDateFormatter * defaultFormatter = [NSDateFormatter new];
    [defaultFormatter setDateFormat:@"MMM dd yyyy hh:mm aa"];
    NSDate * startDate = nil;
    NSDate * edDate = nil;
    if(sharedType == 1){
        if(self.edt_from.text.length > 0)
            startDate = [defaultFormatter dateFromString:self.edt_from.text];
        if(self.edt_to.text.length > 0)
            edDate = [defaultFormatter dateFromString:self.edt_to.text];
    }
    NSMutableData * cmdData = [NSMutableData new];
    int commadHead = 0x38;
    [cmdData appendBytes:&commadHead length:1];
    commadHead = 0x30;
    [cmdData appendBytes:&commadHead length:1];
    commadHead = 0x30;
    [cmdData appendBytes:&commadHead length:1];
    fileName = @"report";
    if(startDate){
        NSDate * Date1980 = [self get1980Date];
        NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:Date1980];
        [cmdData appendBytes:&timeInterval length:sizeof(timeInterval)];
        fileName = [fileName stringByAppendingFormat:@"_from_%@",self.edt_from.text];
    }else{
        int commandCode = 0x30;
        [cmdData appendBytes:&commandCode length:1];
    }
    char commandLine = 0x0d;
    [cmdData appendBytes:&commandLine length:1];
    if(edDate){
        NSDate * Date1980 = [self get1980Date];
        NSTimeInterval timeInterval = [edDate timeIntervalSinceDate:Date1980];
        [cmdData appendBytes:&timeInterval length:sizeof(timeInterval)];
        fileName = [fileName stringByAppendingFormat:@"_to_%@",self.edt_to.text];
    }else{
        int commandCode = 0x30;
        [cmdData appendBytes:&commandCode length:1];
    }
    char endn = '\n';
    [cmdData appendBytes:&endn length:sizeof(endn)];
    [self sendCMD:(char*)[cmdData bytes] :cmdData.length];
    fileName = [fileName stringByAppendingFormat:@"%@",@".txt"];
    [[DeviceMemory createInstance] setShared_fileName:fileName];
}
- (void)writeToFile:(NSString*)date
{
    NSString * localDit = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString * localPath = [localDit stringByAppendingPathComponent:fileName];
    [date writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
- (NSDate*)get1980Date
{
    NSString * string = @"01/01/1980 00:00:00";
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    return [formatter dateFromString:string];
}
- (NSString*)dateStringFromInterval:(long)interval
{
    NSDate * date1980 = [self get1980Date];
    double timeInterval = (double)interval;
    NSDate * currentDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:date1980];
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    return [formatter stringFromDate:currentDate];
}
- (IBAction)onSelectType:(id)sender {
    UIActionSheet * gatingAction = [[UIActionSheet alloc] initWithTitle:@"Select Share dates" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Share All Data" otherButtonTitles:@"Select Date", nil];
    [gatingAction showInView:self.view];
}
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)//share all
    {
        [self.edt_shareType setText:@"Share All Data"];
        [self.view_container setHidden:YES];
        sharedType = 0;
    }else if(buttonIndex == 1)
    {
        [self.edt_shareType setText:@"Select Date"];
        [self.view_container setHidden:NO];
        NSDateFormatter * defaultFormatter = [NSDateFormatter new];
        [defaultFormatter setDateFormat:@"MMM dd yyyy hh:mm aa"];
        NSString * dateString = [defaultFormatter stringFromDate:self.dataPicker.date];
        [self.edt_from setText:dateString];
        [self.edt_from setTextColor:[UIColor greenColor]];
        sharedType = 1;
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.edt_from){
        edting_index = 0;
        [self.edt_from setTextColor:[UIColor greenColor]];
        [self.edt_to setTextColor:[UIColor blackColor]];
    }else if(textField == self.edt_to){
        [self.edt_from setTextColor:[UIColor blackColor]];
        [self.edt_to setTextColor:[UIColor greenColor]];
        edting_index = 1;
    }
    return NO;
}
- (IBAction)onDateChanged:(id)sender {
    NSDateFormatter * defaultFormatter = [NSDateFormatter new];
    [defaultFormatter setDateFormat:@"MMM dd yyyy hh:mm aa"];
    NSString * dateString = [defaultFormatter stringFromDate:self.dataPicker.date];
    if(edting_index == 0){
        [self.edt_from setText:dateString];
    }else{
        [self.edt_to setText:dateString];
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
- (void)BluetoothDeviceResult:(BLERESP*)response
{
    if([response.function isEqualToString:@"didUpdateValueForCharacteristic"]){
        if(!response.message)
            return;
        NSString * value = response.message;
        if(value){
            responseData = [responseData stringByAppendingString:value];
            BOOL containsEnd = NO;
            for(int i=0;i<responseData.length;i+=2){
                NSString * subString = [[responseData substringFromIndex:i] substringToIndex:2];
                if([subString isEqualToString:@"0a"]){
                    containsEnd = YES;
                }
            }
            if(containsEnd){
                
                NSString * string = [responseData stringByReplacingOccurrencesOfString:@"55" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0d" withString:@""];
                string = [string stringByReplacingOccurrencesOfString:@"0a" withString:@""];
                
                packageNumber ++;
                
                NSData * cmdResponseData = [CommonAPI convertStringToHexData:string];
                NSString * convertedString = [[NSString alloc] initWithData:cmdResponseData encoding:NSUTF8StringEncoding];
                if(![convertedString containsString:@"0a"]){
                    m_packageData = @"";
                    responseData = @"";
                    packageNumber --;
                    return;
                }
                convertedString = [convertedString stringByReplacingOccurrencesOfString:@"0a" withString:@""];
                if(packageNumber == 2){
                    if(convertedString.length > 4){
                        convertedString = [convertedString substringFromIndex:4];
                    }else{
                        m_packageData = @"";
                        responseData  = @"";
                        packageNumber --;
                        return;
                    }
                }
                responseData = @"";
                m_packageData = [m_packageData stringByAppendingString:convertedString];
                if(packageNumber == 2){///
                    [self parseDataFromData:m_packageData];
                    packageNumber = 0;
                    m_packageData = [NSString new];
                }
            }
        }
    }else if([response.function isEqualToString:@"didDisconnectPeripheral"]){
    }else if([response.function isEqualToString:@"didConnectPeripheral"]){
    }
    
}
- (void)parseDataFromData:(NSString*)data
{
    
    if(data.length >= 24){
        NSString * idValue = [[NSString alloc] initWithFormat:@"0x%@",[data substringWithRange:NSMakeRange(0, 4)]];
        NSString * chipValue = [[NSString alloc] initWithFormat:@"0x%@",[data substringWithRange:NSMakeRange(4, 8)]];
        NSString * timeValue = [[NSString alloc] initWithFormat:@"0x%@",[data substringWithRange:NSMakeRange(12, 8)]];
        NSString * milisecond = [[NSString alloc] initWithFormat:@"0x%@",[data substringWithRange:NSMakeRange(20, 4)]];
        long short_id =0, short_milisecond = 0;
        long  long_chip = 0, long_time = 0;
        short_id = [self getValueFromString:idValue];
        long_chip = [self getValueFromString:chipValue];
        long_time = [self getValueFromString:timeValue];
        short_milisecond = [self getValueFromString:milisecond];
        
        NSLog(@"id: %lu chip: %lu mili: %ld date:%@",short_id,long_chip,short_milisecond, [self dateStringFromInterval:long_time]);
        
    }
    
}

- (long)getValueFromString:(NSString*)str
{
    NSScanner * pScanner = [NSScanner scannerWithString:str];
    unsigned long long iValue = 0;
    [pScanner scanHexLongLong:&iValue];
    return (long)iValue;
}

@end
