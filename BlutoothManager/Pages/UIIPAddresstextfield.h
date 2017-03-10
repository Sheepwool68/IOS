//
//  UIIPAddresstextfield.h
//  RFIDRacing
//
//  Created by user1 on 2/22/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIIPAddresstextfieldDelegate
-(void)UIIPAddresstextfieldDidBeginEditing:(id)sender;
-(void)UIIPAddresstextfieldDidFinishEditing:(id)sender;
@end

@interface UIIPAddresstextfield : UIView <UITextFieldDelegate>
@property (nonatomic, retain) id<UIIPAddresstextfieldDelegate> ipDelegate;
@property (weak, nonatomic) IBOutlet UITextField *edt_1;
@property (weak, nonatomic) IBOutlet UITextField *edt_2;
@property (weak, nonatomic) IBOutlet UITextField *edt_3;
@property (weak, nonatomic) IBOutlet UITextField *edt_4;
- (void) initializeView;
- (void) setText:(NSString*)ipString;
- (NSString*) getText;
@end
