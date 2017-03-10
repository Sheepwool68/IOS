//
//  ViewController.m
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import "ViewController.h"
#import "BLECommand.h"
#import "WebService.h"
#import "CommonAPI.h"

@interface ViewController () <WebServiceDelegate>
{
    BLECommand * command;
    
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView setText:@""];
    // Do any additional setup after loading the view, typically from a nib.
    command = [BLECommand new];
    
    [self performSelector:@selector(receiveCMD) withObject:nil afterDelay:2];
//    [self performSelector:@selector(receiveRESP) withObject:nil afterDelay:2];
}
- (void) sendCMD:(BLECMD*)com{
    
    NSDictionary * cmdDict = [com convertToDictionary];
    WebService * service = [[WebService alloc] init];
    service.delegate = self;
    [service sendCMDToDest:cmdDict];
    
}
- (void) sendRESP:(BLERESP*)resp{
    
    NSDictionary * cmdDict = [resp convertToDictionary];
    WebService * service = [[WebService alloc] init];
    service.delegate = self;
    [service sendRespToSrc:cmdDict];
}
- (void) receiveCMD{
    WebService * service = [[WebService alloc] init];
    service.delegate = self;
    [service getCMDFromSrc];
    
    [self performSelector:@selector(receiveCMD) withObject:nil afterDelay:2];
}
- (void) receiveRESP{
    WebService * service = [[WebService alloc] init];
    service.delegate = self;
    [service getRespFromDest];
    
    [self performSelector:@selector(receiveRESP) withObject:nil afterDelay:2];
}
- (void)WebServiceDelegate_recieveCMD:(NSArray*)data
{
    for(NSString * cmd in data){
        NSDictionary * dict = [CommonAPI createDictFromJson:cmd];
        BLECMD * comStr = [BLECMD convertFromDictionary:dict];
        [command execCommand:comStr];
        [self setText:[NSString stringWithFormat:@"CMD:\n %@ %d\n",comStr.cmdStr,comStr.cmd_id]];
    }
}
- (void)WebServiceDelegate_recieveRSP:(NSArray*)data
{
    for(NSString * cmd in data){
        NSDictionary * dict = [CommonAPI createDictFromJson:cmd];
        BLERESP * respStr = [BLERESP convertFromDictionary:dict];
        [self setText:[NSString stringWithFormat:@"RESP:\n %@ %@ %@ %d\n",respStr.function,respStr.message, respStr.send, respStr.messageType]];
    }
}
- (void) setText:(NSString*)str
{
    [self.textView setText:[NSString stringWithFormat:@"%@%@",self.textView.text, str]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
