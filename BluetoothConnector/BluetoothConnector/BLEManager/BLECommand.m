//
//  BLECommand.m
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import "BLECommand.h"
#import "CommonAPI.h"
#if REALEASMODE
#import "DeviceMemory.h"
#endif


@interface BLECommand () <BLEManagerDelegate>
{
    NSMutableArray * cmd_array;
    
    BOOL nowRunning;
    
    NSTimer * timer;
    
    
    WebService * webService;
}
@end

@implementation BLECommand
- (void) execCommand:(BLECMD*)cmd
{
    if(!webService){
        webService = [WebService new];
#if REALEASMODE
        webService.delegate = (id)((DeviceMemory*)[DeviceMemory createInstance])._mainViewController;
#endif
    }
    if(!cmd_array)
        cmd_array = [NSMutableArray new];
    [cmd_array addObject:cmd];
#if TESTMODE
    if(nowRunning)
        return;
#endif
    [self runCMD:cmd];
}

- (void) runCMD:(BLECMD*)cmd
{
    nowRunning = YES;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:cmd.cmd_waitTime target:self selector:@selector(endCMD) userInfo:nil repeats:NO];
//    [self performSelector:@selector(endCMD) withObject:nil afterDelay:cmd.cmd_waitTime];
    
    if([cmd.cmdStr isEqualToString:CMDSTR_SCANDEVICE]){
        [[BLEManager createInstanceWithReceiver:self] initialBLELib];
        nowRunning = NO;
    }else if([cmd.cmdStr isEqualToString:CMDSTR_STOPSCAN]){
        [[BLEManager createInstanceWithReceiver:self] stopScan];
    }else if([cmd.cmdStr isEqualToString:CMDSTR_CONNECTDEVICE]){
        NSDictionary * dayaDict = cmd.cmdData;
        NSString * uuid = [dayaDict objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * name = [dayaDict objectForKey:@"peripheral-identifier-Name"];
        [[BLEManager createInstanceWithReceiver:self] connectToDevice:uuid name:name];
    }else if([cmd.cmdStr isEqualToString:CMDSTR_DISCONNECTDEVICE]){
        NSDictionary * dayaDict = cmd.cmdData;
        NSString * uuid = [dayaDict objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * name = [dayaDict objectForKey:@"peripheral-identifier-Name"];
        [[BLEManager createInstanceWithReceiver:self] disconnectToDevice:uuid name:name];
        
    }else if([cmd.cmdStr isEqualToString:CMDSTR_READDATA]){
        NSDictionary * dayaDict = cmd.cmdData;
        NSString * uuid = [dayaDict objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * name = [dayaDict objectForKey:@"peripheral-identifier-Name"];
        [[BLEManager createInstanceWithReceiver:self] readDataFromConnection:uuid name:name];
    }else if([cmd.cmdStr isEqualToString:CMDSTR_WRITEDATA]){
        NSDictionary * dayaDict = cmd.cmdData;
        NSString * uuid = [dayaDict objectForKey:@"peripheral-identifier-UUIDString"];
        NSString * name = [dayaDict objectForKey:@"peripheral-identifier-Name"];
        NSString * writeVal = [dayaDict objectForKey:@"peripheral-write"];
        
        [[BLEManager createInstanceWithReceiver:self] writeDataToConnection:[self convertCMDStringToData:writeVal] :uuid name:name];
    }else if([cmd.cmdStr isEqualToString:CMDSTR_NOTIFY]){
        NSDictionary * dayaDict = cmd.cmdData;
        NSString * name = [dayaDict objectForKey:@"peripheral-identifier-Name"];
        NSString * uuid = [dayaDict objectForKey:@"peripheral-identifier-UUIDString"];
        [[BLEManager createInstanceWithReceiver:self] notifyDataFromConnection:uuid name:name];
        nowRunning = NO;
    }
}

- (NSData*) convertCMDStringToData:(NSString*)string
{
    return [CommonAPI convertStringToHexData:string];
}

- (void)BLEManagerDelegate_Message:(NSString*)functionName :(int)messageType :(NSString*)message :(BOOL)isComplete;
{
    if(isComplete)
        nowRunning = NO;
    //NSLog(@"function:%@ \n messageType:%d \n message:%@",functionName,messageType,message);
    if(!message)
        message = @"";
    NSDictionary * sendData = @{@"function":functionName,
                                @"messageType":[NSNumber numberWithInt:messageType],
                                @"message":message,
                                @"send":@"BLEManagerDelegate_Message"};
    [webService sendRespToSrc:sendData];
    
    if(isComplete){
        [timer invalidate];
        if(cmd_array.count > 0)
            [cmd_array removeObjectAtIndex:0];
        if([cmd_array count] > 0){
            
            [self runCMD:[cmd_array objectAtIndex:0]];
        }
    }
}
- (NSString *) getJsonString:(NSDictionary*)dict
{
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString * myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return myString;
}
- (void)BLEManagerDelegate_Dict:(NSString*)functionName :(int)messageType :(NSDictionary*)message :(BOOL)isComplete;
{
    nowRunning = !isComplete;
    //NSLog(@"function:%@ \n messageType:%d \n Data:%@",functionName,messageType,[CommonAPI createJsonFromDictionary:message]);
    NSDictionary * sendData = @{@"function":functionName,
                                @"messageType":[NSNumber numberWithInt:messageType],
                                @"message":message,
                                @"send":@"BLEManagerDelegate_Dict"};
    [webService sendRespToSrc:sendData];
    
    if(isComplete){
        [timer invalidate];
        if(cmd_array.count > 0)
            [cmd_array removeObjectAtIndex:0];
        if([cmd_array count] > 0){
            
            [self runCMD:[cmd_array objectAtIndex:0]];
        }
    }
}
- (void)endCMD{
    if(nowRunning){
        [timer invalidate];
        nowRunning = NO;
        //NSLog(@"%d command End",((BLECMD*)[cmd_array objectAtIndex:0]).cmd_id);
        NSDictionary * sendData = @{@"function":@"endCMD",
                                    @"messageType":[NSNumber numberWithInt:1],
                                    @"message":[NSString stringWithFormat:@"%d",((BLECMD*)[cmd_array objectAtIndex:0]).cmd_id],
                                    @"send":@"endCMD"};
        [webService sendRespToSrc:sendData];
        
        if(!nowRunning){
            
            if([((BLECMD*)[cmd_array firstObject]).cmdStr isEqualToString:CMDSTR_SCANDEVICE]){
                [[BLEManager createInstanceWithReceiver:self] stopScan];
            }
            if(cmd_array.count > 0)
                [cmd_array removeObjectAtIndex:0];
            if([cmd_array count] > 0){
                
                [self runCMD:[cmd_array objectAtIndex:0]];
            }
        }
    }
}
@end
