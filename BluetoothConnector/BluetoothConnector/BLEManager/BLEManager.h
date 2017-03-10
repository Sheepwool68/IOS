//
//  BLEManager.h
//  BluetoothConnector
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLEManagerDelegate
- (void)BLEManagerDelegate_Message:(NSString*)functionName :(int)messageType :(NSString*)message :(BOOL)isComplete;
- (void)BLEManagerDelegate_Dict:(NSString*)functionName :(int)messageType :(NSDictionary*)message :(BOOL)isComplete;
@end

@interface BLEManager : NSObject
@property (nonatomic, retain) id<BLEManagerDelegate> ble_delegate;

- (void) initialBLELib;
- (void) stopScan;
- (void) connectToDevice:(NSString*)uuids name:(NSString*)name;
- (void) disconnectToDevice:(NSString*)uuids name:(NSString*)name;

- (void) readDataFromConnection:(NSString*)uuids name:(NSString*)name;
- (void) writeDataToConnection:(NSData*)str :(NSString*)uuids name:(NSString*)name;
- (void) notifyDataFromConnection:(NSString*)uuids name:(NSString*)name;

+ (id) createInstanceWithReceiver:(id)reciverID;
@end
