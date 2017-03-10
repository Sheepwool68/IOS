//
//  BLECMD.h
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CMDSTR_SCANDEVICE  @"scandevices"
#define CMDSTR_STOPSCAN   @"stopscan"
#define CMDSTR_CONNECTDEVICE    @"connectdevice"
#define CMDSTR_DISCONNECTDEVICE    @"disconnectdevice"
#define CMDSTR_READDATA    @"readdata"
#define CMDSTR_WRITEDATA    @"writedata"
#define CMDSTR_NOTIFY    @"notify"

@interface BLECMD : NSObject
@property (atomic) int cmd_id;
@property (atomic) int cmd_waitTime;
@property (nonatomic, retain) NSString * cmdStr;
@property (nonatomic, retain) NSDictionary * cmdData;

- (NSDictionary*) convertToDictionary;
+ (BLECMD*) convertFromDictionary:(NSDictionary*)dict;
@end

@interface BLERESP : NSObject
@property (nonatomic, retain) NSString * function;
@property (atomic) int messageType;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * send;

- (NSDictionary*) convertToDictionary;
+ (BLERESP*) convertFromDictionary:(NSDictionary*)dict;
@end
