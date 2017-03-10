//
//  CommonAPI.h
//  BluetoothConnector
//
//  Created by user1 on 11/15/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>

#define USERKEY_USERNAME  @"user_name"
#define USERKEY_ORGNZIATION      @"org"
#define USERKEY_ADDRESS1  @"address1"
#define USERKEY_ADDRESS2  @"address2"
#define USERKEY_CITY      @"city"
#define USERKEY_ZIPCODE   @"zipcode"
#define USERKEY_EMAIL   @"email"

#define USERKEY_DEVICE_NAME   @"deviceName"
#define USERKEY_DEVICE_UUID   @"deviceUUID"

#define DEVICECONF_SPEED  @"deviceSpeeds"
#define DEVICECONF_STEPS  @"deviceSteps"

@interface CommonAPI : NSObject
+ (NSString*) createJsonFromDictionary:(NSDictionary*)dict;
+ (NSDictionary*) createDictFromJson:(NSString*)json;

+(NSString *) convertSecondToTime:(int)second;


+(void) saveStringToLocal:(NSString*)value keyString:(NSString*)key;
+(NSString *) getLocalValeuForKey:(NSString*) key;


+ (void) setTodayCountATime:(int)count;
+ (void) setTodayTimeACount:(int)count;
+ (void) resetTodayCountATime;

+ (NSData*) convertStringToHexData:(NSString*)str;
+ (NSString*) convertDataToHexString:(NSData*)data;
+ (NSMutableData *) addIntToData:(NSMutableData*)data :(int)value;
+ (NSMutableData *) addStringToData:(NSMutableData*)data :(NSString*)string;

+ (NSString*) getIPStyleStringFromHex:(NSString*)string;
+ (NSString*) getMACStyleStringFromHex:(NSString*)string;

@end
