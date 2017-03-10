//
//  WebService.h
//  BluetoothManager
//
//  Created by user1 on 11/15/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ADDRESS @"http://138.197.18.149/"
#define POST_URL        @"insert_api.php?cmd="
#define GET_URL         @"get_api.php?cmd="

@protocol WebServiceDelegate
- (void)WebServiceDelegate_recieveCMD:(NSDictionary*)data;
- (void)WebServiceDelegate_recieveRSP:(NSDictionary*)data;
@end

@interface WebService : NSObject
@property (nonatomic, retain) id<WebServiceDelegate> delegate;

- (void) sendCMDToDest:(NSDictionary*) data;
- (void) getRespFromDest;

- (void) getCMDFromSrc;
- (void) sendRespToSrc:(NSDictionary*)data;
@end
