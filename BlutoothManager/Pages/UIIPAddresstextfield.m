//
//  UIIPAddresstextfield.m
//  RFIDRacing
//
//  Created by user1 on 2/22/17.
//  Copyright © 2017 Malhotra. All rights reserved.
//

#import "UIIPAddresstextfield.h"

@implementation UIIPAddresstextfield

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id) init{
    return [[[NSBundle mainBundle] loadNibNamed:@"UIIPAddresstextfield" owner:self options:nil] objectAtIndex:0];
}
- (void) initializeView
{
    UIToolbar * toolbar1 = [[UIToolbar alloc] init];
    [toolbar1 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar1 sizeToFit];
    
    UIBarButtonItem * flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * done_Button_1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onKeyboardHide1)];
    
    NSArray * items1Array = [NSArray arrayWithObjects:flexButton,done_Button_1, nil];
    [toolbar1 setItems:items1Array];
    [self.edt_1 setInputAccessoryView:toolbar1];
    
    UIToolbar * toolbar2 = [[UIToolbar alloc] init];
    [toolbar2 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar2 sizeToFit];
    
    UIBarButtonItem * done_Button_2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onKeyboardHide2)];
    
    NSArray * items2Array = [NSArray arrayWithObjects:flexButton,done_Button_2, nil];
    [toolbar2 setItems:items2Array];
    [self.edt_2 setInputAccessoryView:toolbar2];
    
    UIToolbar * toolbar3 = [[UIToolbar alloc] init];
    [toolbar3 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar3 sizeToFit];
    
    UIBarButtonItem * done_Button_3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onKeyboardHide3)];
    
    NSArray * items3Array = [NSArray arrayWithObjects:flexButton,done_Button_3, nil];
    [toolbar3 setItems:items3Array];
    [self.edt_3 setInputAccessoryView:toolbar3];
    
    UIToolbar * toolbar4 = [[UIToolbar alloc] init];
    [toolbar4 setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar4 sizeToFit];
    
    UIBarButtonItem * done_Button_4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onKeyboardHide4)];
    
    NSArray * items4Array = [NSArray arrayWithObjects:flexButton,done_Button_4, nil];
    [toolbar4 setItems:items4Array];
    [self.edt_4 setInputAccessoryView:toolbar4];
    
}

- (void)onKeyboardHide1
{
    if(self.edt_1.text.length == 0){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Input value is incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    [self.edt_1 resignFirstResponder];
    [self.edt_2 becomeFirstResponder];
}
- (void)onKeyboardHide2
{
    if(self.edt_2.text.length == 0){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Input value is incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    [self.edt_2 resignFirstResponder];
    [self.edt_3 becomeFirstResponder];
}
- (void)onKeyboardHide3
{
    if(self.edt_3.text.length == 0 || self.edt_3.text.intValue > 255){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Input value is incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    [self.edt_3 resignFirstResponder];
    [self.edt_4 becomeFirstResponder];
}
- (void)onKeyboardHide4
{
    if(self.edt_4.text.length == 0 || self.edt_4.text.intValue > 254){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Input value is incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self.edt_4 resignFirstResponder];
    
    if(self.edt_1.text.length == 0 || self.edt_2.text.length == 0 || self.edt_3.text.length == 0 ){
        [[[UIAlertView alloc] initWithTitle:nil message:@"Input value is incorrect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    if(self.ipDelegate)
        [self.ipDelegate UIIPAddresstextfieldDidFinishEditing:self];
}
- (void) setText:(NSString*)ipString
{
    NSMutableArray * splitArray = [[NSMutableArray alloc] initWithArray:[ipString componentsSeparatedByString:@"."]];
    if([splitArray count] == 4){
        [self.edt_1 setText:[splitArray objectAtIndex:0]];
        [self.edt_2 setText:[splitArray objectAtIndex:1]];
        [self.edt_3 setText:[splitArray objectAtIndex:2]];
        [self.edt_4 setText:[splitArray objectAtIndex:3]];
    }
}
- (NSString*) getText
{
    return [NSString stringWithFormat:@"%@.%@.%@.%@",self.edt_1.text,self.edt_2.text,self.edt_3.text,self.edt_4.text];
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.ipDelegate)
        [self.ipDelegate UIIPAddresstextfieldDidBeginEditing:self];
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.text.length >=3 && range.location == 3)
        return false;
    return true;
}
@end
