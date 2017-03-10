//
//  CommonAPI.m
//  BluetoothConnector
//
//  Created by user1 on 11/15/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import "CommonAPI.h"
#import <SBJson/SBJson4.h>

@implementation CommonAPI
+ (NSString*) createJsonFromDictionary:(NSDictionary*)dict
{
    SBJson4Writer * writer = [SBJson4Writer new];
    return [writer stringWithObject:dict];
}
+ (NSDictionary*) createDictFromJson:(NSString*)json
{
    NSError * error = nil;
    NSData * data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return dict;
}
+(NSString *) convertSecondToTime:(int)second
{
    int hour = second / 3600;
    int min = (second % 3600) / 60;
    int sec = second % 60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hour, min, sec];
}

+(void) saveStringToLocal:(NSString*)value keyString:(NSString*)key
{
    NSUserDefaults * defaultSaver = [NSUserDefaults standardUserDefaults];
    [defaultSaver setValue:value forKey:key];
    [defaultSaver synchronize];
}

+(NSString *) getLocalValeuForKey:(NSString*) key
{
    NSUserDefaults * defaultSaver = [NSUserDefaults standardUserDefaults];
    return [defaultSaver objectForKey:key];
}

+ (void) setTodayCountATime:(int)count
{
    NSUserDefaults * defaultSaver = [NSUserDefaults standardUserDefaults];
    int count_value = (int)[defaultSaver integerForKey:@"KEY_COUNT"];
    [defaultSaver setInteger:count_value + count  forKey:@"KEY_COUNT"];
    [defaultSaver synchronize];
}
+ (void) setTodayTimeACount:(int)count
{
    NSUserDefaults * defaultSaver = [NSUserDefaults standardUserDefaults];
    int count_value = (int)[defaultSaver integerForKey:@"KEY_TIME"];
    [defaultSaver setInteger:count_value + count  forKey:@"KEY_TIME"];
    [defaultSaver synchronize];
}
+ (void) resetTodayCountATime
{
    NSUserDefaults * defaultSaver = [NSUserDefaults standardUserDefaults];
    [defaultSaver setInteger:0  forKey:@"KEY_COUNT"];
    [defaultSaver setInteger:0  forKey:@"KEY_TIME"];
    [defaultSaver synchronize];
}
+ (NSData*) convertStringToHexData:(NSString*)hex
{
    char buf[3];
    buf[2] = '\0';
    unsigned char * bytes = malloc([hex length] / 2);
    unsigned char * bp = bytes;
    for(CFIndex i=0;i<[hex length];i+=2){
        buf[0] = [hex characterAtIndex:i];
        buf[1] = [hex characterAtIndex:i+1];
        char * b2 = NULL;
        *bp++ = strtol(buf, &b2, 16);
    }
    return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
    
}
+ (NSString*) convertDataToHexString:(NSData*)data
{
    NSMutableData * result = [NSMutableData dataWithLength:2* data.length];
    unsigned const char * src = data.bytes;
    unsigned char * dst = result.mutableBytes;
    unsigned char t0;
    unsigned char t1;
    for(int i=0;i<data.length;i++){
        t0 = src[i] >> 4;
        t1 = src[i] & 0x0F;
        dst[i*2] = 48+t0+(t0/10)*39;
        dst[i*2+1] = 48+t1+(t1/10)*39;
    }
    return [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
}

+ (NSMutableData *) addIntToData:(NSMutableData*)data :(int)value
{
    [data appendData:[NSData dataWithBytes:&value length:sizeof(value)]];
    return data;
}
+ (NSMutableData *) addStringToData:(NSMutableData*)data :(NSString*)string
{
    [data appendData:[string dataUsingEncoding:NSASCIIStringEncoding]];
    return data;
}

+ (NSString*) getIPStyleStringFromHex:(NSString*)string
{
    NSString * ipString = @"";
    for(int i = 0;i<string.length;i+=2){
        NSString * subString = @"";
        if(i+1 < string.length){
            subString = [[string substringFromIndex:i] substringToIndex:2];
        }else
            subString = [string substringFromIndex:i];
        subString = [NSString stringWithFormat:@"0x%@",subString];
        unsigned int outVal;
        NSScanner * scanner = [NSScanner scannerWithString:subString];
        [scanner scanHexInt:&outVal];
        ipString = [ipString stringByAppendingFormat:@"%d.",outVal];
    }
    if(ipString.length > 1){
        ipString = [ipString substringToIndex:ipString.length -1];
    }
    if(string.length == 6){
        NSString * subString1 =  [[string substringFromIndex:4] substringToIndex:1];
        NSString * subString2 =  [[string substringFromIndex:5] substringToIndex:1];
        ipString = [ipString substringToIndex:ipString.length -2];
        unsigned int outVal1;
        NSScanner * scanner1 = [NSScanner scannerWithString:subString1];
        [scanner1 scanHexInt:&outVal1];
        unsigned int outVal2;
        NSScanner * scanner2 = [NSScanner scannerWithString:subString2];
        [scanner2 scanHexInt:&outVal2];
        ipString = [ipString stringByAppendingFormat:@"%d.",outVal1];
        ipString = [ipString stringByAppendingFormat:@"%d",outVal2];
    }
    
    return ipString;
}
+ (NSString*) getMACStyleStringFromHex:(NSString*)string
{
    NSString * ipString = @"";
    for(int i = 0;i<string.length;i+=2){
        NSString * subString = @"";
        if(i+1 < string.length){
            subString = [[string substringFromIndex:i] substringToIndex:2];
        }else
            subString = [string substringFromIndex:i];
        if(subString.length == 2)
            ipString = [ipString stringByAppendingFormat:@"%@:",subString];
        else
            ipString = [ipString stringByAppendingFormat:@"0%@:",subString];
    }
    if(ipString.length > 1){
        ipString = [ipString substringToIndex:ipString.length -1];
    }
    return ipString;
}

@end
