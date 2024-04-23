//
//  AppDelegate.h
//  BlutoothManager
//
//  Created by user1 on 11/14/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (atomic) BOOL isConnectedToDevice;

- (void)showLoader;
- (void)hideLoader;

-(void)sharedTxtFile;

@end

