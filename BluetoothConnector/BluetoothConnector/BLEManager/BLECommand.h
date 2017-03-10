//
//  BLECommand.h
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLECMD.h"
#import "BLEManager.h"
#import "WebService.h"


#define CMD_BATTERY     0x33
#define CMD_3GAUTH      0x34
#define CMD_GPSSIGNAL   0x35
#define CMD_DYNAIP      0x36
#define CMD_STATICIP    0x1A
#define CMD_GATING      0x1E
#define CMD_ANTENA      0x0C
#define CMD_BEEP        0x21
#define CMD_ID          0x25
#define CMD_TIME        0x23
#define CMD_CHIP        0x09
#define CMD_LOG         0x1C
#define CMD_CURTIME     0x38
#define CMD_SETTIME     0x38
#define CMD_REMOTE      0x01
#define CMD_PORT        0x03
#define CMD_REMOTESIP   0x02
#define CMD_APN         0x04
#define CMD_GATEWAY     0x2A
#define CMD_DNSSERVER   0x2B
#define CMD_RABBITMAC   0x39
#define CMD_REGION      0x07
#define CMD_POWER       0x18
#define CMD_LOCKOUT     0x37


#define STR_CMD_BATTERY     1
#define STR_CMD_3GAUTH      2
#define STR_CMD_GPSSIGNAL   3
#define STR_CMD_DYNAIP      4
#define STR_CMD_STATICIP    5
#define STR_CMD_GATING      6
#define STR_CMD_ANTENA      7
#define STR_CMD_BEEP        8
#define STR_CMD_ID          9
#define STR_CMD_TIME        10
#define STR_CMD_CHIP        11
#define STR_CMD_LOG         12
#define STR_CMD_CURTIME     13
#define STR_CMD_SETTIME     14
#define STR_CMD_REMOTE      15
#define STR_CMD_PORT        16
#define STR_CMD_REMOTESIP   17
#define STR_CMD_APN         18
#define STR_CMD_GATEWAY     19
#define STR_CMD_DNSSERVER   20
#define STR_CMD_RABBITMAC   21
#define STR_CMD_REGION      22
#define STR_CMD_POWER       23
#define STR_CMD_LOCKOUT     24

static int CMD_VALUE[24] = {CMD_BATTERY, CMD_3GAUTH, CMD_GPSSIGNAL, CMD_DYNAIP, CMD_STATICIP, CMD_GATING, CMD_ANTENA, CMD_BEEP, CMD_ID, CMD_TIME,
                        CMD_CHIP, CMD_LOG, CMD_CURTIME, CMD_SETTIME, CMD_REMOTE, CMD_PORT, CMD_REMOTESIP, CMD_APN, CMD_GATEWAY, CMD_DNSSERVER,
                            CMD_RABBITMAC, CMD_REGION, CMD_POWER, CMD_LOCKOUT};


@interface BLECommand : NSObject
- (void) execCommand:(BLECMD*)cmd;
@end
