//
//  BashboardCell.h
//  BluetoothManager
//
//  Created by user1 on 11/18/16.
//  Copyright © 2016 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BashboardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_value;
@property (weak, nonatomic) IBOutlet UIButton *btn_select;
@property (weak, nonatomic) IBOutlet UITextField *edt_steps;

@end
