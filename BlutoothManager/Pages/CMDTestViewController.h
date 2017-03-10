//
//  CMDTestViewController.h
//  BluetoothManager
//
//  Created by user1 on 11/17/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECommand.h"
#import "WebService.h"
#import "CommonAPI.h"

@class MainViewController;

@interface CMDTestViewController : UIViewController
@property (nonatomic, retain) MainViewController * m_mainview;
@property (weak, nonatomic) IBOutlet UILabel *lbl_deviceName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_deviceUUID;
@property (weak, nonatomic) IBOutlet UIButton *onConnect;
@property (weak, nonatomic) IBOutlet UIButton *onDisConnect;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@property (nonatomic, retain) NSString * m_deviceName;
@property (nonatomic, retain) NSString * m_deviceUDID;
@end
