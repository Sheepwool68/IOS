//
//  BLECMD.m
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import "BLECMD.h"

@implementation BLECMD
- (NSDictionary*) convertToDictionary
{
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:[NSNumber numberWithInt:self.cmd_id] forKey:@"cmd_id"];
    [dict setObject:[NSNumber numberWithInt:self.cmd_waitTime] forKey:@"cmd_waitTime"];
    [dict setObject:self.cmdStr forKey:@"cmdStr"];
    if(self.cmdData)
        [dict setObject:self.cmdData forKey:@"cmdData"];
    return dict;
}
+ (BLECMD*) convertFromDictionary:(NSDictionary*)dict
{
    BLECMD * command = [BLECMD new];
    command.cmd_id = [[dict objectForKey:@"cmd_id"] intValue];
    command.cmd_waitTime = [[dict objectForKey:@"cmd_waitTime"] intValue];
    command.cmdStr = [dict objectForKey:@"cmdStr"];
    command.cmdData = [dict objectForKey:@"cmdData"];
    return command;
}
@end

@implementation BLERESP
- (NSDictionary*) convertToDictionary
{
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:self.function forKey:@"function"];
    [dict setObject:self.message forKey:@"message"];
    [dict setObject:self.send forKey:@"send"];
    [dict setObject:[NSNumber numberWithInt:self.messageType] forKey:@"messageType"];
    return dict;
}
+ (BLERESP*) convertFromDictionary:(NSDictionary*)dict
{
    BLERESP * resp = [BLERESP new];
    resp.function = [dict objectForKey:@"function"];
    resp.message = [dict objectForKey:@"message"];
    resp.send = [dict objectForKey:@"send"];
    resp.messageType = [[dict objectForKey:@"messageType"] intValue];
    return resp;
}
@end
