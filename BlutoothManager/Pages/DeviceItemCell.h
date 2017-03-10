//
//  DeviceItemCell.h
//  RFIDRacing
//
//  Created by user1 on 2/10/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_deviceName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_macaddress;
@property (weak, nonatomic) IBOutlet UILabel *lbl_rssi;

@end
