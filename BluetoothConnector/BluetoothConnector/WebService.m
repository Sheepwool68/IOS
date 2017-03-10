//
//  WebService.m
//  BluetoothManager
//
//  Created by user1 on 11/15/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import "WebService.h"
#import "AFNetworking.h"

@implementation WebService
- (NSString *) getJsonString:(NSDictionary*)dict
{
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString * myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return myString;
}
- (void) sendCMDToDest:(NSDictionary*) data
{
    NSString * url = [NSString stringWithFormat:@"%@%@%@",SERVER_ADDRESS,POST_URL,@"cmd"];
    NSDictionary * params = @{@"data":[self getJsonString:data]};
    
#if TESTMODE
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if(responseObject){
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        
    }];
#endif
    
#if REALEASMODE
    NSArray * array = [[NSArray alloc] initWithObjects:[self getJsonString:data], nil];
    [self.delegate WebServiceDelegate_recieveCMD:(id)array];
#endif
    
}
- (void) getRespFromDest
{
    NSString * url = [NSString stringWithFormat:@"%@%@%@",SERVER_ADDRESS,GET_URL,@"rsp"];
#if TESTMODE
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if(responseObject){
            [self.delegate WebServiceDelegate_recieveRSP:responseObject];
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
    }];
#endif
}

- (void) getCMDFromSrc
{
    NSString * url = [NSString stringWithFormat:@"%@%@%@",SERVER_ADDRESS,GET_URL,@"cmd"];
#if TESTMODE
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if(responseObject){
            [self.delegate WebServiceDelegate_recieveCMD:responseObject];
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
    }];
#endif

}
- (void) sendRespToSrc:(NSDictionary*)data
{
    NSString * url = [NSString stringWithFormat:@"%@%@%@",SERVER_ADDRESS,POST_URL,@"rsp"];
    NSDictionary * params = @{@"data":[self getJsonString:data]};
#if TESTMODE
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.validatesDomainName = NO;
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject) {
        if(responseObject){
        }
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
    }];
#endif
#if REALEASMODE
    NSArray * array = [[NSArray alloc] initWithObjects:[self getJsonString:data], nil];
    [self.delegate WebServiceDelegate_recieveRSP:(id)array];
#endif
}
@end
